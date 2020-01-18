/*
* main.tf
*/
provider "aws" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.22.0"
  # Assign IPv6 address on database subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch
  database_subnet_assign_ipv6_address_on_creation = false
  # Assign IPv6 address on redshift subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch
  redshift_subnet_assign_ipv6_address_on_creation = false
  # Assign IPv6 address on elasticache subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch
  elasticache_subnet_assign_ipv6_address_on_creation = false
  # Should be true to enable ClassicLink for the VPC. Only valid in regions and accounts that support EC2 Classic.
  enable_classiclink = false
  # Assign IPv6 address on public subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch
  public_subnet_assign_ipv6_address_on_creation = false
  # Assign IPv6 address on intra subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch
  intra_subnet_assign_ipv6_address_on_creation = false
  # Assign IPv6 address on private subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch
  private_subnet_assign_ipv6_address_on_creation = false
  # Should be true to enable ClassicLink DNS Support for the VPC. Only valid in regions and accounts that support EC2 Classic.
  enable_classiclink_dns_support = false
}

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.12.0"
  # A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet.
  ipv6_address_count = 1
  # Can be used instead of user_data to pass base64-encoded binary data directly. Use this instead of user_data whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption.
  user_data_base64 = ""
  # The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead.
  user_data = ""
  # Name to be used on all resources as prefix
  name = ""
  # If true, the EC2 instance will have associated public IP address
  associate_public_ip_address = false
  # A list of security group IDs to associate with
  vpc_security_group_ids = []
  # Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface
  ipv6_addresses = []
  # The type of instance to start
  instance_type = ""
  # ID of AMI to use for the instance
  ami = ""
  # Private IP address to associate with the instance in a VPC
  private_ip = ""
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "2.13.0"
  # The port on which the DB accepts connections
  port = ""
  # The engine version to use
  engine_version = ""
  # The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance_window
  backup_window = ""
  # Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file
  password = ""
  # Username for the master DB user
  username = ""
  # The instance type of the RDS instance
  instance_class = ""
  # The allocated storage in gigabytes
  allocated_storage = ""
  # The database engine to use
  engine = ""
  # The name of your final DB snapshot when this DB instance is deleted.
  final_snapshot_identifier = ""
  # The name of the RDS instance, if omitted, Terraform will assign a random, unique identifier
  identifier = ""
  # The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'
  maintenance_window = ""
}

module "elb" {
  source  = "terraform-aws-modules/elb/aws"
  version = "2.3.0"
  # The name of the ELB
  name = ""
  # A list of security group IDs to assign to the ELB
  security_groups = []
  # A health check block
  health_check = {}
  # A list of listener blocks
  listener = []
  # A list of subnet IDs to attach to the ELB
  subnets = []
  # The prefix name of the ELB
  name_prefix = ""
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "3.4.0"
  # Creates a unique name beginning with the specified prefix
  name = ""
  # The number of Amazon EC2 instances that should be running in the group
  desired_capacity = ""
  # A list of subnet IDs to launch resources in
  vpc_zone_identifier = []
  # Controls how health checking is done. Values are - EC2 and ELB
  health_check_type = ""
  # The minimum size of the auto scale group
  min_size = ""
  # The maximum size of the auto scale group
  max_size = ""
  # Setting this will cause Terraform to wait for exactly this number of healthy instances in all attached load balancers on both create and update operations. Takes precedence over min_elb_capacity behavior.
  wait_for_elb_capacity = 1
}

module "vault" {
  source  = "hashicorp/vault/aws"
  version = "0.13.3"
  # The domain name of the Route 53 Hosted Zone in which to add a DNS entry for Vault (e.g. example.com). Only used if var.create_dns_entry is true.
  hosted_zone_domain_name = ""
  # The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair.
  ssh_key_name = ""
  # The ID of the AMI to run in the cluster. This should be an AMI built from the Packer template under examples/vault-consul-ami/vault-consul.json. If no AMI is specified, the template will 'just work' by using the example public AMIs. WARNING! Do not use the example AMIs in a production setting!
  ami_id = ""
  # The domain name to use in the DNS A record for the Vault ELB (e.g. vault.example.com). Make sure that a) this is a domain within the var.hosted_zone_domain_name hosted zone and b) this is the same domain name you used in the TLS certificates for Vault. Only used if var.create_dns_entry is true.
  vault_domain_name = ""
}

module "sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "2.0.0"
  # A unique name beginning with the specified prefix.
  name_prefix = ""
  # This is the human-readable name of the queue. If omitted, Terraform will assign a random name.
  name = ""
  # The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK
  kms_master_key_id = ""
}

module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.3.0"
  # ID of the VPC where to create security group
  vpc_id = ""
  # Name of security group
  name = ""
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "5.0.0"
  # A list of subnets to associate with the load balancer. e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f']
  subnets = []
  # The resource name prefix and Name tag of the load balancer.
  name_prefix = ""
  # The resource name and Name tag of the load balancer.
  name = ""
  # VPC id where the load balancer and other resources will be deployed.
  vpc_id = ""
}

module "notify-slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "2.9.0"
  # The name of the SNS topic to create
  sns_topic_name = ""
  # The description of the Lambda function
  lambda_description = ""
  # The username that will appear on Slack messages
  slack_username = ""
  # The name of the channel in Slack for notifications
  slack_channel = ""
  # The URL of Slack webhook
  slack_webhook_url = ""
  # The ARN of the KMS Key to use when encrypting log data for Lambda
  cloudwatch_log_group_kms_key_id = ""
}
