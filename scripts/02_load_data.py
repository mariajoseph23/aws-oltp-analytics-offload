import os
import random
import time
from datetime import datetime, timedelta

import mysql.connector
from mysql.connector import Error

DB_HOST = os.environ.get("OLTP_HOST") or os.environ.get("DB_HOST")
DB_USER = os.environ["DB_USER"]
DB_PASS = os.environ["DB_PASS"]

DB_NAME = os.environ.get("DB_NAME", "appdb")

TOTAL_ROWS = int(os.environ.get("TOTAL_ROWS", "200000"))
BATCH_SIZE = int(os.environ.get("BATCH_SIZE", "2000"))

STATUSES = ["NEW", "PAID", "SHIPPED", "CANCELLED"]


def connect_with_retry(max_attempts: int = 12, sleep_seconds: int = 10):
    last_err = None
    for attempt in range(1, max_attempts + 1):
        try:
            cn = mysql.connector.connect(
                host=DB_HOST,
                user=DB_USER,
                password=DB_PASS,
                database=DB_NAME,
                connection_timeout=10,
            )
            return cn
        except Error as e:
            last_err = e
            print(f"[connect] attempt {attempt}/{max_attempts} failed: {e}")
            time.sleep(sleep_seconds)
    raise last_err


def main():
    if not DB_HOST:
        raise SystemExit("Missing DB_HOST/OLTP_HOST environment variable")

    cn = connect_with_retry()
    cn.autocommit = False
    cur = cn.cursor()

    now = datetime.utcnow()

    for i in range(0, TOTAL_ROWS, BATCH_SIZE):
        rows = []
        for _ in range(BATCH_SIZE):
            customer_id = random.randint(1, 50_000)
            status = random.choice(STATUSES)
            order_total = round(random.uniform(10, 500), 2)
            created_at = now - timedelta(
                days=random.randint(0, 60),
                seconds=random.randint(0, 86400),
            )
            rows.append((customer_id, status, order_total, created_at))

        cur.executemany(
            "INSERT INTO orders(customer_id,status,order_total,created_at) VALUES (%s,%s,%s,%s)",
            rows,
        )
        cn.commit()
        print(f"Inserted {min(i + BATCH_SIZE, TOTAL_ROWS)} / {TOTAL_ROWS}")

    cur.close()
    cn.close()


if __name__ == "__main__":
    main()
