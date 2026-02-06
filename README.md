## OLTP + Analytics Offload on AWS (RDS MySQL → S3 → Athena)

### Goal

Protect OLTP latency by preventing analytics/reporting queries from competing with transactional workload. Instead of scaling the OLTP database, analytics are offloaded to an independent query layer.

### Architecture

- OLTP: Amazon RDS MySQL (writes + transactional reads)
- Buffer: RDS read replica for analytics-safe reads and exports
- Analytics storage: Amazon S3 (CSV aggregates)
- Analytics query layer: Amazon Athena (serverless SQL over S3)

### What I proved

- Workload separation: analytics queries do not hit the OLTP instance
- Design tradeoffs: offload vs scale-up, RDS vs Aurora, Athena vs Redshift
- Pipeline impact awareness: exports are consumers of DB resources, so they run against the replica

### Evidence

- Athena preview of exported aggregates: `screenshots/athena_orders_agg_preview.png`
- Athena revenue-by-day query results: `screenshots/athena_revenue_by_day.png`

### Cleanup

This lab is designed to be fully destroyable to avoid ongoing AWS cost.
