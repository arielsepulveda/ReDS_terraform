# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# MAIN ReDS Terraform File
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Create Lambda Role
# - - - - - - - - - - - - -

module "iamrole" {
  source     	  = "modules/iamrole"
  unique_name	  = "${var.timestamp_taken}"
  stack_prefix  = "${var.stack_prefix}"
}

# Create S3 Bucket
# - - - - - - - - - - - - -

module "s3bucket" {
  source        = "modules/s3bucket"
  unique_name   = "${var.timestamp_taken}"
  stack_prefix  = "${var.stack_prefix}"
}

# Create Alarms
# - - - - - - - - - - - - -

module "cwalarms" {
  source        	    = "modules/cwalarms"
  unique_name   	    = "${var.timestamp_taken}"
  stack_prefix        = "${var.stack_prefix}"
  rds_instance		    = "${var.rds_instance}"
  up_threshold		    = "${var.up_threshold}"
  up_evaluations	    = "${var.up_evaluations}"
  down_threshold	    = "${var.down_threshold}"
  down_evaluations	  = "${var.down_evaluations}"
  credit_threshold    = "${var.credit_threshold}"
  credit_evaluations  = "${var.credit_evaluations}"
}

# Build YAML Templates
# - - - - - - - - - - - - -

data "template_file" "alarms" {
    template = "${file("modules/lambdafn/alarms.yaml.template")}"
    vars {
        alarm_high    = "${module.cwalarms.reds-alarms-ReDSAlarmHigh_id}"
        alarm_low     = "${module.cwalarms.reds-alarms-ReDSAlarmLow_id}"
        alarm_credits = "${module.cwalarms.reds-alarms-ReDSNoCredits_id}"
    }
}

data "template_file" "vars" {
    template = "${file("modules/lambdafn/vars.yaml.template")}"
    vars {
      stack-prefix            = "${var.stack_prefix}"
      aws-region              = "${var.AWS_REGION}"
      rds-identifier          = "${var.rds_instance}"
      instance-size-1         = "${var.instance_size_1}"
      instance-size-2         = "${var.instance_size_2}"
      instance-size-3         = "${var.instance_size_3}"
      instance-size-4         = "${var.instance_size_4}"
      instance-size-5         = "${var.instance_size_5}"
      down-cron               = "${var.down_cron}"
      down-alarm-duration     = "${var.down_evaluations}"
      down-threshold          = "${var.down_threshold}"
      down-cooldown	          = "${var.down_cooldown}"
      up-cron                 = "${var.up_cron}"
      up-alarm-duration       = "${var.up_evaluations}"
      up-threshold            = "${var.up_threshold}"
      up-cooldown             = "${var.up_cooldown}"
      credits-alarm-duration  = "${var.credit_evaluations}"
      credits-threshold       = "${var.credit_threshold}"
      credits-cooldown        = "${var.credits_cooldown}"
      enabled                 = "${var.enabled}"
      scheduled-index         = "${var.scheduled_index}"
      schedule-enabled        = "${var.schedule_enabled}"
    }
}

resource "null_resource" "buildlambdazip" {
  triggers { key = "${uuid()}" }
  provisioner "local-exec" {
  command = <<EOT
  rm -rf lambda && rm -rf tmp
  mkdir lambda && mkdir tmp
  unzip reds/deps.zip -d lambda/
  cp reds/reds.py lambda/reds.py
  echo "${data.template_file.alarms.rendered}" > lambda/alarms.yaml"
  echo "${data.template_file.vars.rendered}" > lambda/vars.yaml"
  cd lambda/
  zip -r ../tmp/${var.stack_prefix}-${var.timestamp_taken}.zip ./*
  cd ..
EOT
  }
}

module "lambdafn" {
  source        	   = "modules/lambdafn"
  unique_name   	   = "${var.timestamp_taken}"
  lambda_file        = "tmp/${var.stack_prefix}-${var.timestamp_taken}.zip"
  stack_prefix       = "${var.stack_prefix}"
  aws_iam_role_arn   = "${module.iamrole.aws_iam_role_arn}"
}
