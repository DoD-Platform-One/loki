# loki-simple-scalable

![Version: 1.8.10-bb.1](https://img.shields.io/badge/Version-1.8.10--bb.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.6.1](https://img.shields.io/badge/AppVersion-2.6.1-informational?style=flat-square)

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
helm install loki-simple-scalable chart/
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
| fullnameOverride | string | `"logging-loki"` | Overrides the chart's computed fullname |
| imagePullSecrets | list | `[{"name":"private-registry"}]` | Image pull secrets for Docker images |
| loki.readinessProbe.httpGet.path | string | `"/ready"` |  |
| loki.readinessProbe.httpGet.port | string | `"http-metrics"` |  |
| loki.readinessProbe.initialDelaySeconds | int | `30` |  |
| loki.readinessProbe.timeoutSeconds | int | `1` |  |
| loki.image.registry | string | `"registry1.dso.mil"` | The Docker registry |
| loki.image.repository | string | `"ironbank/opensource/grafana/loki"` | Docker image repository |
| loki.image.tag | string | `"2.6.1"` | Overrides the image tag whose default is the chart's appVersion |
| loki.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| loki.podAnnotations | object | `{}` | Common annotations for all pods |
| loki.revisionHistoryLimit | int | `10` | The number of old ReplicaSets to retain to allow rollback |
| loki.podSecurityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001}` | The SecurityContext for Loki pods |
| loki.containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true}` | The SecurityContext for Loki containers |
| loki.existingSecretForConfig | string | `""` | Specify an existing secret containing loki configuration. If non-empty, overrides `loki.config` |
| loki.config | string | See values.yaml | Config file contents for Loki |
| loki.auth_enabled | bool | `false` |  |
| loki.commonConfig | object | `{"path_prefix":"/var/loki","replication_factor":3}` | Check https://grafana.com/docs/loki/latest/configuration/#common_config for more info on how to provide a common configuration |
| loki.extraServerConfig | object | `{}` | Extra server configurations. Check https://grafana.com/docs/loki/latest/configuration/#server for more info |
| loki.storage.bucketNames.chunks | string | `"loki"` |  |
| loki.storage.bucketNames.ruler | string | `"loki"` |  |
| loki.storage.bucketNames.admin | string | `"loki-admin"` |  |
| loki.storage.type | string | `"s3"` |  |
| loki.storage.s3.s3 | string | `nil` |  |
| loki.storage.s3.endpoint | string | `nil` |  |
| loki.storage.s3.region | string | `nil` |  |
| loki.storage.s3.secretAccessKey | string | `nil` |  |
| loki.storage.s3.accessKeyId | string | `nil` |  |
| loki.storage.s3.s3ForcePathStyle | bool | `false` |  |
| loki.storage.s3.insecure | bool | `false` |  |
| loki.storage.gcs.chunkBufferSize | int | `0` |  |
| loki.storage.gcs.requestTimeout | string | `"0s"` |  |
| loki.storage.gcs.enableHttp2 | bool | `true` |  |
| loki.storage.local.chunks_directory | string | `"/var/loki/chunks"` |  |
| loki.storage.local.rules_directory | string | `"/var/loki/rules"` |  |
| loki.memcached | object | `{"chunk_cache":{"batch_size":256,"enabled":false,"host":"","parallelism":10,"service":"memcached-client"},"results_cache":{"default_validity":"12h","enabled":false,"host":"","service":"memcached-client","timeout":"500ms"}}` | Configure memcached as an external cache for chunk and results cache. Disabled by default must enable and specify a host for each cache you would like to use. |
| loki.schemaConfig | object | `{}` | Check https://grafana.com/docs/loki/latest/configuration/#schema_config for more info on how to configure schemas |
| loki.structuredConfig | object | `{}` | Structured loki configuration, takes precedence over `loki.config`, `loki.schemaConfig`, `loki.storageConfig` |
| loki.query_scheduler | object | `{}` | Additional query scheduler config |
| loki.storage_config | object | `{"boltdb_shipper":{"active_index_directory":"/var/loki/boltdb-shipper-active","cache_location":"/var/loki/boltdb-shipper-cache","cache_ttl":"24h","shared_store":"s3"},"hedging":{"at":"250ms","max_per_second":20,"up_to":3}}` | Additional storage config |
| enterprise.enabled | bool | `false` |  |
| enterprise.version | string | `"v1.5.0"` |  |
| enterprise.license | object | `{"contents":"NOTAVALIDLICENSE"}` | Grafana Enterprise Logs license In order to use Grafana Enterprise Logs features, you will need to provide the contents of your Grafana Enterprise Logs license, either by providing the contents of the license.jwt, or the name Kubernetes Secret that contains your license.jwt. To set the license contents, use the flag `--set-file 'license.contents=./license.jwt'` |
| enterprise.useExternalLicense | bool | `false` | Set to true when providing an external license |
| enterprise.externalLicenseName | string | `nil` | Name of external licesne secret to use |
| enterprise.cluster_name | string | `""` | Name of cluster, must match cluster ID/Name on Grafana License |
| enterprise.adminApi | object | `{"enabled":true}` | If enabled, the correct admin_client storage will be configured. If disabled while running enterprise, make sure auth is set to `type: trust`, or that `auth_enabled` is set to `false`. |
| enterprise.config | string | `"{{- if .Values.enterprise.adminApi.enabled }}\n{{- if or .Values.minio.enabled (eq .Values.loki.storage.type \"s3\") (eq .Values.loki.storage.type \"gcs\") }}\nadmin_client:\n  storage:\n    s3:\n      bucket_name: {{ .Values.loki.storage.bucketNames.admin }}\n{{- end }}\n{{- end }}\nauth:\n  type: {{ .Values.enterprise.adminApi.enabled \| ternary \"enterprise\" \"trust\" }}\nauth_enabled: {{ .Values.loki.auth_enabled }}\ncluster_name: {{ default .Release.Name .Values.enterprise.cluster_name \| quote }}\nlicense:\n  path: /etc/loki/license/license.jwt\n"` |  |
| enterprise.image.registry | string | `"registry1.dso.mil"` | The Docker registry |
| enterprise.image.repository | string | `"ironbank/grafana/grafana-enterprise-logs"` | Docker image repository |
| enterprise.image.tag | string | `"v1.5.0"` | Overrides the image tag whose default is the chart's appVersion |
| enterprise.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| enterprise.tokengen | object | `{"adminTokenSecret":"gel-admin-token","annotations":{},"enabled":true,"env":[],"extraArgs":[],"extraVolumeMounts":[],"extraVolumes":[],"labels":{},"securityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001},"tolerations":[]}` | Configuration for `tokengen` target |
| enterprise.tokengen.enabled | bool | `true` | Whether the job should be part of the deployment |
| enterprise.tokengen.adminTokenSecret | string | `"gel-admin-token"` | Name of the secret to store the admin token in |
| enterprise.tokengen.extraArgs | list | `[]` | Additional CLI arguments for the `tokengen` target |
| enterprise.tokengen.env | list | `[]` | Additional Kubernetes environment |
| enterprise.tokengen.labels | object | `{}` | Additional labels for the `tokengen` Job |
| enterprise.tokengen.annotations | object | `{}` | Additional annotations for the `tokengen` Job |
| enterprise.tokengen.extraVolumes | list | `[]` | Additional volumes for Pods |
| enterprise.tokengen.tolerations | list | `[]` | Tolerations for tokengen Job |
| enterprise.tokengen.extraVolumeMounts | list | `[]` | Additional volume mounts for Pods |
| enterprise.tokengen.securityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001}` | Run containers as user `enterprise-logs(uid=10001)` |
| serviceAccount.create | bool | `true` | Specifies whether a ServiceAccount should be created |
| serviceAccount.name | string | `nil` | The name of the ServiceAccount to use. If not set and create is true, a name is generated using the fullname template |
| serviceAccount.imagePullSecrets | list | `[]` | Image pull secrets for the service account |
| serviceAccount.annotations | object | `{}` | Annotations for the service account |
| serviceAccount.automountServiceAccountToken | bool | `true` | Set this toggle to false to opt out of automounting API credentials for the service account |
| rbac.pspEnabled | bool | `false` | If pspEnabled true, a PodSecurityPolicy is created for K8s that use psp. |
| rbac.sccEnabled | bool | `false` | For OpenShift set pspEnabled to 'false' and sccEnabled to 'true' to use the SecurityContextConstraints. |
| monitoring.enabled | bool | `false` | Enable BigBang integration of Monitoring components |
| monitoring.dashboards.enabled | bool | `false` | If enabled, create configmap with dashboards for monitoring Loki |
| monitoring.dashboards.namespace | string | `nil` | Alternative namespace to create dashboards ConfigMap in |
| monitoring.dashboards.annotations | object | `{}` | Additional annotations for the dashboards ConfigMap |
| monitoring.dashboards.labels | object | `{}` | Additional labels for the dashboards ConfigMap |
| monitoring.rules.enabled | bool | `false` | If enabled, create PrometheusRule resource with Loki recording rules |
| monitoring.rules.alerting | bool | `true` | Include alerting rules |
| monitoring.rules.namespace | string | `nil` | Alternative namespace to create recording rules PrometheusRule resource in |
| monitoring.rules.annotations | object | `{}` | Additional annotations for the rules PrometheusRule resource |
| monitoring.rules.labels | object | `{}` | Additional labels for the rules PrometheusRule resource |
| monitoring.rules.additionalGroups | list | `[]` | Additional groups to add to the rules file |
| monitoring.alerts.enabled | bool | `false` | If enabled, create PrometheusRule resource with Loki alerting rules |
| monitoring.alerts.namespace | string | `nil` | Alternative namespace to create alerting rules PrometheusRule resource in |
| monitoring.alerts.annotations | object | `{}` | Additional annotations for the alerts PrometheusRule resource |
| monitoring.alerts.labels | object | `{}` | Additional labels for the alerts PrometheusRule resource |
| monitoring.serviceMonitor.enabled | bool | `false` | If enabled, ServiceMonitor resources for Prometheus Operator are created |
| monitoring.serviceMonitor.namespace | string | `nil` | Alternative namespace for ServiceMonitor resources |
| monitoring.serviceMonitor.namespaceSelector | object | `{}` | Namespace selector for ServiceMonitor resources |
| monitoring.serviceMonitor.annotations | object | `{}` | ServiceMonitor annotations |
| monitoring.serviceMonitor.labels | object | `{}` | Additional ServiceMonitor labels |
| monitoring.serviceMonitor.interval | string | `nil` | ServiceMonitor scrape interval |
| monitoring.serviceMonitor.scrapeTimeout | string | `nil` | ServiceMonitor scrape timeout in Go duration format (e.g. 15s) |
| monitoring.serviceMonitor.relabelings | list | `[]` | ServiceMonitor relabel configs to apply to samples before scraping https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/api.md#relabelconfig |
| monitoring.serviceMonitor.scheme | string | `"http"` | ServiceMonitor will use http by default, but you can pick https as well |
| monitoring.serviceMonitor.tlsConfig | string | `nil` | ServiceMonitor will use these tlsConfig settings to make the health check requests |
| monitoring.selfMonitoring.enabled | bool | `false` |  |
| monitoring.selfMonitoring.grafanaAgent.installOperator | bool | `false` | Controls whether to install the Grafana Agent Operator and its CRDs. Note that helm will not install CRDs if this flag is enabled during an upgrade. In that case install the CRDs manually from https://github.com/grafana/agent/tree/main/production/operator/crds |
| monitoring.selfMonitoring.grafanaAgent.namespace | string | `nil` | Alternative namespace for Grafana Agent resources |
| monitoring.selfMonitoring.grafanaAgent.annotations | object | `{}` | Grafana Agent annotations |
| monitoring.selfMonitoring.grafanaAgent.labels | object | `{}` | Additional Grafana Agent labels |
| monitoring.selfMonitoring.grafanaAgent.enableConfigReadAPI | bool | `false` | Enable the config read api on port 8080 of the agent |
| monitoring.selfMonitoring.podLogs.namespace | string | `nil` | Alternative namespace for PodLogs resources |
| monitoring.selfMonitoring.podLogs.annotations | object | `{}` | PodLogs annotations |
| monitoring.selfMonitoring.podLogs.labels | object | `{}` | Additional PodLogs labels |
| monitoring.selfMonitoring.podLogs.relabelings | list | `[]` | PodLogs relabel configs to apply to samples before scraping https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/api.md#relabelconfig |
| monitoring.selfMonitoring.logsInstance.namespace | string | `nil` | Alternative namespace for LogsInstance resources |
| monitoring.selfMonitoring.logsInstance.annotations | object | `{}` | LogsInstance annotations |
| monitoring.selfMonitoring.logsInstance.labels | object | `{}` | Additional LogsInstance labels |
| write.replicas | int | `2` | Number of replicas for the write |
| write.image.registry | string | `nil` | The Docker registry for the write image. Overrides `loki.image.registry` |
| write.image.repository | string | `nil` | Docker image repository for the write image. Overrides `loki.image.repository` |
| write.image.tag | string | `nil` | Docker image tag for the write image. Overrides `loki.image.tag` |
| write.priorityClassName | string | `nil` | The name of the PriorityClass for write pods |
| write.podAnnotations | object | `{}` | Annotations for write pods |
| write.selectorLabels | object | `{}` | Additional selector labels for each `write` pod |
| write.serviceLabels | object | `{}` | Labels for ingestor service |
| write.extraArgs | list | `[]` | Additional CLI args for the write |
| write.extraEnv | list | `[]` | Environment variables to add to the write pods |
| write.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the write pods |
| write.extraVolumeMounts | list | `[]` | Volume mounts to add to the write pods |
| write.extraVolumes | list | `[]` | Volumes to add to the write pods |
| write.resources | object | `{"limits":{"cpu":"300m","memory":"2Gi"},"requests":{"cpu":"300m","memory":"2Gi"}}` | Resource requests and limits for the write |
| write.terminationGracePeriodSeconds | int | `300` | Grace period to allow the write to shutdown before it is killed. Especially for the ingestor, this must be increased. It must be long enough so writes can be gracefully shutdown flushing/transferring all data and to successfully leave the member ring on shutdown. |
| write.affinity | string | Hard node and soft zone anti-affinity | Affinity for write pods. Passed through `tpl` and, thus, to be configured as string |
| write.nodeSelector | object | `{}` | Node selector for write pods |
| write.tolerations | list | `[]` | Tolerations for write pods |
| write.persistence.size | string | `"10Gi"` | Size of persistent disk |
| write.persistence.storageClass | string | `nil` | Storage class to be used. If defined, storageClassName: <storageClass>. If set to "-", storageClassName: "", which disables dynamic provisioning. If empty or set to null, no storageClassName spec is set, choosing the default provisioner (gp2 on AWS, standard on GKE, AWS, and OpenStack). |
| read.replicas | int | `2` | Number of replicas for the read |
| read.autoscaling.enabled | bool | `false` | Enable autoscaling for the read, this is only used if `queryIndex.enabled: true` |
| read.autoscaling.minReplicas | int | `1` | Minimum autoscaling replicas for the read |
| read.autoscaling.maxReplicas | int | `3` | Maximum autoscaling replicas for the read |
| read.autoscaling.targetCPUUtilizationPercentage | int | `60` | Target CPU utilisation percentage for the read |
| read.autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Target memory utilisation percentage for the read |
| read.image.registry | string | `nil` | The Docker registry for the read image. Overrides `loki.image.registry` |
| read.image.repository | string | `nil` | Docker image repository for the read image. Overrides `loki.image.repository` |
| read.image.tag | string | `nil` | Docker image tag for the read image. Overrides `loki.image.tag` |
| read.priorityClassName | string | `nil` | The name of the PriorityClass for read pods |
| read.podAnnotations | object | `{}` | Annotations for read pods |
| read.selectorLabels | object | `{}` | Additional selecto labels for each `read` pod |
| read.serviceLabels | object | `{}` | Labels for read service |
| read.extraArgs | list | `[]` | Additional CLI args for the read |
| read.extraEnv | list | `[]` | Environment variables to add to the read pods |
| read.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the read pods |
| read.extraVolumeMounts | list | `[]` | Volume mounts to add to the read pods |
| read.extraVolumes | list | `[]` | Volumes to add to the read pods |
| read.resources | object | `{"limits":{"cpu":"300m","memory":"2Gi"},"requests":{"cpu":"300m","memory":"2Gi"}}` | Resource requests and limits for the read |
| read.terminationGracePeriodSeconds | int | `30` | Grace period to allow the read to shutdown before it is killed |
| read.affinity | string | Hard node and soft zone anti-affinity | Affinity for read pods. Passed through `tpl` and, thus, to be configured as string |
| read.nodeSelector | object | `{}` | Node selector for read pods |
| read.tolerations | list | `[]` | Tolerations for read pods |
| read.persistence.size | string | `"10Gi"` | Size of persistent disk |
| read.persistence.storageClass | string | `nil` | Storage class to be used. If defined, storageClassName: <storageClass>. If set to "-", storageClassName: "", which disables dynamic provisioning. If empty or set to null, no storageClassName spec is set, choosing the default provisioner (gp2 on AWS, standard on GKE, AWS, and OpenStack). |
| gateway.enabled | bool | `false` | Specifies whether the gateway should be enabled |
| gateway.replicas | int | `1` | Number of replicas for the gateway |
| gateway.verboseLogging | bool | `true` | Enable logging of 2xx and 3xx HTTP requests |
| gateway.autoscaling.enabled | bool | `false` | Enable autoscaling for the gateway |
| gateway.autoscaling.minReplicas | int | `1` | Minimum autoscaling replicas for the gateway |
| gateway.autoscaling.maxReplicas | int | `3` | Maximum autoscaling replicas for the gateway |
| gateway.autoscaling.targetCPUUtilizationPercentage | int | `60` | Target CPU utilisation percentage for the gateway |
| gateway.autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Target memory utilisation percentage for the gateway |
| gateway.deploymentStrategy | object | `{"type":"RollingUpdate"}` | ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy |
| gateway.image.registry | string | `"registry1.dso.mil"` | The Docker registry for the gateway image |
| gateway.image.repository | string | `"ironbank/opensource/nginx/nginx"` | The gateway image repository |
| gateway.image.tag | string | `"1.23.1"` | The gateway image tag |
| gateway.image.pullPolicy | string | `"IfNotPresent"` | The gateway image pull policy |
| gateway.priorityClassName | string | `nil` | The name of the PriorityClass for gateway pods |
| gateway.podAnnotations | object | `{}` | Annotations for gateway pods |
| gateway.extraArgs | list | `[]` | Additional CLI args for the gateway |
| gateway.extraEnv | list | `[]` | Environment variables to add to the gateway pods |
| gateway.extraEnvFrom | list | `[]` | Environment variables from secrets or configmaps to add to the gateway pods |
| gateway.extraVolumes | list | `[]` | Volumes to add to the gateway pods |
| gateway.extraVolumeMounts | list | `[]` | Volume mounts to add to the gateway pods |
| gateway.podSecurityContext | object | `{"fsGroup":101,"runAsGroup":101,"runAsNonRoot":true,"runAsUser":101}` | The SecurityContext for gateway containers |
| gateway.containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true}` | The SecurityContext for gateway containers |
| gateway.resources | object | `{}` | Resource requests and limits for the gateway |
| gateway.terminationGracePeriodSeconds | int | `30` | Grace period to allow the gateway to shutdown before it is killed |
| gateway.affinity | string | Hard node and soft zone anti-affinity | Affinity for gateway pods. Passed through `tpl` and, thus, to be configured as string |
| gateway.nodeSelector | object | `{}` | Node selector for gateway pods |
| gateway.tolerations | list | `[]` | Tolerations for gateway pods |
| gateway.service.port | int | `80` | Port of the gateway service |
| gateway.service.type | string | `"ClusterIP"` | Type of the gateway service |
| gateway.service.clusterIP | string | `nil` | ClusterIP of the gateway service |
| gateway.service.nodePort | int | `nil` | Node port if service type is NodePort |
| gateway.service.loadBalancerIP | string | `nil` | Load balancer IPO address if service type is LoadBalancer |
| gateway.service.annotations | object | `{}` | Annotations for the gateway service |
| gateway.service.labels | object | `{}` | Labels for gateway service |
| gateway.ingress.enabled | bool | `false` | Specifies whether an ingress for the gateway should be created |
| gateway.ingress.annotations | object | `{}` | Annotations for the gateway ingress |
| gateway.ingress.hosts | list | `[{"host":"gateway.loki.example.com","paths":[{"path":"/"}]}]` | Hosts configuration for the gateway ingress |
| gateway.ingress.tls | list | `[{"hosts":["gateway.loki.example.com"],"secretName":"loki-gateway-tls"}]` | TLS configuration for the gateway ingress |
| gateway.basicAuth.enabled | bool | `false` | Enables basic authentication for the gateway |
| gateway.basicAuth.username | string | `nil` | The basic auth username for the gateway |
| gateway.basicAuth.password | string | `nil` | The basic auth password for the gateway |
| gateway.basicAuth.htpasswd | string | `"{{ htpasswd (required \"'gateway.basicAuth.username' is required\" .Values.gateway.basicAuth.username) (required \"'gateway.basicAuth.password' is required\" .Values.gateway.basicAuth.password) }}"` | Uses the specified username and password to compute a htpasswd using Sprig's `htpasswd` function. The value is templated using `tpl`. Override this to use a custom htpasswd, e.g. in case the default causes high CPU load. |
| gateway.basicAuth.existingSecret | string | `nil` | Existing basic auth secret to use. Must contain '.htpasswd' |
| gateway.readinessProbe.httpGet.path | string | `"/"` |  |
| gateway.readinessProbe.httpGet.port | string | `"http"` |  |
| gateway.readinessProbe.initialDelaySeconds | int | `15` |  |
| gateway.readinessProbe.timeoutSeconds | int | `1` |  |
| gateway.nginxConfig.logFormat | string | `"main '$remote_addr - $remote_user [$time_local]  $status '\n        '\"$request\" $body_bytes_sent \"$http_referer\" '\n        '\"$http_user_agent\" \"$http_x_forwarded_for\"';"` | NGINX log format |
| gateway.nginxConfig.serverSnippet | string | `""` | Allows appending custom configuration to the server block |
| gateway.nginxConfig.httpSnippet | string | `""` | Allows appending custom configuration to the http block |
| gateway.nginxConfig.file | string | See values.yaml | Config file contents for Nginx. Passed through the `tpl` function to allow templating |
| networkPolicy.enabled | bool | `false` | Specifies whether Network Policies should be created |
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
| minio | object | `{"enabled":false,"secrets":{"accessKey":"minio","name":"loki-objstore-creds","secretKey":"minio123"},"service":{"nameOverride":"minio.logging.svc.cluster.local"},"tenant":{"buckets":[{"name":"loki"},{"name":"loki-admin"}],"defaultUserCredentials":{"password":"","username":"minio-user"},"metrics":{"enabled":false,"memory":"128Mi","port":9000},"pools":[{"securityContext":{"fsGroup":1001,"runAsGroup":1001,"runAsUser":1001},"servers":1,"size":"750Mi","volumesPerServer":4}],"users":[{"name":"minio-user"}]}}` | ----------------------------------- |
| minio.enabled | bool | `false` | Enable minio instance support, must have minio-operator installed |
| minio.secrets | object | `{"accessKey":"minio","name":"loki-objstore-creds","secretKey":"minio123"}` | Minio root credentials |
| minio.tenant.buckets | list | `[{"name":"loki"},{"name":"loki-admin"}]` | Buckets to be provisioned to for tenant |
| minio.tenant.users | list | `[{"name":"minio-user"}]` | Users to to be provisioned to for tenant |
| minio.tenant.defaultUserCredentials | object | `{"password":"","username":"minio-user"}` | User credentials to create for above user. Otherwise password is randomly generated. This auth is not required to be set or reclaimed for minio use with Loki |
| monolith | object | `{"containerSecurityContext":{"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true},"enabled":true,"extraPorts":[{"name":"grpc","port":9095,"protocol":"TCP","targetPort":"grpc"},{"name":"tcp-memberlist","port":7946,"protocol":"TCP"}],"fullnameOverride":"loki","image":{"pullPolicy":"IfNotPresent","pullSecrets":["private-registry"],"repository":"registry1.dso.mil/ironbank/opensource/grafana/loki","tag":"2.6.1"},"livenessProbe":{"initialDelaySeconds":80},"nameOverride":"loki","persistence":{"accessModes":["ReadWriteOnce"],"enabled":true,"size":"12Gi"},"readinessProbe":{"initialDelaySeconds":80},"resources":{"limits":{"cpu":"100m","memory":"256Mi"},"requests":{"cpu":"100m","memory":"256Mi"}},"service":{"labels":{"app":"loki","release":"logging-loki"}}}` | ---------------------------------------------- |
| monolith.enabled | bool | `true` | Enable Loki chart in single binary mode. Recommended for smaller or non-production environments |
| monolith.extraPorts[0] | object | `{"name":"grpc","port":9095,"protocol":"TCP","targetPort":"grpc"}` | Extra ports for loki pods. Additional ports exposed to support HA communication |
| monolith.extraPorts[1] | object | `{"name":"tcp-memberlist","port":7946,"protocol":"TCP"}` | Extra ports for loki pods. Additional ports exposed to support memberlist |
| domain | string | `"bigbang.dev"` |  |
| istio.enabled | bool | `false` |  |
| istio.mtls.mode | string | `"STRICT"` |  |
| networkPolicies.enabled | bool | `false` |  |
| networkPolicies.controlPlaneCidr | string | `"0.0.0.0/0"` |  |
| bbtests.enabled | bool | `false` |  |
| bbtests.cypress.artifacts | bool | `true` |  |
| bbtests.cypress.envs.cypress_check_datasource | string | `"false"` |  |
| bbtests.cypress.envs.cypress_grafana_url | string | `"http://monitoring-grafana.monitoring.svc.cluster.local"` |  |
| bbtests.scripts.image | string | `"registry1.dso.mil/ironbank/big-bang/base:2.0.0"` |  |
| bbtests.scripts.envs.LOKI_URL | string | `"http://{{ .Values.monolith.fullnameOverride }}.{{ .Release.Namespace }}.svc:3100"` |  |
| bbtests.scripts.envs.LOKI_VERSION | string | `"{{ .Values.monolith.image.tag }}"` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
