# Create a RDS security group in the VPC which our database will belong to.
# It also wraps a local ansible execution to provision multiple databases in the postgres
# RDS instance, when var.provision_databases = true
module "kms_key_rds" {
  source = "git::https://github.com/cloudposse/terraform-aws-kms-key.git?ref=tags/0.8.0"

  context                 = module.this.context
  description             = "KMS key for rds"
  deletion_window_in_days = 10
  enable_key_rotation     = "true"
  alias                   = "alias/${module.this.id}_kms_key"
}

resource "aws_security_group" "rds" {
  vpc_id = var.vpc_id

  # Keep the instance private by only allowing traffic from the web server.
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = module.this.tags
}

module "db" {
  source                  = "terraform-aws-modules/rds/aws"
  version                 = "~> v2.20.0"
  identifier              = module.this.id
  engine                  = "postgres"
  family                  = var.family
  engine_version          = var.engine_version
  major_engine_version    = var.major_engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  storage_encrypted       = true
  kms_key_id              = module.kms_key_rds.key_arn
  name                    = var.database_name
  username                = var.database_username
  password                = var.database_password
  port                    = "5432"
  subnet_ids              = var.subnet_ids
  vpc_security_group_ids  = [aws_security_group.rds.id]
  multi_az                = false
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = var.backup_retention_period
  create_db_option_group  = false

  create_monitoring_role = true
  monitoring_interval    = "60"
  monitoring_role_name   = "AllowRDSMonitoringFor-${module.this.id}"

  # Snapshot name upon DB deletion
  final_snapshot_identifier   = "${module.this.id}-final-snapshot"
  deletion_protection         = var.deletion_protection_enabled
  skip_final_snapshot         = var.skip_final_snapshot
  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.apply_immediately
  tags                        = module.this.tags
}


data "aws_region" "current" {}

data "aws_ami" "base" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "tag:Application"
    values = [var.provisioner_ami_application_tag]
  }
  #filter {
  #  name   = "tag:Namespace"
  #  values = [module.this.namespace]
  #}
  #filter {
  #  name   = "tag:Environment"
  #  values = [module.this.environment]
  #}
}


locals {
  application       = "provisioner-rds"
  application_snake = "provisioner_rds"
  ami_provisioner   = data.aws_ami.base.id
  rds_vars = yamlencode({
    "aws_profile" : var.aws_profile,
    "region" : data.aws_region.current.name,
    "environment" : module.this.environment,
    "application" : local.application,
    "application_snake" : local.application_snake,
    "image_id" : local.ami_provisioner,
    "instance_name" : module.label_provisioner.id,
    "security_group" : aws_security_group.provisioner.id,
    "iam_instance_profile" : aws_iam_instance_profile.provisioner_profile.id
    "vpc_subnet_id" : var.provisioner_subnet_id,
    "tags" : module.label_provisioner.tags,
    "ansible_python_interpreter" : "/usr/bin/python3",
    "keypair_path" : "./ssh_key",
    "keypair_name" : module.label_provisioner.id,
    "sops_rds_secrets_path" : var.sops_rds_secrets_path
  })
  ansible_inventory = templatefile("${path.module}/aws_ec2.yml.tpl", {
    "region" : data.aws_region.current.name,
    "namespace" : module.this.namespace,
    "environment" : module.this.environment,
    "application" : local.application,
    "application_snake" : local.application_snake
  })
  ansible_playbook_instance = templatefile("${path.module}/instance.yml.tpl", {
    "aws_profile" : var.aws_profile,
    "region" : data.aws_region.current.name,
    "namespace" : module.this.namespace,
    "environment" : module.this.environment,
    "application" : local.application,
    "application_snake" : local.application_snake
  })
  ansible_playbook_db = templatefile("${path.module}/create-db.yml.tpl", {
    "aws_profile" : var.aws_profile,
    "region" : data.aws_region.current.name,
    "namespace" : module.this.namespace,
    "environment" : module.this.environment,
    "application" : local.application,
    "application_snake" : local.application_snake,
    "rds_host" : module.db.this_db_instance_address,
    "rds_port" : module.db.this_db_instance_port,
    "rds_admin_user" : module.db.this_db_instance_username
  })
  ansible_cfg      = templatefile("${path.module}/ansible.cfg", {})
  ansible_reqs     = templatefile("${path.module}/requirements.yml", {})
  ansible_makefile = templatefile("${path.module}/Makefile.tpl", {})
}

