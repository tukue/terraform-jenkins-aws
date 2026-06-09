locals {
  name_prefix = lower("${var.cluster_name}-${var.environment}")
  full_name   = "${local.name_prefix}-eks"

  resolved_vpc_id     = var.vpc_id != "" ? var.vpc_id : data.aws_ssm_parameter.vpc_id[0].value
  resolved_subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : split(",", data.aws_ssm_parameter.private_subnet_ids[0].value)

  common_tags = merge(
    var.tags,
    {
      Cluster        = local.full_name
      Environment    = var.environment
      AWSRegion      = var.aws_region
      AWSAccount     = var.aws_account_id
      NetworkProfile = var.network_profile
      ManagedBy      = "terraform"
      Platform       = "eks-cluster"
    }
  )

  addon_defaults = {
    vpc-cni = {
      addon_version = var.kubernetes_version >= "1.32" ? "v1.19.6eksbuild.1" : var.kubernetes_version >= "1.31" ? "v1.19.3eksbuild.1" : "v1.18.3eksbuild.2"
    }
    coredns = {
      addon_version = var.kubernetes_version >= "1.32" ? "v1.11.4eksbuild.2" : var.kubernetes_version >= "1.31" ? "v1.11.4eksbuild.1" : "v1.11.3eksbuild.1"
    }
    kube-proxy = {
      addon_version = var.kubernetes_version >= "1.32" ? "v1.32.1eksbuild.1" : var.kubernetes_version >= "1.31" ? "v1.31.2eksbuild.1" : "v1.30.6eksbuild.1"
    }
    pod-identity-agent = {
      addon_version = ""
    }
  }
}

data "aws_ssm_parameter" "vpc_id" {
  count = var.vpc_id == "" ? 1 : 0
  name  = "/platform/${var.aws_region}/${var.network_profile}/vpc-id"
}

data "aws_ssm_parameter" "private_subnet_ids" {
  count = length(var.subnet_ids) == 0 ? 1 : 0
  name  = "/platform/${var.aws_region}/${var.network_profile}/private-subnet-ids"
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "tls_certificate" "this" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_cloudwatch_log_group" "eks" {
  count = var.enable_cluster_logging ? 1 : 0

  name              = "/aws/eks/${local.full_name}/cluster"
  retention_in_days = var.environment == "prod" ? 365 : 90
  kms_key_id        = var.kms_key_arn
  tags              = local.common_tags
}

resource "aws_iam_role" "cluster" {
  name = "${local.name_prefix}-eks-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, { Role = "EKSCluster" })
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "cluster_vpc_resource" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_eks_cluster" "this" {
  name     = local.full_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version
  tags     = local.common_tags

  vpc_config {
    subnet_ids              = local.resolved_subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.endpoint_public_access_cidrs
    security_group_ids      = [aws_security_group.cluster.id]
  }

  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions
  }

  dynamic "upgrade_policy" {
    for_each = var.upgrade_support_type != null ? [1] : []
    content {
      support_type = var.upgrade_support_type
    }
  }

  dynamic "encryption_config" {
    for_each = var.cluster_encryption_config.enabled ? [1] : []
    content {
      provider {
        key_arn = var.cluster_encryption_config.kms_key_arn != "" ? var.cluster_encryption_config.kms_key_arn : aws_kms_key.eks[0].arn
      }
      resources = var.cluster_encryption_config.resources
    }
  }

  enabled_cluster_log_types = var.enable_cluster_logging ? var.cluster_log_types : []

  timeouts {
    create = var.cluster_timeout_create
    update = var.cluster_timeout_update
    delete = var.cluster_timeout_delete
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_iam_role_policy_attachment.cluster_vpc_resource,
    aws_cloudwatch_log_group.eks
  ]

  lifecycle {
    precondition {
      condition     = var.aws_region != ""
      error_message = "aws_region must be set to a valid AWS region."
    }

    precondition {
      condition     = var.aws_account_id == "" || data.aws_caller_identity.current.account_id == var.aws_account_id
      error_message = "The active AWS credentials do not match aws_account_id. Use credentials for the intended account before applying."
    }

    precondition {
      condition     = length(local.resolved_subnet_ids) >= 2
      error_message = "At least 2 subnets must be provided for the EKS cluster (multi-AZ requirement)."
    }
  }
}

resource "aws_kms_key" "eks" {
  count = var.cluster_encryption_config.enabled && var.cluster_encryption_config.kms_key_arn == "" ? 1 : 0

  description             = "EKS cluster encryption key for ${local.full_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = merge(local.common_tags, { Purpose = "EKSEncryption" })
}

resource "aws_kms_alias" "eks" {
  count = var.cluster_encryption_config.enabled && var.cluster_encryption_config.kms_key_arn == "" ? 1 : 0

  name          = "alias/${local.full_name}-encryption"
  target_key_id = aws_kms_key.eks[0].key_id
}

