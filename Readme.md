This small project allows Resque queue sizes and failed queue lengths to be exported as Prometheus metrics.

### Enrivonment Variables

- `METRICS_PREFIX` (default: `''`): Allows to prepend the metrics with a prefix
- `METRICS_LABELS` (default: `"{}"`): Allows you to set any labels you might want, takes it in JSON format
