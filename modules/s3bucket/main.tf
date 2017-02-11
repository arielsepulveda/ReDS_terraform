# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# S3 Bucket variables
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

variable "unique_name" {
  description = "Unique name for S3 bucket"
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# S3 Bucket resources
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

resource "aws_s3_bucket" "reds-bucket-code" {
    bucket = "reds-bucket-code-${var.unique_name}"
    acl    = "private"
}
output "aws_s3_bucket_id" { value = "${aws_s3_bucket.reds-bucket-code.id}" }
