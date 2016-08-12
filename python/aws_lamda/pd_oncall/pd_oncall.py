#!/usr/bin/env python

import requests
import json
import datetime

API_KEY      = 'PAGERDUTY_API_KEY'
SCHEDULE_IDS = ['ABCDEFG']

class OnCall(object):
    def __init__(self, api_key, schedule_ids):
        self.api_key      = api_key
        self.schedule_ids = schedule_ids

    @staticmethod
    def schedules_url(schedule_id):
        return 'https://api.pagerduty.com/schedules/' + schedule_id

    @staticmethod
    def user_url(schedule_id):
        return 'https://api.pagerduty.com/schedules/' + schedule_id + '/users'

    def run(self):
        headers = {
            'Accept': 'application/vnd.pagerduty+json;version=2',
            'Authorization': 'Token token=' + self.api_key
        }
        payload = {
            'since' : datetime.datetime.now().isoformat(),
            'until' : datetime.datetime.now().isoformat()
        }

        oncall_list = []

        for schedule_id in self.schedule_ids:
          user     = requests.get(OnCall.user_url(schedule_id), headers=headers, params=payload).json()
          schedule = requests.get(OnCall.schedules_url(schedule_id), headers=headers, params=payload).json()

          oncall_list.append("{0}: {1}".format(schedule['schedule']['summary'], user['users'][0]['name']))

        # print '\n'.join(oncall_list)
        return oncall_list

def lambda_handler(event, context):
    """
    Main entry point for AWS Lambda.
    Variables can not be passed in to AWS Lambda, the configuration parameters below are encrypted using AWS IAM Keys.
    """
    # Boto is always available in AWS lambda, but may not be available in standalone mode
#    import boto3
#    from base64 import b64decode

    # To generate the encrypted values, go to AWS IAM Keys and Generate a key
    # Then grant decryption using the key to the IAM Role used for your lambda function.
    #
    # Use the command `aws kms encrypt --key-id alias/<key-alias> --plaintext <value-to-encrypt>
    # Put the encrypted value in the configuration dictionary below
#    encrypted_config = {
#        'pagerduty_api_key': '<ENCRYPTED VALUE>',
#        'schedule_ids':      '<ENCRYPTED VALUE>'
#    }

#    kms = boto3.client('kms')
#    config = {x: kms.decrypt(CiphertextBlob=b64decode(y))['Plaintext'] for x, y in encrypted_config.iteritems()}
    on_call = OnCall(API_KEY, SCHEDULE_IDS)
    output = on_call.run()

    return { "response_type": "in_channel", "text": '\n'.join(output) }

def main():
    """
    Runs OnCall check as a standalone script
    """
    on_call = OnCall(API_KEY, SCHEDULE_IDS)
    on_call.run()

if __name__ == '__main__':
    main()
