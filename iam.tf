#########################################
# IAM ROLE FOR EC2-FIRST S3 FULL ACCESS #
#########################################

resource "aws_iam_role" "ec2-s3" {
  name = "ec2-s3-full-tf"
  path = "/"
  assume_role_policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "ec2.amazonaws.com"
        },
        "Action" = "sts:AssumeRole"
        "Sid"    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3-full" {
  name = "s3-full-tf"
  role = aws_iam_role.ec2-s3.id
  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Effect" = "Allow",
        "Action" = [
          "s3:*",
          "s3-object-lambda:*"
        ],
        "Resource" = "*"
      }
    ]
  })
}

############################
### IAM INSTANCE PROFILE ###
############################

resource "aws_iam_instance_profile" "instance-role" {
  name = "instance-role"
  role = aws_iam_role.ec2-s3.name
}

##################################
#### LAMBDA ROLE AND POLICIES ####
##################################

resource "aws_iam_role" "iam_for_lambda" {
  name               = "lambda-role-for-s3"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda-s3-dynamodb" {
  name = "lambda-s3-dynamodb"
  role = aws_iam_role.iam_for_lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Effect   = "Allow"
        Resource = ["*"]
      }
    ]

    Statement = [
      {
        Action = [
          "lambda:Invoke*"
        ]
        Effect   = "Allow"
        Resource = ["*"]
      }
    ]
    #-------------------------------------------------------
    # To create inline policy we can use this code blocks
    #-------------------------------------------------------

    # Statement = [
    #   {
    #     Action = ["dynamodb:GetItem",
    #               "dynamodb:PutItem",
    #               "dynamodb:UpdateItem"
    #     ]
    #     Effect = "Allow"
    #     Resource = ["arn:aws:dynamodb:*:*:table/awscapstoneDynamo"]
    #   }
    # ]
  })
}

# data "aws_iam_policy_document" "lambda-s3-dynamodb" {
#   statement {
#     actions = ["s3:PutObject","s3:GetObject","s3:GetObjectVersion"]
#     resources = [ "*" ]
#   }

#   statement {
#     actions   = ["lambda:Invoke*"]
#     resources = [ "*" ]
#   }

#   statement {
#     actions = [ "dynamodb:GetItem",
#                 "dynamodb:PutItem",
#                 "dynamodb:UpdateItem"]
#     resources = [ "arn:aws:dynamodb:*:*:*" ]
#   }

#   statement {
#     actions = [ "s3:*",
#                 "s3-object-lambda:*"]
#     resources = [ "*" ]
#   }
# }

resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/job-function/NetworkAdministrator",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ])
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = each.value
}
