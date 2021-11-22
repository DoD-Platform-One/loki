# loki

![Version: 2.5.1-bb.2](https://img.shields.io/badge/Version-2.5.1--bb.2-informational?style=flat-square) ![AppVersion: v2.3.0](https://img.shields.io/badge/AppVersion-v2.3.0-informational?style=flat-square)

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
| image.repository | string | `"registry1.dso.mil/ironbank/opensource/grafana/grafana-loki"` |  |
| image.tag | string | `"2.3.0"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.pullSecrets[0] | string | `"private-registry"` |  |
| ingress.enabled | bool | `false` |  |
| ingress.annotations | object | `{}` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths | list | `[]` |  |
| ingress.tls | list | `[]` |  |
| imagePullSecrets | object | `{}` |  |
| affinity | object | `{}` |  |
| annotations | object | `{}` |  |
| tracing.jaegerAgentHost | string | `nil` |  |
| config.auth_enabled | bool | `false` |  |
| config.ingester.chunk_idle_period | string | `"3m"` |  |
| config.ingester.chunk_block_size | int | `262144` |  |
| config.ingester.chunk_retain_period | string | `"1m"` |  |
| config.ingester.max_transfer_retries | int | `0` |  |
| config.ingester.lifecycler.ring.kvstore.store | string | `"inmemory"` |  |
| config.ingester.lifecycler.ring.replication_factor | int | `1` |  |
| config.limits_config.enforce_metric_name | bool | `false` |  |
| config.limits_config.reject_old_samples | bool | `true` |  |
| config.limits_config.reject_old_samples_max_age | string | `"168h"` |  |
| config.schema_config.configs[0].from | string | `"2020-10-24"` |  |
| config.schema_config.configs[0].store | string | `"boltdb-shipper"` |  |
| config.schema_config.configs[0].object_store | string | `"filesystem"` |  |
| config.schema_config.configs[0].schema | string | `"v11"` |  |
| config.schema_config.configs[0].index.prefix | string | `"index_"` |  |
| config.schema_config.configs[0].index.period | string | `"24h"` |  |
| config.server.http_listen_port | int | `3100` |  |
| config.storage_config.boltdb_shipper.active_index_directory | string | `"/data/loki/boltdb-shipper-active"` |  |
| config.storage_config.boltdb_shipper.cache_location | string | `"/data/loki/boltdb-shipper-cache"` |  |
| config.storage_config.boltdb_shipper.cache_ttl | string | `"24h"` |  |
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
| resources.limits.cpu | string | `"250m"` |  |
| resources.limits.memory | string | `"256Mi"` |  |
| resources.requests.cpu | string | `"250m"` |  |
| resources.requests.memory | string | `"256Mi"` |  |
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
| initContainers | list | `[]` |  |
| extraContainers | list | `[]` |  |
| extraVolumes | list | `[]` |  |
| extraVolumeMounts | list | `[]` |  |
| extraPorts | list | `[]` |  |
| env | list | `[]` |  |
| alerting_groups | list | `[]` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
