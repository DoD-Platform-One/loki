# loki

![Version: 3.0.4-bb.2](https://img.shields.io/badge/Version-3.0.4--bb.2-informational?style=flat-square) ![AppVersion: v2.5.0](https://img.shields.io/badge/AppVersion-v2.5.0-informational?style=flat-square)

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
| global.existingSecretForConfig | string | `""` | Secret which Pods will consume for config. Only use if 'global.createGlobalConfig' is true. Default: "loki-config" |
| global.objectStorage.endpoint | string | `""` | Endpoint for External ObjectStorage configuration |
| global.objectStorage.region | string | `""` | Region for External ObjectStorage configuration |
| global.objectStorage.bucketnames | string | `""` | Comma separated list of Bucket Names for External ObjectStorage configuration |
| global.objectStorage.access_key_id | string | `""` | AWS access_key_id for External ObjectStorage configuration |
| global.objectStorage.secret_access_key | string | `""` | AWS secret_access_key for External ObjectStorage configuration |
| global.objectStorage.adminBucketName | string | `""` | Grafana Specific Admin Bucket External ObjectStorage configuration |
| global.config | string | `"auth_enabled: false\nserver:\n  log_level: debug\n  http_listen_port: 3100\nmemberlist:\n  join_members:\n    - \"{{ .Values.loki.fullnameOverride }}-memberlist\"\n\ncommon:\n  path_prefix: /var/loki\n  replication_factor: 1\n  ring:\n    kvstore:\n      store: memberlist\n  storage:\n    filesystem: null\n    s3:\n      {{- if not .Values.global.objectStorage.endpoint }}\n      s3: s3://minio:minio123@minio.logging:80/loki\n      {{- end }}\n      {{- if .Values.global.objectStorage.endpoint }}\n      endpoint: \"{{ .Values.global.objectStorage.endpoint }}\"\n      {{- end }}\n      {{- if .Values.global.objectStorage.bucketnames }}\n      bucketnames: \"{{ .Values.global.objectStorage.bucketnames }}\"\n      {{- end }}\n      {{- if .Values.global.objectStorage.access_key_id }}\n      access_key_id: \"{{ .Values.global.objectStorage.access_key_id }}\"\n      {{- end }}\n      {{- if .Values.global.objectStorage.secret_access_key }}\n      secret_access_key: \"{{ .Values.global.objectStorage.secret_access_key }}\"\n      {{- end }}\n      {{- if .Values.global.objectStorage.region }}\n      region: \"{{ .Values.global.objectStorage.region }}\"\n      {{- end }}\n      s3forcepathstyle: true\ningester:\n  chunk_target_size: 196608\n  flush_check_period: 5s\n  flush_op_timeout: 100m\n  lifecycler:\n    ring:\n      kvstore:\n        store: memberlist\n      replication_factor: 1\nschema_config:\n  configs:\n  - from: 2022-01-01 # Anything in the past\n    store: boltdb-shipper\n    object_store: s3\n    schema: v11\n    index:\n      prefix: loki_\n      period: 24h\nstorage_config:\n  boltdb_shipper:\n    active_index_directory: /var/loki/boltdb-shipper-active\n    cache_location: /var/loki/boltdb-shipper-cache\n    cache_ttl: 24h\n    shared_store: s3\n  aws:\n    {{- if not .Values.global.objectStorage.endpoint }}\n    s3: s3://minio:minio123@minio.logging:80/loki\n    {{- end }}\n    {{- if .Values.global.objectStorage.endpoint }}\n    endpoint: \"{{ .Values.global.objectStorage.endpoint }}\"\n    {{- end }}\n    {{- if .Values.global.objectStorage.bucketnames }}\n    bucketnames: \"{{ .Values.global.objectStorage.bucketnames }}\"\n    {{- end }}\n    {{- if .Values.global.objectStorage.access_key_id }}\n    access_key_id: \"{{ .Values.global.objectStorage.access_key_id }}\"\n    {{- end }}\n    {{- if .Values.global.objectStorage.secret_access_key }}\n    secret_access_key: \"{{ .Values.global.objectStorage.secret_access_key }}\"\n    {{- end }}\n    {{- if .Values.global.objectStorage.region }}\n    region: \"{{ .Values.global.objectStorage.region }}\"\n    {{- end }}\n    s3forcepathstyle: true\n"` | Configuration value for all sub-charts. For use when `global.createGlobalConfig=true` & `config.existingSecretForConfig="logging-loki"` |
| domain | string | `"bigbang.dev"` |  |
| istio.enabled | bool | `false` |  |
| istio.mtls.mode | string | `"STRICT"` |  |
| monitoring.enabled | bool | `false` |  |
| networkPolicies.enabled | bool | `false` |  |
| networkPolicies.controlPlaneCidr | string | `"0.0.0.0/0"` |  |
| fullnameOverride | string | `"logging-loki"` |  |
| loki.enabled | bool | `true` | Enable Loki chart in single binary mode. Recommended for smaller or non-production environments |
| loki.image.repository | string | `"registry1.dso.mil/ironbank/opensource/grafana/loki"` |  |
| loki.image.tag | string | `"2.5.0"` |  |
| loki.image.pullPolicy | string | `"IfNotPresent"` |  |
| loki.image.pullSecrets[0] | string | `"private-registry"` |  |
| loki.extraPorts[0] | object | `{"name":"grpc","port":9095,"protocol":"TCP","targetPort":"grpc"}` | Extra ports for loki pods. Additional ports exposed to support HA communication |
| loki.extraPorts[1] | object | `{"name":"tcp-memberlist","port":7946,"protocol":"TCP"}` | Extra ports for loki pods. Additional ports exposed to support memberlist |
| loki.fullnameOverride | string | `"logging-loki"` |  |
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
| loki-simple-scalable.fullnameOverride | string | `"logging-loki"` |  |
| loki-simple-scalable.loki.image.registry | string | `"registry1.dso.mil"` | The Docker registry |
| loki-simple-scalable.loki.image.repository | string | `"ironbank/opensource/grafana/loki"` | Docker image repository |
| loki-simple-scalable.loki.image.tag | string | `"2.5.0"` | Overrides the image tag whose default is the chart's appVersion |
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
| loki-simple-scalable.gateway.enabled | bool | `false` |  |
| loki-simple-scalable.gateway.image.registry | string | `"registry1.dso.mil"` |  |
| loki-simple-scalable.gateway.image.repository | string | `"ironbank/opensource/nginx/nginx"` |  |
| loki-simple-scalable.gateway.image.tag | string | `"1.21.6"` |  |
| loki-simple-scalable.gateway.service.port | int | `3100` | Port of the gateway service |
| loki-simple-scalable.imagePullSecrets[0].name | string | `"private-registry"` |  |
| minio.enabled | bool | `false` | Enable minio instance support, must have minio-operator installed |
| minio.service.nameOverride | string | `"minio.logging.svc.cluster.local"` |  |
| minio.tenants.secrets | object | `{"accessKey":"minio","name":"loki-objstore-creds","secretKey":"minio123"}` | Minio root credentials |
| minio.tenants.buckets | list | `[{"name":"loki"}]` | Buckets to be provisioned to for tenant |
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
| gel.enabled | bool | `false` | Enable Grafana Enterprise Logs chart |
| gel.nameOverride | string | `nil` | Overrides the chart's name |
| gel.fullnameOverride | string | `nil` | Overrides the chart's computed fullname |
| gel.image | object | `{"pullPolicy":"IfNotPresent","pullSecrets":[],"registry":"registry1.dso.mil","repository":"ironbank/grafana/grafana-enterprise-logs","tag":"1.3.0"}` | Definition of the Docker image for Grafana Enterprise Logs If the image block is overwritten in a custom values file, it is also required to update the values in the `loki-distributed.loki.image` block. This can be done by copying the values, or like here, by using an anchor and a pointer. |
| gel.image.registry | string | `"registry1.dso.mil"` | The container registry to use |
| gel.image.repository | string | `"ironbank/grafana/grafana-enterprise-logs"` | The image repository to use |
| gel.image.tag | string | `"1.3.0"` | The version of Grafana Enterprise Logs |
| gel.image.pullPolicy | string | `"IfNotPresent"` | Defines the policy how and when images are pulled |
| gel.image.pullSecrets | list | `[]` | Additional image pull secrets |
| gel.serviceAccount | object | `{"create":true}` | Definition of the ServiceAccount for containers Any additional configuration of the ServiceAccount has to be done in `loki-distributed.serviceAccount`. |
| gel.serviceAccount.create | bool | `true` | Specifies whether a ServiceAccount should be created If this value is changed to `false`, it also needs to be reflected in `loki-distributed.serviceAccount.create`. |
| gel.useExternalConfig | bool | `false` | External config.yaml A GEL configuration file may be provided as Kubernetes Secret outside of this Helm chart. |
| gel.externalConfigName | string | `"loki-config"` |  |
| gel.externalConfigVersion | string | `"0"` |  |
| gel.useExternalLicense | bool | `false` | External license.jwt .Values.global.objectStorage.bucketnames }} A GEL license file may be provided as Kubernetes Secret outside of this Helm chart. |
| gel.externalLicenseName | string | `"enterprise-logs-license"` |  |
| gel.externalLicenseVersion | string | `"0"` |  |
| gel.license | object | `{"cluster_name":null,"contents":"NOTAVALIDLICENSE"}` | Grafana Enterprise Logs license In order to use Grafana Enterprise Logs features, you will need to provide the contents of your Grafana Enterprise Logs license, either by providing the contents of the license.jwt, or the name Kubernetes Secret that contains your license.jwt. To set the license contents, use the flag `--set-file 'license.contents=./license.jwt'` |
| gel.tokengen | object | `{"annotations":{},"enable":true,"env":[],"extraArgs":{},"extraVolumeMounts":[],"extraVolumes":[],"labels":{},"priorityClassName":null,"securityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001}}` | Configuration for `tokengen` target |
| gel.tokengen.enable | bool | `true` | Whether the job should be part of the deployment |
| gel.tokengen.extraArgs | object | `{}` | Additional CLI arguments for the `tokengen` target |
| gel.tokengen.env | list | `[]` | Additional Kubernetes environment |
| gel.tokengen.labels | object | `{}` | Additional labels for the `tokengen` Job |
| gel.tokengen.annotations | object | `{}` | Additional annotations for the `tokengen` Job |
| gel.tokengen.extraVolumes | list | `[]` | Additional volumes for Pods |
| gel.tokengen.extraVolumeMounts | list | `[]` | Additional volume mounts for Pods |
| gel.tokengen.securityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001}` | Run containers as user `enterprise-logs(uid=10001)` |
| gel.adminApi | object | `{"affinity":{},"annotations":{},"env":[],"extraArgs":{},"extraContainers":[],"extraVolumeMounts":[],"extraVolumes":[],"initContainers":[],"labels":{},"livenessProbe":{"httpGet":{"path":"/ready","port":"http-metrics"},"initialDelaySeconds":45},"nodeSelector":{},"persistence":{"subPath":null},"readinessProbe":{"httpGet":{"path":"/ready","port":"http-metrics"},"initialDelaySeconds":45},"replicas":1,"resources":{},"securityContext":{"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001},"service":{"annotations":{},"labels":{}},"strategy":{"type":"RollingUpdate"},"terminationGracePeriodSeconds":60,"tolerations":[]}` | Configuration for the `admin-api` target |
| gel.adminApi.replicas | int | `1` | Define the amount of instances |
| gel.adminApi.extraArgs | object | `{}` | Additional CLI arguments for the `admin-api` target |
| gel.adminApi.labels | object | `{}` | Additional labels for the `admin-api` Deployment |
| gel.adminApi.annotations | object | `{}` | Additional annotations for the `admin-api` Deployment |
| gel.adminApi.service | object | `{"annotations":{},"labels":{}}` | Additional labels and annotations for the `admin-api` Service |
| gel.adminApi.securityContext | object | `{"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001}` | Run container as user `enterprise-logs(uid=10001)` `fsGroup` must not be specified, because these security options are applied on container level not on Pod level. |
| gel.adminApi.resources | object | `{}` | Request and limit Kubernetes resources -- Values are defined in small.yaml and large.yaml |
| gel.adminApi.extraVolumes | list | `[]` | Additional volumes for Pods |
| gel.adminApi.extraVolumeMounts | list | `[]` | Additional volume mounts for Pods |
| gel.adminApi.affinity | object | `{}` | Affinity for admin-api Pods |
| gel.adminApi.nodeSelector | object | `{}` | Node selector for admin-api Pods |
| gel.adminApi.tolerations | list | `[]` | Tolerations for admin-api Pods |
| gel.adminApi.terminationGracePeriodSeconds | int | `60` | Grace period to allow the admin-api to shutdown before it is killed |
| gel.gateway | object | `{"affinity":{},"annotations":{},"env":[],"extraArgs":{},"extraContainers":[],"extraVolumeMounts":[],"extraVolumes":[],"initContainers":[],"labels":{},"livenessProbe":{"httpGet":{"path":"/ready","port":"http-metrics"},"initialDelaySeconds":45},"nodeSelector":{},"persistence":{"subPath":null},"readinessProbe":{"httpGet":{"path":"/ready","port":"http-metrics"},"initialDelaySeconds":45},"replicas":1,"resources":{},"securityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001},"service":{"annotations":{},"labels":{}},"strategy":{"type":"RollingUpdate"},"terminationGracePeriodSeconds":60,"tolerations":[],"useDefaultProxyURLs":true}` | Configuration for the `gateway` target |
| gel.gateway.replicas | int | `1` | Define the amount of instances |
| gel.gateway.extraArgs | object | `{}` | Additional CLI arguments for the `gateway` target |
| gel.gateway.labels | object | `{}` | Additional labels for the `gateway` Pod |
| gel.gateway.annotations | object | `{}` | Additional annotations for the `gateway` Pod |
| gel.gateway.service | object | `{"annotations":{},"labels":{}}` | Additional labels and annotations for the `gateway` Service |
| gel.gateway.securityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001}` | Run container as user `enterprise-logs(uid=10001)` |
| gel.gateway.resources | object | `{}` | Request and limit Kubernetes resources -- Values are defined in small.yaml and large.yaml |
| gel.gateway.extraVolumes | list | `[]` | Additional volumes for Pods |
| gel.gateway.extraVolumeMounts | list | `[]` | Additional volume mounts for Pods |
| gel.gateway.affinity | object | `{}` | Affinity for gateway Pods |
| gel.gateway.nodeSelector | object | `{}` | Node selector for gateway Pods |
| gel.gateway.tolerations | list | `[]` | Tolerations for gateway Pods |
| gel.gateway.terminationGracePeriodSeconds | int | `60` | Grace period to allow the gateway to shutdown before it is killed |
| gel.compactor | object | `{"affinity":{"podAntiAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"target","operator":"In","values":["compactor"]}]},"topologyKey":"kubernetes.io/hostname"},"weight":100}]}},"annotations":{},"env":[],"extraArgs":{},"extraContainers":[],"extraVolumeMounts":[],"extraVolumes":[],"initContainers":[],"labels":{},"livenessProbe":{"failureThreshold":20,"httpGet":{"path":"/ready","port":"http-metrics","scheme":"HTTP"},"initialDelaySeconds":180,"periodSeconds":30,"successThreshold":1,"timeoutSeconds":1},"nodeSelector":{},"persistentVolume":{"accessModes":["ReadWriteOnce"],"annotations":{},"enabled":true,"size":"2Gi","subPath":""},"readinessProbe":{"httpGet":{"path":"/ready","port":"http-metrics"},"initialDelaySeconds":60},"replicas":1,"resources":{},"securityContext":{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001},"service":{"annotations":{},"labels":{}},"strategy":{"type":"RollingUpdate"},"terminationGracePeriodSeconds":300,"tolerations":[]}` | Configuration for the `compactor` target |
| gel.compactor.replicas | int | `1` | Define the amount of instances |
| gel.compactor.extraArgs | object | `{}` | Additional CLI arguments for the `compactor` target |
| gel.compactor.labels | object | `{}` | Additional labels for the `compactor` Pod |
| gel.compactor.annotations | object | `{}` | Additional annotations for the `compactor` Pod |
| gel.compactor.service | object | `{"annotations":{},"labels":{}}` | Additional labels and annotations for the `compactor` Service |
| gel.compactor.securityContext | object | `{"fsGroup":10001,"runAsGroup":10001,"runAsNonRoot":true,"runAsUser":10001}` | Run containers as user `enterprise-logs(uid=10001)` |
| gel.compactor.resources | object | `{}` | Request and limit Kubernetes resources -- Values are defined in small.yaml and large.yaml |
| gel.compactor.extraVolumes | list | `[]` | Additional volumes for Pods |
| gel.compactor.extraVolumeMounts | list | `[]` | Additional volume mounts for Pods |
| gel.compactor.affinity | object | `{"podAntiAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"target","operator":"In","values":["compactor"]}]},"topologyKey":"kubernetes.io/hostname"},"weight":100}]}}` | Affinity for compactor Pods |
| gel.compactor.nodeSelector | object | `{}` | Node selector for compactor Pods |
| gel.compactor.tolerations | list | `[]` | Tolerations for compactor Pods |
| gel.compactor.terminationGracePeriodSeconds | int | `300` | Grace period to allow the compactor to shutdown before it is killed |
| bbtests.enabled | bool | `false` |  |
| bbtests.cypress.artifacts | bool | `true` |  |
| bbtests.cypress.envs.cypress_check_datasource | string | `"false"` |  |
| bbtests.cypress.envs.cypress_grafana_url | string | `"http://monitoring-grafana.monitoring.svc.cluster.local"` |  |
| bbtests.scripts.image | string | `"registry1.dso.mil/ironbank/big-bang/base:1.17.0"` |  |
| bbtests.scripts.envs.LOKI_URL | string | `"http://{{ template \"loki.fullname\" . }}.{{ .Release.Namespace }}.svc:3100"` |  |
| bbtests.scripts.envs.LOKI_VERSION | string | `"{{ .Values.loki.image.tag }}"` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
