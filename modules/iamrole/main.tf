# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# IAM Role variables
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

variable "unique_name"    {}
variable "stack_prefix"   {}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# IAM Role resources
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

resource "aws_iam_role" "reds-role-lambdarole" {
    name               = "${var.stack_prefix}-role-lambdarole"
    assume_role_policy = "${file("modules/iamrole/lambdarole.json")}"
}
output "aws_iam_role_arn" { value = "${aws_iam_role.reds-role-lambdarole.arn}" }
