############################
#  VPC
############################

resource "aws_vpc" "tf_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = {
    Name = "tf_vpc"
  }
  enable_dns_hostnames = true
  enable_dns_support   = true
}

######################################
#  INTERNET GATEWAY AND ATTACHMENT
######################################

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "tf_igw"
  }
}

###########################################
#  VPC ENDPOINT / ROUTE TABLE ASSOCİATİON
###########################################

resource "aws_vpc_endpoint" "tf-endpoint-s3" {
  vpc_id            = aws_vpc.tf_vpc.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  #policy default full access
}


resource "aws_vpc_endpoint_route_table_association" "ft-route-table" {
  route_table_id  = aws_route_table.private.id
  vpc_endpoint_id = aws_vpc_endpoint.tf-endpoint-s3.id
}

###################################################
#  FIRST S3 BLOG BUCKET AND BUCKET NOTIFICATION
####################################################

resource "aws_s3_bucket" "s3-blog" {
  bucket = var.blog-bucket
  # acl    = "public-read"
  # policy = file("policy/policys3lambda.json")
  depends_on = [
    aws_lambda_function.lambda-tf
  ]
}

resource "aws_s3_bucket_acl" "s3-blog-acl" {
  bucket = aws_s3_bucket.s3-blog.bucket
  acl    = "public-read"
}
resource "aws_s3_bucket_policy" "s3-blog-policy" {
  bucket = aws_s3_bucket.s3-blog.bucket
  policy = file("policy/policys3lambda.json")
}


resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.s3-blog.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda-tf.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_prefix       = "media/"
  }

  depends_on = [
    aws_lambda_permission.lambda-invoke
  ]
}

##################################
#  FAILOVER BUCKET
#################################

resource "aws_s3_bucket" "s3-failover" {
  bucket = var.subdomain_name
  # acl    = "public-read"
  # policy = file("policy/policy.json")

  # website {
  #   index_document = "index.html"
  #   error_document = "index.html"
  # }
}

resource "aws_s3_bucket_website_configuration" "s3-failover-website" {
  bucket = aws_s3_bucket.s3-failover.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_acl" "s3-failover-acl" {
  bucket = aws_s3_bucket.s3-failover.bucket
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "s3-failover-policy" {
  bucket = aws_s3_bucket.s3-failover.bucket
  policy = file("policy/policy.json")
}

####################################
# UPLOAD S3 FAILOVER OBJECTS 
##################################

# resource "aws_s3_bucket_object" "sorry" {
#   bucket       = aws_s3_bucket.s3-failover.bucket
#   key          = "sorry.jpg"
#   source       = "html/sorry.jpg"
#   content_type = "text/html"
#   etag         = filemd5("html/sorry.jpg")
#   acl          = "public-read"
# }

resource "aws_s3_object" "sorry" {
  bucket       = aws_s3_bucket.s3-failover.bucket
  key          = "sorry.jpg"
  source       = "html/sorry.jpg"
  acl          = "public-read"
  content_type = "text/html"
  etag         = filemd5("html/sorry.jpg")
}

# resource "aws_s3_bucket_object" "index" {
#   bucket       = aws_s3_bucket.s3-failover.bucket
#   key          = "index.html"
#   source       = "html/index.html"
#   content_type = "text/html"
#   etag         = md5(file("html/index.html"))
#   acl          = "public-read"
# }

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.s3-failover.bucket
  key          = "index.html"
  source       = "html/index.html"
  acl          = "public-read"
  content_type = "text/html"
  etag         = md5(file("html/index.html"))
}

###########################
# BASTION INSTANCE
###########################

resource "aws_instance" "bastion" {
  ami               = var.nat-ami
  key_name          = var.key-name
  instance_type     = var.instance-type
  subnet_id         = aws_subnet.public[0].id
  security_groups   = [aws_security_group.bastion-sec.id]
  source_dest_check = false
  tags = {
    Name = "Bastion-Instance"
  }
}

################################
#  RDS
################################

resource "aws_db_instance" "rds-tf" {
  allocated_storage           = var.db_storage_size # GB of storage dedicated to the database
  engine                      = var.db_engine
  engine_version              = var.db_engine_version
  instance_class              = var.db_instance_class
  db_name                     = var.db_name
  identifier                  = var.db_identifier
  username                    = var.db_username
  password                    = var.db_password
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true # Automatically upgrade minor versions
  skip_final_snapshot         = true # Don't take a final snapshot 
  port                        = 3306
  vpc_security_group_ids      = [aws_security_group.rds-sec.id]
  db_subnet_group_name        = aws_db_subnet_group.rd-subnet.name
}

