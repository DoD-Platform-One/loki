# To upgrade the Loki Package

Check the [upstream changelog](https://grafana.com/docs/loki/latest/upgrading/) and the [helm chart upgrade notes](https://github.com/grafana/loki/tree/helm-loki-3.2.0/production/helm/loki#upgrading-from-v2x).

# Upgrading

Find the latest version of the `loki` image that matches the latest version in IronBank that Renovate has identified from here: https://github.com/grafana/loki/tree/helm-loki-3.2.0/production/helm/loki

Run a KPT update against the main chart folder:
```shell
# To find the chart version for the commmand below:
# - Browse to the [upstream](https://github.com/grafana/loki/tree/main/production/helm/loki).
# - Click on the drop-down menu on the upper left, then on Tags.
# - Scroll through the tags until you get to the Helm chart version tags (e.g. helm-loki-5.9.2, helm-loki-5.9.1, etc.).
# - Starting with the most recent Helm chart version tag, open the Chart.yaml for the tag. If the appVersion value corresponds to the 
# version of Loki that Renovate detected for an upgrade, this is the correct version. So, for example, if you will be updating to chart 
# version helm-loki-5.9.2, your kpt command would be:
#
# kpt pkg update chart@helm-loki-5.9.2 --strategy alpha-git-patch

kpt pkg update chart@helm-loki-${chart.version} --strategy alpha-git-patch
```
Restore all BigBang added templates and tests:
```shell
# Note to reviewer: I removed the 'git checkout' commands here that referenced the nonexistent folder chart/deps. Not sure if the rest of these are needed. 
git checkout chart/templates/bigbang/
git checkout chart/tests/
git checkout chart/dashboards
git checkout chart/templates/tests
```
### Update dependencies in chart.yml
Ensure that the minio version in chart/Chart.yaml matches the latest tag version of minio available in the Big Bang minio package [Chart.yaml](https://repo1.dso.mil/big-bang/product/packages/minio/-/blob/main/chart/Chart.yaml)

## Update binaries
If needed, log into registry1.
```
# Note, if you are using Ubuntu on WSL and get an error about storing credentials or about how `The name org.freedesktop.secrets was not 
# provided by any .service files` when you run the command below, install the libsecret-1-dev and gnome-keyring packages. After doing this, 
# you'll be prompted to set a keyring password the first time you run this command. 
# 
helm registry login https://registry1.dso.mil -u ${registry1.username}
```
Pull assets and commit the binaries as well as the Chart.lock file that was generated.
```
# Note: You may need to resolve merge conflicts in chart/values.yaml before these commands work. Refer to the "Modifications made to upstream" 
# section below for hinsts on how to resolve them. Also, you need to be logged in to registry1 thorough docker. 
export HELM_EXPERIMENTAL_OCI=1
helm dependency update ./chart
```
Then log out.
```
helm registry logout https://registry1.dso.mil
```

## Update main chart

```chart/Chart.yaml```

- update loki `version` and `appVersion`
- Ensure Big Bang version suffix is appended to chart version
- Ensure minio and gluon dependencies are present and up to date
```yaml
version: $VERSION-bb.0
dependencies:
  - name: minio-instance
    alias: minio
    version: $MINIO_VERSION
    repository: file://./deps/minio
    condition: minio.enabled
  - name: grafana-agent-operator
    alias: grafana-agent-operator
    version: $GRAFANA_VERSION
    repository: https://grafana.github.io/helm-charts
    condition: monitoring.selfMonitoring.grafanaAgent.installOperator
  - name: gluon
    version: $GLUON_VERSION
    repository: "oci://registry.dso.mil/platform-one/big-bang/apps/library-charts/gluon"
annotations:
  bigbang.dev/applicationVersions: |
    - Loki: $LOKI_APP_VERSION
```

```chart/values.yaml```

- Verify that Renovate updated the loki: section with the correct value for  `tag`. For example, if Renovate wants to update Loki to version 2.8.3, you
should see:
```
loki:
  # Configures the readiness probe for all of the Loki pods
  readinessProbe:
    httpGet:
      path: /ready
      port: http-metrics
    initialDelaySeconds: 30
    timeoutSeconds: 1
  image:
    # -- The Docker registry
    registry: registry1.dso.mil
    # -- Docker image repository
    repository: ironbank/opensource/grafana/loki
    # -- Overrides the image tag whose default is the chart's appVersion
    tag: 2.8.3
```

```chart/tests/*```

- Verify that cypress testing configuration and tests are present here. You should see contents similar to this in chart/tests/cypress/:
```
drwxr-xr-x 2 ubuntu ubuntu 4096 Aug  1 12:24 ./
drwxr-xr-x 4 ubuntu ubuntu 4096 Aug  1 12:24 ../
-rw-r--r-- 1 ubuntu ubuntu   86 Aug  1 12:24 cypress.json
-rw-r--r-- 1 ubuntu ubuntu 1494 Aug  1 12:24 loki-health.spec.js
```
And this in chart/tests/scripts/:
```
drwxr-xr-x 2 ubuntu ubuntu 4096 Aug  1 12:24 ./
drwxr-xr-x 4 ubuntu ubuntu 4096 Aug  1 12:24 ../
-rw-r--r-- 1 ubuntu ubuntu 2192 Aug  1 12:24 test.sh
```
If you are unsure or if these directories do not exist or are empty, check with the code owners. 

# Modifications made to upstream
This is a high-level list of modifications that Big Bang has made to the upstream helm chart. You can use this as as cross-check to make sure that no modifications were lost during the upgrade process.

```chart/values.yaml```
- Ensure nameOverride is set to `logging-loki`
```
nameOverride: logging-loki
```
- Ensure fullnameOverride is set to `logging-loki`
```
fullnameOverride: logging-loki
```
- Ensure `private-registry` IPS is present:
```
imagePullSecrets:
  - name: private-registry
```

- Verify that the latest image from from registry1 is specified in the kubectlImage section. For example, if the latest image is 1.27.4, you should see:
```
  kubectlImage:
    # -- The Docker registry
    registry: registry1.dso.mil/ironbank
    # -- Docker image repository
    repository: opensource/kubernetes/kubectl
    # -- Overrides the image tag whose default is the chart's appVersion
    tag: v1.27.4
```

Verify that the `loki.image` section points to a registry1 image and has the correct tag. For example, for Loki 2.8.3:
```
  image:
    # -- The Docker registry
    registry: registry1.dso.mil
    # -- Docker image repository
    repository: ironbank/opensource/grafana/loki
    # -- Overrides the image tag whose default is the chart's appVersion
    tag: 2.8.3
```

- Ensure that this block is present somewher in the `loki:` section:
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

- Ensure by default auth is disabled in `loki.auth_enabled`
```
  auth_enabled: false
```

- Ensure that `loki.storage.bucketNames` points to `loki`, `loki` & `loki-admin`
```
  storage:
    bucketNames:
      chunks: loki
      ruler: loki
      admin: loki-admin
```

- Ensure `loki.storage_config.boltdb_shipper` configuration is present
```
  storage_config:
    boltdb_shipper:
      active_index_directory: /var/loki/boltdb-shipper-active
      cache_location: /var/loki/boltdb-shipper-cache
      cache_ttl: 24h
      shared_store: s3
```

- Ensure `enterprise.image` is pointed to registry1 image
```
  image:
    # -- The Docker registry
    registry: registry1.dso.mil
    # -- Docker image repository
    repository: ironbank/grafana/grafana-enterprise-logs
    # -- Overrides the image tag whose default is the chart's appVersion
    tag: vX.X.X
```

- Ensure `enterprise.provisioner.enabled` is  set to `false`
```
  provisioner:
    # -- Whether the job should be part of the deployment
    enabled: false
```

- Ensure all `monitoring:` sub-components are set to `enabled: false`
Including the added `monitoring.enabled` value
```
monitoring:
  # -- Enable BigBang integration of Monitoring components
  enabled: false
```
# Note that as of August 16, 2023, this is a little over 150 lines of code. 

- Ensure `monitoring.selfMonitoring.grafanaAgent.installOperator` is set to `false`

- Ensure `monitoring.lokiCanary.enabled` is set to `false`
```
    lokiCanary:
      enabled: false
```

- Verify that `write.resources` are set:
```
  resources:
    limits:
      cpu: 300m
      memory: 2Gi
    requests:
      cpu: 300m
      memory: 2Gi
```

- Ensure that at the bottom of the `write:` block, there is a `podDisruptionBudget:` section
```
  ## -- Application controller Pod Disruption Budget Configuration
  ## Ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/
  podDisruptionBudget:
    # -- Number of pods that are available after eviction as number or percentage (eg.: 50%)
    # @default -- `""` (defaults to 0 if not specified)
    minAvailable: ""
    # -- Number of pods that are unavailable after eviction as number or percentage (eg.: 50%).
    ## Has higher precedence over `controller.pdb.minAvailable`
    maxUnavailable: "1"
```
- Make sure `read.resources` are set to: 
```
  resources:
    limits:
      cpu: 300m
      memory: 2Gi
    requests:
      cpu: 300m
      memory: 2Gi
```
- Ensure that at the bottom of the `read:` block, there is a `podDisruptionBudget` section
```
  ## -- Application controller Pod Disruption Budget Configuration
  ## Ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/
  podDisruptionBudget:
    # -- Number of pods that are available after eviction as number or percentage (eg.: 50%)
    # @default -- `""` (defaults to 0 if not specified)
    minAvailable: ""
    # -- Number of pods that are unavailable after eviction as number or percentage (eg.: 50%).
    ## Has higher precedence over `controller.pdb.minAvailable`
    maxUnavailable: "1"
```

- Ensure that at the bottom of the `backend:` block, there is a `podDisruptionBudget` section
```
  ## -- Application controller Pod Disruption Budget Configuration
  ## Ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/
  podDisruptionBudget:
    # -- Number of pods that are available after eviction as number or percentage (eg.: 50%)
    # @default -- `""` (defaults to 0 if not specified)
    minAvailable: ""
    # -- Number of pods that are unavailable after eviction as number or percentage (eg.: 50%).
    ## Has higher precedence over `controller.pdb.minAvailable`
    maxUnavailable: "1"
```

- Verify that `singleBinary.replicas` is set to `1`
```
singleBinary:
  # -- Number of replicas for the single binary
  replicas: 1
```

- Verify that  `singleBinary.resources` is set to:
```
  resources:
    limits:
      cpu: 100m
      memory: 256Mi
    requests:
      cpu: 100m
      memory: 256Mi
```

- Make sure `gateway.enabled` is set to `false`.

- Ensure `gateway.image` is pointed to registry1 equivalent
```
  image:
    # -- The Docker registry for the gateway image
    registry: registry1.dso.mil
    # -- The gateway image repository
    repository: ironbank/opensource/nginx/nginx
    # -- The gateway image tag
    tag: X.X.X
```

- Ensure that at the bottom of the `gateway:` block, there is a `podDisruptionBudget` section
```
  ## -- Application controller Pod Disruption Budget Configuration
  ## Ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/
  podDisruptionBudget:
    # -- Number of pods that are available after eviction as number or percentage (eg.: 50%)
    # @default -- `""` (defaults to 0 if not specified)
    minAvailable: ""
    # -- Number of pods that are unavailable after eviction as number or percentage (eg.: 50%).
    ## Has higher precedence over `controller.pdb.minAvailable`
    maxUnavailable: "1"
```
# *** Important ***
Before following the step below, note that if there is only one minio: block, you shouldn't remove it.
- Remove minio block added by upstream

- Move the `extraObjects:` configmap block up under `loki:`, so that it is bettween `loki:` and `enterprise:`.

- Ensure the following BB values are all set under minio key:
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

- End of file add/verify the following blocks:
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
  # -- Control Plane CIDR to allow init job communication to the Kubernetes API.  
  # Use `kubectl get endpoints kubernetes` to get the CIDR range needed for your cluster
  controlPlaneCidr: 0.0.0.0/0

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
- On line 13 for the `$default` function, remove the `ternary` function and ensure the definition looks just like:
```
{{- $default := "loki" }
```

- Ensure the following block for minio looks like:
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

```chart/templates/backend/poddisruptionbudget-backend.yaml```
- Ensure that there is not hard-coded spec for the PDB template
```
  {{- with .Values.backend.podDisruptionBudget.maxUnavailable }}
  maxUnavailable: {{ . }}
  {{- else }}
  minAvailable: {{ .Values.backend.podDisruptionBudget.minAvailable | default 0 }}
  {{- end }}
```

```chart/templates/gateway/poddisruptionbudget-gateway.yaml```
- Ensure that there is not hard-coded spec for the PDB template
```
  {{- with .Values.gateway.podDisruptionBudget.maxUnavailable }}
  maxUnavailable: {{ . }}
  {{- else }}
  minAvailable: {{ .Values.gateway.podDisruptionBudget.minAvailable | default 0 }}
  {{- end }}
```

```chart/templates/read/poddisruptionbudget-read.yaml```
- Ensure that there is not hard-coded spec for the PDB template
```
  {{- with .Values.read.podDisruptionBudget.maxUnavailable }}
  maxUnavailable: {{ . }}
  {{- else }}
  minAvailable: {{ .Values.read.podDisruptionBudget.minAvailable | default 0 }}
  {{- end }}
```

```chart/templates/write/poddisruptionbudget-write.yaml```
- Ensure that there is no hard-coded spec for the PDB template
```
  {{- with .Values.write.podDisruptionBudget.maxUnavailable }}
  maxUnavailable: {{ . }}
  {{- else }}
  minAvailable: {{ .Values.write.podDisruptionBudget.minAvailable | default 0 }}
  {{- end }}
```

```chart/src/dashboards/```
- cd into this directory and run the following command to update the logic so the Release name is captured:
```
sed -i 's/(loki|enterprise-logs)/logging-loki/g' \*.json
```
- modify the `loki-logs.json` dashboard to maintain the `expr` for log querying (lines 775 and 840):
  - 775: `"expr": "sum(rate({namespace=\"$namespace\", pod=~\"$deployment.*\", pod=~\"$pod\", container=~\"$container\" } |logfmt|= \"$filter\" [5m])) by (level)",`
  - 840: `"expr": "{namespace=\"$namespace\", pod=~\"$deployment.*\", pod=~\"$pod\", container=~\"$container\"} | logfmt | level=\"$level\" |= \"$filter\"",`

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
