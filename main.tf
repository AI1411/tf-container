provider "aws" {
  region = "ap-northeast-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "describe_regions_for_ec2" {
  source = "./iam_role"
  name = "describe_regions_for_ec2"
  identifier = "ec2.amazonaws.com"
  policy = data.aws_iam_policy_document.allow_describe_regions.json
}

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "instance_type" {
  default = "t2.micro"
}

data "aws_iam_policy_document" "allow_describe_regions" {
  statement {
    effect = "Allow"
    actions = ["ec2:DescribeRegions"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "example" {
  name = "example"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_policy" "example" {
  name = "tf-iam-policy"
  policy = data.aws_iam_policy_document.allow_describe_regions.json
}

resource "aws_instance" "tfc" {
  ami = "ami-0ecb2a61303230c9d"
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.tfc-sg.id]

  user_data = <<EOF
  #!/bin/bash
  yum install -y httpd
  systemctl start httpd.service
  EOF
}

resource "aws_security_group" "tfc-sg" {
  name = "tf-sg"

  ingress {
    from_port = 80
    protocol  = "tcp"
    to_port   = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_dns" {
  value = aws_instance.tfc.public_dns
}