##############################
# LAUNCH TEMPLATE
##############################

resource "aws_launch_template" "tf-lt" {
  name                   = "tf-lt"
  instance_type          = var.instance-type
  image_id               = var.ubuntu-ami
  key_name               = var.key-name
  vpc_security_group_ids = [aws_security_group.ec2-sec.id]
  user_data              = filebase64("./userdata.sh")
  depends_on = [
    github_repository_file.dbendpoint,
    aws_instance.bastion,
    aws_iam_role.ec2-s3,
    aws_iam_instance_profile.instance-role,
    aws_db_instance.rds-tf
  ]
  iam_instance_profile {
    name = aws_iam_instance_profile.instance-role.name
  }
}

#################################
# UPLOAD RDS ENDPOINT TO GITHUB #
#################################

resource "github_repository_file" "dbendpoint" {
  content             = aws_db_instance.rds-tf.address
  file                = "src/cblog/dbserver.endpoint"
  repository          = var.github_repository_name
  overwrite_on_create = true
  branch              = "main"
}

###############################
#  APPLICATION LOAD BALANCER
###############################

resource "aws_lb" "alb-tf" {
  name               = "alb-tf"
  load_balancer_type = "application"
  internal           = false
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.alb-sec.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]
}

###############################
# LISTENER RULES
###############################

resource "aws_lb_listener" "tf-https" {
  load_balancer_arn = aws_lb.alb-tf.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.isssued.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf-target.arn
  }
  # depends_on = [
  #   aws_acm_certificate.cert
  # ]
}

resource "aws_lb_listener" "tf-http" {
  load_balancer_arn = aws_lb.alb-tf.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


###############################
#  TARGET GROUP
##############################

resource "aws_lb_target_group" "tf-target" {
  name        = "tf-target"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.tf_vpc.id
  health_check {
    protocol            = "HTTP"         # default HTTP
    port                = "traffic-port" # default
    unhealthy_threshold = 2              # default 3
    healthy_threshold   = 5              # default 3
    interval            = 20             # default 30
    timeout             = 5              # default 10
  }
}

################################
# AUTOSCALING GROUP AND POLICY
################################

resource "aws_autoscaling_group" "asg-tf" {
  name                      = "asg-tf"
  max_size                  = 4
  min_size                  = 2
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  target_group_arns         = [aws_lb_target_group.tf-target.arn]
  depends_on = [
    aws_instance.bastion
  ]
  vpc_zone_identifier = [for subnet in aws_subnet.private : subnet.id]
  launch_template {
    id      = aws_launch_template.tf-lt.id
    version = "$Default"
  }
}

resource "aws_autoscaling_policy" "policy-tf" {
  name                   = "asg-policy-tf"
  autoscaling_group_name = aws_autoscaling_group.asg-tf.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

##############################
# LAMBDA FUNCTION
#############################

data "archive_file" "zipit" {
  type        = "zip"
  source_file = "./lambda.py"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "lambda-tf" {
  filename         = "lambda.zip"
  source_code_hash = data.archive_file.zipit.output_base64sha256
  role             = aws_iam_role.iam_for_lambda.arn
  runtime          = "python3.8"
  function_name    = "lambda-function"
  handler          = "index.handler"
  vpc_config {
    subnet_ids         = [aws_subnet.public[0].id, aws_subnet.public[1].id, aws_subnet.private[0].id, aws_subnet.private[1].id]
    security_group_ids = [aws_security_group.bastion-sec.id]
  }
}

resource "aws_lambda_permission" "lambda-invoke" {
  statement_id   = "AllowExecutionFromS3Bucket"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.lambda-tf.function_name
  source_arn     = aws_s3_bucket.s3-blog.arn
  source_account = var.awsAccount
  principal      = "s3.amazonaws.com"
}


##############################
#  DYNAMODB TABLE
##############################

resource "aws_dynamodb_table" "dynamodb-tf" {
  name           = "awscapstoneDynamo"
  hash_key       = "id"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  attribute {
    name = "id"
    type = "S"
  }
}
