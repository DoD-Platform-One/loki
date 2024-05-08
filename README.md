# loki

![Version: 5.47.2-bb.4](https://img.shields.io/badge/Version-5.47.2--bb.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.9.6](https://img.shields.io/badge/AppVersion-2.9.6-informational?style=flat-square)

Helm chart for Grafana Loki in simple, scalable mode

**Homepage:** <https://grafana.github.io/helm-charts>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| trevorwhitney |  |  |
| jeschkies |  |  |

## Source Code

* <https://github.com/grafana/loki>
* <https://grafana.com/oss/loki/>
* <https://grafana.com/docs/loki/latest/>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://grafana.github.io/helm-charts | grafana-agent-operator(grafana-agent-operator) | 0.3.19 |
| oci://registry1.dso.mil/bigbang | gluon | 0.4.8 |
| oci://registry1.dso.mil/bigbang | minio(minio-instance) | 5.0.12-bb.6 |

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
| kubectlImage.registry | string | `"registry1.dso.mil"` | The Docker registry |
| kubectlImage.repository | string | `"ironbank/opensource/kubernetes/kubectl"` | Docker image repository |
| kubectlImage.tag | string | `"v1.28.8"` | Overrides the image tag whose default is the chart's appVersion |
| kubectlImage.digest | string | `nil` | Overrides the image tag with an image digest |
| kubectlImage.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| loki.readinessProbe.httpGet.path | string | `"/ready"` |  |
| loki.readinessProbe.httpGet.port | string | `"http-metrics"` |  |
| loki.readinessProbe.initialDelaySeconds | int | `30` |  |
| loki.readinessProbe.timeoutSeconds | int | `1` |  |
| loki.image.registry | string | `"registry1.dso.mil"` | The Docker registry |
| loki.image.repository | string | `"ironbank/opensource/grafana/loki"` | Docker image repository |
| loki.image.tag | string | `"2.9.6"` | Overrides the image tag whose default is the chart's appVersion |
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
| loki.existingSecretForConfig | string | `""` | Specify an existing secret containing loki configuration. If non-empty, overrides `loki.config` |
| loki.configStorageType | string | `"ConfigMap"` | Defines what kind of object stores the configuration, a ConfigMap or a Secret. In order to move sensitive information (such as credentials) from the ConfigMap/Secret to a more secure location (e.g. vault), it is possible to use [environment variables in the configuration](https://grafana.com/docs/loki/latest/configuration/#use-environment-variables-in-the-configuration). Such environment variables can be then stored in a separate Secret and injected via the global.extraEnvFrom value. For details about environment injection from a Secret please see [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/#use-case-as-container-environment-variables). |
| loki.externalConfigSecretName | string | `"{{ include \"loki.name\" . }}"` | Name of the Secret or ConfigMap that contains the configuration (used for naming even if config is internal). |
| loki.config | string | See values.yaml | Config file contents for Loki |
| loki.auth_enabled | bool | `false` |  |
| loki.memberlistConfig | object | `{}` | memberlist configuration (overrides embedded default) |
| loki.extraMemberlistConfig | object | `{}` | Extra memberlist configuration |
| loki.tenants | list | `[]` | Tenants list to be created on nginx htpasswd file, with name and password keys |
| loki.server | object | `{"grpc_listen_port":9095,"http_listen_port":3100}` | Check https://grafana.com/docs/loki/latest/configuration/#server for more info on the server configuration. |
| loki.limits_config | object | `{"max_cache_freshness_per_query":"10m","reject_old_samples":true,"reject_old_samples_max_age":"168h","split_queries_by_interval":"15m"}` | Limits config |
| loki.runtimeConfig | object | `{}` | Provides a reloadable runtime configuration file for some specific configuration |
| loki.commonConfig | object | `{"compactor_address":"{{ include \"loki.compactorAddress\" . }}","path_prefix":"/var/loki","replication_factor":1}` | Check https://grafana.com/docs/loki/latest/configuration/#common_config for more info on how to provide a common configuration |
| loki.storage | object | `{"azure":{"accountKey":null,"accountName":null,"connectionString":null,"endpointSuffix":null,"requestTimeout":null,"useFederatedToken":false,"useManagedIdentity":false,"userAssignedId":null},"bucketNames":{"admin":"loki-admin","chunks":"loki","ruler":"loki"},"filesystem":{"chunks_directory":"/var/loki/chunks","rules_directory":"/var/loki/rules"},"gcs":{"chunkBufferSize":0,"enableHttp2":true,"requestTimeout":"0s"},"s3":{"accessKeyId":null,"backoff_config":{},"endpoint":null,"http_config":{},"insecure":false,"region":null,"s3":null,"s3ForcePathStyle":false,"secretAccessKey":null,"signatureVersion":null},"swift":{"auth_url":null,"auth_version":null,"connect_timeout":null,"container_name":null,"domain_id":null,"domain_name":null,"internal":null,"max_retries":null,"password":null,"project_domain_id":null,"project_domain_name":null,"project_id":null,"project_name":null,"region_name":null,"request_timeout":null,"user_domain_id":null,"user_domain_name":null,"user_id":null,"username":null},"type":"s3"}` | Storage config. Providing this will automatically populate all necessary storage configs in the templated config. |
| loki.storage.s3.backoff_config | object | `{}` | Check https://grafana.com/docs/loki/latest/configure/#s3_storage_config for more info on how to provide a backoff_config |
| loki.memcached | object | `{"chunk_cache":{"batch_size":256,"enabled":false,"host":"","parallelism":10,"service":"memcached-client"},"results_cache":{"default_validity":"12h","enabled":false,"host":"","service":"memcached-client","timeout":"500ms"}}` | Configure memcached as an external cache for chunk and results cache. Disabled by default must enable and specify a host for each cache you would like to use. |
| loki.schemaConfig | object | `{}` | Check https://grafana.com/docs/loki/latest/configuration/#schema_config for more info on how to configure schemas |
| loki.rulerConfig | object | `{}` | Check https://grafana.com/docs/loki/latest/configuration/#ruler for more info on configuring ruler |
| loki.structuredConfig | object | `{}` | Structured loki configuration, takes precedence over `loki.config`, `loki.schemaConfig`, `loki.storageConfig` |
| loki.query_scheduler | object | `{}` | Additional query scheduler config |
| loki.storage_config | object | `{"boltdb_shipper":{"active_index_directory":"/var/loki/boltdb-shipper-active","cache_location":"/var/loki/boltdb-shipper-cache","cache_ttl":"24h"},"hedging":{"at":"250ms","max_per_second":20,"up_to":3},"tsdb_shipper":{"active_index_directory":"/var/loki/tsdb-index","cache_location":"/var/loki/tsdb-cache","cache_ttl":"24h"}}` | Additional storage config |
| loki.compactor | object | `{}` | Optional compactor configuration |
| loki.analytics | object | `{"reporting_enabled":false}` | Optional analytics configuration |
| loki.analytics.reporting_enabled | bool | `false` | Disable anonymous usage statistics |
| loki.querier | object | `{}` | Optional querier configuration |
| loki.ingester | object | `{"autoforget_unhealthy":true,"chunk_target_size":196608,"flush_check_period":"5s","flush_op_timeout":"100m","lifecycler":{"ring":{"kvstore":{"store":"memberlist"}}}}` | Optional ingester configuration |
| loki.index_gateway | object | `{"mode":"ring"}` | Optional index gateway configuration |
| loki.frontend.scheduler_address | string | `"{{ include \"loki.querySchedulerAddress\" . }}"` |  |
| loki.frontend_worker.scheduler_address | string | `"{{ include \"loki.querySchedulerAddress\" . }}"` |  |
| loki.distributor | object | `{}` | Optional distributor configuration |
| loki.tracing | object | `{"enabled":false}` | Enable tracing |
| enterprise.enabled | bool | `false` |  |
| enterprise.version | string | `"v1.8.6"` |  |
| enterprise.cluster_name | string | `nil` | Optional name of the GEL cluster, otherwise will use .Release.Name The cluster name must match what is in your GEL license |
| enterprise.license | object | `{"contents":"NOTAVALIDLICENSE"}` | Grafana Enterprise Logs license In order to use Grafana Enterprise Logs features, you will need to provide the contents of your Grafana Enterprise Logs license, either by providing the contents of the license.jwt, or the name Kubernetes Secret that contains your license.jwt. To set the license contents, use the flag `--set-file 'enterprise.license.contents=./license.jwt'` |
| enterprise.useExternalLicense | bool | `false` | Set to true when providing an external license |
| enterprise.externalLicenseName | string | `nil` | Name of external license secret to use |
| enterprise.externalConfigName | string | `""` | Name of the external config secret to use |
| enterprise.adminApi | object | `{"enabled":true}` | If enabled, the correct admin_client storage will be configured. If disabled while running enterprise, make sure auth is set to `type: trust`, or that `auth_enabled` is set to `false`. |
| enterprise.config | string | `"{{- if .Values.enterprise.adminApi.enabled }}\n{{- if or .Values.minio.enabled (eq .Values.loki.storage.type \"s3\") (eq .Values.loki.storage.type \"gcs\") (eq .Values.loki.storage.type \"azure\") }}\nadmin_client:\n  storage:\n    s3:\n      bucket_name: {{ .Values.loki.storage.bucketNames.admin }}\n{{- end }}\n{{- end }}\nauth:\n  type: {{ .Values.enterprise.adminApi.enabled | ternary \"enterprise\" \"trust\" }}\nauth_enabled: {{ .Values.loki.auth_enabled }}\ncluster_name: {{ include \"loki.clusterName\" . }}\nlicense:\n  path: /etc/loki/license/license.jwt\n"` |  |
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
| migrate | object | `{"fromDistributed":{"enabled":false,"memberlistService":""}}` | Options that may be necessary when performing a migration from another helm chart |
| migrate.fromDistributed | object | `{"enabled":false,"memberlistService":""}` | When migrating from a distributed chart like loki-distributed or enterprise-logs |
| migrate.fromDistributed.enabled | bool | `false` | Set to true if migrating from a distributed helm chart |
| migrate.fromDistributed.memberlistService | string | `""` | If migrating from a distributed service, provide the distributed deployment's memberlist service DNS so the new deployment can join its ring. |
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
| test | object | `{"annotations":{},"enabled":false,"image":{"digest":null,"pullPolicy":"IfNotPresent","registry":"docker.io","repository":"grafana/loki-helm-test","tag":null},"labels":{},"prometheusAddress":"http://prometheus:9090","timeout":"1m"}` | Section for configuring optional Helm test |
| test.prometheusAddress | string | `"http://prometheus:9090"` | Address of the prometheus server to query for the test |
| test.timeout | string | `"1m"` | Number of times to retry the test before failing |
| test.labels | object | `{}` | Additional labels for the test pods |
| test.annotations | object | `{}` | Additional annotations for test pods |
| test.image | object | `{"digest":null,"pullPolicy":"IfNotPresent","registry":"docker.io","repository":"grafana/loki-helm-test","tag":null}` | Image to use for loki canary |
| test.image.registry | string | `"docker.io"` | The Docker registry |
| test.image.repository | string | `"grafana/loki-helm-test"` | Docker image repository |
| test.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| test.image.digest | string | `nil` | Overrides the image tag with an image digest |
| test.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| fluentbit.enabled | bool | `false` |  |
| promtail.enabled | bool | `false` |  |
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
| monitoring.serviceMonitor.namespace | string | `nil` | Alternative namespace for ServiceMonitor resources |
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
| monitoring.selfMonitoring.enabled | bool | `false` |  |
| monitoring.selfMonitoring.tenant | object | `{"name":"self-monitoring","secretNamespace":"{{ .Release.Namespace }}"}` | Tenant to use for self monitoring |
| monitoring.selfMonitoring.tenant.name | string | `"self-monitoring"` | Name of the tenant |
| monitoring.selfMonitoring.tenant.secretNamespace | string | `"{{ .Release.Namespace }}"` | Namespace to create additional tenant token secret in. Useful if your Grafana instance is in a separate namespace. Token will still be created in the canary namespace. |
| monitoring.selfMonitoring.grafanaAgent.installOperator | bool | `false` | Controls whether to install the Grafana Agent Operator and its CRDs. Note that helm will not install CRDs if this flag is enabled during an upgrade. In that case install the CRDs manually from https://github.com/grafana/agent/tree/main/production/operator/crds |
| monitoring.selfMonitoring.grafanaAgent.namespace | string | `nil` | Alternative namespace for Grafana Agent resources |
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
| monitoring.lokiCanary.enabled | bool | `false` |  |
| monitoring.lokiCanary.annotations | object | `{}` | Additional annotations for the `loki-canary` Daemonset |
| monitoring.lokiCanary.podLabels | object | `{}` | Additional labels for each `loki-canary` pod |
| monitoring.lokiCanary.service.annotations | object | `{}` | Annotations for loki-canary Service |
| monitoring.lokiCanary.service.labels | object | `{}` | Additional labels for loki-canary Service |
| monitoring.lokiCanary.extraArgs | list | `[]` | Additional CLI arguments for the `loki-canary' command |
| monitoring.lokiCanary.extraEnv | list | `[]` | Environment variables to add to the canary pods |
| monitoring.lokiCanary.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the canary pods |
| monitoring.lokiCanary.resources | object | `{}` | Resource requests and limits for the canary |
| monitoring.lokiCanary.dnsConfig | object | `{}` | DNS config for canary pods |
| monitoring.lokiCanary.nodeSelector | object | `{}` | Node selector for canary pods |
| monitoring.lokiCanary.tolerations | list | `[]` | Tolerations for canary pods |
| monitoring.lokiCanary.priorityClassName | string | `nil` | The name of the PriorityClass for loki-canary pods |
| monitoring.lokiCanary.image | object | `{"digest":null,"pullPolicy":"IfNotPresent","registry":"docker.io","repository":"grafana/loki-canary","tag":null}` | Image to use for loki canary |
| monitoring.lokiCanary.image.registry | string | `"docker.io"` | The Docker registry |
| monitoring.lokiCanary.image.repository | string | `"grafana/loki-canary"` | Docker image repository |
| monitoring.lokiCanary.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| monitoring.lokiCanary.image.digest | string | `nil` | Overrides the image tag with an image digest |
| monitoring.lokiCanary.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| monitoring.lokiCanary.updateStrategy | object | `{"rollingUpdate":{"maxUnavailable":1},"type":"RollingUpdate"}` | Update strategy for the `loki-canary` Daemonset pods |
| write.replicas | int | `3` | Number of replicas for the write |
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
| write.terminationGracePeriodSeconds | int | `300` | Grace period to allow the write to shutdown before it is killed. Especially for the ingestor, this must be increased. It must be long enough so writes can be gracefully shutdown flushing/transferring all data and to successfully leave the member ring on shutdown. |
| write.affinity | string | Hard node and soft zone anti-affinity | Affinity for write pods. Passed through `tpl` and, thus, to be configured as string |
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
| tableManager.affinity | string | Hard node and soft zone anti-affinity | Affinity for table-manager pods. Passed through `tpl` and, thus, to be configured as string |
| tableManager.dnsConfig | object | `{}` | DNS config table-manager pods |
| tableManager.nodeSelector | object | `{}` | Node selector for table-manager pods |
| tableManager.tolerations | list | `[]` | Tolerations for table-manager pods |
| tableManager.retention_deletes_enabled | bool | `false` | Enable deletes by retention |
| tableManager.retention_period | int | `0` | Set retention period |
| read.replicas | int | `3` | Number of replicas for the read |
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
| read.affinity | string | Hard node and soft zone anti-affinity | Affinity for read pods. Passed through `tpl` and, thus, to be configured as string |
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
| backend.replicas | int | `3` | Number of replicas for the backend |
| backend.autoscaling.enabled | bool | `false` | Enable autoscaling for the backend. |
| backend.autoscaling.minReplicas | int | `2` | Minimum autoscaling replicas for the backend. |
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
| backend.affinity | string | Hard node and soft zone anti-affinity | Affinity for backend pods. Passed through `tpl` and, thus, to be configured as string |
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
| singleBinary.affinity | string | Hard node and soft zone anti-affinity | Affinity for single binary pods. Passed through `tpl` and, thus, to be configured as string |
| singleBinary.dnsConfig | object | `{}` | DNS config for single binary pods |
| singleBinary.nodeSelector | object | `{}` | Node selector for single binary pods |
| singleBinary.tolerations | list | `[]` | Tolerations for single binary pods |
| singleBinary.persistence.enableStatefulSetAutoDeletePVC | bool | `false` | Enable StatefulSetAutoDeletePVC feature |
| singleBinary.persistence.enabled | bool | `true` | Enable persistent disk |
| singleBinary.persistence.size | string | `"12Gi"` | Size of persistent disk |
| singleBinary.persistence.storageClass | string | `nil` | Storage class to be used. If defined, storageClassName: <storageClass>. If set to "-", storageClassName: "", which disables dynamic provisioning. If empty or set to null, no storageClassName spec is set, choosing the default provisioner (gp2 on AWS, standard on GKE, AWS, and OpenStack). |
| singleBinary.persistence.selector | string | `nil` | Selector for persistent disk |
| ingress.enabled | bool | `false` |  |
| ingress.ingressClassName | string | `""` |  |
| ingress.annotations | object | `{}` |  |
| ingress.labels | object | `{}` |  |
| ingress.paths.write[0] | string | `"/api/prom/push"` |  |
| ingress.paths.write[1] | string | `"/loki/api/v1/push"` |  |
| ingress.paths.read[0] | string | `"/api/prom/tail"` |  |
| ingress.paths.read[1] | string | `"/loki/api/v1/tail"` |  |
| ingress.paths.read[2] | string | `"/loki/api"` |  |
| ingress.paths.read[3] | string | `"/api/prom/rules"` |  |
| ingress.paths.read[4] | string | `"/loki/api/v1/rules"` |  |
| ingress.paths.read[5] | string | `"/prometheus/api/v1/rules"` |  |
| ingress.paths.read[6] | string | `"/prometheus/api/v1/alerts"` |  |
| ingress.paths.singleBinary[0] | string | `"/api/prom/push"` |  |
| ingress.paths.singleBinary[1] | string | `"/loki/api/v1/push"` |  |
| ingress.paths.singleBinary[2] | string | `"/api/prom/tail"` |  |
| ingress.paths.singleBinary[3] | string | `"/loki/api/v1/tail"` |  |
| ingress.paths.singleBinary[4] | string | `"/loki/api"` |  |
| ingress.paths.singleBinary[5] | string | `"/api/prom/rules"` |  |
| ingress.paths.singleBinary[6] | string | `"/loki/api/v1/rules"` |  |
| ingress.paths.singleBinary[7] | string | `"/prometheus/api/v1/rules"` |  |
| ingress.paths.singleBinary[8] | string | `"/prometheus/api/v1/alerts"` |  |
| ingress.hosts | list | `["loki.example.com"]` | Hosts configuration for the ingress, passed through the `tpl` function to allow templating |
| ingress.tls | list | `[]` | TLS configuration for the ingress. Hosts passed through the `tpl` function to allow templating |
| memberlist.service.publishNotReadyAddresses | bool | `false` |  |
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
| gateway.affinity | string | Hard node and soft zone anti-affinity | Affinity for gateway pods. Passed through `tpl` and, thus, to be configured as string |
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
| gateway.basicAuth.htpasswd | string | `"{{ if .Values.loki.tenants }}\n\n  {{- range $t := .Values.loki.tenants }}\n{{ htpasswd (required \"All tenants must have a 'name' set\" $t.name) (required \"All tenants must have a 'password' set\" $t.password) }}\n\n  {{- end }}\n{{ else }} {{ htpasswd (required \"'gateway.basicAuth.username' is required\" .Values.gateway.basicAuth.username) (required \"'gateway.basicAuth.password' is required\" .Values.gateway.basicAuth.password) }} {{ end }}"` | Uses the specified users from the `loki.tenants` list to create the htpasswd file if `loki.tenants` is not set, the `gateway.basicAuth.username` and `gateway.basicAuth.password` are used The value is templated using `tpl`. Override this to use a custom htpasswd, e.g. in case the default causes high CPU load. |
| gateway.basicAuth.existingSecret | string | `nil` | Existing basic auth secret to use. Must contain '.htpasswd' |
| gateway.readinessProbe.httpGet.path | string | `"/"` |  |
| gateway.readinessProbe.httpGet.port | string | `"http"` |  |
| gateway.readinessProbe.initialDelaySeconds | int | `15` |  |
| gateway.readinessProbe.timeoutSeconds | int | `1` |  |
| gateway.nginxConfig.enableIPv6 | bool | `true` | Enable listener for IPv6, disable on IPv4-only systems |
| gateway.nginxConfig.logFormat | string | `"main '$remote_addr - $remote_user [$time_local]  $status '\n        '\"$request\" $body_bytes_sent \"$http_referer\" '\n        '\"$http_user_agent\" \"$http_x_forwarded_for\"';"` | NGINX log format |
| gateway.nginxConfig.serverSnippet | string | `""` | Allows appending custom configuration to the server block |
| gateway.nginxConfig.httpSnippet | string | `"{{ if .Values.loki.tenants }}proxy_set_header X-Scope-OrgID $remote_user;{{ end }}"` | Allows appending custom configuration to the http block, passed through the `tpl` function to allow templating |
| gateway.nginxConfig.customReadUrl | string | `nil` | Override Read URL |
| gateway.nginxConfig.customWriteUrl | string | `nil` | Override Write URL |
| gateway.nginxConfig.customBackendUrl | string | `nil` | Override Backend URL |
| gateway.nginxConfig.resolver | string | `""` | Allows overriding the DNS resolver address nginx will use. |
| gateway.nginxConfig.file | string | See values.yaml | Config file contents for Nginx. Passed through the `tpl` function to allow templating |
| gateway.podDisruptionBudget.minAvailable | string | `""` (defaults to 0 if not specified) | Number of pods that are available after eviction as number or percentage (eg.: 50%) |
| gateway.podDisruptionBudget.maxUnavailable | string | `"1"` | Number of pods that are unavailable after eviction as number or percentage (eg.: 50%). # Has higher precedence over `controller.pdb.minAvailable` |
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
| minio | object | `{"enabled":false,"secrets":{"accessKey":"minio","name":"loki-objstore-creds","secretKey":"minio123"},"service":{"nameOverride":"minio.logging.svc.cluster.local"},"tenant":{"buckets":[{"name":"loki"},{"name":"loki-admin"}],"defaultUserCredentials":{"password":"","username":"minio-user"},"metrics":{"enabled":false,"memory":"128M","port":9000},"pools":[{"containerSecurityContext":{"capabilities":{"drop":["ALL"]}},"securityContext":{"fsGroup":1001,"runAsGroup":1001,"runAsUser":1001},"servers":1,"size":"750Mi","volumesPerServer":4}],"users":[{"name":"minio-user"}]}}` | ----------------------------------- |
| minio.enabled | bool | `false` | Enable minio instance support, must have minio-operator installed |
| minio.secrets | object | `{"accessKey":"minio","name":"loki-objstore-creds","secretKey":"minio123"}` | Minio root credentials |
| minio.tenant.buckets | list | `[{"name":"loki"},{"name":"loki-admin"}]` | Buckets to be provisioned to for tenant |
| minio.tenant.users | list | `[{"name":"minio-user"}]` | Users to to be provisioned to for tenant |
| minio.tenant.defaultUserCredentials | object | `{"password":"","username":"minio-user"}` | User credentials to create for above user. Otherwise password is randomly generated. This auth is not required to be set or reclaimed for minio use with Loki |
| domain | string | `"bigbang.dev"` |  |
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

