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
    assume_role_policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
output "aws_iam_role_id" { value = "${aws_iam_role.reds-role-lambdarole.id}" }
