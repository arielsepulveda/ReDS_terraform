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

output "name" {
  value = "${aws_lambda_function.ecs_ecs_autoscale_lambda.function_name}"
}