resource "local_file" "ansible_makefile" {
  count                = var.provision_databases ? 1 : 0
  filename             = "ansible/Makefile"
  content              = local.ansible_makefile
  file_permission      = "0600"
  directory_permission = "0700"
}
resource "local_file" "ansible_cfg" {
  count                = var.provision_databases ? 1 : 0
  filename             = "ansible/ansible.cfg"
  content              = local.ansible_cfg
  file_permission      = "0600"
  directory_permission = "0700"
}
resource "local_file" "ansible_reqs" {
  count                = var.provision_databases ? 1 : 0
  filename             = "ansible/requirements.yml"
  content              = local.ansible_reqs
  file_permission      = "0600"
  directory_permission = "0700"
}
resource "local_file" "ansible_vars" {
  count                = var.provision_databases ? 1 : 0
  filename             = "ansible/ansible-vars-rds.yml"
  content              = local.rds_vars
  file_permission      = "0600"
  directory_permission = "0700"
}

resource "local_file" "ansible_inventory" {
  count                = var.provision_databases ? 1 : 0
  filename             = "ansible/aws_ec2.yml"
  content              = local.ansible_inventory
  file_permission      = "0600"
  directory_permission = "0700"
}

resource "local_file" "ansible_playbook_instance" {
  count                = var.provision_databases ? 1 : 0
  filename             = "ansible/instance.yml"
  content              = local.ansible_playbook_instance
  file_permission      = "0600"
  directory_permission = "0700"
}
resource "local_file" "ansible_playbook_db" {
  count                = var.provision_databases ? 1 : 0
  filename             = "ansible/create-db.yml"
  content              = local.ansible_playbook_db
  file_permission      = "0600"
  directory_permission = "0700"
}

module "label_provisioner" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.19.2"

  context    = module.this.context
  attributes = concat(["provisioner"], var.attributes)
  tags       = merge({ "Application" : local.application }, var.tags)
}

module "provisioner_session_manager" {
  source = "git::https://gitlab.com/guardianproject-ops/terraform-aws-session-manager-instance-policy?ref=tags/0.3.3"

  name           = module.this.name
  namespace      = module.this.namespace
  environment    = module.this.environment
  attributes     = ["provisioner"]
  s3_bucket_name = var.session_manager_bucket
  s3_key_prefix  = module.label_provisioner.id
}

module "provisioner_instance_role_attachment" {
  source = "git::https://gitlab.com/guardianproject-ops/terraform-aws-iam-instance-role-policy-attachment?ref=tags/2.1.0"

  name        = module.this.name
  namespace   = module.this.namespace
  environment = module.this.environment
  attributes  = ["provisioner"]

  iam_policy_arns = [
    module.provisioner_session_manager.ec2_session_manager_policy_arn,
  ]
}

resource "aws_iam_instance_profile" "provisioner_profile" {
  name = module.label_provisioner.id
  role = module.provisioner_instance_role_attachment.instance_role_id
}

resource "aws_security_group" "provisioner" {
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = module.label_provisioner.tags
}

resource "null_resource" "provisioner_exec" {
  count = var.provision_databases ? 1 : 0
  triggers = {
    vpc_id                    = var.vpc_id
    database_name             = var.database_name
    database_username         = var.database_username
    database_password         = var.database_password
    subnet_ids                = jsonencode(var.subnet_ids)
    db_arn                    = module.db.this_db_instance_arn
    provisioner_subnet_id     = var.provisioner_subnet_id
    ami_provisioner           = local.ami_provisioner
    session_manager_bucket    = var.session_manager_bucket
    profile                   = aws_iam_instance_profile.provisioner_profile.id
    sg                        = aws_security_group.provisioner.id,
    sops_rds_secrets_path     = var.sops_rds_secrets_path
    ansible_inv               = local_file.ansible_inventory[0].content
    ansible_vars              = local_file.ansible_vars[0].content
    ansible_reqs              = local_file.ansible_reqs[0].content
    ansible_cfg               = local_file.ansible_cfg[0].content
    ansible_makefile          = local_file.ansible_makefile[0].content
    ansible_playbook_instance = local_file.ansible_playbook_instance[0].content
    ansible_vars              = local_file.ansible_vars[0].content
    databases                 = jsonencode(var.databases)
    database_users            = jsonencode(var.database_users)
    force_provision           = var.force_provision

  }
  provisioner "local-exec" {
    command = "pwd && cd ./ansible && make provision && cd .. && rm -rf ./ansible"
  }
}
