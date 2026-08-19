resource "aws_iam_role" "eks_cluster" {
  name = "${var.environment}-platform-eks-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_nodes" {
  name = "${var.environment}-platform-eks-nodes"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_nodes" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ])

  role       = aws_iam_role.eks_nodes.name
  policy_arn = each.value
}

resource "aws_eks_cluster" "platform" {
  name     = "${var.environment}-platform"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(module.networking.dev_proj_1_public_subnets, module.networking.dev_proj_1_private_subnets)
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.eks_public_access_cidrs
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster]
}

resource "aws_eks_node_group" "platform" {
  cluster_name    = aws_eks_cluster.platform.name
  node_group_name = "${var.environment}-platform"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = module.networking.dev_proj_1_private_subnets

  scaling_config {
    desired_size = var.eks_node_desired_size
    max_size     = var.eks_node_max_size
    min_size     = var.eks_node_min_size
  }

  instance_types = var.eks_node_instance_types
  capacity_type  = "ON_DEMAND"

  update_config {
    max_unavailable = 1
  }

  depends_on = [aws_iam_role_policy_attachment.eks_nodes]
}

resource "aws_eks_access_entry" "cicd" {
  count = var.cicd_principal_arn == null ? 0 : 1

  cluster_name  = aws_eks_cluster.platform.name
  principal_arn = var.cicd_principal_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "cicd" {
  count = var.cicd_principal_arn == null ? 0 : 1

  cluster_name  = aws_eks_cluster.platform.name
  principal_arn = aws_eks_access_entry.cicd[0].principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_ecr_repository" "applications" {
  name                 = "${var.environment}-platform-applications"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "applications" {
  repository = aws_ecr_repository.applications.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep the most recent application images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 20
      }
      action = { type = "expire" }
    }]
  })
}
