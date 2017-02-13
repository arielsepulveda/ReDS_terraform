# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# LAMBDA variables
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

variable "unique_name"        {}
variable "stack_prefix"       {}
variable "lambda_file"        {}
variable "alarms_yaml_render" {}
variable "vars_yaml_render"   {}
variable "aws_iam_role_arn"   {}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# LAMBDA resources
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

# Build LAMBDA Zip File
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

resource "null_resource" "buildlambdazip" {
  triggers { key = "${uuid()}" }
  provisioner "local-exec" {
  command = <<EOF
  rm -rf lambda && rm -rf tmp
  mkdir lambda && mkdir tmp
  unzip reds/deps.zip -d lambda/
  cp reds/reds.py lambda/reds.py
  echo "${var.alarms_yaml_render}" > lambda/alarms.yaml
  echo "${var.vars_yaml_render}" > lambda/vars.yaml
  cd lambda/
  zip -r ../tmp/${var.stack_prefix}-${var.unique_name}.zip ./*
  while [ ! -f ../tmp/${var.stack_prefix}-${var.unique_name}.zip ]
  do
  sleep 2
  echo "Waiting for .zip file"
  done
  cd ..
EOF
  }
}

# Create lambda function
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

resource "aws_lambda_function" "rds_cas_autoscale_lambda" {
  function_name   = "${var.stack_prefix}_lambda_${var.unique_name}"
  filename        = "${var.lambda_file}"
  role            = "${var.aws_iam_role_arn}"
  runtime         = "python2.7"
  handler         = "reds.lambda_handler"
  timeout         = "30"
  depends_on      = ["null_resource.buildlambdazip"]
}

# Run the function every 5 minutes.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

resource "aws_cloudwatch_event_rule" "every_five_minutes" {
  name = "${var.stack_prefix}_lambda_event_${var.unique_name}"
  description = "Fires every five minutes"
  schedule_expression = "rate(5 minutes)"
}

# Assign event to Lambda target
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

resource "aws_cloudwatch_event_target" "check_every_five_minutes" {
    rule = "${aws_cloudwatch_event_rule.every_five_minutes.name}"
    target_id = "rds_cas_autoscale_lambda"
    arn = "${aws_lambda_function.rds_cas_autoscale_lambda.arn}"
}

# Allow lambda to be called from cloudwatch
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

resource "aws_lambda_permission" "allow_cloudwatch_to_call" {
  statement_id = "${var.stack_prefix}_AllowExecutionFromCloudWatch_${var.unique_name}"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.rds_cas_autoscale_lambda.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.every_five_minutes.arn}"
}

# Output function name
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

output "lambda_function_name" {
  value = "${aws_lambda_function.rds_cas_autoscale_lambda.function_name}"
}
