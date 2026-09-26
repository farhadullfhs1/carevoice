import json
import logging


logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    """
    AWS Lambda entry point.

    This function will eventually be invoked by Amazon Lex V2.
    """

    logger.info("CareVoice Lambda invoked")

    logger.info(
        "Received event: %s",
        json.dumps(event, default=str)
    )

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "CareVoice Lambda is working"
        })
    }
