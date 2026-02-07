# Pipeline Impact

Analytics pipelines are not neutral. They consume database resources and can harm OLTP performance if designed poorly.

## Key risks to OLTP

- **IOPS pressure**: exports that scan large tables increase disk reads and can affect write latency.
- **Replica lag**: heavy reads can slow replica apply and increase lag.
- **Connection spikes**: poorly scheduled jobs can exhaust connection limits.
- **Locking side effects**: long-running queries can increase undo/redo pressure and interfere with transactional patterns.

## Mitigations used in this project

- Run export queries against the **read replica**, not the OLTP primary.
- Export **aggregates**, not raw tables, to reduce scan volume and cost.
- Keep exports bounded (example: last 30 days) and schedule off-peak in real environments.
- Prefer incremental approaches over full-table scans as data grows.

## Operational signals to watch

- OLTP: CPUUtilization, DatabaseConnections, ReadIOPS/WriteIOPS, FreeStorageSpace
- Replica: ReplicaLag (or equivalent), CPUUtilization, ReadIOPS
- Export job: duration, rows processed, failures/retries

## Design principle

Treat pipelines as first-class consumers of database resources.
A “successful” pipeline that degrades OLTP is a platform failure.
