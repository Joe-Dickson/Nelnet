import json


def hello(event, context):
    body = {
        "message": "Hello Nelnet"
    }

    return {"statusCode": 200, "body": json.dumps(body)}
