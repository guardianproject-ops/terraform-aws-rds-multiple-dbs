variable "vpc_cidr_block" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "database_name" {
  type = string
}

variable "database_username" {
  type = string
}

variable "database_password" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "allocated_storage" {
  type = number
}

variable "family" {
  type = string
}

variable "major_engine_version" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "deletion_protection_enabled" {
  type = bool
}

variable "skip_final_snapshot" {
  type = bool
}

variable "allow_major_version_upgrade" {
  type = bool
}

variable "apply_immediately" {
  type = bool
}

variable "backup_retention_period" {
  type = number
}

variable "provisioner_subnet_id" {
  description = "the subnet id to be used for the provisioner instance"
  type        = string
}

variable "session_manager_bucket" {
  type        = string
  description = "S3 bucket name of the bucket where SSM Session Manager logs are stored"
}
variable "playbooks_bucket" {
  type        = string
  description = "bucket used to transfer files for ansible aws_ssm"
}

variable "provision_databases" {
  type        = bool
  description = "Set to true to enable createion of databases in the rds instance"
  default     = false
}
variable "sops_rds_secrets_path" {
  type        = string
  description = "path to the sops encrypted yaml file containing the rds passwords"
}

variable "databases" {
  type = list(object({
    name = string
  }))
}

variable "database_users" {
  type = list(object({
    db       = string,
    username = string,
    password = string
  }))
}

variable "force_provision" {
  type        = string
  default     = ""
  description = "change this variable to force the db provisioner to run"
}
variable "provisioner_ami_application_tag" {
  type    = string
  default = "debian-base"
}
variable "aws_profile" {
  type = string
}
