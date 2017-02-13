# ReDS - ReActive Database System

### Terraform - Auto-Scale for RDS Instances
##### This can save you up to 50% on your RDS costs, and keep your DB online with traffic spikes

This is based on [The Reactive Database System](http://mediatemple.net/blog/tips/the-reactive-database-system-letting-the-cloud-help-you/) by Dan Billeci.

![reds](https://cloud.githubusercontent.com/assets/20051003/22879727/9cda7ed2-f1df-11e6-817e-48f3b27b62f3.jpg)


**Current STATUS : TESTED OK**
- Autoscale up & down is working.
  If you want to test, make sure you use small cooldown/thresold values, otherwise
  it will take 1 hour to scale down for example.

**NOTE:** You will need to enable Multi-AZ on your RDS DB for this script to work,
it will not autoscale databases without Multi-AZ enabled.

To try this on your RDS:
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

I hope you find this useful to be done in Terraform, you also have the original (cloudformation/ansible) version.

Best Regards,
Ariel Sepulveda | cascompany AT gmail.com
