# To upgrade the Loki Package

Check the [upstream changelog](https://grafana.com/docs/loki/latest/upgrading/) and the [helm chart upgrade notes](https://github.com/grafana/loki/tree/helm-loki-3.2.0/production/helm/loki#upgrading-from-v2x).

# Upgrading

Find the latest version of the `loki` image that matches the latest version in IronBank that Renovate has identified from here: https://github.com/grafana/loki/tree/helm-loki-3.2.0/production/helm/loki

Run a KPT update against the main chart folder:
```shell
kpt pkg update chart@helm-loki-3.2.1 --strategy force-delete-replace
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

## Update loki dependency chart templates

```chart/.gitignore```
- line 1, remove `charts/` from the file

## Update binaries

Pull assets and commit the binaries as well as the Chart.lock file that was generated.
```
export HELM_EXPERIMENTAL_OCI=1
helm dependency update ./chart
```

## Update main chart

```chart/Chart.yaml```

- update loki `version` and `appVersion`
- Ensure Big Bang version suffix is appended to chart version
- Ensure minio, gluon, and loki dependencies are present and up to date
```yaml
version: 3.2.1-bb.0
dependencies:
  - name: minio-instance
    alias: minio
    version: 4.4.25-bb.0
    repository: file://./deps/minio
    condition: minio.enabled
  - name: grafana-agent-operator
    alias: grafana-agent-operator
    version: 0.2.3
    repository: https://grafana.github.io/helm-charts
    condition: monitoring.selfMonitoring.grafanaAgent.installOperator
  - name: gluon
    version: 0.3.0
    repository: "oci://registry.dso.mil/platform-one/big-bang/apps/library-charts/gluon"
annotations:
  bigbang.dev/applicationVersions: |
    - Loki: 2.6.1
```

```chart/values.yaml```

- Verify renovate correctly `tag` for the new version.

```chart/tests/*```

- add cypress testing configuration and/or tests _if necessary_.

# Modifications made to upstream
This is a high-level list of modifications that Big Bang has made to the upstream helm chart. You can use this as as cross-check to make sure that no modifications were lost during the upgrade process.

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

- line 25, update the kubectl image to pull from registry1
```
  kubectlImage:
    # -- The Docker registry
    registry: registry1.dso.mil/ironbank
    # -- Docker image repository
    repository: opensource/kubernetes/kubectl
    # -- Overrides the image tag whose default is the chart's appVersion
    tag: v1.25.2
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

- line 114, Ensure `ingester` config is present
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

- line 185, Ensure by default auth is disabled
```
  auth_enabled: false
```

- line 206, Ensure `storage.bucketNames` points to `loki`, `loki` & `loki-admin`
```
  storage:
    bucketNames:
      chunks: loki
      ruler: loki
      admin: loki-admin
```

- line 258, Ensure `storage_config.boltdb_shipper` configuration is present
```
  storage_config:
    boltdb_shipper:
      active_index_directory: /var/loki/boltdb-shipper-active
      cache_location: /var/loki/boltdb-shipper-cache
      cache_ttl: 24h
      shared_store: s3
```

- line 320 , Ensure `enterprise.image` is pointed to registry1 image
```
  image:
    # -- The Docker registry
    registry: registry1.dso.mil
    # -- Docker image repository
    repository: ironbank/grafana/grafana-enterprise-logs
    # -- Overrides the image tag whose default is the chart's appVersion
    tag: vX.X.X
```

- line 363, Ensure `provisioner.enabled` is  set to `false`
```
  provisioner:
    # -- Whether the job should be part of the deployment
    enabled: false
```

- line 542, Ensure all monitoring sub-components are set to `enabled: false`
Including the added `monitoring.enabled` value
```
monitoring:
  # -- Enable BigBang integration of Monitoring components
  enabled: false
```

- line 630 ensure `monitoring.selfMonitoring.grafanaAgent.installOperator` is set to `false`

- line 663, Ensure `lokiCanary.enabled` is set to `false`
```
    lokiCanary:
      enabled: false
```

- line 720, write pod resources set
```
  resources:
    limits:
      cpu: 300m
      memory: 2Gi
    requests:
      cpu: 300m
      memory: 2Gi
```

- line 795, read pod resources set
```
  resources:
    limits:
      cpu: 300m
      memory: 2Gi
    requests:
      cpu: 300m
      memory: 2Gi
```

- line 932 `gateway.enabled` set to `false` by default

- line 952, Ensure `gateway.image` is pointed to registry1 equivalent
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

- line 866, set resource requests and limits for `singleBinary`
```
  resources:
    limits:
      cpu: 100m
      memory: 256Mi
    requests:
      cpu: 100m
      memory: 256Mi
```

- End of file add the following blocks:
```
domain: bigbang.dev

istio:
  enabled: false
  mtls:
    # STRICT = Allow only mutual TLS traffic
    # PERMISSIVE = Allow both plain text and mutual TLS traffic
    mode: STRICT

networkPolicies:
  enabled: false

bbtests:
  enabled: false
  cypress:
    artifacts: true
    envs:
      cypress_check_datasource: 'false'
      cypress_grafana_url: 'http://monitoring-grafana.monitoring.svc.cluster.local'
  scripts:
    image: registry1.dso.mil/ironbank/big-bang/base:2.0.0
    envs:
      LOKI_URL: 'http://{{ .Values.fullnameOverride }}.{{ .Release.Namespace }}.svc:3100'
      LOKI_VERSION: '{{ .Values.loki.image.tag }}'
```

```chart/templates/tokengen/job-tokengen.yaml```
- At the top of the file, at the start of the templates under the conditionals at the very top, add the following NetworkPolicy resources:
```
{{- if .Values.networkPolicies.enabled }}
{{- if .Values.minio.enabled }}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: tokengen-ingress-minio
  namespace: {{ .Release.Namespace }}
  annotations:
    "helm.sh/hook": post-install
    "helm.sh/hook-weight": "-10"
    "helm.sh/hook-delete-policy": hook-succeeded,hook-failed,before-hook-creation
spec:
  podSelector:
    matchLabels:
      app: minio
      app.kubernetes.io/instance: {{ .Release.Name }}
  ingress:
    - from:
      - podSelector:
          matchLabels:
            {{- include "enterprise-logs.tokengenLabels" . | nindent 14 }}
            {{- with .Values.enterprise.tokengen.labels }}
            {{- toYaml . | nindent 14 }}
            {{- end }}
      ports:
        - port: 9000
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: tokengen-egress-minio
  namespace: {{ .Release.Namespace }}
  annotations:
    "helm.sh/hook": post-install
    "helm.sh/hook-weight": "-10"
    "helm.sh/hook-delete-policy": hook-succeeded,hook-failed,before-hook-creation
spec:
  podSelector:
    matchLabels:
      app: minio
      app.kubernetes.io/instance: {{ .Release.Name }}
  egress:
    - to:
      - podSelector:
          matchLabels:
            {{- include "enterprise-logs.tokengenLabels" . | nindent 14 }}
            {{- with .Values.enterprise.tokengen.labels }}
            {{- toYaml . | nindent 14 }}
            {{- end }}
      ports:
        - port: 9000
{{- end }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-egress-tokengen-job
  namespace: {{ .Release.Namespace }}
  annotations:
    "helm.sh/hook": post-install
    "helm.sh/hook-weight": "-10"
    "helm.sh/hook-delete-policy": hook-succeeded,hook-failed,before-hook-creation
spec:
  egress:
  - to:
    - ipBlock:
        cidr: {{ .Values.networkPolicies.controlPlaneCidr }}
        {{- if eq .Values.networkPolicies.controlPlaneCidr "0.0.0.0/0" }}
        # ONLY Block requests to AWS metadata IP
        except:
        - 169.254.169.254/32
        {{- end }}
  podSelector:
    matchLabels:
      {{- include "enterprise-logs.tokengenLabels" . | nindent 6 }}
      {{- with .Values.enterprise.tokengen.labels }}
      {{- toYaml . | nindent 6 }}
      {{- end }}
  policyTypes:
  - Egress
{{- end }}
---
```

```chart/templates/_helpers.tpl```
- On line 5 for the `$default` function, remove the `ternary` function and ensure the definition looks just like:
```
{{- $default := "loki" }
```

- line 115 ensure the following block for minio looks like:
```
{{- if .Values.minio.enabled -}}
s3:
  endpoint: {{ $.Values.minio.service.nameOverride }}
  bucketnames: {{ $.Values.loki.storage.bucketNames.chunks }}
  secret_access_key: {{ $.Values.minio.secrets.secretKey }}
  access_key_id: {{ $.Values.minio.secrets.accessKey }}
  s3forcepathstyle: true
  insecure: true
```

```chart/src/dashboards/```
- cd into this directory and run the following command to update the logic so the Release name is captured:
```
sed -i 's/(loki|enterprise-logs)/logging-loki/g' \*.json
```

# Testing new Loki Version

### Deploy Loki Scalable as a part of BigBang
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

### Deploy Loki Monolith as a part of BigBang
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
  --set tempo.enabled=true
```
`overrides/loki.yaml`
```
loki:
  git:
    tag: ""
    branch: "my-branch-name-goes-here"
  enabled: true
```
- Visit `https://grafana.bigbang.dev` and login
- Navigate to `configuration -> Data Sources -> Loki` and then click `Save & Test` to ensure Data Source changes can be saved successfully.
- Search dashboards for `Loki Dashboard Quick Search` and confirm log data is being populated/no error messages.