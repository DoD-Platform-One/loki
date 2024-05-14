# loki

![Version: 6.3.4-bb.0](https://img.shields.io/badge/Version-6.3.4--bb.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.0.0](https://img.shields.io/badge/AppVersion-3.0.0-informational?style=flat-square)

Helm chart for Grafana Loki in simple, scalable mode

## Upstream References
* <https://grafana.github.io/helm-charts>

* <https://github.com/grafana/loki>
* <https://grafana.com/oss/loki/>
* <https://grafana.com/docs/loki/latest/>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

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
| global.image.registry | string | `nil` | Overrides the Docker registry globally for all images |
| global.priorityClassName | string | `nil` | Overrides the priorityClassName for all pods |
| global.clusterDomain | string | `"cluster.local"` | configures cluster domain ("cluster.local" by default) |
| global.dnsService | string | `"kube-dns"` | configures DNS service name |
| global.dnsNamespace | string | `"kube-system"` | configures DNS service namespace |
| nameOverride | string | `"logging-loki"` | Overrides the chart's name |
| openshift | bool | `false` |  |
| fullnameOverride | string | `"logging-loki"` | Overrides the chart's computed fullname |
| clusterLabelOverride | string | `nil` | Overrides the chart's cluster label |
| imagePullSecrets | list | `[{"name":"private-registry"}]` | Image pull secrets for Docker images |
| deploymentMode | string | `"SingleBinary"` | Deployment mode lets you specify how to deploy Loki. There are 3 options: - SingleBinary: Loki is deployed as a single binary, useful for small installs typically without HA, up to a few tens of GB/day. - SimpleScalable: Loki is deployed as 3 targets: read, write, and backend. Useful for medium installs easier to manage than distributed, up to a about 1TB/day. - Distributed: Loki is deployed as individual microservices. The most complicated but most capable, useful for large installs, typically over 1TB/day. There are also 2 additional modes used for migrating between deployment modes: - SingleBinary<->SimpleScalable: Migrate from SingleBinary to SimpleScalable (or vice versa) - SimpleScalable<->Distributed: Migrate from SimpleScalable to Distributed (or vice versa) Note: SimpleScalable and Distributed REQUIRE the use of object storage. |
| loki | object | `{"analytics":{"reporting_enabled":false},"annotations":{},"auth_enabled":false,"commonConfig":{"compactor_address":"{{ include \"loki.compactorAddress\" . }}","path_prefix":"/var/loki","replication_factor":1},"compactor":{},"config":"{{- if .Values.enterprise.enabled}}\n{{- tpl .Values.enterprise.config . }}\n{{- else }}\nauth_enabled: {{ .Values.loki.auth_enabled }}\n{{- end }}\n\n{{- with .Values.loki.server }}\nserver:\n  {{- toYaml . \| nindent 2}}\n{{- end}}\n\npattern_ingester:\n  enabled: {{ .Values.loki.pattern_ingester.enabled }}\n\nmemberlist:\n{{- if .Values.loki.memberlistConfig }}\n  {{- toYaml .Values.loki.memberlistConfig \| nindent 2 }}\n{{- else }}\n{{- if .Values.loki.extraMemberlistConfig}}\n{{- toYaml .Values.loki.extraMemberlistConfig \| nindent 2}}\n{{- end }}\n  join_members:\n    - {{ include \"loki.memberlist\" . }}\n    {{- with .Values.migrate.fromDistributed }}\n    {{- if .enabled }}\n    - {{ .memberlistService }}\n    {{- end }}\n    {{- end }}\n{{- end }}\n\n{{- with .Values.loki.ingester }}\ningester:\n  {{- tpl (. \| toYaml) $ \| nindent 4 }}\n{{- end }}\n\n{{- if .Values.loki.commonConfig}}\ncommon:\n{{- toYaml .Values.loki.commonConfig \| nindent 2}}\n  storage:\n  {{- include \"loki.commonStorageConfig\" . \| nindent 4}}\n{{- end}}\n\n{{- with .Values.loki.limits_config }}\nlimits_config:\n  {{- tpl (. \| toYaml) $ \| nindent 4 }}\n{{- end }}\n\nruntime_config:\n  file: /etc/loki/runtime-config/runtime-config.yaml\n\n{{- with .Values.chunksCache }}\n{{- if .enabled }}\nchunk_store_config:\n  chunk_cache_config:\n    default_validity: {{ .defaultValidity }}\n    background:\n      writeback_goroutines: {{ .writebackParallelism }}\n      writeback_buffer: {{ .writebackBuffer }}\n      writeback_size_limit: {{ .writebackSizeLimit }}\n    memcached:\n      batch_size: {{ .batchSize }}\n      parallelism: {{ .parallelism }}\n    memcached_client:\n      addresses: dnssrvnoa+_memcached-client._tcp.{{ template \"loki.fullname\" $ }}-chunks-cache.{{ $.Release.Namespace }}.svc\n      consistent_hash: true\n      timeout: {{ .timeout }}\n      max_idle_conns: 72\n{{- end }}\n{{- end }}\n\n{{- if .Values.loki.schemaConfig }}\nschema_config:\n{{- toYaml .Values.loki.schemaConfig \| nindent 2}}\n{{- end }}\n\n{{- if .Values.loki.useTestSchema }}\nschema_config:\n{{- toYaml .Values.loki.testSchemaConfig \| nindent 2}}\n{{- end }}\n\n{{ include \"loki.rulerConfig\" . }}\n\n{{- if or .Values.tableManager.retention_deletes_enabled .Values.tableManager.retention_period }}\ntable_manager:\n  retention_deletes_enabled: {{ .Values.tableManager.retention_deletes_enabled }}\n  retention_period: {{ .Values.tableManager.retention_period }}\n{{- end }}\n\nquery_range:\n  align_queries_with_step: true\n  {{- with .Values.loki.query_range }}\n  {{- tpl (. \| toYaml) $ \| nindent 4 }}\n  {{- end }}\n  {{- if .Values.resultsCache.enabled }}\n  {{- with .Values.resultsCache }}\n  cache_results: true\n  results_cache:\n    cache:\n      default_validity: {{ .defaultValidity }}\n      background:\n        writeback_goroutines: {{ .writebackParallelism }}\n        writeback_buffer: {{ .writebackBuffer }}\n        writeback_size_limit: {{ .writebackSizeLimit }}\n      memcached_client:\n        consistent_hash: true\n        addresses: dnssrvnoa+_memcached-client._tcp.{{ template \"loki.fullname\" $ }}-results-cache.{{ $.Release.Namespace }}.svc\n        timeout: {{ .timeout }}\n        update_interval: 1m\n  {{- end }}\n  {{- end }}\n\n{{- with .Values.loki.storage_config }}\nstorage_config:\n  {{- tpl (. \| toYaml) $ \| nindent 4 }}\n{{- end }}\n\n{{- with .Values.loki.query_scheduler }}\nquery_scheduler:\n  {{- tpl (. \| toYaml) $ \| nindent 4 }}\n{{- end }}\n\n{{- with .Values.loki.compactor }}\ncompactor:\n  {{- tpl (. \| toYaml) $ \| nindent 4 }}\n{{- end }}\n\n{{- with .Values.loki.analytics }}\nanalytics:\n  {{- tpl (. \| toYaml) $ \| nindent 4 }}\n{{- end }}\n\n{{- with .Values.loki.querier }}\nquerier:\n  {{- tpl (. \| toYaml) $ \| nindent 4 }}\n{{- end }}\n\n{{- with .Values.loki.index_gateway }}\nindex_gateway:\n  {{- tpl (. \| toYaml) $ \| nindent 4 }}\n{{- end }}\n\n{{- with .Values.loki.frontend }}\nfrontend:\n  {{- tpl (. \| toYaml) $ \| nindent 4 }}\n{{- end }}\n\n{{- with .Values.loki.frontend_worker }}\nfrontend_worker:\n  {{- tpl (. \| toYaml) $ \| nindent 4 }}\n{{- end }}\n\n{{- with .Values.loki.distributor }}\ndistributor:\n  {{- tpl (. \| toYaml) $ \| nindent 4 }}\n{{- end }}\n\ntracing:\n  enabled: {{ .Values.loki.tracing.enabled }}\n","configObjectName":"{{ include \"loki.name\" . }}","configStorageType":"ConfigMap","containerSecurityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true},"distributor":{},"enableServiceLinks":true,"extraMemberlistConfig":{},"frontend":{"scheduler_address":"{{ include \"loki.querySchedulerAddress\" . }}","tail_proxy_url":"{{ include \"loki.querierAddress\" . }}"},"frontend_worker":{"scheduler_address":"{{ include \"loki.querySchedulerAddress\" . }}"},"generatedConfigObjectName":"{{ include \"loki.name\" . }}","image":{"digest":null,"pullPolicy":"IfNotPresent","registry":"registry1.dso.mil","repository":"ironbank/opensource/grafana/loki","tag":"3.0.0"},"index_gateway":{"mode":"simple"},"ingester":{"autoforget_unhealthy":true,"chunk_target_size":196608,"flush_check_period":"5s","flush_op_timeout":"100m","lifecycler":{"ring":{"kvstore":{"store":"memberlist"},"replication_factor":1}}},"limits_config":{"max_cache_freshness_per_query":"10m","query_timeout":"300s","reject_old_samples":true,"reject_old_samples_max_age":"168h","split_queries_by_interval":"15m","volume_enabled":true},"memberlistConfig":{},"memcached":{"chunk_cache":{"batch_size":256,"enabled":false,"host":"","parallelism":10,"service":"memcached-client"},"results_cache":{"default_validity":"12h","enabled":false,"host":"","service":"memcached-client","timeout":"500ms"}},"pattern_ingester":{"enabled":false},"podAnnotations":{},"podLabels":{},"podSecurityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001},"querier":{},"query_scheduler":{},"readinessProbe":{"httpGet":{"path":"/ready","port":"http-metrics"},"initialDelaySeconds":30,"timeoutSeconds":1},"revisionHistoryLimit":10,"rulerConfig":{},"runtimeConfig":{},"schemaConfig":{"configs":[{"from":"2022-01-11","index":{"period":"24h","prefix":"loki_index_"},"object_store":"{{ .Values.loki.storage.type }}","schema":"v12","store":"boltdb-shipper"},{"from":"2023-08-01","index":{"period":"24h","prefix":"loki_tsdb_"},"object_store":"{{ .Values.loki.storage.type }}","schema":"v12","store":"tsdb"},{"from":"2024-04-01","index":{"period":"24h","prefix":"loki_tsdb_"},"object_store":"{{ .Values.loki.storage.type }}","schema":"v13","store":"tsdb"}]},"server":{"grpc_listen_port":9095,"http_listen_port":3100,"http_server_read_timeout":"600s","http_server_write_timeout":"600s"},"serviceAnnotations":{},"serviceLabels":{},"storage":{"azure":{"accountKey":null,"accountName":null,"connectionString":null,"endpointSuffix":null,"requestTimeout":null,"useFederatedToken":false,"useManagedIdentity":false,"userAssignedId":null},"bucketNames":{"admin":"loki-admin","chunks":"loki","ruler":"loki"},"filesystem":{"chunks_directory":"/var/loki/chunks","rules_directory":"/var/loki/rules"},"gcs":{"chunkBufferSize":0,"enableHttp2":true,"requestTimeout":"0s"},"s3":{"accessKeyId":null,"backoff_config":{},"endpoint":null,"http_config":{},"insecure":false,"region":null,"s3":null,"s3ForcePathStyle":false,"secretAccessKey":null,"signatureVersion":null},"swift":{"auth_url":null,"auth_version":null,"connect_timeout":null,"container_name":null,"domain_id":null,"domain_name":null,"internal":null,"max_retries":null,"password":null,"project_domain_id":null,"project_domain_name":null,"project_id":null,"project_name":null,"region_name":null,"request_timeout":null,"user_domain_id":null,"user_domain_name":null,"user_id":null,"username":null},"type":"s3"},"storage_config":{"boltdb_shipper":{"active_index_directory":"/var/loki/boltdb-shipper-active","cache_location":"/var/loki/boltdb-shipper-cache","cache_ttl":"24h","index_gateway_client":{"server_address":"{{ include \"loki.indexGatewayAddress\" . }}"}},"hedging":{"at":"250ms","max_per_second":20,"up_to":3},"tsdb_shipper":{"active_index_directory":"/var/loki/tsdb-index","cache_location":"/var/loki/tsdb-cache","cache_ttl":"24h","index_gateway_client":{"server_address":"{{ include \"loki.indexGatewayAddress\" . }}"}}},"structuredConfig":{},"tenants":[],"testSchemaConfig":{"configs":[{"from":"2024-04-01","index":{"period":"24h","prefix":"index_"},"object_store":"{{ include \"loki.testSchemaObjectStore\" . }}","schema":"v13","store":"tsdb"}]},"tracing":{"enabled":false},"useTestSchema":false}` | Configuration for running Loki |
| loki.image.registry | string | `"registry1.dso.mil"` | The Docker registry |
| loki.image.repository | string | `"ironbank/opensource/grafana/loki"` | Docker image repository |
| loki.image.tag | string | `"3.0.0"` | Overrides the image tag whose default is the chart's appVersion |
| loki.image.digest | string | `nil` | Overrides the image tag with an image digest |
| loki.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| loki.annotations | object | `{}` | Common annotations for all deployments/StatefulSets |
| loki.podAnnotations | object | `{}` | Common annotations for all pods |
| loki.podLabels | object | `{}` | Common labels for all pods |
| loki.serviceAnnotations | object | `{}` | Common annotations for all services |
| loki.serviceLabels | object | `{}` | Common labels for all services |
| loki.revisionHistoryLimit | int | `10` | The number of old ReplicaSets to retain to allow rollback |
| loki.podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001}` | The SecurityContext for Loki pods |
| loki.containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true}` | The SecurityContext for Loki containers |
| loki.enableServiceLinks | bool | `true` | Should enableServiceLinks be enabled. Default to enable |
| loki.configStorageType | string | `"ConfigMap"` | Defines what kind of object stores the configuration, a ConfigMap or a Secret. In order to move sensitive information (such as credentials) from the ConfigMap/Secret to a more secure location (e.g. vault), it is possible to use [environment variables in the configuration](https://grafana.com/docs/loki/latest/configuration/#use-environment-variables-in-the-configuration). Such environment variables can be then stored in a separate Secret and injected via the global.extraEnvFrom value. For details about environment injection from a Secret please see [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/#use-case-as-container-environment-variables). |
| loki.configObjectName | string | `"{{ include \"loki.name\" . }}"` | The name of the object which Loki will mount as a volume containing the config. If the configStorageType is Secret, this will be the name of the Secret, if it is ConfigMap, this will be the name of the ConfigMap. The value will be passed through tpl. |
| loki.generatedConfigObjectName | string | `"{{ include \"loki.name\" . }}"` | The name of the Secret or ConfigMap that will be created by this chart. If empty, no configmap or secret will be created. The value will be passed through tpl. |
| loki.config | string | See values.yaml | Config file contents for Loki |
| loki.memberlistConfig | object | `{}` | memberlist configuration (overrides embedded default) |
| loki.extraMemberlistConfig | object | `{}` | Extra memberlist configuration |
| loki.tenants | list | `[]` | Tenants list to be created on nginx htpasswd file, with name and password keys |
| loki.server | object | `{"grpc_listen_port":9095,"http_listen_port":3100,"http_server_read_timeout":"600s","http_server_write_timeout":"600s"}` | Check https://grafana.com/docs/loki/latest/configuration/#server for more info on the server configuration. |
| loki.limits_config | object | `{"max_cache_freshness_per_query":"10m","query_timeout":"300s","reject_old_samples":true,"reject_old_samples_max_age":"168h","split_queries_by_interval":"15m","volume_enabled":true}` | Limits config |
| loki.runtimeConfig | object | `{}` | Provides a reloadable runtime configuration file for some specific configuration |
| loki.commonConfig | object | `{"compactor_address":"{{ include \"loki.compactorAddress\" . }}","path_prefix":"/var/loki","replication_factor":1}` | Check https://grafana.com/docs/loki/latest/configuration/#common_config for more info on how to provide a common configuration |
| loki.storage | object | `{"azure":{"accountKey":null,"accountName":null,"connectionString":null,"endpointSuffix":null,"requestTimeout":null,"useFederatedToken":false,"useManagedIdentity":false,"userAssignedId":null},"bucketNames":{"admin":"loki-admin","chunks":"loki","ruler":"loki"},"filesystem":{"chunks_directory":"/var/loki/chunks","rules_directory":"/var/loki/rules"},"gcs":{"chunkBufferSize":0,"enableHttp2":true,"requestTimeout":"0s"},"s3":{"accessKeyId":null,"backoff_config":{},"endpoint":null,"http_config":{},"insecure":false,"region":null,"s3":null,"s3ForcePathStyle":false,"secretAccessKey":null,"signatureVersion":null},"swift":{"auth_url":null,"auth_version":null,"connect_timeout":null,"container_name":null,"domain_id":null,"domain_name":null,"internal":null,"max_retries":null,"password":null,"project_domain_id":null,"project_domain_name":null,"project_id":null,"project_name":null,"region_name":null,"request_timeout":null,"user_domain_id":null,"user_domain_name":null,"user_id":null,"username":null},"type":"s3"}` | Storage config. Providing this will automatically populate all necessary storage configs in the templated config. |
| loki.storage.s3.backoff_config | object | `{}` | Check https://grafana.com/docs/loki/latest/configure/#s3_storage_config for more info on how to provide a backoff_config |
| loki.memcached | object | `{"chunk_cache":{"batch_size":256,"enabled":false,"host":"","parallelism":10,"service":"memcached-client"},"results_cache":{"default_validity":"12h","enabled":false,"host":"","service":"memcached-client","timeout":"500ms"}}` | Configure memcached as an external cache for chunk and results cache. Disabled by default must enable and specify a host for each cache you would like to use. |
| loki.schemaConfig | object | `{"configs":[{"from":"2022-01-11","index":{"period":"24h","prefix":"loki_index_"},"object_store":"{{ .Values.loki.storage.type }}","schema":"v12","store":"boltdb-shipper"},{"from":"2023-08-01","index":{"period":"24h","prefix":"loki_tsdb_"},"object_store":"{{ .Values.loki.storage.type }}","schema":"v12","store":"tsdb"},{"from":"2024-04-01","index":{"period":"24h","prefix":"loki_tsdb_"},"object_store":"{{ .Values.loki.storage.type }}","schema":"v13","store":"tsdb"}]}` | Check https://grafana.com/docs/loki/latest/configuration/#schema_config for more info on how to configure schemas |
| loki.useTestSchema | bool | `false` | a real Loki install requires a proper schemaConfig defined above this, however for testing or playing around you can enable useTestSchema |
| loki.rulerConfig | object | `{}` | Check https://grafana.com/docs/loki/latest/configuration/#ruler for more info on configuring ruler |
| loki.structuredConfig | object | `{}` | Structured loki configuration, takes precedence over `loki.config`, `loki.schemaConfig`, `loki.storageConfig` |
| loki.query_scheduler | object | `{}` | Additional query scheduler config |
| loki.storage_config | object | `{"boltdb_shipper":{"active_index_directory":"/var/loki/boltdb-shipper-active","cache_location":"/var/loki/boltdb-shipper-cache","cache_ttl":"24h","index_gateway_client":{"server_address":"{{ include \"loki.indexGatewayAddress\" . }}"}},"hedging":{"at":"250ms","max_per_second":20,"up_to":3},"tsdb_shipper":{"active_index_directory":"/var/loki/tsdb-index","cache_location":"/var/loki/tsdb-cache","cache_ttl":"24h","index_gateway_client":{"server_address":"{{ include \"loki.indexGatewayAddress\" . }}"}}}` | Additional storage config |
| loki.compactor | object | `{}` | Optional compactor configuration |
| loki.pattern_ingester | object | `{"enabled":false}` | Optional pattern ingester configuration |
| loki.analytics | object | `{"reporting_enabled":false}` | Optional analytics configuration |
| loki.analytics.reporting_enabled | bool | `false` | Disable anonymous usage statistics |
| loki.querier | object | `{}` | Optional querier configuration |
| loki.ingester | object | `{"autoforget_unhealthy":true,"chunk_target_size":196608,"flush_check_period":"5s","flush_op_timeout":"100m","lifecycler":{"ring":{"kvstore":{"store":"memberlist"},"replication_factor":1}}}` | Optional ingester configuration |
| loki.index_gateway | object | `{"mode":"simple"}` | Optional index gateway configuration |
| loki.distributor | object | `{}` | Optional distributor configuration |
| loki.tracing | object | `{"enabled":false}` | Enable tracing |
| enterprise | object | `{"adminApi":{"enabled":true},"adminToken":{"additionalNamespaces":[],"secret":null},"canarySecret":null,"cluster_name":null,"config":"{{- if .Values.enterprise.adminApi.enabled }}\n{{- if or .Values.minio.enabled (eq .Values.loki.storage.type \"s3\") (eq .Values.loki.storage.type \"gcs\") (eq .Values.loki.storage.type \"azure\") }}\nadmin_client:\n  storage:\n    s3:\n      bucket_name: {{ .Values.loki.storage.bucketNames.admin \| default \"admin\" }}\n{{- end }}\n{{- end }}\nauth:\n  type: {{ .Values.enterprise.adminApi.enabled \| ternary \"enterprise\" \"trust\" }}\nauth_enabled: {{ .Values.loki.auth_enabled }}\ncluster_name: {{ include \"loki.clusterName\" . }}\nlicense:\n  path: /etc/loki/license/license.jwt\n","enabled":false,"externalConfigName":"","externalLicenseName":null,"gelGateway":true,"image":{"digest":null,"pullPolicy":"IfNotPresent","registry":"registry1.dso.mil","repository":"ironbank/grafana/grafana-enterprise-logs","tag":"v1.7.1"},"license":{"contents":"NOTAVALIDLICENSE"},"provisioner":{"additionalTenants":[],"annotations":{},"enabled":false,"env":[],"extraVolumeMounts":[],"image":{"digest":null,"pullPolicy":"IfNotPresent","registry":"docker.io","repository":"grafana/enterprise-logs-provisioner","tag":null},"labels":{},"priorityClassName":null,"provisionedSecretPrefix":null,"securityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001}},"tokengen":{"annotations":{"sidecar.istio.io/inject":"false"},"enabled":true,"env":[],"extraArgs":[],"extraEnvFrom":[],"extraVolumeMounts":[],"extraVolumes":[],"labels":{},"priorityClassName":"","securityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001},"targetModule":"tokengen","tolerations":[]},"useExternalLicense":false,"version":"v3.0.0"}` | Configuration for running Enterprise Loki |
| enterprise.cluster_name | string | `nil` | Optional name of the GEL cluster, otherwise will use .Release.Name The cluster name must match what is in your GEL license |
| enterprise.license | object | `{"contents":"NOTAVALIDLICENSE"}` | Grafana Enterprise Logs license In order to use Grafana Enterprise Logs features, you will need to provide the contents of your Grafana Enterprise Logs license, either by providing the contents of the license.jwt, or the name Kubernetes Secret that contains your license.jwt. To set the license contents, use the flag `--set-file 'enterprise.license.contents=./license.jwt'` |
| enterprise.useExternalLicense | bool | `false` | Set to true when providing an external license |
| enterprise.externalLicenseName | string | `nil` | Name of external license secret to use |
| enterprise.externalConfigName | string | `""` | Name of the external config secret to use |
| enterprise.gelGateway | bool | `true` | Use GEL gateway, if false will use the default nginx gateway |
| enterprise.adminApi | object | `{"enabled":true}` | If enabled, the correct admin_client storage will be configured. If disabled while running enterprise, make sure auth is set to `type: trust`, or that `auth_enabled` is set to `false`. |
| enterprise.image.registry | string | `"registry1.dso.mil"` | The Docker registry |
| enterprise.image.repository | string | `"ironbank/grafana/grafana-enterprise-logs"` | Docker image repository |
| enterprise.image.tag | string | `"v1.7.1"` | Overrides the image tag whose default is the chart's appVersion |
| enterprise.image.digest | string | `nil` | Overrides the image tag with an image digest |
| enterprise.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| enterprise.adminToken.secret | string | `nil` | Alternative name for admin token secret, needed by tokengen and provisioner jobs |
| enterprise.adminToken.additionalNamespaces | list | `[]` | Additional namespace to also create the token in. Useful if your Grafana instance is in a different namespace |
| enterprise.canarySecret | string | `nil` | Alternative name of the secret to store token for the canary |
| enterprise.tokengen | object | `{"annotations":{"sidecar.istio.io/inject":"false"},"enabled":true,"env":[],"extraArgs":[],"extraEnvFrom":[],"extraVolumeMounts":[],"extraVolumes":[],"labels":{},"priorityClassName":"","securityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001},"targetModule":"tokengen","tolerations":[]}` | Configuration for `tokengen` target |
| enterprise.tokengen.enabled | bool | `true` | Whether the job should be part of the deployment |
| enterprise.tokengen.targetModule | string | `"tokengen"` | Comma-separated list of Loki modules to load for tokengen |
| enterprise.tokengen.extraArgs | list | `[]` | Additional CLI arguments for the `tokengen` target |
| enterprise.tokengen.env | list | `[]` | Additional Kubernetes environment |
| enterprise.tokengen.labels | object | `{}` | Additional labels for the `tokengen` Job |
| enterprise.tokengen.annotations | object | `{"sidecar.istio.io/inject":"false"}` | Additional annotations for the `tokengen` Job |
| enterprise.tokengen.tolerations | list | `[]` | Tolerations for tokengen Job |
| enterprise.tokengen.extraVolumes | list | `[]` | Additional volumes for Pods |
| enterprise.tokengen.extraVolumeMounts | list | `[]` | Additional volume mounts for Pods |
| enterprise.tokengen.securityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001}` | Run containers as user `enterprise-logs(uid=10001)` |
| enterprise.tokengen.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the tokengen pods |
| enterprise.tokengen.priorityClassName | string | `""` | The name of the PriorityClass for tokengen Pods |
| enterprise.provisioner | object | `{"additionalTenants":[],"annotations":{},"enabled":false,"env":[],"extraVolumeMounts":[],"image":{"digest":null,"pullPolicy":"IfNotPresent","registry":"docker.io","repository":"grafana/enterprise-logs-provisioner","tag":null},"labels":{},"priorityClassName":null,"provisionedSecretPrefix":null,"securityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001}}` | Configuration for `provisioner` target |
| enterprise.provisioner.enabled | bool | `false` | Whether the job should be part of the deployment |
| enterprise.provisioner.provisionedSecretPrefix | string | `nil` | Name of the secret to store provisioned tokens in |
| enterprise.provisioner.additionalTenants | list | `[]` | Additional tenants to be created. Each tenant will get a read and write policy and associated token. Tenant must have a name and a namespace for the secret containting the token to be created in. For example additionalTenants:   - name: loki     secretNamespace: grafana |
| enterprise.provisioner.env | list | `[]` | Additional Kubernetes environment |
| enterprise.provisioner.labels | object | `{}` | Additional labels for the `provisioner` Job |
| enterprise.provisioner.annotations | object | `{}` | Additional annotations for the `provisioner` Job |
| enterprise.provisioner.priorityClassName | string | `nil` | The name of the PriorityClass for provisioner Job |
| enterprise.provisioner.securityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001}` | Run containers as user `enterprise-logs(uid=10001)` |
| enterprise.provisioner.image | object | `{"digest":null,"pullPolicy":"IfNotPresent","registry":"docker.io","repository":"grafana/enterprise-logs-provisioner","tag":null}` | Provisioner image to Utilize |
| enterprise.provisioner.image.registry | string | `"docker.io"` | The Docker registry |
| enterprise.provisioner.image.repository | string | `"grafana/enterprise-logs-provisioner"` | Docker image repository |
| enterprise.provisioner.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| enterprise.provisioner.image.digest | string | `nil` | Overrides the image tag with an image digest |
| enterprise.provisioner.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| enterprise.provisioner.extraVolumeMounts | list | `[]` | Volume mounts to add to the provisioner pods |
| kubectlImage | object | `{"digest":null,"pullPolicy":"IfNotPresent","registry":"registry1.dso.mil","repository":"ironbank/opensource/kubernetes/kubectl","tag":"v1.29.3"}` | kubetclImage is used in the enterprise provisioner and tokengen jobs |
| kubectlImage.registry | string | `"registry1.dso.mil"` | The Docker registry |
| kubectlImage.repository | string | `"ironbank/opensource/kubernetes/kubectl"` | Docker image repository |
| kubectlImage.tag | string | `"v1.29.3"` | Overrides the image tag whose default is the chart's appVersion |
| kubectlImage.digest | string | `nil` | Overrides the image tag with an image digest |
| kubectlImage.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| test | object | `{"annotations":{},"canaryServiceAddress":"http://loki-canary:3500/metrics","enabled":false,"image":{"digest":null,"pullPolicy":"IfNotPresent","registry":"docker.io","repository":"grafana/loki-helm-test","tag":"ewelch-distributed-helm-chart-17db5ee"},"labels":{},"prometheusAddress":"http://prometheus:9090","timeout":"1m"}` | Section for configuring optional Helm test |
| test.canaryServiceAddress | string | `"http://loki-canary:3500/metrics"` | Used to directly query the metrics endpoint of the canary for testing, this approach avoids needing prometheus for testing. This in a newer approach to using prometheusAddress such that tests do not have a dependency on prometheus |
| test.prometheusAddress | string | `"http://prometheus:9090"` | Address of the prometheus server to query for the test. This overrides any value set for canaryServiceAddress. This is kept for backward compatibility and may be removed in future releases. Previous value was 'http://prometheus:9090' |
| test.timeout | string | `"1m"` | Number of times to retry the test before failing |
| test.labels | object | `{}` | Additional labels for the test pods |
| test.annotations | object | `{}` | Additional annotations for test pods |
| test.image | object | `{"digest":null,"pullPolicy":"IfNotPresent","registry":"docker.io","repository":"grafana/loki-helm-test","tag":"ewelch-distributed-helm-chart-17db5ee"}` | Image to use for loki canary |
| test.image.registry | string | `"docker.io"` | The Docker registry |
| test.image.repository | string | `"grafana/loki-helm-test"` | Docker image repository |
| test.image.tag | string | `"ewelch-distributed-helm-chart-17db5ee"` | Overrides the image tag whose default is the chart's appVersion |
| test.image.digest | string | `nil` | Overrides the image tag with an image digest |
| test.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| lokiCanary.enabled | bool | `false` |  |
| lokiCanary.push | bool | `true` |  |
| lokiCanary.labelname | string | `"pod"` | The name of the label to look for at loki when doing the checks. |
| lokiCanary.annotations | object | `{}` | Additional annotations for the `loki-canary` Daemonset |
| lokiCanary.podLabels | object | `{}` | Additional labels for each `loki-canary` pod |
| lokiCanary.service.annotations | object | `{}` | Annotations for loki-canary Service |
| lokiCanary.service.labels | object | `{}` | Additional labels for loki-canary Service |
| lokiCanary.extraArgs | list | `[]` | Additional CLI arguments for the `loki-canary' command |
| lokiCanary.extraEnv | list | `[]` | Environment variables to add to the canary pods |
| lokiCanary.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the canary pods |
| lokiCanary.extraVolumeMounts | list | `[]` | Volume mounts to add to the canary pods |
| lokiCanary.extraVolumes | list | `[]` | Volumes to add to the canary pods |
| lokiCanary.resources | object | `{}` | Resource requests and limits for the canary |
| lokiCanary.dnsConfig | object | `{}` | DNS config for canary pods |
| lokiCanary.nodeSelector | object | `{}` | Node selector for canary pods |
| lokiCanary.tolerations | list | `[]` | Tolerations for canary pods |
| lokiCanary.priorityClassName | string | `nil` | The name of the PriorityClass for loki-canary pods |
| lokiCanary.image | object | `{"digest":null,"pullPolicy":"IfNotPresent","registry":"docker.io","repository":"grafana/loki-canary","tag":null}` | Image to use for loki canary |
| lokiCanary.image.registry | string | `"docker.io"` | The Docker registry |
| lokiCanary.image.repository | string | `"grafana/loki-canary"` | Docker image repository |
| lokiCanary.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| lokiCanary.image.digest | string | `nil` | Overrides the image tag with an image digest |
| lokiCanary.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| lokiCanary.updateStrategy | object | `{"rollingUpdate":{"maxUnavailable":1},"type":"RollingUpdate"}` | Update strategy for the `loki-canary` Daemonset pods |
| serviceAccount.create | bool | `true` | Specifies whether a ServiceAccount should be created |
| serviceAccount.name | string | `nil` | The name of the ServiceAccount to use. If not set and create is true, a name is generated using the fullname template |
| serviceAccount.imagePullSecrets | list | `[]` | Image pull secrets for the service account |
| serviceAccount.annotations | object | `{}` | Annotations for the service account |
| serviceAccount.labels | object | `{}` | Labels for the service account |
| serviceAccount.automountServiceAccountToken | bool | `false` | Set this toggle to false to opt out of automounting API credentials for the service account |
| rbac.pspEnabled | bool | `false` | If pspEnabled true, a PodSecurityPolicy is created for K8s that use psp. |
| rbac.sccEnabled | bool | `false` | For OpenShift set pspEnabled to 'false' and sccEnabled to 'true' to use the SecurityContextConstraints. |
| rbac.pspAnnotations | object | `{}` | Specify PSP annotations Ref: https://kubernetes.io/docs/reference/access-authn-authz/psp-to-pod-security-standards/#podsecuritypolicy-annotations |
| rbac.namespaced | bool | `false` | Whether to install RBAC in the namespace only or cluster-wide. Useful if you want to watch ConfigMap globally. |
| networkPolicy.enabled | bool | `false` | Specifies whether Network Policies should be created |
| networkPolicy.flavor | string | `"kubernetes"` | Specifies whether the policies created will be standard Network Policies (flavor: kubernetes) or Cilium Network Policies (flavor: cilium) |
| networkPolicy.metrics.podSelector | object | `{}` | Specifies the Pods which are allowed to access the metrics port. As this is cross-namespace communication, you also need the namespaceSelector. |
| networkPolicy.metrics.namespaceSelector | object | `{}` | Specifies the namespaces which are allowed to access the metrics port |
| networkPolicy.metrics.cidrs | list | `[]` | Specifies specific network CIDRs which are allowed to access the metrics port. In case you use namespaceSelector, you also have to specify your kubelet networks here. The metrics ports are also used for probes. |
| networkPolicy.ingress.podSelector | object | `{}` | Specifies the Pods which are allowed to access the http port. As this is cross-namespace communication, you also need the namespaceSelector. |
| networkPolicy.ingress.namespaceSelector | object | `{}` | Specifies the namespaces which are allowed to access the http port |
| networkPolicy.alertmanager.port | int | `9093` | Specify the alertmanager port used for alerting |
| networkPolicy.alertmanager.podSelector | object | `{}` | Specifies the alertmanager Pods. As this is cross-namespace communication, you also need the namespaceSelector. |
| networkPolicy.alertmanager.namespaceSelector | object | `{}` | Specifies the namespace the alertmanager is running in |
| networkPolicy.externalStorage.ports | list | `[]` | Specify the port used for external storage, e.g. AWS S3 |
| networkPolicy.externalStorage.cidrs | list | `[]` | Specifies specific network CIDRs you want to limit access to |
| networkPolicy.discovery.port | int | `nil` | Specify the port used for discovery |
| networkPolicy.discovery.podSelector | object | `{}` | Specifies the Pods labels used for discovery. As this is cross-namespace communication, you also need the namespaceSelector. |
| networkPolicy.discovery.namespaceSelector | object | `{}` | Specifies the namespace the discovery Pods are running in |
| networkPolicy.egressWorld.enabled | bool | `false` | Enable additional cilium egress rules to external world for write, read and backend. |
| networkPolicy.egressKubeApiserver.enabled | bool | `false` | Enable additional cilium egress rules to kube-apiserver for backend. |
| memberlist.service.publishNotReadyAddresses | bool | `false` |  |
| adminApi | object | `{"affinity":{},"annotations":{},"containerSecurityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true},"env":[],"extraArgs":{},"extraContainers":[],"extraVolumeMounts":[],"extraVolumes":[],"hostAliases":[],"initContainers":[],"labels":{},"nodeSelector":{},"podSecurityContext":{"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001},"readinessProbe":{"httpGet":{"path":"/ready","port":"http-metrics"},"initialDelaySeconds":45},"replicas":1,"resources":{},"service":{"annotations":{},"labels":{}},"strategy":{"type":"RollingUpdate"},"terminationGracePeriodSeconds":60,"tolerations":[]}` | Configuration for the `admin-api` target |
| adminApi.replicas | int | `1` | Define the amount of instances |
| adminApi.hostAliases | list | `[]` | hostAliases to add |
| adminApi.extraArgs | object | `{}` | Additional CLI arguments for the `admin-api` target |
| adminApi.labels | object | `{}` | Additional labels for the `admin-api` Deployment |
| adminApi.annotations | object | `{}` | Additional annotations for the `admin-api` Deployment |
| adminApi.service | object | `{"annotations":{},"labels":{}}` | Additional labels and annotations for the `admin-api` Service |
| adminApi.podSecurityContext | object | `{"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001}` | Run container as user `enterprise-logs(uid=10001)` `fsGroup` must not be specified, because these security options are applied on container level not on Pod level. |
| adminApi.strategy | object | `{"type":"RollingUpdate"}` | Update strategy |
| adminApi.readinessProbe | object | `{"httpGet":{"path":"/ready","port":"http-metrics"},"initialDelaySeconds":45}` | Readiness probe |
| adminApi.resources | object | `{}` | Values are defined in small.yaml and large.yaml |
| adminApi.env | list | `[]` | Configure optional environment variables |
| adminApi.initContainers | list | `[]` | Configure optional initContainers |
| adminApi.extraContainers | list | `[]` | Conifgure optional extraContainers |
| adminApi.extraVolumes | list | `[]` | Additional volumes for Pods |
| adminApi.extraVolumeMounts | list | `[]` | Additional volume mounts for Pods |
| adminApi.affinity | object | `{}` | Affinity for admin-api Pods |
| adminApi.nodeSelector | object | `{}` | Node selector for admin-api Pods |
| adminApi.tolerations | list | `[]` | Tolerations for admin-api Pods |
| adminApi.terminationGracePeriodSeconds | int | `60` | Grace period to allow the admin-api to shutdown before it is killed |
| gateway.enabled | bool | `false` | Specifies whether the gateway should be enabled |
| gateway.replicas | int | `1` | Number of replicas for the gateway |
| gateway.verboseLogging | bool | `true` | Enable logging of 2xx and 3xx HTTP requests |
| gateway.autoscaling.enabled | bool | `false` | Enable autoscaling for the gateway |
| gateway.autoscaling.minReplicas | int | `1` | Minimum autoscaling replicas for the gateway |
| gateway.autoscaling.maxReplicas | int | `3` | Maximum autoscaling replicas for the gateway |
| gateway.autoscaling.targetCPUUtilizationPercentage | int | `60` | Target CPU utilisation percentage for the gateway |
| gateway.autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Target memory utilisation percentage for the gateway |
| gateway.autoscaling.behavior | object | `{}` | Behavior policies while scaling. |
| gateway.deploymentStrategy.type | string | `"RollingUpdate"` |  |
| gateway.image.registry | string | `"registry1.dso.mil"` | The Docker registry for the gateway image |
| gateway.image.repository | string | `"ironbank/opensource/nginx/nginx"` | The gateway image repository |
| gateway.image.tag | string | `"1.25.4"` | The gateway image tag |
| gateway.image.digest | string | `nil` | Overrides the gateway image tag with an image digest |
| gateway.image.pullPolicy | string | `"IfNotPresent"` | The gateway image pull policy |
| gateway.priorityClassName | string | `nil` | The name of the PriorityClass for gateway pods |
| gateway.annotations | object | `{}` | Annotations for gateway deployment |
| gateway.podAnnotations | object | `{}` | Annotations for gateway pods |
| gateway.podLabels | object | `{}` | Additional labels for gateway pods |
| gateway.extraArgs | list | `[]` | Additional CLI args for the gateway |
| gateway.extraEnv | list | `[]` | Environment variables to add to the gateway pods |
| gateway.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the gateway pods |
| gateway.lifecycle | object | `{}` | Lifecycle for the gateway container |
| gateway.extraVolumes | list | `[]` | Volumes to add to the gateway pods |
| gateway.extraVolumeMounts | list | `[]` | Volume mounts to add to the gateway pods |
| gateway.podSecurityContext | object | `{"fsGroup":101,"runAsGroup":101,"runAsNonRoot":true,"runAsUser":101}` | The SecurityContext for gateway containers |
| gateway.containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true}` | The SecurityContext for gateway containers |
| gateway.resources | object | `{}` | Resource requests and limits for the gateway |
| gateway.extraContainers | list | `[]` | Containers to add to the gateway pods |
| gateway.terminationGracePeriodSeconds | int | `30` | Grace period to allow the gateway to shutdown before it is killed |
| gateway.affinity | object | Hard node anti-affinity | Affinity for gateway pods. |
| gateway.dnsConfig | object | `{}` | DNS config for gateway pods |
| gateway.nodeSelector | object | `{}` | Node selector for gateway pods |
| gateway.topologySpreadConstraints | list | `[]` | Topology Spread Constraints for gateway pods |
| gateway.tolerations | list | `[]` | Tolerations for gateway pods |
| gateway.service.port | int | `80` | Port of the gateway service |
| gateway.service.type | string | `"ClusterIP"` | Type of the gateway service |
| gateway.service.clusterIP | string | `nil` | ClusterIP of the gateway service |
| gateway.service.nodePort | int | `nil` | Node port if service type is NodePort |
| gateway.service.loadBalancerIP | string | `nil` | Load balancer IPO address if service type is LoadBalancer |
| gateway.service.annotations | object | `{}` | Annotations for the gateway service |
| gateway.service.labels | object | `{}` | Labels for gateway service |
| gateway.ingress.enabled | bool | `false` | Specifies whether an ingress for the gateway should be created |
| gateway.ingress.ingressClassName | string | `""` | Ingress Class Name. MAY be required for Kubernetes versions >= 1.18 |
| gateway.ingress.annotations | object | `{}` | Annotations for the gateway ingress |
| gateway.ingress.labels | object | `{}` | Labels for the gateway ingress |
| gateway.ingress.hosts | list | `[{"host":"gateway.loki.example.com","paths":[{"path":"/"}]}]` | Hosts configuration for the gateway ingress, passed through the `tpl` function to allow templating |
| gateway.ingress.tls | list | `[{"hosts":["gateway.loki.example.com"],"secretName":"loki-gateway-tls"}]` | TLS configuration for the gateway ingress. Hosts passed through the `tpl` function to allow templating |
| gateway.basicAuth.enabled | bool | `false` | Enables basic authentication for the gateway |
| gateway.basicAuth.username | string | `nil` | The basic auth username for the gateway |
| gateway.basicAuth.password | string | `nil` | The basic auth password for the gateway |
| gateway.basicAuth.htpasswd | string | `"{{ if .Values.loki.tenants }}\n\n\n  {{- range $t := .Values.loki.tenants }}\n{{ htpasswd (required \"All tenants must have a 'name' set\" $t.name) (required \"All tenants must have a 'password' set\" $t.password) }}\n\n\n\n\n\n  {{- end }}\n{{ else }} {{ htpasswd (required \"'gateway.basicAuth.username' is required\" .Values.gateway.basicAuth.username) (required \"'gateway.basicAuth.password' is required\" .Values.gateway.basicAuth.password) }} {{ end }}"` | Uses the specified users from the `loki.tenants` list to create the htpasswd file if `loki.tenants` is not set, the `gateway.basicAuth.username` and `gateway.basicAuth.password` are used The value is templated using `tpl`. Override this to use a custom htpasswd, e.g. in case the default causes high CPU load. |
| gateway.basicAuth.existingSecret | string | `nil` | Existing basic auth secret to use. Must contain '.htpasswd' |
| gateway.readinessProbe.httpGet.path | string | `"/"` |  |
| gateway.readinessProbe.httpGet.port | string | `"http-metrics"` |  |
| gateway.readinessProbe.initialDelaySeconds | int | `15` |  |
| gateway.readinessProbe.timeoutSeconds | int | `1` |  |
| gateway.nginxConfig.schema | string | `"http"` | Which schema to be used when building URLs. Can be 'http' or 'https'. |
| gateway.nginxConfig.enableIPv6 | bool | `true` | Enable listener for IPv6, disable on IPv4-only systems |
| gateway.nginxConfig.logFormat | string | `"main '$remote_addr - $remote_user [$time_local]  $status '\n        '\"$request\" $body_bytes_sent \"$http_referer\" '\n        '\"$http_user_agent\" \"$http_x_forwarded_for\"';"` | NGINX log format |
| gateway.nginxConfig.serverSnippet | string | `""` | Allows appending custom configuration to the server block |
| gateway.nginxConfig.httpSnippet | string | `"{{ if .Values.loki.tenants }}proxy_set_header X-Scope-OrgID $remote_user;{{ end }}"` | Allows appending custom configuration to the http block, passed through the `tpl` function to allow templating |
| gateway.nginxConfig.ssl | bool | `false` | Whether ssl should be appended to the listen directive of the server block or not. |
| gateway.nginxConfig.customReadUrl | string | `nil` | Override Read URL |
| gateway.nginxConfig.customWriteUrl | string | `nil` | Override Write URL |
| gateway.nginxConfig.customBackendUrl | string | `nil` | Override Backend URL |
| gateway.nginxConfig.resolver | string | `""` | Allows overriding the DNS resolver address nginx will use. |
| gateway.nginxConfig.file | string | See values.yaml | Config file contents for Nginx. Passed through the `tpl` function to allow templating |
| gateway.podDisruptionBudget.minAvailable | string | `""` (defaults to 0 if not specified) | Number of pods that are available after eviction as number or percentage (eg.: 50%) |
| gateway.podDisruptionBudget.maxUnavailable | string | `"1"` | Number of pods that are unavailable after eviction as number or percentage (eg.: 50%). # Has higher precedence over `controller.pdb.minAvailable` |
| enterpriseGateway.replicas | int | `1` | Define the amount of instances |
| enterpriseGateway.hostAliases | list | `[]` | hostAliases to add |
| enterpriseGateway.extraArgs | object | `{}` | Additional CLI arguments for the `gateway` target |
| enterpriseGateway.labels | object | `{}` | Additional labels for the `gateway` Pod |
| enterpriseGateway.annotations | object | `{}` | Additional annotations for the `gateway` Pod |
| enterpriseGateway.service | object | `{"annotations":{},"labels":{},"type":"ClusterIP"}` | Service overriding service type |
| enterpriseGateway.podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001}` | Run container as user `enterprise-logs(uid=10001)` |
| enterpriseGateway.containerSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
| enterpriseGateway.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| enterpriseGateway.containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| enterpriseGateway.useDefaultProxyURLs | bool | `true` | If you want to use your own proxy URLs, set this to false. |
| enterpriseGateway.strategy | object | `{"type":"RollingUpdate"}` | update strategy |
| enterpriseGateway.readinessProbe | object | `{"httpGet":{"path":"/ready","port":"http-metrics"},"initialDelaySeconds":45}` | Readiness probe |
| enterpriseGateway.resources | object | `{}` | Values are defined in small.yaml and large.yaml |
| enterpriseGateway.env | list | `[]` | Configure optional environment variables |
| enterpriseGateway.initContainers | list | `[]` | Configure optional initContainers |
| enterpriseGateway.extraContainers | list | `[]` | Conifgure optional extraContainers |
| enterpriseGateway.extraVolumes | list | `[]` | Additional volumes for Pods |
| enterpriseGateway.extraVolumeMounts | list | `[]` | Additional volume mounts for Pods |
| enterpriseGateway.affinity | object | `{}` | Affinity for gateway Pods |
| enterpriseGateway.nodeSelector | object | `{}` | Node selector for gateway Pods |
| enterpriseGateway.tolerations | list | `[]` | Tolerations for gateway Pods |
| enterpriseGateway.terminationGracePeriodSeconds | int | `60` | Grace period to allow the gateway to shutdown before it is killed |
| ingress | object | `{"annotations":{},"enabled":false,"hosts":["loki.example.com"],"ingressClassName":"","labels":{},"paths":{"read":["/api/prom/tail","/loki/api/v1/tail","/loki/api","/api/prom/rules","/loki/api/v1/rules","/prometheus/api/v1/rules","/prometheus/api/v1/alerts"],"singleBinary":["/api/prom/push","/loki/api/v1/push","/api/prom/tail","/loki/api/v1/tail","/loki/api","/api/prom/rules","/loki/api/v1/rules","/prometheus/api/v1/rules","/prometheus/api/v1/alerts"],"write":["/api/prom/push","/loki/api/v1/push"]},"tls":[]}` | Ingress configuration Use either this ingress or the gateway, but not both at once. If you enable this, make sure to disable the gateway. You'll need to supply authn configuration for your ingress controller. |
| ingress.hosts | list | `["loki.example.com"]` | Hosts configuration for the ingress, passed through the `tpl` function to allow templating |
| ingress.tls | list | `[]` | TLS configuration for the ingress. Hosts passed through the `tpl` function to allow templating |
| migrate | object | `{"fromDistributed":{"enabled":false,"memberlistService":""}}` | Options that may be necessary when performing a migration from another helm chart |
| migrate.fromDistributed | object | `{"enabled":false,"memberlistService":""}` | When migrating from a distributed chart like loki-distributed or enterprise-logs |
| migrate.fromDistributed.enabled | bool | `false` | Set to true if migrating from a distributed helm chart |
| migrate.fromDistributed.memberlistService | string | `""` | If migrating from a distributed service, provide the distributed deployment's memberlist service DNS so the new deployment can join its ring. |
| singleBinary.replicas | int | `1` | Number of replicas for the single binary |
| singleBinary.autoscaling.enabled | bool | `false` | Enable autoscaling |
| singleBinary.autoscaling.minReplicas | int | `1` | Minimum autoscaling replicas for the single binary |
| singleBinary.autoscaling.maxReplicas | int | `3` | Maximum autoscaling replicas for the single binary |
| singleBinary.autoscaling.targetCPUUtilizationPercentage | int | `60` | Target CPU utilisation percentage for the single binary |
| singleBinary.autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Target memory utilisation percentage for the single binary |
| singleBinary.image.registry | string | `nil` | The Docker registry for the single binary image. Overrides `loki.image.registry` |
| singleBinary.image.repository | string | `nil` | Docker image repository for the single binary image. Overrides `loki.image.repository` |
| singleBinary.image.tag | string | `nil` | Docker image tag for the single binary image. Overrides `loki.image.tag` |
| singleBinary.priorityClassName | string | `nil` | The name of the PriorityClass for single binary pods |
| singleBinary.annotations | object | `{}` | Annotations for single binary StatefulSet |
| singleBinary.podAnnotations | object | `{}` | Annotations for single binary pods |
| singleBinary.podLabels | object | `{}` | Additional labels for each `single binary` pod |
| singleBinary.selectorLabels | object | `{}` | Additional selector labels for each `single binary` pod |
| singleBinary.service.annotations | object | `{}` | Annotations for single binary Service |
| singleBinary.service.labels | object | `{}` | Additional labels for single binary Service |
| singleBinary.targetModule | string | `"all"` | Comma-separated list of Loki modules to load for the single binary |
| singleBinary.extraArgs | list | `[]` | Labels for single binary service |
| singleBinary.extraEnv | list | `[]` | Environment variables to add to the single binary pods |
| singleBinary.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the single binary pods |
| singleBinary.extraContainers | list | `[]` | Extra containers to add to the single binary loki pod |
| singleBinary.initContainers | list | `[]` | Init containers to add to the single binary pods |
| singleBinary.extraVolumeMounts | list | `[]` | Volume mounts to add to the single binary pods |
| singleBinary.extraVolumes | list | `[]` | Volumes to add to the single binary pods |
| singleBinary.resources | object | `{"limits":{"cpu":"100m","memory":"256Mi"},"requests":{"cpu":"100m","memory":"256Mi"}}` | Resource requests and limits for the single binary |
| singleBinary.terminationGracePeriodSeconds | int | `30` | Grace period to allow the single binary to shutdown before it is killed |
| singleBinary.affinity | object | Hard node anti-affinity | Affinity for single binary pods. |
| singleBinary.dnsConfig | object | `{}` | DNS config for single binary pods |
| singleBinary.nodeSelector | object | `{}` | Node selector for single binary pods |
| singleBinary.tolerations | list | `[]` | Tolerations for single binary pods |
| singleBinary.persistence.enableStatefulSetAutoDeletePVC | bool | `false` | Enable StatefulSetAutoDeletePVC feature |
| singleBinary.persistence.enabled | bool | `true` | Enable persistent disk |
| singleBinary.persistence.size | string | `"12Gi"` | Size of persistent disk |
| singleBinary.persistence.storageClass | string | `nil` | Storage class to be used. If defined, storageClassName: <storageClass>. If set to "-", storageClassName: "", which disables dynamic provisioning. If empty or set to null, no storageClassName spec is set, choosing the default provisioner (gp2 on AWS, standard on GKE, AWS, and OpenStack). |
| singleBinary.persistence.selector | string | `nil` | Selector for persistent disk |
| write.replicas | int | `0` | Number of replicas for the write |
| write.autoscaling.enabled | bool | `false` | Enable autoscaling for the write. |
| write.autoscaling.minReplicas | int | `2` | Minimum autoscaling replicas for the write. |
| write.autoscaling.maxReplicas | int | `6` | Maximum autoscaling replicas for the write. |
| write.autoscaling.targetCPUUtilizationPercentage | int | `60` | Target CPU utilisation percentage for the write. |
| write.autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Target memory utilization percentage for the write. |
| write.autoscaling.behavior | object | `{"scaleDown":{"policies":[{"periodSeconds":1800,"type":"Pods","value":1}],"stabilizationWindowSeconds":3600},"scaleUp":{"policies":[{"periodSeconds":900,"type":"Pods","value":1}]}}` | Behavior policies while scaling. |
| write.autoscaling.behavior.scaleUp | object | `{"policies":[{"periodSeconds":900,"type":"Pods","value":1}]}` | see https://github.com/grafana/loki/blob/main/docs/sources/operations/storage/wal.md#how-to-scale-updown for scaledown details |
| write.image.registry | string | `nil` | The Docker registry for the write image. Overrides `loki.image.registry` |
| write.image.repository | string | `nil` | Docker image repository for the write image. Overrides `loki.image.repository` |
| write.image.tag | string | `nil` | Docker image tag for the write image. Overrides `loki.image.tag` |
| write.priorityClassName | string | `nil` | The name of the PriorityClass for write pods |
| write.annotations | object | `{}` | Annotations for write StatefulSet |
| write.podAnnotations | object | `{}` | Annotations for write pods |
| write.podLabels | object | `{}` | Additional labels for each `write` pod |
| write.selectorLabels | object | `{}` | Additional selector labels for each `write` pod |
| write.service.annotations | object | `{}` | Annotations for write Service |
| write.service.labels | object | `{}` | Additional labels for write Service |
| write.targetModule | string | `"write"` | Comma-separated list of Loki modules to load for the write |
| write.extraArgs | list | `[]` | Additional CLI args for the write |
| write.extraEnv | list | `[]` | Environment variables to add to the write pods |
| write.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the write pods |
| write.lifecycle | object | `{}` | Lifecycle for the write container |
| write.initContainers | list | `[]` | Init containers to add to the write pods |
| write.extraContainers | list | `[]` | Containers to add to the write pods |
| write.extraVolumeMounts | list | `[]` | Volume mounts to add to the write pods |
| write.extraVolumes | list | `[]` | Volumes to add to the write pods |
| write.extraVolumeClaimTemplates | list | `[]` | volumeClaimTemplates to add to StatefulSet |
| write.resources | object | `{"limits":{"cpu":"300m","memory":"2Gi"},"requests":{"cpu":"300m","memory":"2Gi"}}` | Resource requests and limits for the write |
| write.terminationGracePeriodSeconds | int | `300` | Grace period to allow the write to shutdown before it is killed. Especially for the ingester, this must be increased. It must be long enough so writes can be gracefully shutdown flushing/transferring all data and to successfully leave the member ring on shutdown. |
| write.affinity | object | Hard node anti-affinity | Affinity for write pods. |
| write.dnsConfig | object | `{}` | DNS config for write pods |
| write.nodeSelector | object | `{}` | Node selector for write pods |
| write.topologySpreadConstraints | list | `[]` | Topology Spread Constraints for write pods |
| write.tolerations | list | `[]` | Tolerations for write pods |
| write.podManagementPolicy | string | `"Parallel"` | The default is to deploy all pods in parallel. |
| write.persistence.volumeClaimsEnabled | bool | `true` | Enable volume claims in pod spec |
| write.persistence.dataVolumeParameters | object | `{"emptyDir":{}}` | Parameters used for the `data` volume when volumeClaimEnabled if false |
| write.persistence.enableStatefulSetAutoDeletePVC | bool | `false` | Enable StatefulSetAutoDeletePVC feature |
| write.persistence.size | string | `"10Gi"` | Size of persistent disk |
| write.persistence.storageClass | string | `nil` | Storage class to be used. If defined, storageClassName: <storageClass>. If set to "-", storageClassName: "", which disables dynamic provisioning. If empty or set to null, no storageClassName spec is set, choosing the default provisioner (gp2 on AWS, standard on GKE, AWS, and OpenStack). |
| write.persistence.selector | string | `nil` | Selector for persistent disk |
| write.podDisruptionBudget.minAvailable | string | `""` (defaults to 0 if not specified) | Number of pods that are available after eviction as number or percentage (eg.: 50%) |
| write.podDisruptionBudget.maxUnavailable | string | `"1"` | Number of pods that are unavailable after eviction as number or percentage (eg.: 50%). # Has higher precedence over `controller.pdb.minAvailable` |
| read | object | `{"affinity":{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"app.kubernetes.io/component":"read"}},"topologyKey":"kubernetes.io/hostname"}]}},"annotations":{},"autoscaling":{"behavior":{},"enabled":false,"maxReplicas":6,"minReplicas":2,"targetCPUUtilizationPercentage":60,"targetMemoryUtilizationPercentage":null},"dnsConfig":{},"extraArgs":[],"extraContainers":[],"extraEnv":[],"extraEnvFrom":[],"extraVolumeMounts":[],"extraVolumes":[],"image":{"registry":null,"repository":null,"tag":null},"legacyReadTarget":false,"lifecycle":{},"nodeSelector":{},"persistence":{"enableStatefulSetAutoDeletePVC":true,"selector":null,"size":"10Gi","storageClass":null},"podAnnotations":{},"podDisruptionBudget":{"maxUnavailable":"1","minAvailable":""},"podLabels":{},"podManagementPolicy":"Parallel","priorityClassName":null,"replicas":0,"resources":{"limits":{"cpu":"300m","memory":"2Gi"},"requests":{"cpu":"300m","memory":"2Gi"}},"selectorLabels":{},"service":{"annotations":{},"labels":{}},"targetModule":"read","terminationGracePeriodSeconds":30,"tolerations":[],"topologySpreadConstraints":[]}` | Configuration for the read pod(s) |
| read.replicas | int | `0` | Number of replicas for the read |
| read.autoscaling.enabled | bool | `false` | Enable autoscaling for the read, this is only used if `queryIndex.enabled: true` |
| read.autoscaling.minReplicas | int | `2` | Minimum autoscaling replicas for the read |
| read.autoscaling.maxReplicas | int | `6` | Maximum autoscaling replicas for the read |
| read.autoscaling.targetCPUUtilizationPercentage | int | `60` | Target CPU utilisation percentage for the read |
| read.autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Target memory utilisation percentage for the read |
| read.autoscaling.behavior | object | `{}` | Behavior policies while scaling. |
| read.image.registry | string | `nil` | The Docker registry for the read image. Overrides `loki.image.registry` |
| read.image.repository | string | `nil` | Docker image repository for the read image. Overrides `loki.image.repository` |
| read.image.tag | string | `nil` | Docker image tag for the read image. Overrides `loki.image.tag` |
| read.priorityClassName | string | `nil` | The name of the PriorityClass for read pods |
| read.annotations | object | `{}` | Annotations for read deployment |
| read.podAnnotations | object | `{}` | Annotations for read pods |
| read.podLabels | object | `{}` | Additional labels for each `read` pod |
| read.selectorLabels | object | `{}` | Additional selector labels for each `read` pod |
| read.service.annotations | object | `{}` | Annotations for read Service |
| read.service.labels | object | `{}` | Additional labels for read Service |
| read.targetModule | string | `"read"` | Comma-separated list of Loki modules to load for the read |
| read.legacyReadTarget | bool | `false` | Whether or not to use the 2 target type simple scalable mode (read, write) or the 3 target type (read, write, backend). Legacy refers to the 2 target type, so true will run two targets, false will run 3 targets. |
| read.extraArgs | list | `[]` | Additional CLI args for the read |
| read.extraContainers | list | `[]` | Containers to add to the read pods |
| read.extraEnv | list | `[]` | Environment variables to add to the read pods |
| read.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the read pods |
| read.lifecycle | object | `{}` | Lifecycle for the read container |
| read.extraVolumeMounts | list | `[]` | Volume mounts to add to the read pods |
| read.extraVolumes | list | `[]` | Volumes to add to the read pods |
| read.resources | object | `{"limits":{"cpu":"300m","memory":"2Gi"},"requests":{"cpu":"300m","memory":"2Gi"}}` | Resource requests and limits for the read |
| read.terminationGracePeriodSeconds | int | `30` | Grace period to allow the read to shutdown before it is killed |
| read.affinity | object | Hard node anti-affinity | Affinity for read pods. |
| read.dnsConfig | object | `{}` | DNS config for read pods |
| read.nodeSelector | object | `{}` | Node selector for read pods |
| read.topologySpreadConstraints | list | `[]` | Topology Spread Constraints for read pods |
| read.tolerations | list | `[]` | Tolerations for read pods |
| read.podManagementPolicy | string | `"Parallel"` | The default is to deploy all pods in parallel. |
| read.persistence.enableStatefulSetAutoDeletePVC | bool | `true` | Enable StatefulSetAutoDeletePVC feature |
| read.persistence.size | string | `"10Gi"` | Size of persistent disk |
| read.persistence.storageClass | string | `nil` | Storage class to be used. If defined, storageClassName: <storageClass>. If set to "-", storageClassName: "", which disables dynamic provisioning. If empty or set to null, no storageClassName spec is set, choosing the default provisioner (gp2 on AWS, standard on GKE, AWS, and OpenStack). |
| read.persistence.selector | string | `nil` | Selector for persistent disk |
| read.podDisruptionBudget.minAvailable | string | `""` (defaults to 0 if not specified) | Number of pods that are available after eviction as number or percentage (eg.: 50%) |
| read.podDisruptionBudget.maxUnavailable | string | `"1"` | Number of pods that are unavailable after eviction as number or percentage (eg.: 50%). # Has higher precedence over `controller.pdb.minAvailable` |
| backend | object | `{"affinity":{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"app.kubernetes.io/component":"backend"}},"topologyKey":"kubernetes.io/hostname"}]}},"annotations":{},"autoscaling":{"behavior":{},"enabled":false,"maxReplicas":6,"minReplicas":3,"targetCPUUtilizationPercentage":60,"targetMemoryUtilizationPercentage":null},"dnsConfig":{},"extraArgs":[],"extraEnv":[],"extraEnvFrom":[],"extraVolumeMounts":[],"extraVolumes":[],"image":{"registry":null,"repository":null,"tag":null},"initContainers":[],"nodeSelector":{},"persistence":{"dataVolumeParameters":{"emptyDir":{}},"enableStatefulSetAutoDeletePVC":true,"selector":null,"size":"10Gi","storageClass":null,"volumeClaimsEnabled":true},"podAnnotations":{},"podDisruptionBudget":{"maxUnavailable":"1","minAvailable":""},"podLabels":{},"podManagementPolicy":"Parallel","priorityClassName":null,"replicas":0,"resources":{},"selectorLabels":{},"service":{"annotations":{},"labels":{}},"targetModule":"backend","terminationGracePeriodSeconds":300,"tolerations":[],"topologySpreadConstraints":[]}` | Configuration for the backend pod(s) |
| backend.replicas | int | `0` | Number of replicas for the backend |
| backend.autoscaling.enabled | bool | `false` | Enable autoscaling for the backend. |
| backend.autoscaling.minReplicas | int | `3` | Minimum autoscaling replicas for the backend. |
| backend.autoscaling.maxReplicas | int | `6` | Maximum autoscaling replicas for the backend. |
| backend.autoscaling.targetCPUUtilizationPercentage | int | `60` | Target CPU utilization percentage for the backend. |
| backend.autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Target memory utilization percentage for the backend. |
| backend.autoscaling.behavior | object | `{}` | Behavior policies while scaling. |
| backend.image.registry | string | `nil` | The Docker registry for the backend image. Overrides `loki.image.registry` |
| backend.image.repository | string | `nil` | Docker image repository for the backend image. Overrides `loki.image.repository` |
| backend.image.tag | string | `nil` | Docker image tag for the backend image. Overrides `loki.image.tag` |
| backend.priorityClassName | string | `nil` | The name of the PriorityClass for backend pods |
| backend.annotations | object | `{}` | Annotations for backend StatefulSet |
| backend.podAnnotations | object | `{}` | Annotations for backend pods |
| backend.podLabels | object | `{}` | Additional labels for each `backend` pod |
| backend.selectorLabels | object | `{}` | Additional selector labels for each `backend` pod |
| backend.service.annotations | object | `{}` | Annotations for backend Service |
| backend.service.labels | object | `{}` | Additional labels for backend Service |
| backend.targetModule | string | `"backend"` | Comma-separated list of Loki modules to load for the read |
| backend.extraArgs | list | `[]` | Additional CLI args for the backend |
| backend.extraEnv | list | `[]` | Environment variables to add to the backend pods |
| backend.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the backend pods |
| backend.initContainers | list | `[]` | Init containers to add to the backend pods |
| backend.extraVolumeMounts | list | `[]` | Volume mounts to add to the backend pods |
| backend.extraVolumes | list | `[]` | Volumes to add to the backend pods |
| backend.resources | object | `{}` | Resource requests and limits for the backend |
| backend.terminationGracePeriodSeconds | int | `300` | Grace period to allow the backend to shutdown before it is killed. Especially for the ingester, this must be increased. It must be long enough so backends can be gracefully shutdown flushing/transferring all data and to successfully leave the member ring on shutdown. |
| backend.affinity | object | Hard node anti-affinity | Affinity for backend pods. |
| backend.dnsConfig | object | `{}` | DNS config for backend pods |
| backend.nodeSelector | object | `{}` | Node selector for backend pods |
| backend.topologySpreadConstraints | list | `[]` | Topology Spread Constraints for backend pods |
| backend.tolerations | list | `[]` | Tolerations for backend pods |
| backend.podManagementPolicy | string | `"Parallel"` | The default is to deploy all pods in parallel. |
| backend.persistence.volumeClaimsEnabled | bool | `true` | Enable volume claims in pod spec |
| backend.persistence.dataVolumeParameters | object | `{"emptyDir":{}}` | Parameters used for the `data` volume when volumeClaimEnabled if false |
| backend.persistence.enableStatefulSetAutoDeletePVC | bool | `true` | Enable StatefulSetAutoDeletePVC feature |
| backend.persistence.size | string | `"10Gi"` | Size of persistent disk |
| backend.persistence.storageClass | string | `nil` | Storage class to be used. If defined, storageClassName: <storageClass>. If set to "-", storageClassName: "", which disables dynamic provisioning. If empty or set to null, no storageClassName spec is set, choosing the default provisioner (gp2 on AWS, standard on GKE, AWS, and OpenStack). |
| backend.persistence.selector | string | `nil` | Selector for persistent disk |
| backend.podDisruptionBudget.minAvailable | string | `""` (defaults to 0 if not specified) | Number of pods that are available after eviction as number or percentage (eg.: 50%) |
| backend.podDisruptionBudget.maxUnavailable | string | `"1"` | Number of pods that are unavailable after eviction as number or percentage (eg.: 50%). # Has higher precedence over `controller.pdb.minAvailable` |
| ingester | object | `{"affinity":{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"app.kubernetes.io/component":"ingester"}},"topologyKey":"kubernetes.io/hostname"}]}},"appProtocol":{"grpc":""},"autoscaling":{"behavior":{"enabled":false,"scaleDown":{},"scaleUp":{}},"customMetrics":[],"enabled":false,"maxReplicas":3,"minReplicas":1,"targetCPUUtilizationPercentage":60,"targetMemoryUtilizationPercentage":null},"command":null,"extraArgs":[],"extraContainers":[],"extraEnv":[],"extraEnvFrom":[],"extraVolumeMounts":[],"extraVolumes":[],"hostAliases":[],"image":{"registry":null,"repository":null,"tag":null},"initContainers":[],"lifecycle":{},"livenessProbe":{},"maxUnavailable":1,"nodeSelector":{},"persistence":{"claims":[{"name":"data","size":"10Gi","storageClass":null}],"enableStatefulSetAutoDeletePVC":false,"enabled":false,"inMemory":false,"whenDeleted":"Retain","whenScaled":"Retain"},"podAnnotations":{},"podLabels":{},"priorityClassName":null,"readinessProbe":{},"replicas":0,"resources":{},"serviceLabels":{},"terminationGracePeriodSeconds":300,"tolerations":[],"topologySpreadConstraints":[{"labelSelector":{"matchLabels":{"app.kubernetes.io/component":"ingester"}},"maxSkew":1,"topologyKey":"kubernetes.io/hostname","whenUnsatisfiable":"ScheduleAnyway"}],"zoneAwareReplication":{"enabled":true,"maxUnavailablePct":33,"migration":{"enabled":false,"excludeDefaultZone":false,"readPath":false,"writePath":false},"zoneA":{"annotations":{},"extraAffinity":{},"nodeSelector":null,"podAnnotations":{}},"zoneB":{"annotations":{},"extraAffinity":{},"nodeSelector":null,"podAnnotations":{}},"zoneC":{"annotations":{},"extraAffinity":{},"nodeSelector":null,"podAnnotations":{}}}}` | Configuration for the ingester |
| ingester.replicas | int | `0` | Number of replicas for the ingester, when zoneAwareReplication.enabled is true, the total number of replicas will match this value with each zone having 1/3rd of the total replicas. |
| ingester.hostAliases | list | `[]` | hostAliases to add |
| ingester.autoscaling.enabled | bool | `false` | Enable autoscaling for the ingester |
| ingester.autoscaling.minReplicas | int | `1` | Minimum autoscaling replicas for the ingester |
| ingester.autoscaling.maxReplicas | int | `3` | Maximum autoscaling replicas for the ingester |
| ingester.autoscaling.targetCPUUtilizationPercentage | int | `60` | Target CPU utilisation percentage for the ingester |
| ingester.autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Target memory utilisation percentage for the ingester |
| ingester.autoscaling.customMetrics | list | `[]` | Allows one to define custom metrics using the HPA/v2 schema (for example, Pods, Object or External metrics) |
| ingester.autoscaling.behavior.enabled | bool | `false` | Enable autoscaling behaviours |
| ingester.autoscaling.behavior.scaleDown | object | `{}` | define scale down policies, must conform to HPAScalingRules |
| ingester.autoscaling.behavior.scaleUp | object | `{}` | define scale up policies, must conform to HPAScalingRules |
| ingester.image.registry | string | `nil` | The Docker registry for the ingester image. Overrides `loki.image.registry` |
| ingester.image.repository | string | `nil` | Docker image repository for the ingester image. Overrides `loki.image.repository` |
| ingester.image.tag | string | `nil` | Docker image tag for the ingester image. Overrides `loki.image.tag` |
| ingester.command | string | `nil` | Command to execute instead of defined in Docker image |
| ingester.podLabels | object | `{}` | Labels for ingester pods |
| ingester.podAnnotations | object | `{}` | Annotations for ingester pods |
| ingester.serviceLabels | object | `{}` | Labels for ingestor service |
| ingester.extraArgs | list | `[]` | Additional CLI args for the ingester |
| ingester.extraEnv | list | `[]` | Environment variables to add to the ingester pods |
| ingester.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the ingester pods |
| ingester.extraVolumeMounts | list | `[]` | Volume mounts to add to the ingester pods |
| ingester.extraVolumes | list | `[]` | Volumes to add to the ingester pods |
| ingester.resources | object | `{}` | Resource requests and limits for the ingester |
| ingester.extraContainers | list | `[]` | Containers to add to the ingester pods |
| ingester.initContainers | list | `[]` | Init containers to add to the ingester pods |
| ingester.terminationGracePeriodSeconds | int | `300` | Grace period to allow the ingester to shutdown before it is killed. Especially for the ingestor, this must be increased. It must be long enough so ingesters can be gracefully shutdown flushing/transferring all data and to successfully leave the member ring on shutdown. |
| ingester.lifecycle | object | `{}` | Lifecycle for the ingester container |
| ingester.topologySpreadConstraints | list | Defaults to allow skew no more than 1 node | topologySpread for ingester pods. |
| ingester.affinity | object | Hard node anti-affinity | Affinity for ingester pods. Ignored if zoneAwareReplication is enabled. |
| ingester.maxUnavailable | int | `1` | Pod Disruption Budget maxUnavailable |
| ingester.nodeSelector | object | `{}` | Node selector for ingester pods |
| ingester.tolerations | list | `[]` | Tolerations for ingester pods |
| ingester.readinessProbe | object | `{}` | readiness probe settings for ingester pods. If empty, use `loki.readinessProbe` |
| ingester.livenessProbe | object | `{}` | liveness probe settings for ingester pods. If empty use `loki.livenessProbe` |
| ingester.persistence.enabled | bool | `false` | Enable creating PVCs which is required when using boltdb-shipper |
| ingester.persistence.inMemory | bool | `false` | Use emptyDir with ramdisk for storage. **Please note that all data in ingester will be lost on pod restart** |
| ingester.persistence.claims | list |  | List of the ingester PVCs |
| ingester.persistence.enableStatefulSetAutoDeletePVC | bool | `false` | Enable StatefulSetAutoDeletePVC feature |
| ingester.appProtocol | object | `{"grpc":""}` | Adds the appProtocol field to the ingester service. This allows ingester to work with istio protocol selection. |
| ingester.appProtocol.grpc | string | `""` | Set the optional grpc service protocol. Ex: "grpc", "http2" or "https" |
| ingester.zoneAwareReplication | object | `{"enabled":true,"maxUnavailablePct":33,"migration":{"enabled":false,"excludeDefaultZone":false,"readPath":false,"writePath":false},"zoneA":{"annotations":{},"extraAffinity":{},"nodeSelector":null,"podAnnotations":{}},"zoneB":{"annotations":{},"extraAffinity":{},"nodeSelector":null,"podAnnotations":{}},"zoneC":{"annotations":{},"extraAffinity":{},"nodeSelector":null,"podAnnotations":{}}}` | Enabling zone awareness on ingesters will create 3 statefulests where all writes will send a replica to each zone. This is primarily intended to accelerate rollout operations by allowing for multiple ingesters within a single zone to be shutdown and restart simultaneously (the remaining 2 zones will be guaranteed to have at least one copy of the data). Note: This can be used to run Loki over multiple cloud provider availability zones however this is not currently recommended as Loki is not optimized for this and cross zone network traffic costs can become extremely high extremely quickly. Even with zone awareness enabled, it is recommended to run Loki in a single availability zone. |
| ingester.zoneAwareReplication.enabled | bool | `true` | Enable zone awareness. |
| ingester.zoneAwareReplication.maxUnavailablePct | int | `33` | The percent of replicas in each zone that will be restarted at once. In a value of 0-100 |
| ingester.zoneAwareReplication.zoneA | object | `{"annotations":{},"extraAffinity":{},"nodeSelector":null,"podAnnotations":{}}` | zoneA configuration |
| ingester.zoneAwareReplication.zoneA.nodeSelector | string | `nil` | optionally define a node selector for this zone |
| ingester.zoneAwareReplication.zoneA.extraAffinity | object | `{}` | optionally define extra affinity rules, by default different zones are not allowed to schedule on the same host |
| ingester.zoneAwareReplication.zoneA.annotations | object | `{}` | Specific annotations to add to zone A statefulset |
| ingester.zoneAwareReplication.zoneA.podAnnotations | object | `{}` | Specific annotations to add to zone A pods |
| ingester.zoneAwareReplication.zoneB.nodeSelector | string | `nil` | optionally define a node selector for this zone |
| ingester.zoneAwareReplication.zoneB.extraAffinity | object | `{}` | optionally define extra affinity rules, by default different zones are not allowed to schedule on the same host |
| ingester.zoneAwareReplication.zoneB.annotations | object | `{}` | Specific annotations to add to zone B statefulset |
| ingester.zoneAwareReplication.zoneB.podAnnotations | object | `{}` | Specific annotations to add to zone B pods |
| ingester.zoneAwareReplication.zoneC.nodeSelector | string | `nil` | optionally define a node selector for this zone |
| ingester.zoneAwareReplication.zoneC.extraAffinity | object | `{}` | optionally define extra affinity rules, by default different zones are not allowed to schedule on the same host |
| ingester.zoneAwareReplication.zoneC.annotations | object | `{}` | Specific annotations to add to zone C statefulset |
| ingester.zoneAwareReplication.zoneC.podAnnotations | object | `{}` | Specific annotations to add to zone C pods |
| ingester.zoneAwareReplication.migration | object | `{"enabled":false,"excludeDefaultZone":false,"readPath":false,"writePath":false}` | The migration block allows migrating non zone aware ingesters to zone aware ingesters. |
| distributor | object | `{"affinity":{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"app.kubernetes.io/component":"distributor"}},"topologyKey":"kubernetes.io/hostname"}]}},"appProtocol":{"grpc":""},"autoscaling":{"behavior":{"enabled":false,"scaleDown":{},"scaleUp":{}},"customMetrics":[],"enabled":false,"maxReplicas":3,"minReplicas":1,"targetCPUUtilizationPercentage":60,"targetMemoryUtilizationPercentage":null},"command":null,"extraArgs":[],"extraContainers":[],"extraEnv":[],"extraEnvFrom":[],"extraVolumeMounts":[],"extraVolumes":[],"hostAliases":[],"image":{"registry":null,"repository":null,"tag":null},"maxSurge":0,"maxUnavailable":null,"nodeSelector":{},"podAnnotations":{},"podLabels":{},"priorityClassName":null,"replicas":0,"resources":{},"serviceLabels":{},"terminationGracePeriodSeconds":30,"tolerations":[]}` | Configuration for the distributor |
| distributor.replicas | int | `0` | Number of replicas for the distributor |
| distributor.hostAliases | list | `[]` | hostAliases to add |
| distributor.autoscaling.enabled | bool | `false` | Enable autoscaling for the distributor |
| distributor.autoscaling.minReplicas | int | `1` | Minimum autoscaling replicas for the distributor |
| distributor.autoscaling.maxReplicas | int | `3` | Maximum autoscaling replicas for the distributor |
| distributor.autoscaling.targetCPUUtilizationPercentage | int | `60` | Target CPU utilisation percentage for the distributor |
| distributor.autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Target memory utilisation percentage for the distributor |
| distributor.autoscaling.customMetrics | list | `[]` | Allows one to define custom metrics using the HPA/v2 schema (for example, Pods, Object or External metrics) |
| distributor.autoscaling.behavior.enabled | bool | `false` | Enable autoscaling behaviours |
| distributor.autoscaling.behavior.scaleDown | object | `{}` | define scale down policies, must conform to HPAScalingRules |
| distributor.autoscaling.behavior.scaleUp | object | `{}` | define scale up policies, must conform to HPAScalingRules |
| distributor.image.registry | string | `nil` | The Docker registry for the distributor image. Overrides `loki.image.registry` |
| distributor.image.repository | string | `nil` | Docker image repository for the distributor image. Overrides `loki.image.repository` |
| distributor.image.tag | string | `nil` | Docker image tag for the distributor image. Overrides `loki.image.tag` |
| distributor.command | string | `nil` | Command to execute instead of defined in Docker image |
| distributor.priorityClassName | string | `nil` | The name of the PriorityClass for distributor pods |
| distributor.podLabels | object | `{}` | Labels for distributor pods |
| distributor.podAnnotations | object | `{}` | Annotations for distributor pods |
| distributor.serviceLabels | object | `{}` | Labels for distributor service |
| distributor.extraArgs | list | `[]` | Additional CLI args for the distributor |
| distributor.extraEnv | list | `[]` | Environment variables to add to the distributor pods |
| distributor.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the distributor pods |
| distributor.extraVolumeMounts | list | `[]` | Volume mounts to add to the distributor pods |
| distributor.extraVolumes | list | `[]` | Volumes to add to the distributor pods |
| distributor.resources | object | `{}` | Resource requests and limits for the distributor |
| distributor.extraContainers | list | `[]` | Containers to add to the distributor pods |
| distributor.terminationGracePeriodSeconds | int | `30` | Grace period to allow the distributor to shutdown before it is killed |
| distributor.affinity | object | Hard node anti-affinity | Affinity for distributor pods. |
| distributor.maxUnavailable | string | `nil` | Pod Disruption Budget maxUnavailable |
| distributor.maxSurge | int | `0` | Max Surge for distributor pods |
| distributor.nodeSelector | object | `{}` | Node selector for distributor pods |
| distributor.tolerations | list | `[]` | Tolerations for distributor pods |
| distributor.appProtocol | object | `{"grpc":""}` | Adds the appProtocol field to the distributor service. This allows distributor to work with istio protocol selection. |
| distributor.appProtocol.grpc | string | `""` | Set the optional grpc service protocol. Ex: "grpc", "http2" or "https" |
| querier | object | `{"affinity":{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"app.kubernetes.io/component":"querier"}},"topologyKey":"kubernetes.io/hostname"}]}},"appProtocol":{"grpc":""},"autoscaling":{"behavior":{"enabled":false,"scaleDown":{},"scaleUp":{}},"customMetrics":[],"enabled":false,"maxReplicas":3,"minReplicas":1,"targetCPUUtilizationPercentage":60,"targetMemoryUtilizationPercentage":null},"command":null,"dnsConfig":{},"extraArgs":[],"extraContainers":[],"extraEnv":[],"extraEnvFrom":[],"extraVolumeMounts":[],"extraVolumes":[],"hostAliases":[],"image":{"registry":null,"repository":null,"tag":null},"initContainers":[],"maxSurge":0,"maxUnavailable":null,"nodeSelector":{},"persistence":{"annotations":{},"enabled":false,"size":"10Gi","storageClass":null},"podAnnotations":{},"podLabels":{},"priorityClassName":null,"replicas":0,"resources":{"limits":{"cpu":"300m","memory":"2Gi"},"requests":{"cpu":"300m","memory":"2Gi"}},"serviceLabels":{},"terminationGracePeriodSeconds":30,"tolerations":[],"topologySpreadConstraints":[{"labelSelector":{"matchLabels":{"app.kubernetes.io/component":"querier"}},"maxSkew":1,"topologyKey":"kubernetes.io/hostname","whenUnsatisfiable":"ScheduleAnyway"}]}` | Configuration for the querier |
| querier.replicas | int | `0` | Number of replicas for the querier |
| querier.hostAliases | list | `[]` | hostAliases to add |
| querier.autoscaling.enabled | bool | `false` | Enable autoscaling for the querier, this is only used if `indexGateway.enabled: true` |
| querier.autoscaling.minReplicas | int | `1` | Minimum autoscaling replicas for the querier |
| querier.autoscaling.maxReplicas | int | `3` | Maximum autoscaling replicas for the querier |
| querier.autoscaling.targetCPUUtilizationPercentage | int | `60` | Target CPU utilisation percentage for the querier |
| querier.autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Target memory utilisation percentage for the querier |
| querier.autoscaling.customMetrics | list | `[]` | Allows one to define custom metrics using the HPA/v2 schema (for example, Pods, Object or External metrics) |
| querier.autoscaling.behavior.enabled | bool | `false` | Enable autoscaling behaviours |
| querier.autoscaling.behavior.scaleDown | object | `{}` | define scale down policies, must conform to HPAScalingRules |
| querier.autoscaling.behavior.scaleUp | object | `{}` | define scale up policies, must conform to HPAScalingRules |
| querier.image.registry | string | `nil` | The Docker registry for the querier image. Overrides `loki.image.registry` |
| querier.image.repository | string | `nil` | Docker image repository for the querier image. Overrides `loki.image.repository` |
| querier.image.tag | string | `nil` | Docker image tag for the querier image. Overrides `loki.image.tag` |
| querier.command | string | `nil` | Command to execute instead of defined in Docker image |
| querier.priorityClassName | string | `nil` | The name of the PriorityClass for querier pods |
| querier.podLabels | object | `{}` | Labels for querier pods |
| querier.podAnnotations | object | `{}` | Annotations for querier pods |
| querier.serviceLabels | object | `{}` | Labels for querier service |
| querier.extraArgs | list | `[]` | Additional CLI args for the querier |
| querier.extraEnv | list | `[]` | Environment variables to add to the querier pods |
| querier.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the querier pods |
| querier.extraVolumeMounts | list | `[]` | Volume mounts to add to the querier pods |
| querier.extraVolumes | list | `[]` | Volumes to add to the querier pods |
| querier.resources | object | `{"limits":{"cpu":"300m","memory":"2Gi"},"requests":{"cpu":"300m","memory":"2Gi"}}` | Resource requests and limits for the querier |
| querier.extraContainers | list | `[]` | Containers to add to the querier pods |
| querier.initContainers | list | `[]` | Init containers to add to the querier pods |
| querier.terminationGracePeriodSeconds | int | `30` | Grace period to allow the querier to shutdown before it is killed |
| querier.topologySpreadConstraints | list | Defaults to allow skew no more then 1 node | topologySpread for querier pods. |
| querier.affinity | object | Hard node anti-affinity | Affinity for querier pods. |
| querier.maxUnavailable | string | `nil` | Pod Disruption Budget maxUnavailable |
| querier.maxSurge | int | `0` | Max Surge for querier pods |
| querier.nodeSelector | object | `{}` | Node selector for querier pods |
| querier.tolerations | list | `[]` | Tolerations for querier pods |
| querier.dnsConfig | object | `{}` | DNSConfig for querier pods |
| querier.persistence.enabled | bool | `false` | Enable creating PVCs for the querier cache |
| querier.persistence.size | string | `"10Gi"` | Size of persistent disk |
| querier.persistence.storageClass | string | `nil` | Storage class to be used. If defined, storageClassName: <storageClass>. If set to "-", storageClassName: "", which disables dynamic provisioning. If empty or set to null, no storageClassName spec is set, choosing the default provisioner (gp2 on AWS, standard on GKE, AWS, and OpenStack). |
| querier.persistence.annotations | object | `{}` | Annotations for querier PVCs |
| querier.appProtocol | object | `{"grpc":""}` | Adds the appProtocol field to the querier service. This allows querier to work with istio protocol selection. |
| querier.appProtocol.grpc | string | `""` | Set the optional grpc service protocol. Ex: "grpc", "http2" or "https" |
| queryFrontend | object | `{"affinity":{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"app.kubernetes.io/component":"query-frontend"}},"topologyKey":"kubernetes.io/hostname"}]}},"appProtocol":{"grpc":""},"autoscaling":{"behavior":{"enabled":false,"scaleDown":{},"scaleUp":{}},"customMetrics":[],"enabled":false,"maxReplicas":3,"minReplicas":1,"targetCPUUtilizationPercentage":60,"targetMemoryUtilizationPercentage":null},"command":null,"extraArgs":[],"extraContainers":[],"extraEnv":[],"extraEnvFrom":[],"extraVolumeMounts":[],"extraVolumes":[],"hostAliases":[],"image":{"registry":null,"repository":null,"tag":null},"maxUnavailable":null,"nodeSelector":{},"podAnnotations":{},"podLabels":{},"priorityClassName":null,"replicas":0,"resources":{},"serviceLabels":{},"terminationGracePeriodSeconds":30,"tolerations":[]}` | Configuration for the query-frontend |
| queryFrontend.replicas | int | `0` | Number of replicas for the query-frontend |
| queryFrontend.hostAliases | list | `[]` | hostAliases to add |
| queryFrontend.autoscaling.enabled | bool | `false` | Enable autoscaling for the query-frontend |
| queryFrontend.autoscaling.minReplicas | int | `1` | Minimum autoscaling replicas for the query-frontend |
| queryFrontend.autoscaling.maxReplicas | int | `3` | Maximum autoscaling replicas for the query-frontend |
| queryFrontend.autoscaling.targetCPUUtilizationPercentage | int | `60` | Target CPU utilisation percentage for the query-frontend |
| queryFrontend.autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Target memory utilisation percentage for the query-frontend |
| queryFrontend.autoscaling.customMetrics | list | `[]` | Allows one to define custom metrics using the HPA/v2 schema (for example, Pods, Object or External metrics) |
| queryFrontend.autoscaling.behavior.enabled | bool | `false` | Enable autoscaling behaviours |
| queryFrontend.autoscaling.behavior.scaleDown | object | `{}` | define scale down policies, must conform to HPAScalingRules |
| queryFrontend.autoscaling.behavior.scaleUp | object | `{}` | define scale up policies, must conform to HPAScalingRules |
| queryFrontend.image.registry | string | `nil` | The Docker registry for the query-frontend image. Overrides `loki.image.registry` |
| queryFrontend.image.repository | string | `nil` | Docker image repository for the query-frontend image. Overrides `loki.image.repository` |
| queryFrontend.image.tag | string | `nil` | Docker image tag for the query-frontend image. Overrides `loki.image.tag` |
| queryFrontend.command | string | `nil` | Command to execute instead of defined in Docker image |
| queryFrontend.priorityClassName | string | `nil` | The name of the PriorityClass for query-frontend pods |
| queryFrontend.podLabels | object | `{}` | Labels for query-frontend pods |
| queryFrontend.podAnnotations | object | `{}` | Annotations for query-frontend pods |
| queryFrontend.serviceLabels | object | `{}` | Labels for query-frontend service |
| queryFrontend.extraArgs | list | `[]` | Additional CLI args for the query-frontend |
| queryFrontend.extraEnv | list | `[]` | Environment variables to add to the query-frontend pods |
| queryFrontend.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the query-frontend pods |
| queryFrontend.extraVolumeMounts | list | `[]` | Volume mounts to add to the query-frontend pods |
| queryFrontend.extraVolumes | list | `[]` | Volumes to add to the query-frontend pods |
| queryFrontend.resources | object | `{}` | Resource requests and limits for the query-frontend |
| queryFrontend.extraContainers | list | `[]` | Containers to add to the query-frontend pods |
| queryFrontend.terminationGracePeriodSeconds | int | `30` | Grace period to allow the query-frontend to shutdown before it is killed |
| queryFrontend.affinity | object | Hard node anti-affinity | Affinity for query-frontend pods. |
| queryFrontend.maxUnavailable | string | `nil` | Pod Disruption Budget maxUnavailable |
| queryFrontend.nodeSelector | object | `{}` | Node selector for query-frontend pods |
| queryFrontend.tolerations | list | `[]` | Tolerations for query-frontend pods |
| queryFrontend.appProtocol | object | `{"grpc":""}` | Adds the appProtocol field to the queryFrontend service. This allows queryFrontend to work with istio protocol selection. |
| queryFrontend.appProtocol.grpc | string | `""` | Set the optional grpc service protocol. Ex: "grpc", "http2" or "https" |
| queryScheduler | object | `{"affinity":{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"app.kubernetes.io/component":"query-scheduler"}},"topologyKey":"kubernetes.io/hostname"}]}},"appProtocol":{"grpc":""},"extraArgs":[],"extraContainers":[],"extraEnv":[],"extraEnvFrom":[],"extraVolumeMounts":[],"extraVolumes":[],"hostAliases":[],"image":{"registry":null,"repository":null,"tag":null},"maxUnavailable":1,"nodeSelector":{},"podAnnotations":{},"podLabels":{},"priorityClassName":null,"replicas":0,"resources":{},"serviceLabels":{},"terminationGracePeriodSeconds":30,"tolerations":[]}` | Configuration for the query-scheduler |
| queryScheduler.replicas | int | `0` | Number of replicas for the query-scheduler. It should be lower than `-querier.max-concurrent` to avoid generating back-pressure in queriers; it's also recommended that this value evenly divides the latter |
| queryScheduler.hostAliases | list | `[]` | hostAliases to add |
| queryScheduler.image.registry | string | `nil` | The Docker registry for the query-scheduler image. Overrides `loki.image.registry` |
| queryScheduler.image.repository | string | `nil` | Docker image repository for the query-scheduler image. Overrides `loki.image.repository` |
| queryScheduler.image.tag | string | `nil` | Docker image tag for the query-scheduler image. Overrides `loki.image.tag` |
| queryScheduler.priorityClassName | string | `nil` | The name of the PriorityClass for query-scheduler pods |
| queryScheduler.podLabels | object | `{}` | Labels for query-scheduler pods |
| queryScheduler.podAnnotations | object | `{}` | Annotations for query-scheduler pods |
| queryScheduler.serviceLabels | object | `{}` | Labels for query-scheduler service |
| queryScheduler.extraArgs | list | `[]` | Additional CLI args for the query-scheduler |
| queryScheduler.extraEnv | list | `[]` | Environment variables to add to the query-scheduler pods |
| queryScheduler.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the query-scheduler pods |
| queryScheduler.extraVolumeMounts | list | `[]` | Volume mounts to add to the query-scheduler pods |
| queryScheduler.extraVolumes | list | `[]` | Volumes to add to the query-scheduler pods |
| queryScheduler.resources | object | `{}` | Resource requests and limits for the query-scheduler |
| queryScheduler.extraContainers | list | `[]` | Containers to add to the query-scheduler pods |
| queryScheduler.terminationGracePeriodSeconds | int | `30` | Grace period to allow the query-scheduler to shutdown before it is killed |
| queryScheduler.affinity | object | Hard node anti-affinity | Affinity for query-scheduler pods. |
| queryScheduler.maxUnavailable | int | `1` | Pod Disruption Budget maxUnavailable |
| queryScheduler.nodeSelector | object | `{}` | Node selector for query-scheduler pods |
| queryScheduler.tolerations | list | `[]` | Tolerations for query-scheduler pods |
| queryScheduler.appProtocol | object | `{"grpc":""}` | Set the optional grpc service protocol. Ex: "grpc", "http2" or "https" |
| indexGateway | object | `{"affinity":{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"app.kubernetes.io/component":"index-gateway"}},"topologyKey":"kubernetes.io/hostname"}]}},"appProtocol":{"grpc":""},"extraArgs":[],"extraContainers":[],"extraEnv":[],"extraEnvFrom":[],"extraVolumeMounts":[],"extraVolumes":[],"hostAliases":[],"image":{"registry":null,"repository":null,"tag":null},"initContainers":[],"joinMemberlist":true,"maxUnavailable":null,"nodeSelector":{},"persistence":{"annotations":{},"enableStatefulSetAutoDeletePVC":false,"enabled":false,"inMemory":false,"size":"10Gi","storageClass":null,"whenDeleted":"Retain","whenScaled":"Retain"},"podAnnotations":{},"podLabels":{},"priorityClassName":null,"replicas":0,"resources":{},"serviceLabels":{},"terminationGracePeriodSeconds":300,"tolerations":[]}` | Configuration for the index-gateway |
| indexGateway.replicas | int | `0` | Number of replicas for the index-gateway |
| indexGateway.joinMemberlist | bool | `true` | Whether the index gateway should join the memberlist hashring |
| indexGateway.hostAliases | list | `[]` | hostAliases to add |
| indexGateway.image.registry | string | `nil` | The Docker registry for the index-gateway image. Overrides `loki.image.registry` |
| indexGateway.image.repository | string | `nil` | Docker image repository for the index-gateway image. Overrides `loki.image.repository` |
| indexGateway.image.tag | string | `nil` | Docker image tag for the index-gateway image. Overrides `loki.image.tag` |
| indexGateway.priorityClassName | string | `nil` | The name of the PriorityClass for index-gateway pods |
| indexGateway.podLabels | object | `{}` | Labels for index-gateway pods |
| indexGateway.podAnnotations | object | `{}` | Annotations for index-gateway pods |
| indexGateway.serviceLabels | object | `{}` | Labels for index-gateway service |
| indexGateway.extraArgs | list | `[]` | Additional CLI args for the index-gateway |
| indexGateway.extraEnv | list | `[]` | Environment variables to add to the index-gateway pods |
| indexGateway.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the index-gateway pods |
| indexGateway.extraVolumeMounts | list | `[]` | Volume mounts to add to the index-gateway pods |
| indexGateway.extraVolumes | list | `[]` | Volumes to add to the index-gateway pods |
| indexGateway.resources | object | `{}` | Resource requests and limits for the index-gateway |
| indexGateway.extraContainers | list | `[]` | Containers to add to the index-gateway pods |
| indexGateway.initContainers | list | `[]` | Init containers to add to the index-gateway pods |
| indexGateway.terminationGracePeriodSeconds | int | `300` | Grace period to allow the index-gateway to shutdown before it is killed. |
| indexGateway.affinity | object | Hard node anti-affinity | Affinity for index-gateway pods. |
| indexGateway.maxUnavailable | string | `nil` | Pod Disruption Budget maxUnavailable |
| indexGateway.nodeSelector | object | `{}` | Node selector for index-gateway pods |
| indexGateway.tolerations | list | `[]` | Tolerations for index-gateway pods |
| indexGateway.persistence.enabled | bool | `false` | Enable creating PVCs which is required when using boltdb-shipper |
| indexGateway.persistence.inMemory | bool | `false` | Use emptyDir with ramdisk for storage. **Please note that all data in indexGateway will be lost on pod restart** |
| indexGateway.persistence.size | string | `"10Gi"` | Size of persistent or memory disk |
| indexGateway.persistence.storageClass | string | `nil` | Storage class to be used. If defined, storageClassName: <storageClass>. If set to "-", storageClassName: "", which disables dynamic provisioning. If empty or set to null, no storageClassName spec is set, choosing the default provisioner (gp2 on AWS, standard on GKE, AWS, and OpenStack). |
| indexGateway.persistence.annotations | object | `{}` | Annotations for index gateway PVCs |
| indexGateway.persistence.enableStatefulSetAutoDeletePVC | bool | `false` | Enable StatefulSetAutoDeletePVC feature |
| indexGateway.appProtocol | object | `{"grpc":""}` | Set the optional grpc service protocol. Ex: "grpc", "http2" or "https" |
| compactor | object | `{"affinity":{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"app.kubernetes.io/component":"compactor"}},"topologyKey":"kubernetes.io/hostname"}]}},"appProtocol":{"grpc":""},"command":null,"extraArgs":[],"extraContainers":[],"extraEnv":[],"extraEnvFrom":[],"extraVolumeMounts":[],"extraVolumes":[],"hostAliases":[],"image":{"registry":null,"repository":null,"tag":null},"initContainers":[],"livenessProbe":{},"nodeSelector":{},"persistence":{"annotations":{},"claims":[{"name":"data","size":"10Gi","storageClass":null}],"enableStatefulSetAutoDeletePVC":false,"enabled":false,"size":"10Gi","storageClass":null,"whenDeleted":"Retain","whenScaled":"Retain"},"podAnnotations":{},"podLabels":{},"priorityClassName":null,"readinessProbe":{},"replicas":0,"resources":{"limits":{"cpu":"300m","memory":"2Gi"},"requests":{"cpu":"300m","memory":"2Gi"}},"serviceAccount":{"annotations":{},"automountServiceAccountToken":true,"create":false,"imagePullSecrets":[],"name":null},"serviceLabels":{},"terminationGracePeriodSeconds":30,"tolerations":[]}` | Configuration for the compactor |
| compactor.replicas | int | `0` | Number of replicas for the compactor |
| compactor.hostAliases | list | `[]` | hostAliases to add |
| compactor.image.registry | string | `nil` | The Docker registry for the compactor image. Overrides `loki.image.registry` |
| compactor.image.repository | string | `nil` | Docker image repository for the compactor image. Overrides `loki.image.repository` |
| compactor.image.tag | string | `nil` | Docker image tag for the compactor image. Overrides `loki.image.tag` |
| compactor.command | string | `nil` | Command to execute instead of defined in Docker image |
| compactor.priorityClassName | string | `nil` | The name of the PriorityClass for compactor pods |
| compactor.podLabels | object | `{}` | Labels for compactor pods |
| compactor.podAnnotations | object | `{}` | Annotations for compactor pods |
| compactor.affinity | object | Hard node anti-affinity | Affinity for compactor pods. |
| compactor.serviceLabels | object | `{}` | Labels for compactor service |
| compactor.extraArgs | list | `[]` | Additional CLI args for the compactor |
| compactor.extraEnv | list | `[]` | Environment variables to add to the compactor pods |
| compactor.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the compactor pods |
| compactor.extraVolumeMounts | list | `[]` | Volume mounts to add to the compactor pods |
| compactor.extraVolumes | list | `[]` | Volumes to add to the compactor pods |
| compactor.readinessProbe | object | `{}` | readiness probe settings for ingester pods. If empty, use `loki.readinessProbe` |
| compactor.livenessProbe | object | `{}` | liveness probe settings for ingester pods. If empty use `loki.livenessProbe` |
| compactor.resources | object | `{"limits":{"cpu":"300m","memory":"2Gi"},"requests":{"cpu":"300m","memory":"2Gi"}}` | Resource requests and limits for the compactor |
| compactor.extraContainers | list | `[]` | Containers to add to the compactor pods |
| compactor.initContainers | list | `[]` | Init containers to add to the compactor pods |
| compactor.terminationGracePeriodSeconds | int | `30` | Grace period to allow the compactor to shutdown before it is killed |
| compactor.nodeSelector | object | `{}` | Node selector for compactor pods |
| compactor.tolerations | list | `[]` | Tolerations for compactor pods |
| compactor.appProtocol | object | `{"grpc":""}` | Set the optional grpc service protocol. Ex: "grpc", "http2" or "https" |
| compactor.persistence.enabled | bool | `false` | Enable creating PVCs for the compactor |
| compactor.persistence.size | string | `"10Gi"` | Size of persistent disk |
| compactor.persistence.storageClass | string | `nil` | Storage class to be used. If defined, storageClassName: <storageClass>. If set to "-", storageClassName: "", which disables dynamic provisioning. If empty or set to null, no storageClassName spec is set, choosing the default provisioner (gp2 on AWS, standard on GKE, AWS, and OpenStack). |
| compactor.persistence.annotations | object | `{}` | Annotations for compactor PVCs |
| compactor.persistence.claims | list |  | List of the compactor PVCs |
| compactor.persistence.enableStatefulSetAutoDeletePVC | bool | `false` | Enable StatefulSetAutoDeletePVC feature |
| compactor.serviceAccount.name | string | `nil` | The name of the ServiceAccount to use for the compactor. If not set and create is true, a name is generated by appending "-compactor" to the common ServiceAccount. |
| compactor.serviceAccount.imagePullSecrets | list | `[]` | Image pull secrets for the compactor service account |
| compactor.serviceAccount.annotations | object | `{}` | Annotations for the compactor service account |
| compactor.serviceAccount.automountServiceAccountToken | bool | `true` | Set this toggle to false to opt out of automounting API credentials for the service account |
| bloomGateway | object | `{"affinity":{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"app.kubernetes.io/component":"bloom-gateway"}},"topologyKey":"kubernetes.io/hostname"}]}},"appProtocol":{"grpc":""},"command":null,"extraArgs":[],"extraContainers":[],"extraEnv":[],"extraEnvFrom":[],"extraVolumeMounts":[],"extraVolumes":[],"hostAliases":[],"image":{"registry":null,"repository":null,"tag":null},"initContainers":[],"livenessProbe":{},"nodeSelector":{},"persistence":{"annotations":{},"claims":[{"name":"data","size":"10Gi","storageClass":null}],"enableStatefulSetAutoDeletePVC":false,"enabled":false,"size":"10Gi","storageClass":null,"whenDeleted":"Retain","whenScaled":"Retain"},"podAnnotations":{},"podLabels":{},"priorityClassName":null,"readinessProbe":{},"replicas":0,"resources":{},"serviceAccount":{"annotations":{},"automountServiceAccountToken":true,"create":false,"imagePullSecrets":[],"name":null},"serviceLabels":{},"terminationGracePeriodSeconds":30,"tolerations":[]}` | Configuration for the bloom gateway |
| bloomGateway.replicas | int | `0` | Number of replicas for the bloom gateway |
| bloomGateway.hostAliases | list | `[]` | hostAliases to add |
| bloomGateway.image.registry | string | `nil` | The Docker registry for the bloom gateway image. Overrides `loki.image.registry` |
| bloomGateway.image.repository | string | `nil` | Docker image repository for the bloom gateway image. Overrides `loki.image.repository` |
| bloomGateway.image.tag | string | `nil` | Docker image tag for the bloom gateway image. Overrides `loki.image.tag` |
| bloomGateway.command | string | `nil` | Command to execute instead of defined in Docker image |
| bloomGateway.priorityClassName | string | `nil` | The name of the PriorityClass for bloom gateway pods |
| bloomGateway.podLabels | object | `{}` | Labels for bloom gateway pods |
| bloomGateway.podAnnotations | object | `{}` | Annotations for bloom gateway pods |
| bloomGateway.affinity | object | Hard node anti-affinity | Affinity for bloom gateway pods. |
| bloomGateway.serviceLabels | object | `{}` | Labels for bloom gateway service |
| bloomGateway.extraArgs | list | `[]` | Additional CLI args for the bloom gateway |
| bloomGateway.extraEnv | list | `[]` | Environment variables to add to the bloom gateway pods |
| bloomGateway.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the bloom gateway pods |
| bloomGateway.extraVolumeMounts | list | `[]` | Volume mounts to add to the bloom gateway pods |
| bloomGateway.extraVolumes | list | `[]` | Volumes to add to the bloom gateway pods |
| bloomGateway.readinessProbe | object | `{}` | readiness probe settings for ingester pods. If empty, use `loki.readinessProbe` |
| bloomGateway.livenessProbe | object | `{}` | liveness probe settings for ingester pods. If empty use `loki.livenessProbe` |
| bloomGateway.resources | object | `{}` | Resource requests and limits for the bloom gateway |
| bloomGateway.extraContainers | list | `[]` | Containers to add to the bloom gateway pods |
| bloomGateway.initContainers | list | `[]` | Init containers to add to the bloom gateway pods |
| bloomGateway.terminationGracePeriodSeconds | int | `30` | Grace period to allow the bloom gateway to shutdown before it is killed |
| bloomGateway.nodeSelector | object | `{}` | Node selector for bloom gateway pods |
| bloomGateway.tolerations | list | `[]` | Tolerations for bloom gateway pods |
| bloomGateway.appProtocol | object | `{"grpc":""}` | Set the optional grpc service protocol. Ex: "grpc", "http2" or "https" |
| bloomGateway.persistence.enabled | bool | `false` | Enable creating PVCs for the bloom gateway |
| bloomGateway.persistence.size | string | `"10Gi"` | Size of persistent disk |
| bloomGateway.persistence.storageClass | string | `nil` | Storage class to be used. If defined, storageClassName: <storageClass>. If set to "-", storageClassName: "", which disables dynamic provisioning. If empty or set to null, no storageClassName spec is set, choosing the default provisioner (gp2 on AWS, standard on GKE, AWS, and OpenStack). |
| bloomGateway.persistence.annotations | object | `{}` | Annotations for bloom gateway PVCs |
| bloomGateway.persistence.claims | list |  | List of the bloom gateway PVCs |
| bloomGateway.persistence.enableStatefulSetAutoDeletePVC | bool | `false` | Enable StatefulSetAutoDeletePVC feature |
| bloomGateway.serviceAccount.name | string | `nil` | The name of the ServiceAccount to use for the bloom gateway. If not set and create is true, a name is generated by appending "-bloom-gateway" to the common ServiceAccount. |
| bloomGateway.serviceAccount.imagePullSecrets | list | `[]` | Image pull secrets for the bloom gateway service account |
| bloomGateway.serviceAccount.annotations | object | `{}` | Annotations for the bloom gateway service account |
| bloomGateway.serviceAccount.automountServiceAccountToken | bool | `true` | Set this toggle to false to opt out of automounting API credentials for the service account |
| bloomCompactor | object | `{"affinity":{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"app.kubernetes.io/component":"bloom-compactor"}},"topologyKey":"kubernetes.io/hostname"}]}},"appProtocol":{"grpc":""},"command":null,"extraArgs":[],"extraContainers":[],"extraEnv":[],"extraEnvFrom":[],"extraVolumeMounts":[],"extraVolumes":[],"hostAliases":[],"image":{"registry":null,"repository":null,"tag":null},"initContainers":[],"livenessProbe":{},"nodeSelector":{},"persistence":{"annotations":{},"claims":[{"name":"data","size":"10Gi","storageClass":null}],"enableStatefulSetAutoDeletePVC":false,"enabled":false,"size":"10Gi","storageClass":null,"whenDeleted":"Retain","whenScaled":"Retain"},"podAnnotations":{},"podLabels":{},"priorityClassName":null,"readinessProbe":{},"replicas":0,"resources":{},"serviceAccount":{"annotations":{},"automountServiceAccountToken":true,"create":false,"imagePullSecrets":[],"name":null},"serviceLabels":{},"terminationGracePeriodSeconds":30,"tolerations":[]}` | Configuration for the bloom compactor |
| bloomCompactor.replicas | int | `0` | Number of replicas for the bloom compactor |
| bloomCompactor.hostAliases | list | `[]` | hostAliases to add |
| bloomCompactor.image.registry | string | `nil` | The Docker registry for the bloom compactor image. Overrides `loki.image.registry` |
| bloomCompactor.image.repository | string | `nil` | Docker image repository for the bloom compactor image. Overrides `loki.image.repository` |
| bloomCompactor.image.tag | string | `nil` | Docker image tag for the bloom compactor image. Overrides `loki.image.tag` |
| bloomCompactor.command | string | `nil` | Command to execute instead of defined in Docker image |
| bloomCompactor.priorityClassName | string | `nil` | The name of the PriorityClass for bloom compactor pods |
| bloomCompactor.podLabels | object | `{}` | Labels for bloom compactor pods |
| bloomCompactor.podAnnotations | object | `{}` | Annotations for bloom compactor pods |
| bloomCompactor.affinity | object | Hard node anti-affinity | Affinity for bloom compactor pods. |
| bloomCompactor.serviceLabels | object | `{}` | Labels for bloom compactor service |
| bloomCompactor.extraArgs | list | `[]` | Additional CLI args for the bloom compactor |
| bloomCompactor.extraEnv | list | `[]` | Environment variables to add to the bloom compactor pods |
| bloomCompactor.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the bloom compactor pods |
| bloomCompactor.extraVolumeMounts | list | `[]` | Volume mounts to add to the bloom compactor pods |
| bloomCompactor.extraVolumes | list | `[]` | Volumes to add to the bloom compactor pods |
| bloomCompactor.readinessProbe | object | `{}` | readiness probe settings for ingester pods. If empty, use `loki.readinessProbe` |
| bloomCompactor.livenessProbe | object | `{}` | liveness probe settings for ingester pods. If empty use `loki.livenessProbe` |
| bloomCompactor.resources | object | `{}` | Resource requests and limits for the bloom compactor |
| bloomCompactor.extraContainers | list | `[]` | Containers to add to the bloom compactor pods |
| bloomCompactor.initContainers | list | `[]` | Init containers to add to the bloom compactor pods |
| bloomCompactor.terminationGracePeriodSeconds | int | `30` | Grace period to allow the bloom compactor to shutdown before it is killed |
| bloomCompactor.nodeSelector | object | `{}` | Node selector for bloom compactor pods |
| bloomCompactor.tolerations | list | `[]` | Tolerations for bloom compactor pods |
| bloomCompactor.appProtocol | object | `{"grpc":""}` | Set the optional grpc service protocol. Ex: "grpc", "http2" or "https" |
| bloomCompactor.persistence.enabled | bool | `false` | Enable creating PVCs for the bloom compactor |
| bloomCompactor.persistence.size | string | `"10Gi"` | Size of persistent disk |
| bloomCompactor.persistence.storageClass | string | `nil` | Storage class to be used. If defined, storageClassName: <storageClass>. If set to "-", storageClassName: "", which disables dynamic provisioning. If empty or set to null, no storageClassName spec is set, choosing the default provisioner (gp2 on AWS, standard on GKE, AWS, and OpenStack). |
| bloomCompactor.persistence.annotations | object | `{}` | Annotations for bloom compactor PVCs |
| bloomCompactor.persistence.claims | list |  | List of the bloom compactor PVCs |
| bloomCompactor.persistence.enableStatefulSetAutoDeletePVC | bool | `false` | Enable StatefulSetAutoDeletePVC feature |
| bloomCompactor.serviceAccount.name | string | `nil` | The name of the ServiceAccount to use for the bloom compactor. If not set and create is true, a name is generated by appending "-bloom-compactor" to the common ServiceAccount. |
| bloomCompactor.serviceAccount.imagePullSecrets | list | `[]` | Image pull secrets for the bloom compactor service account |
| bloomCompactor.serviceAccount.annotations | object | `{}` | Annotations for the bloom compactor service account |
| bloomCompactor.serviceAccount.automountServiceAccountToken | bool | `true` | Set this toggle to false to opt out of automounting API credentials for the service account |
| patternIngester | object | `{"affinity":{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"app.kubernetes.io/component":"pattern-ingester"}},"topologyKey":"kubernetes.io/hostname"}]}},"appProtocol":{"grpc":""},"command":null,"extraArgs":[],"extraContainers":[],"extraEnv":[],"extraEnvFrom":[],"extraVolumeMounts":[],"extraVolumes":[],"hostAliases":[],"image":{"registry":null,"repository":null,"tag":null},"initContainers":[],"livenessProbe":{},"nodeSelector":{},"persistence":{"annotations":{},"claims":[{"name":"data","size":"10Gi","storageClass":null}],"enableStatefulSetAutoDeletePVC":false,"enabled":false,"size":"10Gi","storageClass":null,"whenDeleted":"Retain","whenScaled":"Retain"},"podAnnotations":{},"podLabels":{},"priorityClassName":null,"readinessProbe":{},"replicas":0,"resources":{"limits":{"cpu":"100m","memory":"256Mi"},"requests":{"cpu":"100m","memory":"256Mi"}},"serviceAccount":{"annotations":{},"automountServiceAccountToken":true,"create":false,"imagePullSecrets":[],"name":null},"serviceLabels":{},"terminationGracePeriodSeconds":30,"tolerations":[]}` | Configuration for the pattern ingester |
| patternIngester.replicas | int | `0` | Number of replicas for the pattern ingester |
| patternIngester.hostAliases | list | `[]` | hostAliases to add |
| patternIngester.image.registry | string | `nil` | The Docker registry for the pattern ingester image. Overrides `loki.image.registry` |
| patternIngester.image.repository | string | `nil` | Docker image repository for the pattern ingester image. Overrides `loki.image.repository` |
| patternIngester.image.tag | string | `nil` | Docker image tag for the pattern ingester image. Overrides `loki.image.tag` |
| patternIngester.command | string | `nil` | Command to execute instead of defined in Docker image |
| patternIngester.priorityClassName | string | `nil` | The name of the PriorityClass for pattern ingester pods |
| patternIngester.podLabels | object | `{}` | Labels for pattern ingester pods |
| patternIngester.podAnnotations | object | `{}` | Annotations for pattern ingester pods |
| patternIngester.affinity | object | Hard node anti-affinity | Affinity for pattern ingester pods. |
| patternIngester.serviceLabels | object | `{}` | Labels for pattern ingester service |
| patternIngester.extraArgs | list | `[]` | Additional CLI args for the pattern ingester |
| patternIngester.extraEnv | list | `[]` | Environment variables to add to the pattern ingester pods |
| patternIngester.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the pattern ingester pods |
| patternIngester.extraVolumeMounts | list | `[]` | Volume mounts to add to the pattern ingester pods |
| patternIngester.extraVolumes | list | `[]` | Volumes to add to the pattern ingester pods |
| patternIngester.readinessProbe | object | `{}` | readiness probe settings for ingester pods. If empty, use `loki.readinessProbe` |
| patternIngester.livenessProbe | object | `{}` | liveness probe settings for ingester pods. If empty use `loki.livenessProbe` |
| patternIngester.resources | object | `{"limits":{"cpu":"100m","memory":"256Mi"},"requests":{"cpu":"100m","memory":"256Mi"}}` | Resource requests and limits for the pattern ingester |
| patternIngester.extraContainers | list | `[]` | Containers to add to the pattern ingester pods |
| patternIngester.initContainers | list | `[]` | Init containers to add to the pattern ingester pods |
| patternIngester.terminationGracePeriodSeconds | int | `30` | Grace period to allow the pattern ingester to shutdown before it is killed |
| patternIngester.nodeSelector | object | `{}` | Node selector for pattern ingester pods |
| patternIngester.tolerations | list | `[]` | Tolerations for pattern ingester pods |
| patternIngester.appProtocol | object | `{"grpc":""}` | Set the optional grpc service protocol. Ex: "grpc", "http2" or "https" |
| patternIngester.persistence.enabled | bool | `false` | Enable creating PVCs for the pattern ingester |
| patternIngester.persistence.size | string | `"10Gi"` | Size of persistent disk |
| patternIngester.persistence.storageClass | string | `nil` | Storage class to be used. If defined, storageClassName: <storageClass>. If set to "-", storageClassName: "", which disables dynamic provisioning. If empty or set to null, no storageClassName spec is set, choosing the default provisioner (gp2 on AWS, standard on GKE, AWS, and OpenStack). |
| patternIngester.persistence.annotations | object | `{}` | Annotations for pattern ingester PVCs |
| patternIngester.persistence.claims | list |  | List of the pattern ingester PVCs |
| patternIngester.persistence.enableStatefulSetAutoDeletePVC | bool | `false` | Enable StatefulSetAutoDeletePVC feature |
| patternIngester.serviceAccount.name | string | `nil` | The name of the ServiceAccount to use for the pattern ingester. If not set and create is true, a name is generated by appending "-pattern-ingester" to the common ServiceAccount. |
| patternIngester.serviceAccount.imagePullSecrets | list | `[]` | Image pull secrets for the pattern ingester service account |
| patternIngester.serviceAccount.annotations | object | `{}` | Annotations for the pattern ingester service account |
| patternIngester.serviceAccount.automountServiceAccountToken | bool | `true` | Set this toggle to false to opt out of automounting API credentials for the service account |
| ruler | object | `{"affinity":{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"app.kubernetes.io/component":"ruler"}},"topologyKey":"kubernetes.io/hostname"}]}},"appProtocol":{"grpc":""},"command":null,"directories":{},"dnsConfig":{},"enabled":true,"extraArgs":[],"extraContainers":[],"extraEnv":[],"extraEnvFrom":[],"extraVolumeMounts":[],"extraVolumes":[],"hostAliases":[],"image":{"registry":null,"repository":null,"tag":null},"initContainers":[],"maxUnavailable":null,"nodeSelector":{},"persistence":{"annotations":{},"enabled":false,"size":"10Gi","storageClass":null},"podAnnotations":{},"podLabels":{},"priorityClassName":null,"replicas":0,"resources":{},"serviceLabels":{},"terminationGracePeriodSeconds":300,"tolerations":[]}` | Configuration for the ruler |
| ruler.enabled | bool | `true` | The ruler component is optional and can be disabled if desired. |
| ruler.replicas | int | `0` | Number of replicas for the ruler |
| ruler.hostAliases | list | `[]` | hostAliases to add |
| ruler.image.registry | string | `nil` | The Docker registry for the ruler image. Overrides `loki.image.registry` |
| ruler.image.repository | string | `nil` | Docker image repository for the ruler image. Overrides `loki.image.repository` |
| ruler.image.tag | string | `nil` | Docker image tag for the ruler image. Overrides `loki.image.tag` |
| ruler.command | string | `nil` | Command to execute instead of defined in Docker image |
| ruler.priorityClassName | string | `nil` | The name of the PriorityClass for ruler pods |
| ruler.podLabels | object | `{}` | Labels for compactor pods |
| ruler.podAnnotations | object | `{}` | Annotations for ruler pods |
| ruler.serviceLabels | object | `{}` | Labels for ruler service |
| ruler.extraArgs | list | `[]` | Additional CLI args for the ruler |
| ruler.extraEnv | list | `[]` | Environment variables to add to the ruler pods |
| ruler.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the ruler pods |
| ruler.extraVolumeMounts | list | `[]` | Volume mounts to add to the ruler pods |
| ruler.extraVolumes | list | `[]` | Volumes to add to the ruler pods |
| ruler.resources | object | `{}` | Resource requests and limits for the ruler |
| ruler.extraContainers | list | `[]` | Containers to add to the ruler pods |
| ruler.initContainers | list | `[]` | Init containers to add to the ruler pods |
| ruler.terminationGracePeriodSeconds | int | `300` | Grace period to allow the ruler to shutdown before it is killed |
| ruler.affinity | object | Hard node anti-affinity | Affinity for ruler pods. |
| ruler.maxUnavailable | string | `nil` | Pod Disruption Budget maxUnavailable |
| ruler.nodeSelector | object | `{}` | Node selector for ruler pods |
| ruler.tolerations | list | `[]` | Tolerations for ruler pods |
| ruler.dnsConfig | object | `{}` | DNSConfig for ruler pods |
| ruler.persistence.enabled | bool | `false` | Enable creating PVCs which is required when using recording rules |
| ruler.persistence.size | string | `"10Gi"` | Size of persistent disk |
| ruler.persistence.storageClass | string | `nil` | Storage class to be used. If defined, storageClassName: <storageClass>. If set to "-", storageClassName: "", which disables dynamic provisioning. If empty or set to null, no storageClassName spec is set, choosing the default provisioner (gp2 on AWS, standard on GKE, AWS, and OpenStack). |
| ruler.persistence.annotations | object | `{}` | Annotations for ruler PVCs |
| ruler.appProtocol | object | `{"grpc":""}` | Set the optional grpc service protocol. Ex: "grpc", "http2" or "https" |
| ruler.directories | object | `{}` | Directories containing rules files |
| memcached.image.repository | string | `"registry1.dso.mil/ironbank/opensource/memcached/memcached"` | Memcached Docker image repository |
| memcached.image.tag | string | `"1.6.23"` | Memcached Docker image tag |
| memcached.image.pullPolicy | string | `"IfNotPresent"` | Memcached Docker image pull policy |
| memcached.podSecurityContext | object | `{}` | The SecurityContext override for memcached pods |
| memcached.priorityClassName | string | `nil` | The name of the PriorityClass for memcached pods |
| memcached.containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"fsGroup":10001,"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001}` | The SecurityContext for memcached containers |
| memcachedExporter.enabled | bool | `false` | Whether memcached metrics should be exported |
| memcachedExporter.image.repository | string | `"prom/memcached-exporter"` |  |
| memcachedExporter.image.tag | string | `"v0.14.2"` |  |
| memcachedExporter.image.pullPolicy | string | `"IfNotPresent"` |  |
| memcachedExporter.resources.requests | object | `{}` |  |
| memcachedExporter.resources.limits | object | `{}` |  |
| memcachedExporter.containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"fsGroup":10001,"readOnlyRootFilesystem":true,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001}` | The SecurityContext for memcached exporter containers |
| memcachedExporter.extraArgs | object | `{}` | Extra args to add to the exporter container. Example: extraArgs:   memcached.tls.enable: true   memcached.tls.cert-file: /certs/cert.crt   memcached.tls.key-file: /certs/cert.key   memcached.tls.ca-file: /certs/ca.crt   memcached.tls.insecure-skip-verify: false   memcached.tls.server-name: memcached |
| resultsCache.enabled | bool | `false` | Specifies whether memcached based results-cache should be enabled |
| resultsCache.defaultValidity | string | `"12h"` | Specify how long cached results should be stored in the results-cache before being expired |
| resultsCache.timeout | string | `"500ms"` | Memcached operation timeout |
| resultsCache.replicas | int | `1` | Total number of results-cache replicas |
| resultsCache.port | int | `11211` | Port of the results-cache service |
| resultsCache.allocatedMemory | int | `1024` | Amount of memory allocated to results-cache for object storage (in MB). |
| resultsCache.maxItemMemory | int | `5` | Maximum item results-cache for memcached (in MB). |
| resultsCache.connectionLimit | int | `16384` | Maximum number of connections allowed |
| resultsCache.writebackSizeLimit | string | `"500MB"` | Max memory to use for cache write back |
| resultsCache.writebackBuffer | int | `500000` | Max number of objects to use for cache write back |
| resultsCache.writebackParallelism | int | `1` | Number of parallel threads for cache write back |
| resultsCache.initContainers | list | `[]` | Extra init containers for results-cache pods |
| resultsCache.annotations | object | `{}` | Annotations for the results-cache pods |
| resultsCache.nodeSelector | object | `{}` | Node selector for results-cache pods |
| resultsCache.affinity | object | `{}` | Affinity for results-cache pods |
| resultsCache.topologySpreadConstraints | list | `[]` | topologySpreadConstraints allows to customize the default topologySpreadConstraints. This can be either a single dict as shown below or a slice of topologySpreadConstraints. labelSelector is taken from the constraint itself (if it exists) or is generated by the chart using the same selectors as for services. |
| resultsCache.tolerations | list | `[]` | Tolerations for results-cache pods |
| resultsCache.podDisruptionBudget | object | `{"maxUnavailable":1}` | Pod Disruption Budget |
| resultsCache.priorityClassName | string | `nil` | The name of the PriorityClass for results-cache pods |
| resultsCache.podLabels | object | `{}` | Labels for results-cache pods |
| resultsCache.podAnnotations | object | `{}` | Annotations for results-cache pods |
| resultsCache.podManagementPolicy | string | `"Parallel"` | Management policy for results-cache pods |
| resultsCache.terminationGracePeriodSeconds | int | `60` | Grace period to allow the results-cache to shutdown before it is killed |
| resultsCache.statefulStrategy | object | `{"type":"RollingUpdate"}` | Stateful results-cache strategy |
| resultsCache.extraExtendedOptions | string | `""` | Add extended options for results-cache memcached container. The format is the same as for the memcached -o/--extend flag. Example: extraExtendedOptions: 'tls,modern,track_sizes' |
| resultsCache.extraArgs | object | `{}` | Additional CLI args for results-cache |
| resultsCache.extraContainers | list | `[]` | Additional containers to be added to the results-cache pod. |
| resultsCache.extraVolumes | list | `[]` | Additional volumes to be added to the results-cache pod (applies to both memcached and exporter containers). Example: extraVolumes: - name: extra-volume   secret:    secretName: extra-volume-secret |
| resultsCache.extraVolumeMounts | list | `[]` | Additional volume mounts to be added to the results-cache pod (applies to both memcached and exporter containers). Example: extraVolumeMounts: - name: extra-volume   mountPath: /etc/extra-volume   readOnly: true |
| resultsCache.resources | string | `nil` | Resource requests and limits for the results-cache By default a safe memory limit will be requested based on allocatedMemory value (floor (* 1.2 allocatedMemory)). |
| resultsCache.service | object | `{"annotations":{},"labels":{}}` | Service annotations and labels |
| chunksCache.enabled | bool | `false` | Specifies whether memcached based chunks-cache should be enabled |
| chunksCache.batchSize | int | `4` | Batchsize for sending and receiving chunks from chunks cache |
| chunksCache.parallelism | int | `5` | Parallel threads for sending and receiving chunks from chunks cache |
| chunksCache.timeout | string | `"2000ms"` | Memcached operation timeout |
| chunksCache.defaultValidity | string | `"0s"` | Specify how long cached chunks should be stored in the chunks-cache before being expired |
| chunksCache.replicas | int | `1` | Total number of chunks-cache replicas |
| chunksCache.port | int | `11211` | Port of the chunks-cache service |
| chunksCache.allocatedMemory | int | `8192` | Amount of memory allocated to chunks-cache for object storage (in MB). |
| chunksCache.maxItemMemory | int | `5` | Maximum item memory for chunks-cache (in MB). |
| chunksCache.connectionLimit | int | `16384` | Maximum number of connections allowed |
| chunksCache.writebackSizeLimit | string | `"500MB"` | Max memory to use for cache write back |
| chunksCache.writebackBuffer | int | `500000` | Max number of objects to use for cache write back |
| chunksCache.writebackParallelism | int | `1` | Number of parallel threads for cache write back |
| chunksCache.initContainers | list | `[]` | Extra init containers for chunks-cache pods |
| chunksCache.annotations | object | `{}` | Annotations for the chunks-cache pods |
| chunksCache.nodeSelector | object | `{}` | Node selector for chunks-cache pods |
| chunksCache.affinity | object | `{}` | Affinity for chunks-cache pods |
| chunksCache.topologySpreadConstraints | list | `[]` | topologySpreadConstraints allows to customize the default topologySpreadConstraints. This can be either a single dict as shown below or a slice of topologySpreadConstraints. labelSelector is taken from the constraint itself (if it exists) or is generated by the chart using the same selectors as for services. |
| chunksCache.tolerations | list | `[]` | Tolerations for chunks-cache pods |
| chunksCache.podDisruptionBudget | object | `{"maxUnavailable":1}` | Pod Disruption Budget |
| chunksCache.priorityClassName | string | `nil` | The name of the PriorityClass for chunks-cache pods |
| chunksCache.podLabels | object | `{}` | Labels for chunks-cache pods |
| chunksCache.podAnnotations | object | `{}` | Annotations for chunks-cache pods |
| chunksCache.podManagementPolicy | string | `"Parallel"` | Management policy for chunks-cache pods |
| chunksCache.terminationGracePeriodSeconds | int | `60` | Grace period to allow the chunks-cache to shutdown before it is killed |
| chunksCache.statefulStrategy | object | `{"type":"RollingUpdate"}` | Stateful chunks-cache strategy |
| chunksCache.extraExtendedOptions | string | `""` | Add extended options for chunks-cache memcached container. The format is the same as for the memcached -o/--extend flag. Example: extraExtendedOptions: 'tls,no_hashexpand' |
| chunksCache.extraArgs | object | `{}` | Additional CLI args for chunks-cache |
| chunksCache.extraContainers | list | `[]` | Additional containers to be added to the chunks-cache pod. |
| chunksCache.extraVolumes | list | `[]` | Additional volumes to be added to the chunks-cache pod (applies to both memcached and exporter containers). Example: extraVolumes: - name: extra-volume   secret:    secretName: extra-volume-secret |
| chunksCache.extraVolumeMounts | list | `[]` | Additional volume mounts to be added to the chunks-cache pod (applies to both memcached and exporter containers). Example: extraVolumeMounts: - name: extra-volume   mountPath: /etc/extra-volume   readOnly: true |
| chunksCache.resources | string | `nil` | Resource requests and limits for the chunks-cache By default a safe memory limit will be requested based on allocatedMemory value (floor (* 1.2 allocatedMemory)). |
| chunksCache.service | object | `{"annotations":{},"labels":{}}` | Service annotations and labels |
| rollout_operator | object | `{"enabled":false,"podSecurityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true}}` | Setting for the Grafana Rollout Operator https://github.com/grafana/helm-charts/tree/main/charts/rollout-operator |
| rollout_operator.podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001,"seccompProfile":{"type":"RuntimeDefault"}}` | podSecurityContext is the pod security context for the rollout operator. When installing on OpenShift, override podSecurityContext settings with  rollout_operator:   podSecurityContext:     fsGroup: null     runAsGroup: null     runAsUser: null |
| minio | object | `{"address":"minio.logging.svc.cluster.local","enabled":false,"secrets":{"accessKey":"minio","name":"loki-objstore-creds","secretKey":"minio123"},"tenant":{"buckets":[{"name":"loki"},{"name":"loki-admin"}],"defaultUserCredentials":{"password":"","username":"minio-user"},"metrics":{"enabled":false,"memory":"128M","port":9000},"pools":[{"containerSecurityContext":{"capabilities":{"drop":["ALL"]}},"securityContext":{"fsGroup":1001,"runAsGroup":1001,"runAsUser":1001},"servers":1,"size":"750Mi","volumesPerServer":4}],"users":[{"name":"minio-user"}]}}` | Configuration for the minio subchart |
| minio.enabled | bool | `false` | Enable minio instance support, must have minio-operator installed |
| minio.secrets | object | `{"accessKey":"minio","name":"loki-objstore-creds","secretKey":"minio123"}` | Minio root credentials |
| minio.tenant.buckets | list | `[{"name":"loki"},{"name":"loki-admin"}]` | Buckets to be provisioned to for tenant |
| minio.tenant.users | list | `[{"name":"minio-user"}]` | Users to to be provisioned to for tenant |
| minio.tenant.defaultUserCredentials | object | `{"password":"","username":"minio-user"}` | User credentials to create for above user. Otherwise password is randomly generated. This auth is not required to be set or reclaimed for minio use with Loki |
| extraObjects | list | `[]` |  |
| sidecar.image.repository | string | `"registry1.dso.mil/ironbank/kiwigrid/k8s-sidecar"` |  |
| sidecar.image.tag | string | `"1.26.1"` |  |
| sidecar.image.sha | string | `""` |  |
| sidecar.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| sidecar.resources.limits.cpu | string | `"100m"` |  |
| sidecar.resources.limits.memory | string | `"100Mi"` |  |
| sidecar.resources.requests.cpu | string | `"100m"` |  |
| sidecar.resources.requests.memory | string | `"100Mi"` |  |
| sidecar.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| sidecar.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| sidecar.securityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| sidecar.skipTlsVerify | bool | `false` | Set to true to skip tls verification for kube api calls. |
| sidecar.enableUniqueFilenames | bool | `false` | Ensure that rule files aren't conflicting and being overwritten by prefixing their name with the namespace they are defined in. |
| sidecar.readinessProbe | object | `{}` | Readiness probe definition. Probe is disabled on the sidecar by default. |
| sidecar.livenessProbe | object | `{}` | Liveness probe definition. Probe is disabled on the sidecar by default. |
| sidecar.rules.enabled | bool | `false` | Whether or not to create a sidecar to ingest rule from specific ConfigMaps and/or Secrets. |
| sidecar.rules.label | string | `"loki_rule"` | Label that the configmaps/secrets with rules will be marked with. |
| sidecar.rules.labelValue | string | `""` | Label value that the configmaps/secrets with rules will be set to. |
| sidecar.rules.folder | string | `"/rules"` | Folder into which the rules will be placed. |
| sidecar.rules.searchNamespace | string | `nil` | Comma separated list of namespaces. If specified, the sidecar will search for config-maps/secrets inside these namespaces. Otherwise the namespace in which the sidecar is running will be used. It's also possible to specify 'ALL' to search in all namespaces. |
| sidecar.rules.watchMethod | string | `"WATCH"` | Method to use to detect ConfigMap changes. With WATCH the sidecar will do a WATCH request, with SLEEP it will list all ConfigMaps, then sleep for 60 seconds. |
| sidecar.rules.resource | string | `"both"` | Search in configmap, secret, or both. |
| sidecar.rules.script | string | `nil` | Absolute path to the shell script to execute after a configmap or secret has been reloaded. |
| sidecar.rules.watchServerTimeout | int | `60` | WatchServerTimeout: request to the server, asking it to cleanly close the connection after that. defaults to 60sec; much higher values like 3600 seconds (1h) are feasible for non-Azure K8S. |
| sidecar.rules.watchClientTimeout | int | `60` | WatchClientTimeout: is a client-side timeout, configuring your local socket. If you have a network outage dropping all packets with no RST/FIN, this is how long your client waits before realizing & dropping the connection. Defaults to 66sec. |
| sidecar.rules.logLevel | string | `"INFO"` | Log level of the sidecar container. |
| domain | string | `"bigbang.dev"` |  |
| fluentbit.enabled | bool | `false` |  |
| promtail.enabled | bool | `false` |  |
| istio.enabled | bool | `false` |  |
| istio.hardened.enabled | bool | `false` |  |
| istio.hardened.outboundTrafficPolicyMode | string | `"REGISTRY_ONLY"` |  |
| istio.hardened.customServiceEntries | list | `[]` |  |
| istio.hardened.customAuthorizationPolicies | list | `[]` |  |
| istio.hardened.monitoring.enabled | bool | `true` |  |
| istio.hardened.monitoring.namespaces[0] | string | `"monitoring"` |  |
| istio.hardened.monitoring.principals[0] | string | `"cluster.local/ns/monitoring/sa/monitoring-grafana"` |  |
| istio.hardened.monitoring.principals[1] | string | `"cluster.local/ns/monitoring/sa/monitoring-monitoring-kube-alertmanager"` |  |
| istio.hardened.monitoring.principals[2] | string | `"cluster.local/ns/monitoring/sa/monitoring-monitoring-kube-operator"` |  |
| istio.hardened.monitoring.principals[3] | string | `"cluster.local/ns/monitoring/sa/monitoring-monitoring-kube-prometheus"` |  |
| istio.hardened.monitoring.principals[4] | string | `"cluster.local/ns/monitoring/sa/monitoring-monitoring-kube-state-metrics"` |  |
| istio.hardened.monitoring.principals[5] | string | `"cluster.local/ns/monitoring/sa/monitoring-monitoring-prometheus-node-exporter"` |  |
| istio.hardened.promtail.enabled | bool | `true` |  |
| istio.hardened.promtail.namespaces[0] | string | `"promtail"` |  |
| istio.hardened.promtail.principals[0] | string | `"cluster.local/ns/promtail/sa/promtail-promtail"` |  |
| istio.hardened.fluentbit.enabled | bool | `true` |  |
| istio.hardened.fluentbit.namespaces[0] | string | `"fluentbit"` |  |
| istio.hardened.fluentbit.principals[0] | string | `"cluster.local/ns/fluentbit/sa/fluentbit-fluent-bit"` |  |
| istio.hardened.minioOperator.enabled | bool | `true` |  |
| istio.hardened.minioOperator.namespaces[0] | string | `"minio-operator"` |  |
| istio.hardened.minioOperator.principals[0] | string | `"cluster.local/ns/minio-operator/sa/minio-operator"` |  |
| istio.loki.enabled | bool | `false` |  |
| istio.loki.annotations | object | `{}` |  |
| istio.loki.labels | object | `{}` |  |
| istio.loki.gateways[0] | string | `"istio-system/public"` |  |
| istio.loki.hosts[0] | string | `"loki.{{ .Values.domain }}"` |  |
| istio.loki.service | string | `""` |  |
| istio.loki.port | string | `""` |  |
| istio.loki.exposeReadyEndpoint | bool | `false` |  |
| istio.mtls.mode | string | `"STRICT"` |  |
| networkPolicies.enabled | bool | `false` |  |
| networkPolicies.controlPlaneCidr | string | `"0.0.0.0/0"` | Control Plane CIDR to allow init job communication to the Kubernetes API.   Use `kubectl get endpoints kubernetes` to get the CIDR range needed for your cluster |
| networkPolicies.ingressLabels.app | string | `"public-ingressgateway"` |  |
| networkPolicies.ingressLabels.istio | string | `"ingressgateway"` |  |
| networkPolicies.additionalPolicies | list | `[]` |  |
| bbtests.enabled | bool | `false` |  |
| bbtests.cypress.artifacts | bool | `true` |  |
| bbtests.cypress.envs.cypress_check_datasource | string | `"false"` |  |
| bbtests.cypress.envs.cypress_grafana_url | string | `"http://monitoring-grafana.monitoring.svc.cluster.local"` |  |
| bbtests.scripts.image | string | `"registry1.dso.mil/ironbank/big-bang/base:2.1.0"` |  |
| bbtests.scripts.envs.LOKI_URL | string | `"http://{{ .Values.fullnameOverride }}.{{ .Release.Namespace }}.svc:3100"` |  |
| bbtests.scripts.envs.LOKI_VERSION | string | `"{{ .Values.loki.image.tag }}"` |  |
| monitoring | object | `{"dashboards":{"annotations":{},"enabled":false,"labels":{"grafana_dashboard":"1"},"namespace":null},"enabled":false,"rules":{"additionalGroups":[],"additionalRuleLabels":{},"alerting":true,"annotations":{},"disabled":{},"enabled":false,"labels":{},"namespace":null},"selfMonitoring":{"enabled":false,"grafanaAgent":{"annotations":{},"enableConfigReadAPI":false,"installOperator":false,"labels":{},"priorityClassName":null,"resources":{},"tolerations":[]},"logsInstance":{"annotations":{},"clients":null,"labels":{}},"podLogs":{"additionalPipelineStages":[],"annotations":{},"apiVersion":"monitoring.grafana.com/v1alpha1","labels":{},"relabelings":[]},"tenant":{"name":"self-monitoring","password":null,"secretNamespace":"{{ .Release.Namespace }}"}},"serviceMonitor":{"annotations":{},"enabled":false,"interval":"15s","labels":{},"metricRelabelings":[],"metricsInstance":{"annotations":{},"enabled":false,"labels":{},"remoteWrite":null},"namespaceSelector":{},"relabelings":[],"scheme":"http","scrapeTimeout":null,"tlsConfig":null}}` | DEPRECATED Monitoring section determines which monitoring features to enable, this section is being replaced by https://github.com/grafana/meta-monitoring-chart |
| monitoring.enabled | bool | `false` | Enable BigBang integration of Monitoring components |
| monitoring.dashboards.enabled | bool | `false` | If enabled, create configmap with dashboards for monitoring Loki |
| monitoring.dashboards.namespace | string | `nil` | Alternative namespace to create dashboards ConfigMap in |
| monitoring.dashboards.annotations | object | `{}` | Additional annotations for the dashboards ConfigMap |
| monitoring.dashboards.labels | object | `{"grafana_dashboard":"1"}` | Labels for the dashboards ConfigMap |
| monitoring.rules.enabled | bool | `false` | If enabled, create PrometheusRule resource with Loki recording rules |
| monitoring.rules.alerting | bool | `true` | Include alerting rules |
| monitoring.rules.disabled | object | `{}` | If you disable all the alerts and keep .monitoring.rules.alerting set to true, the chart will fail to render. |
| monitoring.rules.namespace | string | `nil` | Alternative namespace to create PrometheusRule resources in |
| monitoring.rules.annotations | object | `{}` | Additional annotations for the rules PrometheusRule resource |
| monitoring.rules.labels | object | `{}` | Additional labels for the rules PrometheusRule resource |
| monitoring.rules.additionalRuleLabels | object | `{}` | Additional labels for PrometheusRule alerts |
| monitoring.rules.additionalGroups | list | `[]` | Additional groups to add to the rules file |
| monitoring.serviceMonitor.enabled | bool | `false` | If enabled, ServiceMonitor resources for Prometheus Operator are created |
| monitoring.serviceMonitor.namespaceSelector | object | `{}` | Namespace selector for ServiceMonitor resources |
| monitoring.serviceMonitor.annotations | object | `{}` | ServiceMonitor annotations |
| monitoring.serviceMonitor.labels | object | `{}` | Additional ServiceMonitor labels |
| monitoring.serviceMonitor.interval | string | `"15s"` | ServiceMonitor scrape interval Default is 15s because included recording rules use a 1m rate, and scrape interval needs to be at least 1/4 rate interval. |
| monitoring.serviceMonitor.scrapeTimeout | string | `nil` | ServiceMonitor scrape timeout in Go duration format (e.g. 15s) |
| monitoring.serviceMonitor.relabelings | list | `[]` | ServiceMonitor relabel configs to apply to samples before scraping https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/api.md#relabelconfig |
| monitoring.serviceMonitor.metricRelabelings | list | `[]` | ServiceMonitor metric relabel configs to apply to samples before ingestion https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#endpoint |
| monitoring.serviceMonitor.scheme | string | `"http"` | ServiceMonitor will use http by default, but you can pick https as well |
| monitoring.serviceMonitor.tlsConfig | string | `nil` | ServiceMonitor will use these tlsConfig settings to make the health check requests |
| monitoring.serviceMonitor.metricsInstance | object | `{"annotations":{},"enabled":false,"labels":{},"remoteWrite":null}` | If defined, will create a MetricsInstance for the Grafana Agent Operator. |
| monitoring.serviceMonitor.metricsInstance.enabled | bool | `false` | If enabled, MetricsInstance resources for Grafana Agent Operator are created |
| monitoring.serviceMonitor.metricsInstance.annotations | object | `{}` | MetricsInstance annotations |
| monitoring.serviceMonitor.metricsInstance.labels | object | `{}` | Additional MetricsInstance labels |
| monitoring.serviceMonitor.metricsInstance.remoteWrite | string | `nil` | If defined a MetricsInstance will be created to remote write metrics. |
| monitoring.selfMonitoring.tenant | object | `{"name":"self-monitoring","password":null,"secretNamespace":"{{ .Release.Namespace }}"}` | Tenant to use for self monitoring |
| monitoring.selfMonitoring.tenant.name | string | `"self-monitoring"` | Name of the tenant |
| monitoring.selfMonitoring.tenant.password | string | `nil` | Password of the gateway for Basic auth |
| monitoring.selfMonitoring.tenant.secretNamespace | string | `"{{ .Release.Namespace }}"` | Namespace to create additional tenant token secret in. Useful if your Grafana instance is in a separate namespace. Token will still be created in the canary namespace. |
| monitoring.selfMonitoring.grafanaAgent.installOperator | bool | `false` | Controls whether to install the Grafana Agent Operator and its CRDs. Note that helm will not install CRDs if this flag is enabled during an upgrade. In that case install the CRDs manually from https://github.com/grafana/agent/tree/main/production/operator/crds |
| monitoring.selfMonitoring.grafanaAgent.annotations | object | `{}` | Grafana Agent annotations |
| monitoring.selfMonitoring.grafanaAgent.labels | object | `{}` | Additional Grafana Agent labels |
| monitoring.selfMonitoring.grafanaAgent.enableConfigReadAPI | bool | `false` | Enable the config read api on port 8080 of the agent |
| monitoring.selfMonitoring.grafanaAgent.priorityClassName | string | `nil` | The name of the PriorityClass for GrafanaAgent pods |
| monitoring.selfMonitoring.grafanaAgent.resources | object | `{}` | Resource requests and limits for the grafanaAgent pods |
| monitoring.selfMonitoring.grafanaAgent.tolerations | list | `[]` | Tolerations for GrafanaAgent pods |
| monitoring.selfMonitoring.podLogs.apiVersion | string | `"monitoring.grafana.com/v1alpha1"` | PodLogs version |
| monitoring.selfMonitoring.podLogs.annotations | object | `{}` | PodLogs annotations |
| monitoring.selfMonitoring.podLogs.labels | object | `{}` | Additional PodLogs labels |
| monitoring.selfMonitoring.podLogs.relabelings | list | `[]` | PodLogs relabel configs to apply to samples before scraping https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/api.md#relabelconfig |
| monitoring.selfMonitoring.podLogs.additionalPipelineStages | list | `[]` | Additional pipeline stages to process logs after scraping https://grafana.com/docs/agent/latest/operator/api/#pipelinestagespec-a-namemonitoringgrafanacomv1alpha1pipelinestagespeca |
| monitoring.selfMonitoring.logsInstance.annotations | object | `{}` | LogsInstance annotations |
| monitoring.selfMonitoring.logsInstance.labels | object | `{}` | Additional LogsInstance labels |
| monitoring.selfMonitoring.logsInstance.clients | string | `nil` | Additional clients for remote write |
| tableManager | object | `{"affinity":{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchLabels":{"app.kubernetes.io/component":"table-manager"}},"topologyKey":"kubernetes.io/hostname"}]}},"annotations":{},"command":null,"dnsConfig":{},"enabled":false,"extraArgs":[],"extraContainers":[],"extraEnv":[],"extraEnvFrom":[],"extraVolumeMounts":[],"extraVolumes":[],"image":{"registry":null,"repository":null,"tag":null},"nodeSelector":{},"podAnnotations":{},"podLabels":{},"priorityClassName":null,"resources":{},"retention_deletes_enabled":false,"retention_period":0,"service":{"annotations":{},"labels":{}},"terminationGracePeriodSeconds":30,"tolerations":[]}` | DEPRECATED Configuration for the table-manager. The table-manager is only necessary when using a deprecated index type such as Cassandra, Bigtable, or DynamoDB, it has not been necessary since loki introduced self- contained index types like 'boltdb-shipper' and 'tsdb'. This will be removed in a future helm chart. |
| tableManager.enabled | bool | `false` | Specifies whether the table-manager should be enabled |
| tableManager.image.registry | string | `nil` | The Docker registry for the table-manager image. Overrides `loki.image.registry` |
| tableManager.image.repository | string | `nil` | Docker image repository for the table-manager image. Overrides `loki.image.repository` |
| tableManager.image.tag | string | `nil` | Docker image tag for the table-manager image. Overrides `loki.image.tag` |
| tableManager.command | string | `nil` | Command to execute instead of defined in Docker image |
| tableManager.priorityClassName | string | `nil` | The name of the PriorityClass for table-manager pods |
| tableManager.podLabels | object | `{}` | Labels for table-manager pods |
| tableManager.annotations | object | `{}` | Annotations for table-manager deployment |
| tableManager.podAnnotations | object | `{}` | Annotations for table-manager pods |
| tableManager.service.annotations | object | `{}` | Annotations for table-manager Service |
| tableManager.service.labels | object | `{}` | Additional labels for table-manager Service |
| tableManager.extraArgs | list | `[]` | Additional CLI args for the table-manager |
| tableManager.extraEnv | list | `[]` | Environment variables to add to the table-manager pods |
| tableManager.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the table-manager pods |
| tableManager.extraVolumeMounts | list | `[]` | Volume mounts to add to the table-manager pods |
| tableManager.extraVolumes | list | `[]` | Volumes to add to the table-manager pods |
| tableManager.resources | object | `{}` | Resource requests and limits for the table-manager |
| tableManager.extraContainers | list | `[]` | Containers to add to the table-manager pods |
| tableManager.terminationGracePeriodSeconds | int | `30` | Grace period to allow the table-manager to shutdown before it is killed |
| tableManager.affinity | object | Hard node and anti-affinity | Affinity for table-manager pods. |
| tableManager.dnsConfig | object | `{}` | DNS config table-manager pods |
| tableManager.nodeSelector | object | `{}` | Node selector for table-manager pods |
| tableManager.tolerations | list | `[]` | Tolerations for table-manager pods |
| tableManager.retention_deletes_enabled | bool | `false` | Enable deletes by retention |
| tableManager.retention_period | int | `0` | Set retention period |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
