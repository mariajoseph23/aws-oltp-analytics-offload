import csv
import os
from datetime import datetime

import boto3
import mysql.connector

DB_HOST = os.environ.get("REPLICA_HOST") or os.environ.get("OLTP_HOST")
DB_USER = os.environ["DB_USER"]
DB_PASS = os.environ["DB_PASS"]
DB_NAME = os.environ.get("DB_NAME", "appdb")

S3_BUCKET = os.environ["S3_BUCKET"]
EXPORT_PREFIX = os.environ.get("EXPORT_PREFIX", "exports/orders_agg/")


def main():
    if not DB_HOST:
        raise SystemExit("Missing REPLICA_HOST or OLTP_HOST")
    if not S3_BUCKET:
        raise SystemExit("Missing S3_BUCKET")

    cn = mysql.connector.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        database=DB_NAME,
    )
    cur = cn.cursor()

    # Aggregate last 30 days into a small CSV suited for Athena.
    query = """
    SELECT
      status,
      DATE(created_at) AS day,
      COUNT(*) AS orders,
      ROUND(SUM(order_total), 2) AS revenue
    FROM orders
    WHERE created_at >= UTC_TIMESTAMP() - INTERVAL 30 DAY
    GROUP BY status, DATE(created_at)
    ORDER BY day DESC, status;
    """
    cur.execute(query)

    rows = cur.fetchall()
    headers = ["status", "day", "orders", "revenue"]

    ts = datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")
    key = f"{EXPORT_PREFIX}orders_agg_{ts}.csv"

    # Write CSV locally first (small file)
    tmp_path = f"/tmp/orders_agg_{ts}.csv"
    with open(tmp_path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(headers)
        for r in rows:
            w.writerow(r)

    s3 = boto3.client("s3")
    s3.upload_file(tmp_path, S3_BUCKET, key)

    print(f"Exported {len(rows)} rows to s3://{S3_BUCKET}/{key}")

    cur.close()
    cn.close()


if __name__ == "__main__":
    main()
