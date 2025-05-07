terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.97.0"

    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      Environment = "PRD"
      Owner       = "Platform team"
      Project     = "Taxi-platform"
    }
  }
}


terraform {
  backend "s3" {
    bucket         = "tfstate-aws-taxi-platform"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tfstate-lock"
  }
}


module "lambda" {
  source                     = "./modules/lambda"
  receipts_s3_destination    = "${module.s3.taxi_drives_bucket_arn}/${module.s3.taxi_drives_receipts_folder_key}"
  iam_role_put_order_arn     = module.iam.iam_role_put_order_arn
  dynamodb_table_orders_name = module.dynamodb.dynamodb_table_orders_name
  lambda_kms_key_arn         = module.kms.lambda_kms_key_arn
}

module "s3" {
  source         = "./modules/s3"
  account_id     = var.account_id
  s3_kms_key_arn = module.kms.s3_kms_key_arn
}

module "vpc" {
  source = "./modules/vpc"
}

module "iot-core" {
  source = "./modules/iot-core"
}

module "kinesis" {
  source = "./modules/kinesis"
}

module "flink" {
  source = "./modules/flink"
}

module "step-function" {
  source = "./modules/step-function"
}

module "sns" {
  source = "./modules/sns"
}

module "sqs" {
  source = "./modules/sqs"
}

module "glue" {
  source = "./modules/glue"
}

module "dynamodb" {
  source               = "./modules/dynamodb"
  dynamodb_kms_key_arn = module.kms.dynamodb_kms_key_arn
}

module "api-gateway" {
  source = "./modules/api-gateway"
}

module "ses" {
  source = "./modules/ses"
}

module "secretsmanager" {
  source = "./modules/secretsmanager"
}

module "iam" {
  source                     = "./modules/iam"
  dynamodb_table_orders_name = module.dynamodb.dynamodb_table_orders_name
  taxi_drives_bucket_arn     = module.s3.taxi_drives_bucket_arn
}

module "kms" {
  source = "./modules/kms"
  kms_services = [
    "lambda",
    "s3",
    "dynamodb",
  ]
  account_id = var.account_id
  region     = var.region
}