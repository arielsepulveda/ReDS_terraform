# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# IAM Role variables
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

variable "unique_name" {
  description = "Unique name for IAM Role"
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# IAM Role resources
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

resource "aws_iam_role" "reds-role-lambdarole" {
    name               = "reds-role-lambdarole-${var.unique_name}"
    path               = "/"
    assume_role_policy = "${file("lambdarole.json")}"
}
output "aws_iam_role_id" { value = "${aws_iam_role.reds-role-lambdarole.id}" }
