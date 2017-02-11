# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# S3 Bucket variables
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

variable "unique_name"    {}
variable "stack_prefix"   {}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# S3 Bucket resources
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

resource "aws_s3_bucket" "reds-bucket-code" {
    bucket = "${var.stack_prefix}-bucket-code-${var.unique_name}"
    acl    = "private"
}
output "aws_s3_bucket_id" { value = "${aws_s3_bucket.reds-bucket-code.id}" }
