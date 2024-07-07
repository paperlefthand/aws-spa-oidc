import json

from aws_lambda_powertools import Logger

logger = Logger()


@logger.inject_lambda_context(log_event=True)
def lambda_handler(event, context):
    logger.info(event)
    response = {
        "statusCode": 200,
        "body": json.dumps(
            {
                "message": "personal data",
            }
        ),
    }
    return response
