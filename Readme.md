This small project allows Resque queue sizes and failed queue lengths to be exported as Prometheus metrics.

### Enrivonment Variables

- `METRICS_PREFIX` (default: `''`): Allows to prepend the metrics with a prefix
- `METRICS_LABELS` (default: `"{}"`): Allows you to set any labels you might want, takes it in JSON format

### Dockerfile

It is available as a Dockerfile under `nambrot/resque-prometheus-exporter`, the default command `rackup` should open at port `9292`
