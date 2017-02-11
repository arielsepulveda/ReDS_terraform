provider "aws" {
    region = "${var.AWS_REGION}"
}
data "aws_availability_zones" "available" {}
