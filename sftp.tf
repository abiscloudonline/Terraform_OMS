terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.51"
    }
  }
}
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_s3_bucket" "b2209nyra" {
  bucket = "b2209nyra"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b2209nyra.id
  acl    = "private"
}

resource "aws_transfer_ssh_key" "example" {
  server_id = aws_transfer_server.example.id
  user_name = aws_transfer_user.example.user_name
  body      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDbex+5IrL3UcuXerypur624Ushii5QgvSol6J6bsxRzkMmr1ma68maktXMxZyZPZL/EDN7tlfEIkplti6b9lFc1YRpy/OVThBbLn8IowbO4WZ5iaD/zWE1aIwnie5tNSBaYxYhziDtgObQxgtVKF/6Bg6frlm4boVy7pZlZKYtaJDDjCMqRBFe7Pb9AZeeEuhp3k+NoKmBl3uwUgTziF/Qyv4IEseOIMhOVgcogskn9mulh9yHMD3Ta4IuuqxjMOATgXZIzl4Ohyuf9qQhVc8jYfuCCqZe7/D+PBd2VutuI+kOH5YvpuCtxy+ec//uKaUISpVYTBC5xwo6LVRiiZl+1tKQRODYuc+Y52nsJEyO5ISW0D0tzRIv3MxmbjAgvbHfwYWlFDZOXeA1Ckc11+kvnr2rh+6Wqnje9hD4pNk7eeiK2HjgxAn4WznyyZA5wNPrQU07M/HgoKyqVXupmTTpIc5ehrraMsQ+VJ51zCZQbfDity8IC7xLDIIrreoDtj8="
}

resource "aws_transfer_server" "example" {
  identity_provider_type = "SERVICE_MANAGED"

  tags = {
    NAME = "tf-acc-test-transfer-server"
  }
}

resource "aws_transfer_user" "example" {
  server_id = aws_transfer_server.example.id
  user_name = "tftestuser"
  role      = aws_iam_role.example.arn
  home_directory_type = "LOGICAL"
  home_directory_mappings {
    entry  = "/"
    target = "/${aws_s3_bucket.b2209nyra.id}/$${Transfer:user_name}"
  }

  tags = {
    NAME = "tftestuser"
  }
}

resource "aws_iam_role" "example" {
  name = "tf-test-transfer-user-iam-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "example" {
  name = "tf-test-transfer-user-iam-policy"
  role = aws_iam_role.example.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowFullAccesstoS3",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}
