# Variables
###################################
variable "external_id" {
  type        = string
  description = "ProwlerPro IAM Role External ID - Please input your External ID here below"
}
variable "bucket_name" {
  type        = string
  description = "This is the name of the S3 Bucket where ProwlerPro SaaS will store the reports of your AWS Account(s)."
}
variable "destination_bucket_account" {
  type        = string
  description = "This is the AWS Account ID of the S3 Bucket where ProwlerPro SaaS will store the reports of your AWS Account(s)."
}

##### PLEASE, DO NOT EDIT BELOW THIS LINE #####


# Terraform Provider Configuration
###################################
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.10"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


# IAM Role
###################################
data "aws_iam_policy_document" "prowler_pro_saas_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::232136659152:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values = [
        var.external_id,
      ]
    }
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::232136659152:role/prowler-pro-saas*"
      ]
    }
  }
}
data "aws_iam_policy_document" "prowler_pro_saas_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "account:Get*",
      "appstream:Describe*",
      "appstream:List*",
      "backup:List*",
      "cloudtrail:GetInsightSelectors",
      "codeartifact:List*",
      "codebuild:BatchGet*",
      "dlm:Get*",
      "drs:Describe*",
      "ds:Get*",
      "ds:Describe*",
      "ds:List*",
      "ec2:GetEbsEncryptionByDefault",
      "ecr:Describe*",
      "ecr:GetRegistryScanningConfiguration",
      "elasticfilesystem:DescribeBackupPolicy",
      "glue:GetConnections",
      "glue:GetSecurityConfiguration*",
      "glue:SearchTables",
      "lambda:GetFunction*",
      "logs:FilterLogEvents",
      "macie2:GetMacieSession",
      "s3:GetAccountPublicAccessBlock",
      "shield:DescribeProtection",
      "shield:GetSubscriptionState",
      "securityhub:BatchImportFindings",
      "securityhub:GetFindings",
      "ssm:GetDocument",
      "ssm-incidents:List*",
      "support:Describe*",
      "tag:GetTagKeys",
      "wellarchitected:List*"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "prowler_pro_saas_role_apigw_policy" {
  statement {
    effect = "Allow"
    actions = [
      "apigateway:GET"
    ]
    resources = ["arn:${data.aws_partition.current.partition}:apigateway:*::/restapis/*", "arn:${data.aws_partition.current.partition}:apigateway:*::/apis/*"]
  }
}

data "aws_iam_policy_document" "prowler_pro_saas_role_s3_integration_delete" {
  statement {
    effect = "Allow"
    actions = [
      "s3:DeleteObject"
    ]
    resources = ["arn:${data.aws_partition.current.partition}:s3:::${var.bucket_name}/*ProwlerProBeacon"]
    condition {
      test     = "StringEquals"
      variable = "s3:ResourceAccount"
      values = [
        var.destination_bucket_account,
      ]
    }
  }
}

data "aws_iam_policy_document" "prowler_pro_saas_role_s3_integration_put" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = ["arn:${data.aws_partition.current.partition}:s3:::${var.bucket_name}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:ResourceAccount"
      values = [
        var.destination_bucket_account,
      ]
    }
  }
}

resource "aws_iam_role" "prowler_pro_saas_role" {
  name                = "ProwlerProSaaSScanRole"
  assume_role_policy  = data.aws_iam_policy_document.prowler_pro_saas_assume_role_policy.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/SecurityAudit", "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"]
  inline_policy {
    name   = "prowler-pro-saas-role-additional-view-privileges"
    policy = data.aws_iam_policy_document.prowler_pro_saas_role_policy.json
  }
  inline_policy {
    name   = "prowler-pro-saas-role-apigateway-view-privileges"
    policy = data.aws_iam_policy_document.prowler_pro_saas_role_apigw_policy.json
  }
  tags = tomap({
    "Name"      = "ProwlerProSaaSScanRole",
    "Terraform" = "true",
    "Service"   = "https://prowler.pro",
    "Support"   = "help@prowler.pro"
    "Version"   = "1.0.1"
  })
}
