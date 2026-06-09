variable "cluster_name" {
  type        = string
  description = "Name prefix for the EKS cluster"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,48}$", var.cluster_name))
    error_message = "cluster_name must be 3-48 characters and use lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  type        = string
  description = "Environment name (dev, qa, prod)"

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "Environment must be dev, qa, or prod."
  }
}

variable "aws_region" {
  type        = string
  default     = "eu-north-1"
  description = "AWS region for the EKS cluster"
}

variable "aws_account_id" {
  type        = string
  default     = ""
  description = "AWS account ID where the EKS cluster is provisioned"
}

variable "network_profile" {
  type        = string
  default     = "standard"
  description = "Regional landing zone profile used to resolve network defaults from SSM"
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID for the EKS cluster. Leave empty to resolve from SSM using network_profile."
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "Subnet IDs for the EKS cluster. Leave empty to resolve from SSM using network_profile."
}

variable "kubernetes_version" {
  type        = string
  default     = "1.31"
  description = "Kubernetes version for the EKS cluster"

  validation {
    condition     = can(regex("^1\\.(3[0-1]|[2-2][0-9])$", var.kubernetes_version))
    error_message = "kubernetes_version must be a supported EKS version (e.g., 1.29, 1.30, 1.31)."
  }
}

variable "endpoint_private_access" {
  type        = bool
  default     = true
  description = "Enable private API server endpoint access"
}

variable "endpoint_public_access" {
  type        = bool
  default     = true
  description = "Enable public API server endpoint access"
}

variable "endpoint_public_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR blocks allowed to access the public API server endpoint"
}

variable "enable_cluster_logging" {
  type        = bool
  default     = true
  description = "Enable EKS control plane logging"
}

variable "cluster_log_types" {
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "EKS control plane log types to enable"

  validation {
    condition = alltrue([
      for t in var.cluster_log_types : contains(["api", "audit", "authenticator", "controllerManager", "scheduler"], t)
    ])
    error_message = "cluster_log_types must be a subset of [api, audit, authenticator, controllerManager, scheduler]."
  }
}

variable "cluster_encryption_config" {
  type = object({
    enabled     = bool
    kms_key_arn = optional(string, "")
    resources   = optional(list(string), ["secrets"])
  })
  default = {
    enabled   = true
    resources = ["secrets"]
  }
  description = "EKS cluster encryption configuration for Kubernetes secrets"
}

variable "node_groups" {
  type = map(object({
    instance_types  = optional(list(string), ["t3.medium"])
    min_size        = optional(number, 1)
    max_size        = optional(number, 3)
    desired_size    = optional(number, 1)
    disk_size       = optional(number, 20)
    ami_type        = optional(string, "AL2_x86_64")
    capacity_type   = optional(string, "ON_DEMAND")
    labels          = optional(map(string), {})
    taints          = optional(list(object({ key = string, value = string, effect = string })), [])
    k8s_labels      = optional(map(string), {})
    max_unavailable = optional(number, 1)
    update_type     = optional(string, "ROLLING_UPDATE")
  }))
  default = {
    general = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 3
      desired_size   = 1
      disk_size      = 20
      ami_type       = "AL2_x86_64"
      capacity_type  = "ON_DEMAND"
    }
  }
  description = "Managed node group configurations for the EKS cluster"

  validation {
    condition = alltrue([
      for name, ng in var.node_groups : ng.min_size >= 1 &&
      ng.max_size >= ng.min_size &&
      ng.desired_size >= ng.min_size &&
      ng.desired_size <= ng.max_size
    ])
    error_message = "For each node group: min_size >= 1, max_size >= min_size, and desired_size must be between min and max."
  }
}

variable "cluster_addons" {
  type = map(object({
    addon_version            = optional(string, "")
    resolve_conflicts        = optional(string, "OVERWRITE")
    service_account_role_arn = optional(string, "")
  }))
  default = {
    vpc-cni    = {}
    coredns    = {}
    kube-proxy = {}
  }
  description = "EKS cluster add-ons to install"

  validation {
    condition = alltrue([
      for name, config in var.cluster_addons :
      contains(["OVERWRITE", "NONE", "PRESERVE"], config.resolve_conflicts)
    ])
    error_message = "resolve_conflicts for each add-on must be OVERWRITE, NONE, or PRESERVE."
  }
}

variable "create_oidc_provider" {
  type        = bool
  default     = true
  description = "Create the IAM OIDC identity provider for the EKS cluster"
}

variable "irsa_roles" {
  type = map(object({
    namespace       = string
    service_account = string
    policy_arns     = list(string)
    policy_document = optional(string, "")
  }))
  default     = {}
  description = "IRSA roles to create for service accounts"
}

variable "enable_lb_controller" {
  type        = bool
  default     = false
  description = "Create IAM role for AWS Load Balancer Controller IRSA"
}

variable "lb_controller_policy_arn" {
  type        = string
  default     = ""
  description = "Optional custom IAM policy ARN for AWS Load Balancer Controller. If empty and enable_lb_controller is true, a default policy is created."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional resource tags"
}
