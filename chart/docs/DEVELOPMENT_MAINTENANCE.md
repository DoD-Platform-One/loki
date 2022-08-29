# To upgrade the Loki Package

Check the [upstream changelog](https://grafana.com/docs/loki/latest/upgrading/) and the [helm chart upgrade notes](https://github.com/grafana/helm-charts/tree/main/charts/loki#upgrading).

# Upgrading

Find the latest version of `loki-simple-scalable` that matches the latest version in IronBank that Renovate has identified from here: https://github.com/grafana/helm-charts/tree/main/charts/loki-simple-scalable

Run a KPT update against the main chart folder:
```shell
kpt pkg update chart@loki-simple-scalable-1.8.10 --strategy force-delete-replace
```

Restore all BigBang added templates and tests:
```shell
git checkout chart/templates/bigbang/
git checkout chart/deps/loki
git checkout chart/deps/minio
git checkout chart/tests/
git checkout chart/dashboards
git checkout chart/templates/tests
```

## Update dependencies  
  
Typically, the `--strategy=force-delete-replace` is useful to "heavy handidly" bring in dep changes which may need to be reviewed. 
```shell
cd chart/deps 
kpt pkg update minio@$LATEST_BB_PACKAGE_TAG_VERSION$ --strategy=force-delete-replace
kpt pkg update loki@loki-$LATEST_LOKI_CHART_VERSION$ --strategy=force-delete-replace
```

## Update binaries

Pull assets and commit the binaries as well as the Chart.lock file that was generated.
```
export HELM_EXPERIMENTAL_OCI=1
helm dependency update ./chart
``` 

## Update chart

```chart/Chart.yaml```

- update loki `version` and `appVersion`
- Ensure Big Bang version suffix is appended to chart version
- Ensure minio, gluon, and loki dependencies are present and up to date 
```yaml
dependencies:
  - name: minio-instance
    alias: minio
    version: 4.4.25-bb.0
    repository: file://./deps/minio
    condition: minio.enabled
...
  - name: gluon
    version: 0.2.10
    repository: "oci://registry.dso.mil/platform-one/big-bang/apps/library-charts/gluon"
  - name: loki
    alias: monolith
    repository: file://./deps/loki
    version: 2.14.1
    condition: monolith.enabled
```

```chart/values.yaml```

- Verify renovate correctly `tag` for the new version.

```chart/tests/*```

- add cypress testing configuration and/or tests _if necessary_.

# Modifications made to upstream
This is a high-level list of modifitations that Big Bang has made to the upstream helm chart. You can use this as as cross-check to make sure that no modifications were lost during the upgrade process.

```chart/values.yaml```
- line 16, Ensure nameOverride is set to `logging-loki`
`nameOverride: logging-loki`

- line 19, Ensure fullnameOverride is set to `logging-loki`
`fullnameOverride: logging-loki`

- line 22, Ensure `private-registry` IPS is present:
```
imagePullSecrets:
  - name: private-registry
```

line 32, Ensure `loki.image` section points to registry1 image and correct tag 
```
  image:
    # -- The Docker registry
    registry: registry1.dso.mil
    # -- Docker image repository
    repository: ironbank/opensource/grafana/loki
    # -- Overrides the image tag whose default is the chart's appVersion
    tag: X.X.X
```

- line 107, Ensure `ingester` config is present 
```
    ingester:
      chunk_target_size: 196608
      flush_check_period: 5s
      flush_op_timeout: 100m
      lifecycler:
        ring:
          kvstore:
            store: memberlist
          replication_factor: 1
```

- line 171, Ensure by default auth is disabled
```
  auth_enabled: false
```

- line 181, Ensure `storage.bucketNames` points to `loki`, `loki` & `loki-admin`
```
  storage:
    bucketNames:
      chunks: loki
      ruler: loki
      admin: loki-admin
```

- line 229, Ensure `storage_config.boltdb_shipper` configuration is present 
```
  storage_config:
    boltdb_shipper:
      active_index_directory: /var/loki/boltdb-shipper-active
      cache_location: /var/loki/boltdb-shipper-cache
      cache_ttl: 24h
      shared_store: s3
```

- line 262, Ensure line for `enterprise.cluster_name` is present, this is a BB added value 
```
...
  # -- Name of cluster, must match cluster ID/Name on Grafana License
  cluster_name: ""
```

- line 283, in `enterprise.config` chomp value ensure that `cluster_name` function has the second value present:
```
    ...
    cluster_name: {{ default .Release.Name .Values.enterprise.cluster_name | quote }}
    ...
```

- line 287 , Ensure `enterprise.image` is pointed to registry1 image 
```
  image:
    # -- The Docker registry
    registry: registry1.dso.mil
    # -- Docker image repository
    repository: ironbank/grafana/grafana-enterprise-logs
    # -- Overrides the image tag whose default is the chart's appVersion
    tag: vX.X.X
```

- line 312, ensure `tolerations` value is present for the `tokengen` job 
```
  tokengen:
    ...
    # -- Tolerations for tokengen Job
    tolerations: []
```

- line 343, Ensure all monitoring sub-components are set to `enabled: false`
Including the added `monitoring.enabled` value 
```
monitoring: 
  # -- Enable BigBang integration of Monitoring components
  enabled: false
```

line 428 ensure `monitoring.selfMonitoring.grafanaAgent.installOperator` is set to `false`

- line 489, write pod resources set 
```
  resources:
    limits:
      cpu: 300m
      memory: 2Gi
    requests:
      cpu: 300m
      memory: 2Gi
```

- line 564, read pod resources set 
```
  resources:
    limits:
      cpu: 300m
      memory: 2Gi
    requests:
      cpu: 300m
      memory: 2Gi
```

- line 599 `gateway.enabled` set to `false` by default 

- line 619, Ensure `gateway.image` is pointed to registry1 equivalent
```
  image:
    # -- The Docker registry for the gateway image
    registry: registry1.dso.mil
    # -- The gateway image repository
    repository: ironbank/opensource/nginx/nginx
    # -- The gateway image tag
    tag: X.X.X
```

- line 914, ensure the following BB values are all set under minio key:
```
minio:
  # -- Enable minio instance support, must have minio-operator installed
  enabled: false
  # Override the minio service name for easier connection setup
  service:
    nameOverride: "minio.logging.svc.cluster.local"
  # -- Minio root credentials
  secrets:
    name: "loki-objstore-creds"
    accessKey: "minio"
    secretKey: "minio123" # default key, change this!
  tenant:
    # -- Buckets to be provisioned to for tenant
    buckets:
      - name: loki
      - name: loki-admin
    # -- Users to to be provisioned to for tenant
    users:
      - name: minio-user
    # -- User credentials to create for above user. Otherwise password is randomly generated.
    # This auth is not required to be set or reclaimed for minio use with Loki
    defaultUserCredentials:
      username: "minio-user"
      password: ""
    ## Specification for MinIO Pool(s) in this Tenant.
    pools:
      - servers: 1
        volumesPerServer: 4
        size: 750Mi
        securityContext:
          runAsUser: 1001
          runAsGroup: 1001
          fsGroup: 1001
    metrics:
      enabled: false
      port: 9000
      memory: 128M
```

- End of file add the following blocks:
```
monolith:
  # -- Enable Loki chart in single binary mode.
  # Recommended for smaller or non-production environments
  enabled: true
  image:
    repository: registry1.dso.mil/ironbank/opensource/grafana/loki
    tag: X.X.X
    pullPolicy: IfNotPresent
    pullSecrets:
      - private-registry
  extraPorts:
  # -- Extra ports for loki pods.
  # Additional ports exposed to support HA communication
  - name: grpc
    port: 9095
    targetPort: grpc
    protocol: TCP
  # -- Extra ports for loki pods.
  # Additional ports exposed to support memberlist
  - name: tcp-memberlist
    port: 7946
    protocol: TCP

  nameOverride: loki
  fullnameOverride: loki

  #Required for monolith ServiceMonitor template
  service:
    labels:
      app: loki
      release: logging-loki

  readinessProbe:
    initialDelaySeconds: 80
  livenessProbe:
    initialDelaySeconds: 80

  resources:
    limits:
      cpu: 100m
      memory: 256Mi
    requests:
      cpu: 100m
      memory: 256Mi
  persistence:
    enabled: true
    accessModes:
    - ReadWriteOnce
    size: 12Gi


domain: bigbang.dev

istio:
  enabled: false
  mtls:
    # STRICT = Allow only mutual TLS traffic
    # PERMISSIVE = Allow both plain text and mutual TLS traffic
    mode: STRICT
```

```chart/deps/loki-simple-scalable/templates/read/*```
- Ensure every template has at the top of each template
`{{- if not (index .Values "read" "disabled") }}`
paired with `{{- end }}` at the bottom
(Check `git diff FILE_NAME` to see example)

```chart/deps/loki-simple-scalable/templates/write/*```
- Ensure every template has at the top of each template
`{{- if not (index .Values "write" "disabled") }}`
paired with `{{- end }}` at the bottom
(Check `git diff FILE_NAME` to see example)

```chart/templates/_helpers.tpl```
- On line 5 for the `$default` function, remove the `ternary` function and ensure the definition looks just like:
```
{{- $default := "loki" }
```

- line 115 ensure the following block for minio looks like: 
```
{{- if .Values.minio.enabled -}}
s3:
  endpoint: minio.logging.svc
  bucketnames: {{ $.Values.loki.storage.bucketNames.chunks }}
  secret_access_key: minio123
  access_key_id: minio
  s3forcepathstyle: true
  insecure: true
```

- At the very bottom ensure this function is present 
```
{{/*
loki netpol matchLabels -- Big Bang Addition
*/}}
{{- define "loki.matchLabels" -}}
  {{- if .Values.loki.enabled }}
  app: loki
  {{- else }}
  {{ include "loki.selectorLabels" . | nindent 2 }}
  {{- end }}
{{- end }}
```

```chart/templates/configmap.yaml```
- Ensure the template has the following at the top
`{{- if and (not (index .Values "read" "disabled")) (not (index .Values "write" "disabled")) }}`
paired with `{{- end }}` at the bottom

```chart/templates/tokengen/job-tokengen.yaml```
- Add enterprise tokengen tolerations value to job template on line 86
```
      {{- with .Values.enterprise.tokengen.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
```

# Testing new Loki Version

- Deploy Loki as a part of BigBang  
```
helm upgrade \
  --install bigbang ./bigbang/chart \
  --create-namespace \
  --namespace bigbang \
  --values ./bigbang/chart/values.yaml \
  --values ./bigbang/chart/ingress-certs.yaml \
  --values ./overrides/loki.yaml \
  --set gatekeeper.enabled=false \
  --set clusterAuditor.enabled=false \
  --set twistlock.enabled=false \
  --set loki.enabled=true \
  --set promtail.enabled=true \
  --set logging.enabled=false \
  --set eckoperator.enabled=false \
  --set fluentbit.enabled=true \
  --set jaeger.enabled=false \
  --set tempo.enabled=true \
  --set addons.minioOperator.enabled=true
```
`overrides/loki.yaml`
```
loki:
  git:
    tag: ""
    branch: "my-branch-name-goes-here"
  enabled: true
  strategy: scalable
```
- Visit `https://grafana.bigbang.dev` and login
- Navigate to `configuration -> Data Sources -> Loki` and then click `Save & Test` to ensure Data Source changes can be saved successfully.
- Search dashboards for `Loki Dashboard Quick Search` and confirm log data is being populated/no error messages.
