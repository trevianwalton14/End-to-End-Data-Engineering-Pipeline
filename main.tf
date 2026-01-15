# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 4.0"
#     }
#   }
# }

# resource "aws_vpc" "EndtoEnd_VPC" {
#   cidr_block = "10.0.0.0/16"
#   tags = {
#     Name = "EndtoEnd_VPC"
#   }

# }

# # Create three S3 buckets: source, destination, and code buckets
# resource "aws_s3_bucket" "s3_source_bucket" {
#   bucket        = "endtoend-source-bucket-1234567"
#   force_destroy = true

#   tags = {
#     Name = "EndtoEnd Source Bucket"
#   }
# }

# resource "aws_s3_bucket" "s3_destination_bucket" {
#   bucket        = "endtoend-destination-bucket-1234567"
#   force_destroy = true

#   tags = {
#     Name = "EndtoEnd Destination Bucket"
#   }
# }

# resource "aws_s3_bucket" "s3_code_bucket" {
#   bucket        = "endtoend-code-bucket-1234567"
#   force_destroy = true

#   tags = {
#     Name = "EndtoEnd Code Bucket"
#   }
# }

# resource "aws_s3_object" "glue_script" {
#   bucket = aws_s3_bucket.s3_code_bucket.bucket
#   key    = "script.py"
#   source = "C:/terraform-projects/EndtoEndDataPipeline/script.py"

# }

# resource "aws_iam_role" "aws_glue_role" {
#   name = "aws_glue_service_role"

#   assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Action": "sts:AssumeRole",
#         "Principal": {
#           "Service": "glue.amazonaws.com"
#         }
#       }
#     ]
#   }
# EOF
# }

# resource "aws_iam_role_policy" "aws_glue_role_policy" {
#   name   = "aws_glue_service_role_policy"
#   role   = aws_iam_role.aws_glue_role.name
#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Action": [
#           "s3:*",
#           "glue:*"
#         ],
#         "Resource": [
#           "${aws_s3_bucket.s3_source_bucket.arn}",
#           "${aws_s3_bucket.s3_source_bucket.arn}/*",
#           "${aws_s3_bucket.s3_destination_bucket.arn}",
#           "${aws_s3_bucket.s3_destination_bucket.arn}/*",
#           "${aws_s3_bucket.s3_code_bucket.arn}",
#           "${aws_s3_bucket.s3_code_bucket.arn}/*"
#         ]
#       },
#       {
#         "Effect": "Allow",
#         "Action": [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#           "s3:ListBucket",
#           "s3:GetObject",
#           "s3:PutObject",
#           "s3:DeleteObject",
#           "s3:GetBucketLocation",
#           "s3:GetBucketAcl",
#           "s3:CreateBucket",
#           "glue:GetDatabase",
#           "glue:CreateDatabase",
#           "glue:UpdateDatabase",
#           "glue:DeleteDatabase",
#           "glue:GetTable",
#           "glue:CreateTable",
#           "glue:UpdateTable",
#           "glue:DeleteTable",
#           "glue:CreatePartition",
#           "glue:UpdatePartition",
#           "glue:DeletePartition",
#           "glue:GetPartition"
#         ],
#         "Resource": "*"
#       }
#     ]
#   }
# EOF
# }

# resource "aws_glue_crawler" "endtoend_glue_crawler" {
#   name          = "endtoend-glue-crawler"
#   role          = aws_iam_role.aws_glue_role.arn
#   database_name = "endtoend_glue_database"

#   s3_target {
#     path = "s3://${aws_s3_bucket.s3_source_bucket.bucket}/"
#   }

#   #If tables already exist in the database, this policy will log the deletion of the tables instead of deleting them outright.
#   schema_change_policy {
#     delete_behavior = "LOG"
#   }

#   configuration = <<EOF
# {
#     "Version": 1.0,
#     "CrawlerOutput": {
#         "Partitions": {
#             "AddOrUpdateBehavior": "InheritFromTable"
#         }
#     },

#     "Grouping": {
#         "TableGroupingPolicy": "CombineCompatibleSchemas"
#     }

# }
# EOF
# }

# resource "aws_glue_catalog_database" "endtoend_glue_database" {
#   name         = "endtoend_glue_database"
#   location_uri = "s3://${aws_s3_bucket.s3_code_bucket.bucket}/glue-database/"
# }

# resource "aws_glue_trigger" "endtoend_glue_trigger" {
#   name = "endtoend-glue-trigger"
#   type = "ON_DEMAND"
#   actions {
#     crawler_name = aws_glue_crawler.endtoend_glue_crawler.name
#   }
# }

# resource "aws_glue_job" "endtoend_glue_job" {
#   name     = "endtoend-glue-job"
#   role_arn = aws_iam_role.aws_glue_role.arn
#   command {
#     name            = "glueetl"
#     script_location = "s3://${aws_s3_bucket.s3_code_bucket.bucket}/${aws_s3_object.glue_script.key}"
#     python_version  = "3"
#   }
#   default_arguments = {
#     "--enable-auto-scaling"              = "true"
#     "--datalake-formats"                 = "delta"
#     "--source-path"                      = "s3://${aws_s3_bucket.s3_source_bucket.bucket}/"
#     "--destination-path"                 = "s3://${aws_s3_bucket.s3_destination_bucket.bucket}/"
#     "--job-language"                     = "python"
#     "--enable-continuous-cloudwatch-log" = "true"
#     "--enable-metrics"                   = "true"
#     "--enable-glue-datacatalog"          = "true"
#     "--jog-name"                         = "endtoend-glue-job"
#   }
#   max_retries       = 1
#   glue_version      = "3.0"
#   number_of_workers = 2
#   worker_type       = "G.1X"
# }