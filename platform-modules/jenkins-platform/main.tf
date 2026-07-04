data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "networking" {
  source               = "../network"
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  cidr_public_subnet   = var.cidr_public_subnet
  eu_availability_zone = var.eu_availability_zone
  cidr_private_subnet  = var.cidr_private_subnet
  environment          = var.environment
  enable_nat_gateway   = var.enable_nat_gateway
}

module "security_group" {
  source                             = "../security"
  ec2_sg_name                        = "${var.environment}-jenkins-ec2"
  vpc_id                             = module.networking.vpc_id
  vpc_cidr                           = var.vpc_cidr
  ec2_jenkins_sg_name                = "${var.environment}-jenkins-service"
  alb_sg_name                        = "${var.environment}-jenkins-alb"
  allowed_alb_cidr_blocks            = var.allowed_alb_cidr_blocks
  allowed_jenkins_egress_cidr_blocks = length(var.allowed_jenkins_egress_cidr_blocks) > 0 ? var.allowed_jenkins_egress_cidr_blocks : [var.vpc_cidr]
  environment                        = var.environment
}

module "jenkins" {
  source                    = "../compute"
  ami_id                    = local.effective_ec2_ami_id
  instance_type             = var.instance_type
  tag_name                  = "${var.environment}-jenkins"
  public_key                = var.public_key
  subnet_id                 = tolist(module.networking.private_subnet_ids)[0]
  sg_for_jenkins            = [module.security_group.sg_ec2_jenkins_port_8080]
  enable_public_ip_address  = false
  user_data_install_jenkins = templatefile("${path.root}/../../jenkins-runner-script/jenkins-installer.sh", {})
  environment               = var.environment
  run_ansible               = var.run_ansible
}

module "jenkins_alb_waf" {
  source = "../edge"

  name_prefix           = "${var.environment}-jenkins"
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = tolist(module.networking.public_subnet_ids)
  alb_security_group_id = module.security_group.sg_alb_http_https_id
  jenkins_instance_id   = module.jenkins.jenkins_instance_id
  jenkins_port          = var.jenkins_port
  certificate_arn       = var.alb_certificate_arn
  enable_waf            = var.enable_waf
  waf_rate_limit        = var.waf_rate_limit
  tags                  = local.common_tags
}

module "prometheus" {
  count = var.enable_observability ? 1 : 0

  source = "../../prometheus"

  environment            = var.environment
  workspace_alias        = var.observability_workspace_alias
  jenkins_static_targets = var.observability_jenkins_targets
  tags                   = var.tags
}

module "cloudwatch_observability" {
  count = var.enable_observability ? 1 : 0

  source = "../../cloudwatch-observability"

  environment        = var.environment
  instance_id        = module.jenkins.jenkins_instance_id
  instance_name      = "Jenkins"
  instance_public_ip = module.jenkins.dev_proj_1_ec2_instance_public_ip
  tags               = var.tags
}

module "grafana" {
  count = var.enable_grafana_service ? 1 : 0

  source = "../../grafana"

  environment    = var.environment
  ami_id         = local.effective_ec2_ami_id
  instance_type  = var.grafana_instance_type
  subnet_id      = tolist(module.networking.public_subnet_ids)[0]
  vpc_id         = module.networking.vpc_id
  allowed_cidrs  = var.grafana_allowed_cidrs
  prometheus_url = var.grafana_prometheus_url
  admin_user     = var.grafana_admin_user
  admin_password = var.grafana_admin_password
  tags           = var.tags
}
