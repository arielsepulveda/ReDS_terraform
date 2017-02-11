import boto3
import yaml
import datetime
import croniter
import pytz


class reds:

    def __init__(self):
        self.rds_client = None
        self.cloudwatch_client = None
        self.now = None
        self.vars = None
        self.alarms = None
        self.in_scheduled_up = None
        self.details = None
        self.alarm_status = None
        self.execute = None
        self.events = None
        self.result = None
        self.on_index = None

    def lambda_startup(self):
        self.rds_client = boto3.client('rds')
        self.cloudwatch_client = boto3.client('cloudwatch')

        self.now = datetime.datetime.utcnow()

        self.set_vars(
            yaml.load(file('vars.yaml')), yaml.load(file('alarms.yaml')))

        self.process(
            self.rds_client.describe_db_instances(
                DBInstanceIdentifier=self.vars['rds_identifier']
            )['DBInstances'][0],
            self.cloudwatch_client.describe_alarms(
                AlarmNames=[
                    self.alarms['alarm_high'],
                    self.alarms['alarm_low'],
                    self.alarms['alarm_credits'],
                ]),
            self.rds_client.describe_events(
                SourceIdentifier=self.vars['rds_identifier'],
                SourceType="db-instance",
                EventCategories=[
                    "configuration change"
                ])
        )

    def testing_startup(self, _vars, _alarms, _details, _alarm_status, _events):
        self.now = datetime.datetime.utcnow()
        self.set_vars(_vars, _alarms)
        self.process(_details, _alarm_status, _events, False)
        self.print_logs()

    def set_vars(self, _vars, _alarms):
        self.vars = _vars
        self.alarms = _alarms

    def abort(self, msg):
        self.result['Action'] = 'NO_ACTION'
        self.result['Message'] = msg
        self.result['Logs'].append(
            "{}: {}".format(self.result['Action'], self.result['Message']))
        return self.result

    def info(self, msg):
        self.result['Logs'].append("{}: {}".format("INFO", msg))

    def success(self, msg):
        self.result['Action'] = 'RESIZE'
        self.result['Message'] = msg
        self.result['Logs'].append(
            "{}: {}".format(self.result['Action'], self.result['Message']))
        return self.result

    def process(self, _details, _alarm_status, _events, _execute=True):
        self.in_scheduled_up = False

        self.result = {
            "Action": None,
            "Message": None,
            "Logs": []
        }

        self.details = _details
        self.alarm_status = _alarm_status
        self.events = _events
        self.execute = _execute

        self.info("Startup Time: {}".format(self.now.utcnow()))
        self.info("Configured instance sizes: {}".format(
            self.vars['instance_sizes']))

        self.info("RDS {} size/status/MultiAZ: {}/{}/{}".format(
            self.vars['rds_identifier'], self.details['DBInstanceClass'],
            self.details['DBInstanceStatus'], self.details['MultiAZ']))

        if self.details['DBInstanceStatus'] != 'available':
            return self.abort("In middle of an operation already!")

        if not self.details['MultiAZ']:
            return self.abort("Unable to work on singleAZ RDS!")

        try:
            self.on_index = self.vars['instance_sizes'].index(
                self.details['DBInstanceClass'])
            self.info("DB pointer (0-{}) is currently on {}".format(
                len(self.vars['instance_sizes'])-1, self.on_index))
        except ValueError:
            return self.abort("Instance size not in list!")

        if self.vars['schedule_enabled']:
            self.info("Checking to see if we are in a scheduled uptime")

            cron_up = croniter.croniter(
                self.vars['scale_up']['cron'], self.now)
            prev_up_exec = cron_up.get_prev(datetime.datetime)
            next_up_exec = cron_up.get_next(datetime.datetime)

            cron_down = croniter.croniter(
                self.vars['scale_down']['cron'], self.now)
            prev_down_exec = cron_down.get_prev(datetime.datetime)
            next_down_exec = cron_down.get_next(datetime.datetime)

            self.info("Prev CRON Up {}".format(prev_up_exec))
            self.info("Prev CRON Down {}".format(prev_down_exec))
            self.info("Next CRON Up {}".format(next_up_exec))
            self.info("Next CRON Down {}".format(next_down_exec))

            self.info("Current Time {}".format(self.now))

            if prev_down_exec < prev_up_exec < next_down_exec < next_up_exec \
                    and prev_up_exec < self.now < next_down_exec:
                self.in_scheduled_up = True
                self.info("In middle of a scheduled uptime! " +
                          "PrevUp/Current/NextDown {}/{}/{}".format(
                              prev_up_exec,
                              self.now,
                              next_down_exec
                          ))
                try:
                    up_db = self.vars['instance_sizes'][
                        self.vars['scheduled_index']]
                except IndexError:
                    return self.abort("invalid scheduled_index")
                self.info("Min allowed instance size is: {}".format(up_db))
                if self.on_index < self.vars['scheduled_index']:
                    self.info("Running scheduled scale up to {}".format(
                        self.vars['instance_sizes'][self.vars['scheduled_index']]))
                    return self.scale('scale_up', self.vars['scheduled_index'])
            else:
                self.info("Not in middle of a scheduled uptime")
        else:
            self.info("Scheduling not enabled")

        self.info("Checking alarm statuses")

        if self.details['DBInstanceClass'].startswith('db.t') and \
                self.alarm_status['MetricAlarms'][2]['StateValue'] == 'ALARM':
            self.info("CPU-Credit-Low Alarm status is: ALARM")
            self.info("Attempting scale up to next non (T) instance")
            for dbtype in self.vars['instance_sizes'][int(self.on_index+1):]:
                if not dbtype.startswith('db.t'):
                    return self.scale('credits', self.vars['instance_sizes'].index(dbtype))
            self.info("No non-T instance found above current size!")

        if self.alarm_status['MetricAlarms'][0]['StateValue'] == 'ALARM':
            self.info("High-CPU Alarm status is: ALARM")
            self.info("Attempting scale up one size!")
            return self.scale('scale_up', int(self.on_index+1))

        if self.alarm_status['MetricAlarms'][1]['StateValue'] == 'ALARM':
            self.info("Low-CPU Alarm status is: ALARM")
            self.info("Attempting scale down one size!")
            return self.scale('scale_down', int(self.on_index-1))

        return self.abort("Nothing to do")

    def assert_cooldown_expired(self, reason):
        cooldown = self.vars[reason]['cooldown']
        self.info(
            "cooldown period (minutes) for {} is {}".format(reason, cooldown))
        for mod in self.events['Events'][::-1]:
            if mod['Message'].startswith("Finished applying modification to DB instance class"):
                delta_time = self.now.replace(tzinfo=pytz.utc) - mod['Date']
                delta_time_calculated = divmod(
                    delta_time.days * 86400 + delta_time.seconds, 60)
                self.info("Last finished modification {} Diff: (Min, Sec): {}".format(
                    mod['Date'], delta_time_calculated))
                if delta_time_calculated[0] < cooldown:
                    self.info("Not enough time has passed since last modification ({})".format(
                        cooldown))
                    return False
                break
        return True

    def scale(self, reason, to_index=None):
        if not self.vars['enabled']:
            return self.abort("Resizing disabled")
        if 0 <= to_index < len(self.vars['instance_sizes']):
            if self.in_scheduled_up and to_index < self.vars['scheduled_index']:
                return self.abort("Already at bottom for size during scheduled scale up")
            self.info(
                "Scaling to {}".format(self.vars['instance_sizes'][to_index]))
            if not self.assert_cooldown_expired(reason):
                return self.abort("{} Cooldown threshold not reached".format(reason))
            if self.execute:
                self.info("Executing scale command")
            else:
                self.info("Skipping scale command per passed in param")
            return self.success(self.vars['instance_sizes'][to_index])
        else:
            return self.abort("Unable to scale - invalid to_index: {}".format(to_index))

    def lambda_apply_action(self):
        if self.result['Action'] == 'RESIZE':
            amz_res = self.rds_client.modify_db_instance(
                DBInstanceIdentifier=self.vars['rds_identifier'],
                DBInstanceClass=self.result['Message'],
                ApplyImmediately=True)
            self.info("AMZ response {}".format(amz_res))

    def print_logs(self):
        for log in self.result['Logs']:
            print(log)


def lambda_handler(context, event):
    red = reds()
    red.lambda_startup()
    red.lambda_apply_action()
    red.print_logs()
