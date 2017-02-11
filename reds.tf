# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# MAIN ReDS Terraform File
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

module "iamrole" {
  source     	= "modules/iamrole"
  unique_name	= "${var.unique_name}"
}

module "s3bucket" {
  source        = "modules/s3bucket"
  unique_name   = "${var.unique_name}"
}

module "cwalarms" {
  source        	= "modules/cwalarms"
  unique_name   	= "${var.unique_name}"
  rds_instance		= "${var.rds_instance}"
  up_threshold		= "${var.up_threshold}"
  up_evaluations	= "${var.up_evaluations}"
  down_threshold	= "${var.down_threshold}"
  down_evaluations	= "${var.down_evaluations}"
  credit_threshold	= "${var.credit_threshold}"
  credit_evaluations	= "${var.credit_evaluations}"
}

