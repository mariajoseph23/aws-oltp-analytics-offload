-- Use the Glue catalog database created by Terraform
-- If it doesn't show up in Athena immediately, wait 1-2 minutes and refresh.
CREATE DATABASE IF NOT EXISTS oltp_analytics_offload;

DROP TABLE IF EXISTS oltp_analytics_offload.orders_agg;

CREATE EXTERNAL TABLE oltp_analytics_offload.orders_agg (
  status string,
  day date,
  orders int,
  revenue double
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar'     = '\"',
  'escapeChar'    = '\\'
)
LOCATION 's3://oltp-analytics-offload-549460685609/exports/orders_agg/'
TBLPROPERTIES ('skip.header.line.count'='1');

-- Sanity check
SELECT * FROM oltp_analytics_offload.orders_agg
LIMIT 10;

-- Example analytics query (Athena, not OLTP)
SELECT day, SUM(revenue) AS total_revenue
FROM oltp_analytics_offload.orders_agg
GROUP BY day
ORDER BY day DESC
LIMIT 15;
