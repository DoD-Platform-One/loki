# loki

![Version: 2.10.1-bb.2](https://img.shields.io/badge/Version-2.10.1--bb.2-informational?style=flat-square) ![AppVersion: v2.4.2](https://img.shields.io/badge/AppVersion-v2.4.2-informational?style=flat-square)

Loki: like Prometheus, but for logs.

## Upstream References
* <https://grafana.com/loki>

* <https://github.com/grafana/loki>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Kubernetes: `^1.10.0-0`

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install loki chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image.repository | string | `"registry1.dso.mil/ironbank/opensource/grafana/loki"` |  |
| image.tag | string | `"2.4.2"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.pullSecrets[0] | string | `"private-registry"` |  |
| ingress.enabled | bool | `false` |  |
| ingress.annotations | object | `{}` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths | list | `[]` |  |
| ingress.tls | list | `[]` |  |
| affinity | object | `{}` |  |
| annotations | object | `{}` |  |
| tracing.jaegerAgentHost | string | `nil` |  |
| config.auth_enabled | bool | `false` |  |
| config.ingester.chunk_idle_period | string | `"3m"` |  |
| config.ingester.chunk_block_size | int | `262144` |  |
| config.ingester.flush_check_period | string | `"5s"` |  |
| config.ingester.flush_op_timeout | string | `"100m"` |  |
| config.ingester.chunk_retain_period | string | `"1m"` |  |
| config.ingester.max_transfer_retries | int | `0` |  |
| config.ingester.wal.dir | string | `"/data/loki/wal"` |  |
| config.ingester.lifecycler.ring.kvstore.store | string | `"inmemory"` |  |
| config.ingester.lifecycler.ring.replication_factor | int | `1` |  |
| config.limits_config.enforce_metric_name | bool | `false` |  |
| config.limits_config.reject_old_samples | bool | `true` |  |
| config.limits_config.reject_old_samples_max_age | string | `"168h"` |  |
| config.limits_config.unordered_writes | bool | `true` |  |
| config.schema_config.configs[0].from | string | `"2020-10-24"` |  |
| config.schema_config.configs[0].store | string | `"boltdb-shipper"` |  |
| config.schema_config.configs[0].object_store | string | `"filesystem"` |  |
| config.schema_config.configs[0].schema | string | `"v11"` |  |
| config.schema_config.configs[0].index.prefix | string | `"index_"` |  |
| config.schema_config.configs[0].index.period | string | `"24h"` |  |
| config.server.http_listen_port | int | `3100` |  |
| config.storage_config.boltdb_shipper.active_index_directory | string | `"/data/loki/boltdb-shipper-active"` |  |
| config.storage_config.boltdb_shipper.cache_location | string | `"/data/loki/boltdb-shipper-cache"` |  |
| config.storage_config.boltdb_shipper.cache_ttl | string | `"168h"` |  |
| config.storage_config.boltdb_shipper.shared_store | string | `"filesystem"` |  |
| config.storage_config.filesystem.directory | string | `"/data/loki/chunks"` |  |
| config.chunk_store_config.max_look_back_period | string | `"0s"` |  |
| config.table_manager.retention_deletes_enabled | bool | `false` |  |
| config.table_manager.retention_period | string | `"0s"` |  |
| config.compactor.working_directory | string | `"/data/loki/boltdb-shipper-compactor"` |  |
| config.compactor.shared_store | string | `"filesystem"` |  |
| extraArgs | object | `{}` |  |
| livenessProbe.httpGet.path | string | `"/ready"` |  |
| livenessProbe.httpGet.port | string | `"http-metrics"` |  |
| livenessProbe.initialDelaySeconds | int | `45` |  |
| networkPolicy.enabled | bool | `false` |  |
| networkPolicies.enabled | bool | `false` |  |
| networkPolicies.controlPlaneCidr | string | `"0.0.0.0/0"` |  |
| monitoring.enabled | bool | `false` |  |
| istio.enabled | bool | `false` |  |
| client | object | `{}` |  |
| nodeSelector | object | `{}` |  |
| persistence.enabled | bool | `false` |  |
| persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| persistence.size | string | `"10Gi"` |  |
| persistence.annotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podAnnotations."prometheus.io/scrape" | string | `"true"` |  |
| podAnnotations."prometheus.io/port" | string | `"http-metrics"` |  |
| podManagementPolicy | string | `"OrderedReady"` |  |
| rbac.create | bool | `true` |  |
| rbac.pspEnabled | bool | `true` |  |
| readinessProbe.httpGet.path | string | `"/ready"` |  |
| readinessProbe.httpGet.port | string | `"http-metrics"` |  |
| readinessProbe.initialDelaySeconds | int | `45` |  |
| replicas | int | `1` |  |
| resources.limits.cpu | string | `"300m"` |  |
| resources.limits.memory | string | `"1Gi"` |  |
| resources.requests.cpu | string | `"300m"` |  |
| resources.requests.memory | string | `"1Gi"` |  |
| securityContext.fsGroup | int | `10001` |  |
| securityContext.runAsGroup | int | `10001` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `10001` |  |
| service.type | string | `"ClusterIP"` |  |
| service.nodePort | string | `nil` |  |
| service.port | int | `3100` |  |
| service.annotations | object | `{}` |  |
| service.labels | object | `{}` |  |
| service.targetPort | string | `"http-metrics"` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `nil` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automountServiceAccountToken | bool | `true` |  |
| terminationGracePeriodSeconds | int | `4800` |  |
| tolerations | list | `[]` |  |
| podDisruptionBudget | object | `{}` |  |
| updateStrategy.type | string | `"RollingUpdate"` |  |
| serviceMonitor.enabled | bool | `false` |  |
| serviceMonitor.interval | string | `""` |  |
| serviceMonitor.additionalLabels | object | `{}` |  |
| serviceMonitor.annotations | object | `{}` |  |
| serviceMonitor.prometheusRule.enabled | bool | `false` |  |
| serviceMonitor.prometheusRule.additionalLabels | object | `{}` |  |
| serviceMonitor.prometheusRule.rules[0].alert | string | `"LokiProcessTooManyRestarts"` |  |
| serviceMonitor.prometheusRule.rules[0].expr | string | `"changes(process_start_time_seconds{job=~\"loki\"}[15m]) > 2"` |  |
| serviceMonitor.prometheusRule.rules[0].for | string | `"0m"` |  |
| serviceMonitor.prometheusRule.rules[0].labels.severity | string | `"warning"` |  |
| serviceMonitor.prometheusRule.rules[0].annotations.summary | string | `"Loki process too many restarts (instance {{ $labels.instance }})"` |  |
| serviceMonitor.prometheusRule.rules[0].annotations.description | string | `"A loki process had too many restarts (target {{ $labels.instance }})\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"` |  |
| serviceMonitor.prometheusRule.rules[1].alert | string | `"LokiRequestErrors"` |  |
| serviceMonitor.prometheusRule.rules[1].expr | string | `"100 * sum(rate(loki_request_duration_seconds_count{status_code=~\"5..\"}[1m])) by (namespace, job, route) / sum(rate(loki_request_duration_seconds_count[1m])) by (namespace, job, route) > 10"` |  |
| serviceMonitor.prometheusRule.rules[1].for | string | `"15m"` |  |
| serviceMonitor.prometheusRule.rules[1].labels.severity | string | `"critical"` |  |
| serviceMonitor.prometheusRule.rules[1].annotations.summary | string | `"Loki request errors (instance {{ $labels.instance }})"` |  |
| serviceMonitor.prometheusRule.rules[1].annotations.description | string | `"The {{ $labels.job }} and {{ $labels.route }} are experiencing errors\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"` |  |
| serviceMonitor.prometheusRule.rules[2].alert | string | `"LokiRequestPanic"` |  |
| serviceMonitor.prometheusRule.rules[2].expr | string | `"sum(increase(loki_panic_total[10m])) by (namespace, job) > 0"` |  |
| serviceMonitor.prometheusRule.rules[2].for | string | `"5m"` |  |
| serviceMonitor.prometheusRule.rules[2].labels.severity | string | `"critical"` |  |
| serviceMonitor.prometheusRule.rules[2].annotations.summary | string | `"Loki request panic (instance {{ $labels.instance }})"` |  |
| serviceMonitor.prometheusRule.rules[2].annotations.description | string | `"The {{ $labels.job }} is experiencing {{ printf \"%.2f\" $value }}% increase of panics\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"` |  |
| serviceMonitor.prometheusRule.rules[3].alert | string | `"LokiRequestLatency"` |  |
| serviceMonitor.prometheusRule.rules[3].expr | string | `"(histogram_quantile(0.99, sum(rate(loki_request_duration_seconds_bucket{route!~\"(?i).*tail.*\"}[5m])) by (le)))  > 1"` |  |
| serviceMonitor.prometheusRule.rules[3].for | string | `"5m"` |  |
| serviceMonitor.prometheusRule.rules[3].labels.severity | string | `"critical"` |  |
| serviceMonitor.prometheusRule.rules[3].annotations.summary | string | `"Loki request latency (instance {{ $labels.instance }})"` |  |
| serviceMonitor.prometheusRule.rules[3].annotations.description | string | `"The {{ $labels.job }} {{ $labels.route }} is experiencing {{ printf \"%.2f\" $value }}s 99th percentile latency\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"` |  |
| initContainers | list | `[]` |  |
| extraContainers | list | `[]` |  |
| extraVolumes | list | `[]` |  |
| extraVolumeMounts | list | `[]` |  |
| extraPorts | list | `[]` |  |
| env | list | `[]` |  |
| alerting_groups | list | `[]` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
