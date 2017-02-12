# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# Variables
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

# * * I M P O R T A N T
# * * D O   N O T   P U T   Y O U R   A C C E S S  K E Y  H E R E * *
# Put your AWS Credential in: terraform.tfvars file
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
variable "AWS_ACCESS_KEY" {} # Do not change
variable "AWS_SECRET_KEY" {} # Do not change

# AWS Region, for this to work without noticable downtime, select a zone that
# have Multi-AZ available (and enable it on your RDS Database)
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
variable "AWS_REGION" {
  default = "us-west-2"
  description = "AWS Region where you have the RDS (remember to enable Multi-AZ)"
}

# Unique/Random for resource generation. {{timestamp}} not working?
#
# variable "timestamp_taken" { default = "{{timestamp}}" }
#
# In the mean time, will ask for a unique name, remove or change default.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
variable "timestamp_taken" {
  default = "testingnow"  # Change here for your default "unique" name ReDS.
  description = "Enter Unique Name (lowercase)"
}

# MAIN CONFIGURATION, modify defaults, or it will ask them at apply/plan time
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
variable "rds_instance" {
#  default = "your_rds_database"
  description = "RDS Instance Name to Auto-Scale"
}
variable "enabled" {
  default = true
  description = "Enable RDS Resize"
}
variable "stack_prefix" {
  default = "reds"
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
# RDS Instance types that will be used in the auto-scaling
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
variable "instance_size_1" { default = "db.t2.micro" }
variable "instance_size_2" { default = "db.t2.small" }
variable "instance_size_3" { default = "db.m3.medium" }
variable "instance_size_4" { default = "db.m4.large" }
variable "instance_size_5" { default = "db.m4.xlarge" }

# Scale UP configuration (when will your RDS scale up?)
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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

# Scale DOWN configuration (when will your RDS scale down?)
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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

# Credit alarm variables
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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

# Other defined variables
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
variable "alarm-high" {default = ""}
variable "alarm-low" {default = ""}
variable "alarm-credits" {default = ""}