resource "aws_security_group" "cluster" {
  name        = "${local.name_prefix}-eks-cluster"
  description = "Security group for EKS cluster ${local.full_name}"
  vpc_id      = local.resolved_vpc_id

  egress {
    description = "EKS cluster outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Role = "EKSClusterSG" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "cluster_ingress_node" {
  security_group_id = aws_security_group.cluster.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  self              = true
  description       = "Allow nodes to communicate with cluster API"
}

resource "aws_security_group_rule" "cluster_ingress_https" {
  count = var.endpoint_public_access ? 1 : 0

  security_group_id = aws_security_group.cluster.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.endpoint_public_access_cidrs
  description       = "Allow public HTTPS access to the API server"
}

resource "aws_security_group_rule" "cluster_ingress_ext_cluster" {
  count = length(var.cluster_additional_security_group_ids) > 0 ? 1 : 0

  security_group_id        = aws_security_group.cluster.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = var.cluster_additional_security_group_ids[0]
  description              = "Allow additional security group to access API"
}

resource "aws_eks_access_entry" "this" {
  for_each = var.access_entries

  cluster_name      = aws_eks_cluster.this.name
  principal_arn     = each.value.principal_arn
  kubernetes_groups = each.value.kubernetes_groups
  type              = each.value.type
  user_name         = each.value.user_name

  tags = local.common_tags
}

resource "aws_eks_access_policy_association" "this" {
  for_each = var.access_policy_associations

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value.principal_arn
  policy_arn    = each.value.policy_arn
  access_scope {
    type       = each.value.access_scope_type
    namespaces = each.value.access_scope_type == "namespace" ? each.value.namespaces : null
  }
}

resource "aws_iam_role" "node" {
  name = "${local.name_prefix}-eks-node"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, { Role = "EKSNode" })
}

resource "aws_iam_role_policy_attachment" "node_worker" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_registry" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_ssm" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${local.name_prefix}-${each.key}"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = local.resolved_subnet_ids
  version         = var.kubernetes_version

  instance_types = each.value.instance_types
  disk_size      = each.value.disk_size
  capacity_type  = each.value.capacity_type
  ami_type       = each.value.ami_type

  dynamic "taint" {
    for_each = each.value.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  dynamic "launch_template" {
    for_each = each.value.launch_template_name != null ? [1] : []
    content {
      name    = each.value.launch_template_name
      version = each.value.launch_template_version
    }
  }

  labels = merge(
    each.value.labels,
    {
      "nodegroup"   = each.key
      "environment" = var.environment
    }
  )

  scaling_config {
    min_size     = each.value.min_size
    max_size     = each.value.max_size
    desired_size = each.value.desired_size
  }

  update_config {
    max_unavailable = each.value.max_unavailable
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, { NodeGroup = each.key })
}

resource "aws_iam_openid_connect_provider" "this" {
  count = var.create_oidc_provider ? 1 : 0

  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this.certificates[0].sha1_fingerprint]

  tags = merge(local.common_tags, { Role = "EKS-OIDC" })
}

resource "aws_eks_addon" "this" {
  for_each = var.cluster_addons

  cluster_name = aws_eks_cluster.this.name
  addon_name   = each.key

  addon_version = each.value.addon_version != "" ? each.value.addon_version : try(local.addon_defaults[each.key].addon_version, "")

  resolve_conflicts_on_create = each.value.resolve_conflicts
  resolve_conflicts_on_update = each.value.resolve_conflicts

  service_account_role_arn = each.value.service_account_role_arn != "" ? each.value.service_account_role_arn : null

  dynamic "pod_identity_association" {
    for_each = each.value.pod_identity_role_arn != "" ? [1] : []
    content {
      role_arn = each.value.pod_identity_role_arn
    }
  }

  depends_on = [aws_eks_cluster.this]

  tags = local.common_tags
}

resource "aws_iam_role" "irsa" {
  for_each = var.irsa_roles

  name = "${local.name_prefix}-irsa-${each.key}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.create_oidc_provider ? aws_iam_openid_connect_provider.this[0].arn : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:${each.value.namespace}:${each.value.service_account}"
          }
        }
      }
    ]
  })

  tags = merge(local.common_tags, { IRSA = each.key })
}

resource "aws_iam_role_policy_attachment" "irsa" {
  for_each = {
    for pair in flatten([
      for k, v in var.irsa_roles : [
        for i, policy in v.policy_arns : {
          id     = "${k}-${i}"
          key    = k
          policy = policy
        }
      ]
    ]) : pair.id => pair
  }

  role       = aws_iam_role.irsa[each.value.key].name
  policy_arn = each.value.policy
}

resource "aws_iam_role_policy" "irsa_inline" {
  for_each = {
    for k, v in var.irsa_roles : k => v if v.policy_document != ""
  }

  name   = "${local.name_prefix}-irsa-${each.key}-inline"
  role   = aws_iam_role.irsa[each.key].name
  policy = each.value.policy_document
}

data "aws_iam_policy_document" "lb_controller" {
  count = var.enable_lb_controller && var.lb_controller_policy_arn == "" ? 1 : 0

  statement {
    actions = [
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeInstances",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeAddresses",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeTags",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAvailabilityZones",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteSecurityGroup",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:DeleteTags",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeListenerAttributes",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags",
      "iam:CreateServiceLinkedRole",
      "cognito-idp:DescribeUserPoolClient",
      "waf-regional:GetWebACLForResource",
      "waf-regional:GetWebACL",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "tag:GetResources",
      "waf:GetWebACL"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lb_controller" {
  count = var.enable_lb_controller && var.lb_controller_policy_arn == "" ? 1 : 0

  name   = "${local.name_prefix}-aws-lb-controller"
  policy = data.aws_iam_policy_document.lb_controller[0].json

  tags = merge(local.common_tags, { Role = "AWSLBController" })
}

resource "aws_iam_role" "lb_controller" {
  count = var.enable_lb_controller ? 1 : 0

  name = "${local.name_prefix}-irsa-aws-lb-controller"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.create_oidc_provider ? aws_iam_openid_connect_provider.this[0].arn : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  tags = merge(local.common_tags, { IRSA = "aws-lb-controller" })
}

resource "aws_iam_role_policy_attachment" "lb_controller" {
  count = var.enable_lb_controller ? 1 : 0

  role       = aws_iam_role.lb_controller[0].name
  policy_arn = var.lb_controller_policy_arn != "" ? var.lb_controller_policy_arn : aws_iam_policy.lb_controller[0].arn
}
