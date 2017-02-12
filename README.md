# ReDS

### Terraform - Auto-Scale for RDS Instances

This is based on [The Reactive Database System](http://mediatemple.net/blog/tips/the-reactive-database-system-letting-the-cloud-help-you/) by Dan Billeci.

** Current STATUS : Under Testing

To try this on your RDS:
- clone this git.
- Rename terraform.tfvars.example to terraform.tfvars
- Configure your AWS access in terraform.tfvars
- Edit vars.tf
-- Change the AWS Region (use any with Multi-AZ enabled)
-- Change the timestamp_taken variable to some unique name or timestamp
-- Uncomment and configure rds_instance var, or leave as this (it will ask at runtime)
-- Feel free to change other variables for your needs (threshold, crons, etc)
- Run terraform get for modules, plan to check, and apply.
```
# terraform get
# terraform plan
# terraform apply
```
I hope you find this useful.
Ariel Sepulveda | cascompany AT gmail.com
