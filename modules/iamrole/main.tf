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

# Create the Policy Document
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

data "aws_iam_policy_document" "lambdapolicy" {
    statement {
        sid = "1"
        actions = [ "rds:DescribeDBInstances",
                    "rds:DescribeEvents" ]
        resources = [ "*" ]
    }
    statement {
        actions = [ "rds:ModifyDBInstance" ]
        resources = [ "*" ]  # We can also use the RDS ARN here.
    }
   statement {
        actions = [ "cloudwatch:DescribeAlarms" ]
        resources = [ "*" ]
    }
    statement {
         actions = [ "logs:CreateLogGroup",
                     "logs:CreateLogStream",
                     "logs:PutLogEvents" ]
         resources = [ "arn:aws:logs:*:*:*" ]
     }
}

# Apply the Policy Document we just created in data
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

resource "aws_iam_role_policy" "reds-role-lambdapolicy" {
  name = "${var.stack_prefix}-role-lambdapolicy-${var.unique_name}"
  role = "${aws_iam_role.reds-role-lambdarole.id}"
  policy = "${data.aws_iam_policy_document.lambdapolicy.json}"
}

# Output the ARN of the lambda role
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

output "aws_iam_role_arn" {
  value = "${aws_iam_role.reds-role-lambdarole.arn}"
}
