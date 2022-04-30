variable "key-name" {
  type        = string
  description = "The AWS key pair to use for resources."
  default     = "east1" # Define your key pair name here
}

variable "aws_profile" {
  type        = string
  description = "The AWS profile to use for resources."
  default     = "default"
}

variable "ami" {
  type        = map(string)
  description = "A map of AMIs."
  default     = {}
  # type = "map"
}

variable "instance-type" {
  type        = string
  description = "The instance type."
  default     = "t2.micro"
}

variable "region" {
  type        = string
  description = "The AWS region."
  default     = "us-east-1"
}

variable "AZ" {
  description = "The AWS region."
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  default = "20.0.0.0/16"
}

variable "subnet_cidr_public" {
  description = "Subnet CIDRs for public subnets (length must match configured availability_zones)"
  default     = ["20.0.1.0/24", "20.0.3.0/24"]
}

variable "subnet_cidr_private" {
  description = "Subnet CIDRs for private subnets (length must match configured availability_zones)"
  default     = ["20.0.2.0/24", "20.0.4.0/24"]
}

variable "blog-bucket" {
  default = "enesblog" #  PLEASE ENTER YOUR FIRST BUCKET NAME
}

variable "s3-failover" {
  default = "capstone.caucasusllc.com" # PLEASE ENTER YOUR SECOND BUCKET NAME IT MUST BE SAME NAME WITH YOUR SUBDOMAIN NAME
}

# data "aws_ami" "tf-ami" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-kernel-5.10*"]
#   }
# }

variable "ubuntu-ami" {
  default     = "ami-0e472ba40eb589f49"
  description = "The AMI to use for the instance."
}

variable "nat-ami" {
  default     = "ami-003acd4f8da7e06f9"
  description = "The AMI to use for the NAT instance."
}

variable "S3hostedzoneID" {
  default = "Z3AQBSTGFYJSTF"
}

variable "S3websiteendpoint" {
  default = "s3-website-us-east-1.amazonaws.com"
}

variable "domain_name" {
  default     = "caucasusllc.com" #  PLEASE ENTER YOUR DOMAIN NAME
  description = "The domain name for the website."
}

variable "subdomain_name" {
  default     = "capstone.caucasusllc.com" #  PLEASE ENTER YOUR FULL SUBDOMAIN NAME
  description = "The subdomain name for the website."
}
variable "awsAccount" {
  default     = "**************" # PLEASE ENTER YOUR AWS ACCOUNT ID WITHOUT "-"
  description = "AWS Account ID"
}

variable "github_token" {
  default     = "*******************************" # PLEASE ENTER YOUR GITHUB TOKEN
  description = "Github token for Terraform Github provider"
}

variable "github_repository_name" {
  default     = "terraform-blog-application" # PLEASE ENTER YOUR GITHUB REPOSITORY NAME
  description = "The name of the repository to use for uploading the RDS Endpoint."
}

############################
###### RDS VARIABLES #######
############################

variable "db_name" {
  default     = "database1"
  description = "The name of the database."
}

variable "db_identifier" {
  default     = "database1"
  description = "The identifier of the RDS instance."
}

variable "db_username" {
  default     = "admin"
  description = "The database username."
}

variable "db_instance_class" {
  default     = "db.t2.micro"
  description = "The instance type to use."
}

variable "db_engine" {
  default     = "mysql"
  description = "The database engine to use."
}

variable "db_engine_version" {
  default     = "8.0.28"
  description = "The version of the database engine to use."
}

variable "db_password" {
  default     = "Devenes123" # PLEASE ENTER YOUR DATABASE PASSWORD
  description = "The database password."
}

variable "db_storage_size" {
  default     = "20"
  description = "Database storage size in GB"
}
