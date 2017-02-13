# ReDS - ReActive Database System
## Terraform - Auto-Scale for RDS Instances
### This can save you up to 50% on your RDS costs, and avoid headaches on traffic spikes!

![reds](https://cloud.githubusercontent.com/assets/20051003/22879727/9cda7ed2-f1df-11e6-817e-48f3b27b62f3.jpg)

### Features

- Can be used on any RDS database or project.
- Automatically increases or decreases RDS instance, based on CPU too high or low.
- Have schedule mode with cron, so you can go bigger on weekday and back down at nights or weekends.
- Handles credit balance on T2 instances, to upgrade to M/R if they run out of credits.
- 100% configurable (thresholds, cooldowns, cron, resource names, etc)
- Creates and uses CloudWatch alarms to determine when it needs to scale.
- Output logs to CloudWatch logs for review
- Built using security and IAM roles, maintains your infrastructure secure.
- Simple terraform script you can apply/destroy with a single command.
- Intangible cost to operate, it runs aprox. 300,000 sec/month and no more than 40Mb (free tier)
- Will provide BIG savings over night or weekends (going m4.large to t2.small for example)
- Based on the [Reactive Database System](http://mediatemple.net/blog/tips/the-reactive-database-system-letting-the-cloud-help-you/) by Dan Billeci.

### Status

Fully working, scale up / down or by schedule, or both.
If you want to test, make sure you configure cooldown/thresold values to not
have to wait and hour for downscale for example.

**NOTE:** You will need to enable Multi-AZ on your RDS DB for this script to work,
it will not autoscale databases without Multi-AZ enabled.

### How to use

- Clone this GitHub.
- Rename terraform.tfvars.example to terraform.tfvars
- Configure your AWS access in terraform.tfvars
  * You will need an AWS Access Key and Secret Key (admin)
  * You need to use a Multi-AZ capable AWS Region, and enable Multi-AZ the RDS.
  * You can use Reactive (CPU driven) or Scheduled (Cron) Auto Scale.
  * You can select the instance sizes you want to use.
  * Configure up/down/credits thresholds, evaluations and cooldown for your needs.
- Install [Terraform](https://www.terraform.io/intro/getting-started/install.html) if needed.
- Run terraform get to install modules.
- Run terraform plan to see what will be done.
- Run terraform apply to make the real changes and enable Auto Scale on your RDS.
```
# terraform get
# terraform plan
# terraform apply
```

### Some example Lambda log and explanation.
In this example, RDS was running on db.t2.small, Low-CPU status was triggered,
and lambda has not done any scale down in the last 45 min (cooldown), so it
goes ahead and resize the instance to db.t2.micro (DB pointer 0).

```
01:47:27 START RequestId: 5fc4029e-f18e-11e6-975c-d54a6973df45 Version: $LATEST
01:47:29 INFO: Startup Time: 2017-02-13 01:47:28.705375
01:47:29 INFO: Configured instance sizes: ['db.t2.micro', 'db.t2.small', 'db.m3.medium', 'db.m4.large', 'db.m4.xlarge']
01:47:29 INFO: RDS reds2 size/status/MultiAZ: db.t2.small/available/True
01:47:29 INFO: DB pointer (0-4) is currently on 1
01:47:29 INFO: Scheduling not enabled
01:47:29 INFO: Checking alarm statuses
01:47:29 INFO: Low-CPU Alarm status is: ALARM
01:47:29 INFO: Attempting scale down one size!
01:47:29 INFO: Scaling to db.t2.micro
01:47:29 INFO: cooldown period (minutes) for scale_down is 45
01:47:29 INFO: Executing scale command
01:47:29 RESIZE: db.t2.micro
01:47:29 INFO: AMZ response {u'DBInstance': {u'PubliclyAccessible': True, u'MasterUsername': 'admin', u'MonitoringInterval': 5, u'LicenseModel': 'general-public-license', u'VpcSecurityGroups': [{u'Status': 'active', u'VpcSecurityGroupId': 'sg-3f157c47'}], u'InstanceCreateTime': datetime.datetime(2017, 2, 12, 23, 32, 57, 514000, tzinfo=tzlocal()), u'CopyTagsToSnapshot': False, u'OptionGroupMemberships': [{u
01:47:29 END RequestId: 5fc4029e-f18e-11e6-975c-d54a6973df45
01:47:29 REPORT RequestId: 5fc4029e-f18e-11e6-975c-d54a6973df45	Duration: 1772.42 ms	Billed Duration: 1800 ms Memory Size: 128 MB	Max Memory Used: 41 MB
```

### Example savings

##### Standard Setup (without ReDS) – High Performance required 24/7:

M4.large – 100% monthly use: $261
[- Amazon Calculator -](https://calculator.s3.amazonaws.com/index.html#r=PDX&s=RDS&key=calc-A2583B0A-0A08-48AE-A84F-86344E9723CD)

##### ReDS Setup – High Performance during peak hours, with evenings lower + weekends lowest:

M4.large – 24% monthly use (M-F 9-5): $67
T2.medium – 50% monthly use (M-F off hours): $55
T2.small – 26% monthly use (Sat/Sun all day): $18

[- Amazon Calculator -](https://calculator.s3.amazonaws.com/index.html#r=IAD&s=RDS&key=calc-2451517A-F680-4AEF-AEE6-A9C1F2EFCAF8)

In this example, you will save
# 47% of your monthly RDS Cost

I hope you found this useful and easy in Terraform.

Best Regards,
Ariel Sepulveda | cascompany AT gmail.com
