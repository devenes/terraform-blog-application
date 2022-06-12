variable "key-name" {
  type        = string
  description = "The AWS key pair to use for resources."
}

variable "aws_profile" {
  description = "The AWS profile to use for resources."
}

variable "ami" {
  type        = map(string)
  description = "A map of AMIs."
  default     = {}
  # type = "map"
}

variable "instance-type" {
  description = "The instance type."
}

variable "region" {
  description = "The AWS region."
}

variable "AZ" {}

variable "vpc_cidr" {}

variable "subnet_cidr_public" {
  description = "Subnet CIDRs for public subnets (length must match configured availability_zones)"
}

variable "subnet_cidr_private" {
  description = "Subnet CIDRs for private subnets (length must match configured availability_zones)"
}

variable "blog-bucket" {}

variable "s3-failover" {}

# data "aws_ami" "tf-ami" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-kernel-5.10*"]
#   }
# }

variable "ubuntu-ami" {
  description = "The AMI to use for the instance."
}

variable "nat-ami" {
  description = "The AMI to use for the NAT instance."
}

variable "S3hostedzoneID" {}

variable "S3websiteendpoint" {}

variable "domain_name" {
  description = "The domain name for the website."
}

variable "subdomain_name" {
  description = "The subdomain name for the website."
}
variable "awsAccount" {
  description = "AWS Account ID"
}

variable "github_token" {
  description = "Github token for Terraform Github provider"
}

variable "github_repository_name" {
  description = "The name of the repository to use for uploading the RDS Endpoint."
}

############################
###### RDS VARIABLES #######
############################

variable "db_name" {
  description = "The name of the database."
}

variable "db_identifier" {
  description = "The identifier of the RDS instance."
}

variable "db_username" {
  description = "The database username."
}

variable "db_instance_class" {
  description = "The instance type to use."
}

variable "db_engine" {
  description = "The database engine to use."
}

variable "db_engine_version" {
  description = "The version of the database engine to use."
}

variable "db_password" {
  description = "The database password."
}

variable "db_storage_size" {
  description = "Database storage size in GB"
}
