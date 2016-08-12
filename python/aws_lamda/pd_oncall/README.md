## PagerDuty On Call

PoC Script to find out who is currently on call from PagerDuty.

AWS Lambda Function for a Slack Slash Command.
Currently Slack times out on 3 seconds so production script should run on intervals and cache data in DynomoDB

### Setup

`make setup`

### Deployment

```
# Remove old files
make clean

# Make a new package.zip
make package
```

Then upload to the AWS Lambda function.
