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

locals {
  effective_ec2_ami_id = trimspace(var.ec2_ami_id) != "" ? var.ec2_ami_id : data.aws_ami.latest_ubuntu.id
}

module "networking" {
  source               = "./networking"
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  cidr_public_subnet   = var.cidr_public_subnet
  eu_availability_zone = var.eu_availability_zone
  cidr_private_subnet  = var.cidr_private_subnet
  environment          = var.environment
  enable_nat_gateway   = var.enable_nat_gateway
}

module "security_group" {
  source              = "./security-groups"
  ec2_sg_name         = "SG for EC2 to enable SSH(22), HTTPS(443) and HTTP(80)"
  vpc_id              = module.networking.dev_proj_1_vpc_id
  ec2_jenkins_sg_name = "Allow port 8080 for jenkins"
  alb_sg_name         = "Allow HTTP and HTTPS for Jenkins ALB"
  environment         = var.environment
}

module "jenkins" {
  source                    = "./jenkins"
  ami_id                    = local.effective_ec2_ami_id
  instance_type             = var.instance_type
  tag_name                  = "Jenkins:Ubuntu Linux EC2"
  public_key                = var.public_key
  subnet_id                 = tolist(module.networking.dev_proj_1_private_subnets)[0]
  sg_for_jenkins            = [module.security_group.sg_ec2_jenkins_port_8080]
  enable_public_ip_address  = false
  user_data_install_jenkins = templatefile("./jenkins-runner-script/jenkins-installer.sh", {})
  environment               = var.environment
  run_ansible               = var.run_ansible
}

module "jenkins_alb_waf" {
  source = "./modules/jenkins-alb-waf"

  name_prefix           = "${var.environment}-jenkins"
  vpc_id                = module.networking.dev_proj_1_vpc_id
  public_subnet_ids     = tolist(module.networking.dev_proj_1_public_subnets)
  alb_security_group_id = module.security_group.sg_alb_http_https_id
  jenkins_instance_id   = module.jenkins.jenkins_ec2_instance_ip
  jenkins_port          = var.jenkins_port
  certificate_arn       = var.alb_certificate_arn
  enable_waf            = var.enable_waf
  waf_rate_limit        = var.waf_rate_limit
  tags                  = local.common_tags
}

module "prometheus" {
  count = var.enable_observability ? 1 : 0

  source = "./prometheus"

  environment            = var.environment
  workspace_alias        = var.observability_workspace_alias
  jenkins_static_targets = var.observability_jenkins_targets
  tags                   = var.tags
}

module "cloudwatch_observability" {
  count = var.enable_observability ? 1 : 0

  source = "./cloudwatch-observability"

  environment        = var.environment
  instance_id        = module.jenkins.jenkins_ec2_instance_ip
  instance_name      = "Jenkins"
  instance_public_ip = module.jenkins.dev_proj_1_ec2_instance_public_ip
  tags               = var.tags
}

module "grafana" {
  count = var.enable_grafana_service ? 1 : 0

  source = "./grafana"

  environment    = var.environment
  ami_id         = local.effective_ec2_ami_id
  instance_type  = var.grafana_instance_type
  subnet_id      = tolist(module.networking.dev_proj_1_public_subnets)[0]
  vpc_id         = module.networking.dev_proj_1_vpc_id
  allowed_cidrs  = var.grafana_allowed_cidrs
  prometheus_url = var.grafana_prometheus_url
  admin_user     = var.grafana_admin_user
  admin_password = var.grafana_admin_password
  tags           = var.tags
}

/*
module "alb" {
  source                    = "./load-balancer"
  lb_name                   = "dev-proj-1-alb"
  is_external               = false
  lb_type                   = "application"
  sg_enable_ssh_https       = module.security_group.sg_ec2_sg_ssh_http_id
  subnet_ids                = tolist(module.networking.dev_proj_1_public_subnets)
  tag_name                  = "dev-proj-1-alb"
  lb_target_group_arn       = module.lb_target_group.dev_proj_1_lb_target_group_arn
  ec2_instance_id           = module.jenkins.jenkins_ec2_instance_ip
  lb_listner_port           = 80
  lb_listner_protocol       = "HTTP"
  lb_listner_default_action = "forward"
  lb_https_listner_port     = 443
  lb_https_listner_protocol = "HTTPS"
  dev_proj_1_acm_arn        = module.aws_ceritification_manager.dev_proj_1_acm_arn
  lb_target_group_attachment_port = 8080
  environment               = var.environment
} 

module "hosted_zone" {
  source          = "./hosted-zone"
  domain_name     = ""
  aws_lb_dns_name = module.alb.aws_lb_dns_name
  aws_lb_zone_id  = module.alb.aws_lb_zone_id
  environment     = var.environment
}

module "aws_ceritification_manager" {
  source         = "./certificate-manager"
  domain_name    = ""
  hosted_zone_id = module.hosted_zone.hosted_zone_id
  environment    = var.environment
}  */
