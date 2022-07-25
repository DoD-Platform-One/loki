# loki

![Version: 4.0.0-bb.0](https://img.shields.io/badge/Version-4.0.0--bb.0-informational?style=flat-square) ![AppVersion: v2.6.0](https://img.shields.io/badge/AppVersion-v2.6.0-informational?style=flat-square)

BigBang amalgamation of Grafana upstream charts to provide several ways of deploying Loki; like Prometheus, but for logs.

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
| global.image.priorityClassName | string | `nil` |  |
| global.image.pullPolicy | string | `"IfNotPresent"` |  |
| global.image.pullSecrets[0] | string | `"private-registry"` |  |
| global.createGlobalConfig | bool | `false` | Create Loki config for all sub-charts. Uses data within 'global.config' value |
| global.existingSecretForConfig | string | `""` | Secret which Pods will consume for config. Only use if 'global.createGlobalConfig' is true or you have a pre-existing Secret. BigBang createGlobalConfig creates Secret: "loki-config" |
| global.auth_enabled | bool | `false` | Should authentication be enabled |
| global.storage.bucketNames | object | `{"admin":"admin","chunks":"loki","ruler":"loki"}` | Values for external storage like S3 & GCS Buckets, also can set `local` storage configuration |
| global.storage.type | string | `"s3"` |  |
| global.storage.s3.s3 | string | `nil` |  |
| global.storage.s3.endpoint | string | `nil` | Endpoint for External ObjectStorage configuration |
| global.storage.s3.region | string | `nil` | Region for External ObjectStorage configuration |
| global.storage.s3.secretAccessKey | string | `nil` | AWS secret_access_key for External ObjectStorage configuration |
| global.storage.s3.accessKeyId | string | `nil` | AWS access_key_id for External ObjectStorage configuration |
| global.storage.s3.s3ForcePathStyle | bool | `true` | Force S3 path style for ObjectStorage configuration |
| global.storage.s3.insecure | bool | `false` | Toggle insecure for ObjectStorage configuration |
| global.storage.gcs.chunkBufferSize | int | `0` |  |
| global.storage.gcs.requestTimeout | string | `"0s"` |  |
| global.storage.gcs.enableHttp2 | bool | `true` |  |
| global.storage.local.chunks_directory | string | `"/var/loki/chunks"` |  |
| global.storage.local.rules_directory | string | `"/var/loki/rules"` |  |
| global.schemaConfig | object | `{}` | Check https://grafana.com/docs/loki/latest/configuration/#schema_config for more info on how to configure schemas |
| global.structuredConfig | object | `{}` | Structured loki configuration, takes precedence over `loki.config`, `loki.schemaConfig`, `loki.storageConfig` |
| global.query_scheduler | object | `{}` | Additional query scheduler config |
| global.storage_config | object | `{"boltdb_shipper":{"active_index_directory":"/var/loki/boltdb-shipper-active","cache_location":"/var/loki/boltdb-shipper-cache","cache_ttl":"24h","shared_store":"s3"},"hedging":{"at":"250ms","max_per_second":20,"up_to":3}}` | Additional storage config |
| global.commonConfig.path_prefix | string | `"/var/loki"` |  |
| global.commonConfig.ring.kvstore.store | string | `"memberlist"` |  |
| global.memcached | object | `{"chunk_cache":{"batch_size":256,"enabled":false,"host":"","parallelism":10,"service":"memcached-client"},"results_cache":{"default_validity":"12h","enabled":false,"host":"","service":"memcached-client","timeout":"500ms"}}` | Configure memcached as an external cache for chunk and results cache. Disabled by default must enable and specify a host for each cache you would like to use. |
| global.enterprise.enabled | bool | `false` | Enable enterprise features, license must be provided |
| global.config | string | `"{{- if .Values.global.enterprise.enabled}}\n{{- tpl (index .Values \"loki-simple-scalable\" \"enterprise\" \"config\") . }}\n{{- else }}\nauth_enabled: {{ .Values.global.auth_enabled }}\n{{- end }}\n\nserver:\n  http_listen_port: 3100\n  grpc_listen_port: 9095\n\nmemberlist:\n  join_members:\n    - {{ include \"loki.name\" . }}-memberlist\n\n{{- if .Values.global.commonConfig}}\ncommon:\n{{- toYaml .Values.global.commonConfig | nindent 2}}\n  storage:\n  {{- include \"loki.commonStorageConfig\" . | nindent 4}}\n{{- end}}\n\nlimits_config:\n  enforce_metric_name: false\n  reject_old_samples: true\n  reject_old_samples_max_age: 168h\n  max_cache_freshness_per_query: 10m\n  split_queries_by_interval: 15m\n\n{{- with .Values.global.memcached.chunk_cache }}\n{{- if and .enabled .host }}\nchunk_store_config:\n  chunk_cache_config:\n    memcached:\n      batch_size: {{ .batch_size }}\n      parallelism: {{ .parallelism }}\n    memcached_client:\n      host: {{ .host }}\n      service: {{ .service }}\n{{- end }}\n{{- end }}\n\n{{- if .Values.global.schemaConfig}}\nschema_config:\n{{- toYaml .Values.global.schemaConfig | nindent 2}}\n{{- else }}\nschema_config:\n  configs:\n    - from: 2022-01-11\n      store: boltdb-shipper\n      {{- if eq .Values.global.storage.type \"s3\" }}\n      object_store: s3\n      {{- else if eq .Values.global.storage.type \"gcs\" }}\n      object_store: gcs\n      {{- else }}\n      object_store: filesystem\n      {{- end }}\n      schema: v12\n      index:\n        prefix: loki_index_\n        period: 24h\n{{- end }}\n\n{{- if or .Values.minio.enabled (eq .Values.global.storage.type \"s3\") (eq .Values.global.storage.type \"gcs\") }}\nruler:\n  storage:\n  {{- include \"loki.rulerStorageConfig\" . | nindent 4}}\n{{- end }}\n\ningester:\n  chunk_target_size: 196608\n  flush_check_period: 5s\n  flush_op_timeout: 100m\n  lifecycler:\n    ring:\n      kvstore:\n        store: memberlist\n\n{{- with .Values.global.memcached.results_cache }}\nquery_range:\n  align_queries_with_step: true\n  {{- if and .enabled .host }}\n  cache_results: {{ .enabled }}\n  results_cache:\n    cache:\n      default_validity: {{ .default_validity }}\n      memcached_client:\n        host: {{ .host }}\n        service: {{ .service }}\n        timeout: {{ .timeout }}\n  {{- end }}\n{{- end }}\n\n{{- with .Values.global.storage_config }}\nstorage_config:\n  {{- tpl (. | toYaml) $ | nindent 4 }}\n{{- end }}\n\n{{- with .Values.global.query_scheduler }}\nquery_scheduler:\n  {{- tpl (. | toYaml) $ | nindent 4 }}\n{{- end }}\n"` | Configuration value for all sub-charts. For use when `global.createGlobalConfig=true` & `config.existingSecretForConfig="logging-loki"` |
| domain | string | `"bigbang.dev"` |  |
| istio.enabled | bool | `false` |  |
| istio.mtls.mode | string | `"STRICT"` |  |
| monitoring.enabled | bool | `false` |  |
| networkPolicies.enabled | bool | `false` |  |
| networkPolicies.controlPlaneCidr | string | `"0.0.0.0/0"` |  |
| nameOverride | string | `"logging-loki"` |  |
| loki.enabled | bool | `true` | Enable Loki chart in single binary mode. Recommended for smaller or non-production environments |
| loki.image.repository | string | `"registry1.dso.mil/ironbank/opensource/grafana/loki"` |  |
| loki.image.tag | string | `"2.6.0"` |  |
| loki.image.pullPolicy | string | `"IfNotPresent"` |  |
| loki.image.pullSecrets[0] | string | `"private-registry"` |  |
| loki.extraPorts[0] | object | `{"name":"grpc","port":9095,"protocol":"TCP","targetPort":"grpc"}` | Extra ports for loki pods. Additional ports exposed to support HA communication |
| loki.extraPorts[1] | object | `{"name":"tcp-memberlist","port":7946,"protocol":"TCP"}` | Extra ports for loki pods. Additional ports exposed to support memberlist |
| loki.nameOverride | string | `"logging-loki"` |  |
| loki.readinessProbe.initialDelaySeconds | int | `80` |  |
| loki.livenessProbe.initialDelaySeconds | int | `80` |  |
| loki.resources.limits.cpu | string | `"100m"` |  |
| loki.resources.limits.memory | string | `"256Mi"` |  |
| loki.resources.requests.cpu | string | `"100m"` |  |
| loki.resources.requests.memory | string | `"256Mi"` |  |
| loki.persistence.enabled | bool | `false` |  |
| loki.persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| loki.persistence.size | string | `"10Gi"` |  |
| loki-simple-scalable.enabled | bool | `false` | Enable upstream loki-simple-scalable based chart Recommended for large production environments |
| loki-simple-scalable.nameOverride | string | `"logging-loki"` |  |
| loki-simple-scalable.loki.image.registry | string | `"registry1.dso.mil"` | The Docker registry |
| loki-simple-scalable.loki.image.repository | string | `"ironbank/opensource/grafana/loki"` | Docker image repository |
| loki-simple-scalable.loki.image.tag | string | `"2.6.0"` | Overrides the image tag whose default is the chart's appVersion |
| loki-simple-scalable.loki.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| loki-simple-scalable.write.replicas | int | `2` | Number of replicas for the write |
| loki-simple-scalable.write.resources.limits.cpu | string | `"300m"` |  |
| loki-simple-scalable.write.resources.limits.memory | string | `"2Gi"` |  |
| loki-simple-scalable.write.resources.requests.cpu | string | `"300m"` |  |
| loki-simple-scalable.write.resources.requests.memory | string | `"2Gi"` |  |
| loki-simple-scalable.read.replicas | int | `2` | Number of replicas for the read |
| loki-simple-scalable.read.resources.limits.cpu | string | `"300m"` |  |
| loki-simple-scalable.read.resources.limits.memory | string | `"2Gi"` |  |
| loki-simple-scalable.read.resources.requests.cpu | string | `"300m"` |  |
| loki-simple-scalable.read.resources.requests.memory | string | `"2Gi"` |  |
| loki-simple-scalable.gateway.enabled | bool | `false` | Specifies whether the gateway should be enabled |
| loki-simple-scalable.gateway.image.registry | string | `"registry1.dso.mil"` |  |
| loki-simple-scalable.gateway.image.repository | string | `"ironbank/opensource/nginx/nginx"` |  |
| loki-simple-scalable.gateway.image.tag | string | `"1.21.6"` |  |
| loki-simple-scalable.gateway.service.port | int | `3100` | Port of the gateway service |
| loki-simple-scalable.imagePullSecrets[0].name | string | `"private-registry"` |  |
| loki-simple-scalable.enterprise.enabled | bool | `false` | Enable enterprise features, license must be provided |
| loki-simple-scalable.enterprise.version | string | `"v1.4.1"` |  |
| loki-simple-scalable.enterprise.license | object | `{"contents":"NOTAVALIDLICENSE"}` | Grafana Enterprise Logs license In order to use Grafana Enterprise Logs features, you will need to provide the contents of your Grafana Enterprise Logs license, either by providing the contents of the license.jwt, or the name Kubernetes Secret that contains your license.jwt. To set the license contents, use the flag `--set-file 'license.contents=./license.jwt'` |
| loki-simple-scalable.enterprise.useExternalLicense | bool | `false` | Set to true when providing an external license |
| loki-simple-scalable.enterprise.externalLicenseName | string | `nil` | Name of external licesne secret to use |
| loki-simple-scalable.enterprise.adminApi | object | `{"enabled":true}` | If enabled, the correct admin_client storage will be configured. If disabled while running enterprise, make sure auth is set to `type: trust`, or that `auth_enabled` is set to `false`. |
| loki-simple-scalable.enterprise.config | string | `"{{- if .Values.enterprise.adminApi.enabled }}\n{{- if or .Values.minio.enabled (eq .Values.global.storage.type \"s3\") (eq .Values.global.storage.type \"gcs\") }}\nadmin_client:\n  storage:\n    s3:\n      bucket_name: {{ .Values.global.storage.bucketNames.admin }}\n{{- end }}\n{{- end }}\nauth:\n  type: {{ .Values.enterprise.adminApi.enabled | ternary \"enterprise\" \"trust\" }}\nauth_enabled: {{ .Values.global.auth_enabled }}\ncluster_name: {{ .Release.Name }}\nlicense:\n  path: /etc/loki/license/license.jwt\n"` |  |
| loki-simple-scalable.enterprise.image.registry | string | `"registry1.dso.mil"` | The Docker registry |
| loki-simple-scalable.enterprise.image.repository | string | `"ironbank/grafana/grafana-enterprise-logs"` | Docker image repository |
| loki-simple-scalable.enterprise.image.tag | string | `"v1.4.1"` | Overrides the image tag whose default is the chart's appVersion |
| loki-simple-scalable.enterprise.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| loki-simple-scalable.enterprise.tokengen | object | `{"adminTokenSecret":"gel-admin-token","annotations":{},"enabled":true,"env":[],"extraArgs":[],"extraVolumeMounts":[],"extraVolumes":[],"labels":{},"securityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001}}` | Configuration for `tokengen` target |
| loki-simple-scalable.enterprise.tokengen.enabled | bool | `true` | Whether the job should be part of the deployment |
| loki-simple-scalable.enterprise.tokengen.adminTokenSecret | string | `"gel-admin-token"` | Name of the secret to store the admin token in |
| loki-simple-scalable.enterprise.tokengen.extraArgs | list | `[]` | Additional CLI arguments for the `tokengen` target |
| loki-simple-scalable.enterprise.tokengen.env | list | `[]` | Additional Kubernetes environment |
| loki-simple-scalable.enterprise.tokengen.labels | object | `{}` | Additional labels for the `tokengen` Job |
| loki-simple-scalable.enterprise.tokengen.annotations | object | `{}` | Additional annotations for the `tokengen` Job |
| loki-simple-scalable.enterprise.tokengen.extraVolumes | list | `[]` | Additional volumes for Pods |
| loki-simple-scalable.enterprise.tokengen.extraVolumeMounts | list | `[]` | Additional volume mounts for Pods |
| loki-simple-scalable.enterprise.tokengen.securityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001}` | Run containers as user `enterprise-logs(uid=10001)` |
| minio.enabled | bool | `false` | Enable minio instance support, must have minio-operator installed |
| minio.service.nameOverride | string | `"minio.logging.svc.cluster.local"` |  |
| minio.tenants.secrets | object | `{"accessKey":"minio","name":"loki-objstore-creds","secretKey":"minio123"}` | Minio root credentials |
| minio.tenants.buckets | list | `[{"name":"chunks"},{"name":"ruler"}]` | Buckets to be provisioned to for tenant |
| minio.tenants.users | list | `[{"name":"minio-user"}]` | Users to to be provisioned to for tenant |
| minio.tenants.defaultUserCredentials | object | `{"password":"","username":"minio-user"}` | User credentials to create for above user. Otherwise password is randomly generated. This auth is not required to be set or reclaimed for minio use with Loki |
| minio.tenants.pools[0].servers | int | `1` |  |
| minio.tenants.pools[0].volumesPerServer | int | `4` |  |
| minio.tenants.pools[0].size | string | `"750Mi"` |  |
| minio.tenants.pools[0].securityContext.runAsUser | int | `1001` |  |
| minio.tenants.pools[0].securityContext.runAsGroup | int | `1001` |  |
| minio.tenants.pools[0].securityContext.fsGroup | int | `1001` |  |
| minio.tenants.metrics.enabled | bool | `false` |  |
| minio.tenants.metrics.port | int | `9000` |  |
| minio.tenants.metrics.memory | string | `"128Mi"` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `nil` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automountServiceAccountToken | bool | `true` |  |
| bbtests.enabled | bool | `false` |  |
| bbtests.cypress.artifacts | bool | `true` |  |
| bbtests.cypress.envs.cypress_check_datasource | string | `"false"` |  |
| bbtests.cypress.envs.cypress_grafana_url | string | `"http://monitoring-grafana.monitoring.svc.cluster.local"` |  |
| bbtests.scripts.image | string | `"registry1.dso.mil/ironbank/big-bang/base:2.0.0"` |  |
| bbtests.scripts.envs.LOKI_URL | string | `"http://{{ template \"loki.fullname\" . }}.{{ .Release.Namespace }}.svc:3100"` |  |
| bbtests.scripts.envs.LOKI_VERSION | string | `"{{ .Values.loki.image.tag }}"` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
