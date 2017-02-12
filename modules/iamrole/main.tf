# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# IAM Role variables
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

variable "unique_name"    {}
variable "stack_prefix"   {}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# IAM Role resources
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

# Create the lambda role (using lambdarole.json file)
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

resource "aws_iam_role" "reds-role-lambdarole" {
  name               = "${var.stack_prefix}-role-lambdarole-${var.unique_name}"
  assume_role_policy = "${file("modules/iamrole/lambdarole.json")}"
}

# Output the ARN of the lambda role
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

output "aws_iam_role_arn" {
  value = "${aws_iam_role.reds-role-lambdarole.arn}"
}
