# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Variables
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

### Access Key --------------------------
variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
### AWS Region --------------------------
variable "AWS_REGION" {
  default = "us-west-2"
  description = "AWS Region where you have the RDS (remember to enable Multi-AZ)"
}

# this will create a resource every time.
variable "timestamp_taken" { default = "{{timestamp}}" }
# this will ASK you for the unique name
# variable "timestamp_taken" {
#   description = "Enter Unique Name or TimeStamp"
# }

### Main Configuration --------------------------
variable "rds_instance" {
  description = "RDS Instance Name to Auto-Scale"
}
variable "enabled" {
  default = true
  description = "Enable RDS Resize"
}
variable "stack_prefix" {
  description = "Stack prefix ( STACKPREFIX-resource_name )"
}
variable "schedule_enabled" {
  default = false
  description = "Enable Schedule Scale Up of RDS (and set size in schedule-index)"
}
variable "scheduled_index" {
  default = "2"
  description = "Instance size in 'instance_sizes' (starting from 0) that you want to scale in scheduled hours."
}
### RDS Instance types used in the Scale Up/Down --------------------------
variable "instance_size_1" { default = "db.t2.micro" }
variable "instance_size_2" { default = "db.t2.small" }
variable "instance_size_3" { default = "db.m3.medium" }
variable "instance_size_4" { default = "db.m4.large" }
variable "instance_size_5" { default = "db.m4.xlarge" }

### Up Scale Configurations --------------------------
variable "up_cron" {
  default = "0 15 * * 1-5"
  description = "Cron for CPU High"
}
variable "up_threshold" {
  default = "80"
  description = "CPU High Alarm threshold"
}
variable "up_evaluations" {
  default = "10"
  description = "CPU High Alarm evaluations periods"
}
variable "up_cooldown" {
  default = "10"
  description = "Cooldown for CPU High"
}
### Down Scale Configurations --------------------------
variable "down_cron" {
  default = "0 5 * * 2-6"
  description = "Cron for CPU Low"
}
variable "down_threshold" {
  default = "10"
  description = "CPU Low Alarm threshold"
}
variable "down_evaluations" {
  default = "5"
  description = "CPU Low Alarm evaluation periods"
}
variable "down_cooldown" {
  default = "60"
  description = "Cooldown for CPU Low"
}
### Credit Configurations --------------------------
variable "credit_threshold" {
  default = "2"
  description = "CPU Credits Exhausted Alarm threshold"
}
variable "credit_evaluations" {
  default = "10"
  description = "CPU Credits Exhausted Alarm evaluation periods"
}
variable "credits_cooldown" {
  default = "10"
  description = "Cooldown for Credits"
}
