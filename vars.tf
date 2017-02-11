# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Main Variables
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# AWS Access Key
variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
# AWS Region
variable "AWS_REGION" {
  default = "us-west-2"
  description = "AWS Region where you have the RDS (remember to enable Multi-AZ)"
}
variable "rds_instance" {
  description = "RDS Instance Name to Auto-Scale"
}
variable "unique_name" {
  description = "Unique name for resources  (resource_name-UNIQUENAME)"
}
variable "up_threshold" {
  default = "80.0"
  description = "CPU High Alarm threshold"
}
variable "up_evaluations" {
  default = "10"
  description = "CPU High Alarm evaluations periods"
}
variable "down_threshold" {
  default = "10.0"
  description = "CPU Low Alarm threshold"
}
variable "down_evaluations" {
  default = "5"
  description = "CPU Low Alarm evaluation periods"
}
variable "credit_threshold" {
  default = "2.0"
  description = "CPU Credits Exhausted Alarm threshold"
}
variable "credit_evaluations" {
  default = "10"
  description = "CPU Credits Exhausted Alarm evaluation periods"
}
