# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# LAMBDA variables
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

variable "unique_name"    {}
variable "stack_prefix"   {}
variable "lambda_file"    {}

variable "aws_iam_role_arn" {
  description = "Lambda IAM Role ARN"
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# LAMBDA resources
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

resource "aws_lambda_function" "ecs_ecs_autoscale_lambda" {
  function_name   = "${var.stack_prefix}-lambda-${var.unique_name}"
  filename        = "${var.lambda_file}"
  role            = "${var.aws_iam_role_arn}"
  runtime         = "python2.7"
  handler         = "reds.lambda_handler"
  timeout         = "30"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call" {
    statement_id = "AllowExecutionFromCloudWatch"
      action = "lambda:InvokeFunction"
      function_name = "${aws_lambda_function.ecs_ecs_autoscale_lambda.function_name}"
      principal = "events.amazonaws.com"
      source_arn = "${aws_lambda_function.ecs_ecs_autoscale_lambda.arn}"
}

resource "aws_cloudwatch_event_rule" "every_five_minutes" {
    name = "every-five-minutes"
    description = "Fires every five minutes"
    schedule_expression = "rate(5 minutes)"
}

output "lambda_function_name" {
  value = "${aws_lambda_function.ecs_ecs_autoscale_lambda.function_name}"
}
