# Cost Tradeoffs

This project is intentionally designed to show that scaling OLTP is not the default answer.

## RDS vs Aurora (OLTP)

**Chose RDS MySQL for this lab** because the workload is predictable and the goal is architectural separation, not maximum throughput.

- **RDS MySQL**: lower baseline cost, simpler mental model for a steady OLTP workload.
- **Aurora MySQL**: can justify higher cost when you need faster failover, higher throughput, or multi-AZ behavior optimized for strict SLAs.

Decision rule:

- If the business needs higher throughput or faster recovery and can justify cost, consider Aurora.
- If the goal is stability and cost control with known load patterns, RDS is sufficient.

## Athena vs Redshift (Analytics)

**Chose Athena** because analytics here are:

- aggregated exports
- ad-hoc querying
- small-to-medium data volumes

- **Athena**: serverless, pay-per-scan, great for occasional queries.
- **Redshift**: better when you have sustained high-volume analytics, many concurrent users, or complex warehouse workloads.

Decision rule:

- If queries are occasional and dataset is moderate, Athena keeps cost low and ops minimal.
- If queries are frequent, heavy, and business-critical, Redshift can be more predictable and performant.

## Why offload instead of scaling OLTP

Scaling OLTP to “handle reporting” increases:

- cost (bigger instances, more IOPS, more risk)
- blast radius (analytics can degrade transactions)
- operational noise (CPU spikes, lock contention, connection storms)

Offloading analytics isolates risk and keeps OLTP latency predictable.
