"""S3 アップロードイベントを受けてオブジェクトメタデータを処理するサンプル Lambda。"""

import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

LOG_BUCKET_NAME = os.environ["LOG_BUCKET_NAME"]


def handler(event: dict, context: dict) -> dict:
    for record in event.get("Records", []):
        s3 = record["s3"]
        metadata = {
            "bucket": s3["bucket"]["name"],
            "key": s3["object"]["key"],
            "size": s3["object"].get("size", 0),
            "event_name": record.get("eventName", ""),
        }
        logger.info("processed %s", json.dumps(metadata))

    return {"processed": len(event.get("Records", []))}
