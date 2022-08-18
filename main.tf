provider "aws" {
  region = "ap-northeast-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "instance_type" {
  default = "t2.micro"
}

resource "aws_instance" "example" {
  ami = "ami0c3fd0f5d33134a76"
  instance_type = var.instance_type
}
