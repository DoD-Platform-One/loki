# Loki Development and Maintenance Guide

## To upgrade the Loki Package

1. Navigate to the upstream [chart repo and folder](https://github.com/grafana/loki/blob/main/production/helm/loki/Chart.yaml) and find the tag that corresponds with the new chart version for this update.

    - Check the [upstream changelog](https://grafana.com/docs/loki/latest/upgrading/) for upgrade notices.

2. Checkout the `renovate/ironbank` branch

3. From the root of the repo run `kpt pkg update chart@<tag> --strategy alpha-git-patch`, where tag is found in step 1 (loki ref: `helm-loki-<tag>`)

    - Run a KPT update against the main chart folder:

    ```shell
      # To find the chart version for the command below:
      # - Browse to the [upstream](https://github.com/grafana/loki/tree/main/production/helm/loki).
      # - Click on the drop-down menu on the upper left, then on Tags.
      # - Scroll/Search through the tags until you get to the Helm chart version tags (e.g. helm-loki-5.9.2, helm-loki-5.9.1, etc.).
      # - Starting with the most recent Helm chart version tag, open the Chart.yaml for the tag. If the appVersion value corresponds to the
      # version of Loki that Renovate detected for an upgrade, this is the correct version. So, for example, if you will be updating to chart
      # version helm-loki-5.9.2, your kpt command would be:
      #
      # kpt pkg update chart@helm-loki-5.9.2 --strategy alpha-git-patch

      kpt pkg update chart@helm-loki-<tag> --strategy alpha-git-patch
    ```

    - Restore all BigBang added templates and tests:

    ```shell
      git checkout chart/templates/bigbang/
      git checkout chart/tests/
      git checkout chart/dashboards
      git checkout chart/templates/tests
    ```

    - Follow the [Update main chart](#update-main-chart) section of this document for a list of changes per file to be aware of, for how Big Bang differs from upstream.

4. Modify the version in `Chart.yaml` and append `-bb.0` to the chart version from upstream.

5. Update dependencies and binaries using `helm dependency update ./chart`

    - Ensure that the minio version in chart/Chart.yaml matches the latest tag version of minio available in the Big Bang minio package [Chart.yaml](https://repo1.dso.mil/big-bang/product/packages/minio/-/blob/main/chart/Chart.yaml)

    - If needed, log into registry1.

      ```shell
      # Note, if you are using Ubuntu on WSL and get an error about storing credentials or about how `The name org.freedesktop.secrets was not
      # provided by any .service files` when you run the command below, install the libsecret-1-dev and gnome-keyring packages. After doing this,
      # you'll be prompted to set a keyring password the first time you run this command.
      #
      helm registry login https://registry1.dso.mil -u ${registry1.username}
      ```

    - Pull assets and commit the binaries as well as the Chart.lock file that was generated.

      ```shell
      # Note: You may need to resolve merge conflicts in chart/values.yaml before these commands work. Refer to the "Modifications made to upstream"
      # section below for hinsts on how to resolve them. Also, you need to be logged in to registry1 thorough docker.
      export HELM_EXPERIMENTAL_OCI=1
      helm dependency update ./chart
      ```

      Then log out.

      ```shell
      helm registry logout https://registry1.dso.mil
      ```

6. Update `CHANGELOG.md` adding an entry for the new version and noting all changes in a list (at minimum should include `- Updated <chart or dependency> to x.x.x`).

7. Generate the `README.md` updates by following the [guide in gluon](https://repo1.dso.mil/big-bang/product/packages/gluon/-/blob/master/docs/bb-package-readme.md).

8. Push up your changes, add upgrade notices if applicable, validate that CI passes.

    - If there are any failures, follow the information in the pipeline to make the necessary updates.

    - Add the `debug` label to the MR for more detailed information.

    - Reach out to the CODEOWNERS if needed.

9. (_Optional, only required if package changes are expected to have cascading effects on bigbang umbrella chart_) As part of your MR that modifies bigbang packages, you should modify the bigbang [bigbang/tests/test-values.yaml](https://repo1.dso.mil/big-bang/bigbang/-/blob/master/tests/test-values.yaml?ref_type=heads) against your branch for the CI/CD MR testing by enabling your packages. 

    - To do this, at a minimum, you will need to follow the instructions at [bigbang/docs/developer/test-package-against-bb.md](https://repo1.dso.mil/big-bang/bigbang/-/blob/master/docs/developer/test-package-against-bb.md?ref_type=heads) with changes for Loki enabled (the below is a reference, actual changes could be more depending on what changes where made to Loki in the package MR).

### [test-values.yaml](https://repo1.dso.mil/big-bang/bigbang/-/blob/master/tests/test-values.yaml?ref_type=heads)

```yaml
loki:
  enabled: true
  git:
    tag: null
    branch: "renovate/ironbank"
  values:
    istio:
      hardened:
        enabled: true
  ### Additional components of Loki should be changed to reflect testing changes introduced in the package MR
```

10. Follow the `Testing new Loki Version` section of this document for manual testing.

### Local chart rendering (routes/netpols)

When rendering the chart locally, note that Istio resources (including `routes.inbound` netpols) only render if the Istio API is present. Add the API version to your `helm template` call and set `containerPort` if you want it reflected in the netpol port.

```shell
helm dependency update ./chart

helm template loki ./chart \
  --namespace logging \
  --set networkPolicies.enabled=true \
  --set routes.inbound.loki.containerPort=8080 \
  --api-versions networking.istio.io/v1 \
  > /tmp/loki-render.yaml

rg -n "NetworkPolicy|VirtualService" /tmp/loki-render.yaml
```

## Update main chart

### ```chart/Chart.yaml```

- update loki `version` and `appVersion`
- Ensure Big Bang version suffix is appended to chart version
- Ensure minio and gluon dependencies are present and up to date

  ```yaml
  appVersion: $LOKI_APP_VERSION
  version: $VERSION-bb.0
  dependencies:
    - name: minio-instance
      alias: minio
      version: $MINIO_VERSION
      repository: oci://registry1.dso.mil/bigbang
      condition: minio.enabled
    - name: grafana-agent-operator
      alias: grafana-agent-operator
      version: $GRAFANA_VERSION
      repository: https://grafana.github.io/helm-charts
      condition: monitoring.selfMonitoring.grafanaAgent.installOperator
    - name: gluon
      version: $GLUON_VERSION
      repository: "oci://registry1.dso.mil/bigbang"
    - name: rollout-operator
      alias: rollout_operator
      repository: https://grafana.github.io/helm-charts
      version: $ROLLOUT_OPERATOR_VERSION
      condition: rollout_operator.enabled
  annotations:
    bigbang.dev/applicationVersions: |
      - Loki: $LOKI_APP_VERSION
  ```

### ```chart/values.yaml```

- Verify that Renovate updated the `loki:` section with the correct value for `tag`. For example, if Renovate wants to update Loki to version 2.8.3, you should see:

  ```yaml
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

### ```chart/tests/*```

- Verify that cypress testing configuration and tests are present here. You should see contents similar to this in chart/tests/cypress/:

```shell
drwxr-xr-x 2 ubuntu ubuntu 4096 Aug  1 12:24 ./
drwxr-xr-x 4 ubuntu ubuntu 4096 Aug  1 12:24 ../
-rw-r--r-- 1 ubuntu ubuntu   86 Aug  1 12:24 cypress.json
-rw-r--r-- 1 ubuntu ubuntu 1494 Aug  1 12:24 loki-health.spec.js
```

And this in chart/tests/scripts/:

```shell
drwxr-xr-x 2 ubuntu ubuntu 4096 Aug  1 12:24 ./
drwxr-xr-x 4 ubuntu ubuntu 4096 Aug  1 12:24 ../
-rw-r--r-- 1 ubuntu ubuntu 2192 Aug  1 12:24 test.sh
```

If you are unsure or if these directories do not exist or are empty, check with the code owners.

## Modifications made to upstream

This is a high-level list of modifications that Big Bang has made to the upstream helm chart. You can use this as as cross-check to make sure that no modifications were lost during the upgrade process.

### ```chart/values.yaml```

- Ensure nameOverride is set to `logging-loki`

  ```yaml
  nameOverride: logging-loki
  ```

- Ensure fullnameOverride is set to `logging-loki`

  ```yaml
  fullnameOverride: logging-loki
  ```

- Ensure `private-registry` IPS is present:

  ```yaml
  imagePullSecrets:
    - name: private-registry
  ```

- Ensure `deploymentMode` is set to `SingleBinary`

  ```yaml
  deploymentMode: SingleBinary
  ```

- Ensure the loki image is properly set:

  ```yaml
  loki:
    image:
      # -- The Docker registry
      registry: registry1.dso.mil
      # -- Docker image repository
      repository: ironbank/opensource/grafana/loki
      # -- Overrides the image tag whose default is the chart's appVersion
      tag: X.X.X
  ```

- Ensure `loki.auth_enabled` is set to `false`

  ```yaml
  auth_enabled: false
  ```

- Ensure `loki.commonConfig.replication_factor` is set to `1`

  ```yaml
  commonConfig:
    replication_factor: 1
  ```

- Ensure `loki.storage.bucketNames` is set:

  ```yaml
  storage:
    bucketNames:
      chunks: loki
      ruler: loki
      admin: loki-admin
      deletion: loki-deletion
  ```

- Ensure the following is present for `loki.schemaConfig`:

  ```yaml
  schemaConfig:
    configs:
      - from: 2022-01-11
        store: boltdb-shipper
        object_store: "{{ .Values.loki.storage.type }}"
        schema: v12
        index:
          prefix: loki_index_
          period: 24h
      - from: 2023-08-01
        store: tsdb
        object_store: "{{ .Values.loki.storage.type }}"
        schema: v12
        index:
          prefix: loki_tsdb_
          period: 24h
      - from: 2024-05-30
        store: tsdb
        object_store: "{{ .Values.loki.storage.type }}"
        schema: v13
        index:
          prefix: loki_tsdb_
          period: 24h
  ```

- Ensure the 3 lines below are present within `loki.storage_config.boltdb_shipper`:

  ```yaml
  storage_config:
    boltdb_shipper:
      active_index_directory: /var/loki/boltdb-shipper-active
      cache_location: /var/loki/boltdb-shipper-cache
      cache_ttl: 24h
  ```

- Ensure the 3 lines below are present within `loki.storage_config.tsdb_shipper`:

  ```yaml
  storage_config:
    tsdb_shipper:
      active_index_directory: /var/loki/tsdb-index
      cache_location: /var/loki/tsdb-cache
      cache_ttl: 24h
  ```

- Ensure `loki.analytics.reporting_enabled` is set to `false`

  ```yaml
  analytics:
    reporting_enabled: false
  ```

- Ensure `loki.ingester` configuration is set to:

  ```yaml
  ingester:
    chunk_target_size: 196608
    flush_check_period: 5s
    flush_op_timeout: 100m
    autoforget_unhealthy: true
    lifecycler:
      ring:
        kvstore:
          store: memberlist
        replication_factor: 1
  ```

- Ensure `enterprise.image` is set to the registry1 image:

  ```yaml
  image:
    # -- The Docker registry
    registry: registry1.dso.mil
    # -- Docker image repository
    repository: ironbank/grafana/grafana-enterprise-logs
    # -- Overrides the image tag whose default is the chart's appVersion
    tag: vX.X.X
  ```

- Ensure `enterprise.tokengen.annotations` includes:

  ```yaml
  annotations:
    sidecar.istio.io/inject: "false"
  ```

- Ensure `enterprise.provisioner.enabled` is set to `false`

  ```yaml
  provisioner:
    # -- Whether the job should be part of the deployment
    enabled: false
  ```

- Ensure `kubectlImage` is set to the registry1 image:

  ```yaml
  kubectlImage:
    # -- The Docker registry
    registry: registry1.dso.mil
    # -- Docker image repository
    repository: ironbank/opensource/kubernetes/kubectl
    # -- Overrides the image tag whose default is the chart's appVersion
    tag: vX.X.X
  ```

- Ensure `test.enabled` is set to `false` and that `test.prometheusAddress` is set to `"http://prometheus:9090"`

  ```yaml
  test:
    enabled: false
    prometheusAddress: "http://prometheus:9090"
  ```

- Ensure `lokiCanary.enabled` is set to `false`

  ```yaml
  lokiCanary:
    enabled: false
  ```

- Ensure `serviceAccount.automountServiceAccountToken` is set to `false`:

  ```yaml
  serviceAccount:
    # -- Set this toggle to false to opt out of automounting API credentials for the service account
    automountServiceAccountToken: false
  ```

- Ensure `gateway.enabled` is set to `false`

  ```yaml
  gateway:
    enabled: false
  ```

- Ensure `gateway.image` is set to the registry1 image:

  ```yaml
  image:
    # -- The Docker registry for the gateway image
    registry: registry1.dso.mil
    # -- The gateway image repository
    repository: ironbank/opensource/nginx/nginx
    # -- The gateway image tag
    tag: X.X.X
  ```

- Ensure that at the bottom of the `gateway:` block, there is a `podDisruptionBudget` section

  ```yaml
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

- Ensure `singleBinary.replicas` is set to `1`

  ```yaml
  singleBinary:
    # -- Number of replicas for the single binary
    replicas: 1
  ```

- Verify that `singleBinary.resources` is set to:

  ```yaml
  resources:
    limits:
      cpu: 100m
      memory: 256Mi
    requests:
      cpu: 100m
      memory: 256Mi
  ```

- Ensure that `singleBinary.persistence.enableStatefulSetAutoDeletePVC` is set to `false`.

- Ensure that `singleBinary.persistence.size` is set to `12Gi`

- Ensure that `write.replicas` is set to `0`:

  ```yaml
  replicas: 0
  ```

- Verify that `write.resources` are set:

  ```yaml
  resources:
    limits:
      cpu: 300m
      memory: 2Gi
    requests:
      cpu: 300m
      memory: 2Gi
  ```

- Ensure that at the bottom of the `write:` block, there is a `podDisruptionBudget:` section

  ```yaml
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

- Ensure that `read.replicas` is set to `0`:

  ```yaml
  replicas: 0
  ```

- Make sure `read.resources` are set to:

  ```yaml
  resources:
    limits:
      cpu: 300m
      memory: 2Gi
    requests:
      cpu: 300m
      memory: 2Gi
  ```

- Ensure that at the bottom of the `read:` block, there is a `podDisruptionBudget` section

  ```yaml
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

- Ensure that `backend.replicas` is set to `0`:

  ```yaml
  replicas: 0
  ```

- Ensure that at the bottom of the `backend:` block, there is a `podDisruptionBudget` section

  ```yaml
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

- Ensure that `querier.resources` are set to:

  ```yaml
  resources:
    limits:
      cpu: 300m
      memory: 2Gi
    requests:
      cpu: 300m
      memory: 2Gi
  ```

- Ensure that `compactor.resources` are set to:

  ```yaml
  resources:
    limits:
      cpu: 300m
      memory: 2Gi
    requests:
      cpu: 300m
      memory: 2Gi
  ```

- Ensure that `compactor.serviceAccount.automountServiceAccountToken` is set to `false`

  ```yaml
  serviceAccount:
    automountServiceAccountToken: false
  ```

- Ensure that `bloomGateway.serviceAccount.automountServiceAccountToken` is set to `false`

  ```yaml
  serviceAccount:
    automountServiceAccountToken: false
  ```

- Ensure that `bloomCompactor.serviceAccount.automountServiceAccountToken` is set to `false`

  ```yaml
  serviceAccount:
    automountServiceAccountToken: false
  ```

- Ensure that `patternIngestor.resources` are set to:

  ```yaml
  resources:
    limits:
      cpu: 100m
      memory: 256Mi
    requests:
      cpu: 100m
      memory: 256Mi
  ```

- Ensure that `patternIngestor.serviceAccount.automountServiceAccountToken` is set to `false`

  ```yaml
  serviceAccount:
    automountServiceAccountToken: false
  ```

- Ensure that the value for `memcached.image.repository` and `memcached.image.tag` are set to valid values from registry1.

  ```yaml
  memcached:
    # -- Memcached Docker image repository
    image:
      # -- Memcached Docker image repository
      repository: registry1.dso.mil/ironbank/opensource/memcached/memcached
      # -- Memcached Docker image tag
      tag: X.X.X
  ```

- Ensured that `memcached.containerSecurityContext` includes the following:

  ```yaml
  fsGroup: 10001
  runAsGroup: 10001
  runAsNonRoot: true
  runAsUser: 10001
  ```

- Ensure that `memcachedExporter.enabled` is set to `false`.

  ```yaml
  memcachedExporter:
    # -- Whether memcached metrics should be exported
    enabled: false
  ```

- Ensure that `memcachedExporter.containerSecurityContext` includes the following:

  ```yaml
  fsGroup: 10001
  runAsGroup: 10001
  runAsNonRoot: true
  runAsUser: 10001
  ```

- Ensure that `resultsCache.enabled` is set to `false`.

  ```yaml
  resultsCache:
    # -- Specifies whether memcached based results-cache should be enabled
    enabled: false
  ```

- Ensure that `chunksCache.enabled` is set to `false`.

  ```yaml
  chunksCache:
    # -- Specifies whether memcached based chunks-cache should be enabled
    enabled: false
  ```

### \*\* **Important** \*\*

#### **Before following the step below, note that if there is only one `minio:` block, you shouldn't remove it.**

- Remove minio block added by upstream

- Ensure the following BB values are all set under minio key:

  ```yaml
  minio:
    # -- Enable minio instance support, must have minio-operator installed
    enabled: false
    # Allow the address used by Loki to refer to Minio to be overridden
    address: "minio.logging.svc.cluster.local"
    port: 9000
    # -- Minio root credentials
    secrets:
      name: "loki-objstore-creds"
      accessKey: "minio"
      secretKey: "minio123" # default key, change this!
    upstream:
      tenant:
        # -- Buckets to be provisioned to for tenant
        buckets:
          - name: loki
          - name: loki-admin
          - name: loki-deletion
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
          - name: pool-0
            servers: 1
            volumesPerServer: 4
            size: 750Mi
            securityContext:
              runAsUser: 1001
              runAsGroup: 1001
              fsGroup: 1001
            containerSecurityContext:
              capabilities:
                drop:
                  - ALL

        metrics:
          enabled: false
          port: 9000
          memory: 128M
    waitJob:
      enabled: false
  ```

- Ensure the `sidecar.image` is set to the equivalent registry1 image:

  ```yaml
  sidecar:
    image:
    # -- The Docker registry and image for the k8s sidecar
    repository: registry1.dso.mil/ironbank/kiwigrid/k8s-sidecar
    # -- Docker image tag
    tag: X.X.X
    # -- Docker image sha. If empty, no sha will be used
    sha: ""
  ```

- Ensure the `sidecar.resources` are set to:

  ```yaml
  resources:
    limits:
      cpu: 100m
      memory: 100Mi
    requests:
      cpu: 100m
      memory: 100Mi
  ```

- Ensure the `sidecar.securityContext` is set to:

  ```yaml
  securityContext:
    allowPrivilegeEscalation: false
    capabilities:
      drop:
      - ALL
    seccompProfile:
      type: RuntimeDefault
  ```

- Ensure `sidecar.rules.enabled` is set to `false`

  ```yaml
  rules:
    enabled: false
  ```

- At the end of file, but before the `DEPRECATED VALUES` section (if that section is present), add/verify the following blocks:

  ```yaml
  domain: dev.bigbang.mil

  # Default to false, override in openshift-test-values.yaml
  openshift: false

  fluentbit:
    enabled: false

  istio:
    enabled: false
    hardened:
      enabled: false
      outboundTrafficPolicyMode: "REGISTRY_ONLY"
      customServiceEntries: []
        # - name: "allow-google"
        #   enabled: true
        #   spec:
        #     hosts:
        #       - google.com
        #       - www.google.com
        #     location: MESH_EXTERNAL
        #     ports:
        #       - number: 443
        #         protocol: TLS
        #         name: https
        #         resolution: DNS
      customAuthorizationPolicies: []
      # - name: "allow-nothing"
      #   enabled: true
      #   spec: {}
      monitoring:
        enabled: true
        namespaces:
          - monitoring
        principals:
          - cluster.local/ns/monitoring/sa/monitoring-grafana
          - cluster.local/ns/monitoring/sa/monitoring-monitoring-kube-alertmanager
          - cluster.local/ns/monitoring/sa/monitoring-monitoring-kube-operator
          - cluster.local/ns/monitoring/sa/monitoring-monitoring-kube-prometheus
          - cluster.local/ns/monitoring/sa/monitoring-monitoring-kube-state-metrics
          - cluster.local/ns/monitoring/sa/monitoring-monitoring-prometheus-node-exporter
      fluentbit:
        enabled: true
        namespaces:
        - fluentbit
        principals:
        - cluster.local/ns/fluentbit/sa/fluentbit-fluent-bit
      minioOperator:
        enabled: true
        namespaces:
        - minio-operator
        principals:
        - cluster.local/ns/minio-operator/sa/minio-operator
    loki:
      enabled: false
      annotations: {}
      labels: {}
      gateways:
        - istio-system/public
      hosts:
        - "loki.{{ .Values.domain }}"
    mtls:
      # STRICT = Allow only mutual TLS traffic
      # PERMISSIVE = Allow both plain text and mutual TLS traffic
      mode: STRICT

  networkPolicies:
    enabled: false
    # -- Control Plane CIDR to allow init job communication to the Kubernetes API.
    # Use `kubectl get endpoints kubernetes` to get the CIDR range needed for your cluster
    controlPlaneCidr: 0.0.0.0/0
    ingressLabels:
      app: public-ingressgateway
      istio: ingressgateway
    additionalPolicies: []

  bbtests:
    enabled: false
    cypress:
      artifacts: true
      envs:
        cypress_check_datasource: 'false'
        cypress_grafana_url: 'http://monitoring-grafana.monitoring.svc.cluster.local'
    scripts:
      image: registry1.dso.mil/ironbank/big-bang/base:2.1.0
      envs:
        LOKI_URL: 'http://{{ .Values.fullnameOverride }}.{{ .Release.Namespace }}.svc:3100'
        LOKI_VERSION: '{{ .Values.loki.image.tag }}'
  ```

- In the `DEPRECATED VALUES` section (if that section is present), set `monitoring.enabled` to `false`

    ```yaml
    monitoring:
      # -- Enable BigBang integration of Monitoring components
      enabled: false
    ```

- In the `DEPRECATED VALUES` section (if that section is present), ensure all `monitoring:` sub-components are set to `enabled: false`
  - Ensure `monitoring.dashboards.enabled` is set to `false`
  - Ensure `monitoring.rules.enabled` is set to `false`
  - Ensure `monitoring.serviceMonitor.enabled` is set to `false`
  - Ensure `monitoring.serviceMonitor.metricsInstance.enabled` is set to `false`
  - Ensure `monitoring.selfMonitoring.enabled` is set to `false`
  - Ensure `monitoring.selfMonitoring.grafanaAgent.installOperator` is set to `false`

### ```chart/ci/```

- In these four files in the `chart/ci` directory: `default-single-binary-values.yaml`, `default-values.yaml`, `ingress-values.yaml`, and `legacy-monitoring-values.yaml`, ensure that `loki.storage.bucketNames` is set to:

    ```yaml
    storage:
      bucketNames:
        chunks: loki
        ruler: loki
        admin: loki-admin
        deletion: loki-deletion
    ```

### ```chart/src/dashboards/```

- `cd` into this directory and run the following command to update the logic so the Release name is captured:

  - Bash:

    ```bash
    sed -i 's/(loki|enterprise-logs)/logging-loki/g' \*.json
    ```

    **Note** On Mac, use GNU SED which can be installed via `brew install gnu-sed`. By default, this version of the command is invoked using `gsed` instead of `sed`.

  **Note** This will cause changes in the following files if they haven't already been updated:
  - `loki-chunks.json`
  - `loki-deletion.json`
  - `loki-operational.json`
  - `loki-reads-resources.json`
  - `loki-reads.json`
  - `loki-retention.json`
  - `loki-writes-resources.json`
  - `loki-writes.json`

- modify the `loki-logs.json` dashboard to maintain the `expr` for log querying (lines 775 and 840):
  - 775:

    ```json
    "expr": "sum(rate({namespace=\"$namespace\", pod=~\"$deployment.+\", pod=~\"$pod\", container=~\"$container\" } |logfmt|= \"$filter\" [5m])) by (level)",
    ```

  - 840:

    ```json
    "expr": "{namespace=\"$namespace\", pod=~\"$deployment.+\", pod=~\"$pod\", container=~\"$container\"} | logfmt | level=\"$level\" |= \"$filter\"",
    ```

### ```chart/templates/backend/poddisruptionbudget-backend.yaml```

- Ensure that there is not hard-coded spec for the PDB template

  ```yaml
    {{- with .Values.backend.podDisruptionBudget.maxUnavailable }}
    maxUnavailable: {{ . }}
    {{- else }}
    minAvailable: {{ .Values.backend.podDisruptionBudget.minAvailable | default 0 }}
    {{- end }}
  ```

### ```chart/templates/backend/query-scheduler-discovery.yaml```

- Ensure that the `grpc` port specifies an `appProtocol` of `tcp`, as in:

  ```yaml
  - name: grpc
    port: {{ .Values.loki.server.grpc_listen_port }}
    targetPort: grpc
    appProtocol: tcp
    protocol: TCP
  ```

### ```chart/templates/backend/service-backend-headless.yaml```

- Ensure that the `grpc` port specifies an `appProtocol` of `tcp`, as in:

  ```yaml
  - name: grpc
    port: {{ .Values.loki.server.grpc_listen_port }}
    targetPort: grpc
    appProtocol: tcp
    protocol: TCP
  ```

### ```chart/templates/backend/service-backend.yaml```

- Ensure that the `grpc` port specifies an `appProtocol` of `tcp`, as in:

  ```yaml
  - name: grpc
    port: {{ .Values.loki.server.grpc_listen_port }}
    targetPort: grpc
    appProtocol: tcp
    protocol: TCP
  ```

### ```chart/templates/gateway/poddisruptionbudget-gateway.yaml```

- Ensure that there is not hard-coded spec for the PDB template

  ```yaml
    {{- with .Values.gateway.podDisruptionBudget.maxUnavailable }}
    maxUnavailable: {{ . }}
    {{- else }}
    minAvailable: {{ .Values.gateway.podDisruptionBudget.minAvailable | default 0 }}
    {{- end }}
  ```

### ```chart/templates/read/poddisruptionbudget-read.yaml```

- Ensure that there is not hard-coded spec for the PDB template

  ```yaml
    {{- with .Values.read.podDisruptionBudget.maxUnavailable }}
    maxUnavailable: {{ . }}
    {{- else }}
    minAvailable: {{ .Values.read.podDisruptionBudget.minAvailable | default 0 }}
    {{- end }}
  ```

### ```chart/templates/read/service-read.yaml```

- Ensure that the `grpc` port specifies an `appProtocol` of `tcp`, as in:

  ```yaml
  - name: grpc
    port: {{ .Values.loki.server.grpc_listen_port }}
    targetPort: grpc
    appProtocol: tcp
    protocol: TCP
  ```

- Ensure  that `spec.publishNotReadyAddresses` is set to `true`

  ```yaml
  publishNotReadyAddresses: true
  ```

### ```chart/templates/tokengen/job-tokengen.yaml```

- At the top of the file, at the start of the templates under the conditionals at the very top, add the following NetworkPolicy resources:

  ```yaml
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
        {{- include "minio.labels" . | nindent 6 }}
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
        {{- include "minio.labels" . | nindent 6 }}
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
  ---
  {{- end }}
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
  ---
  {{- end }}
  ```

### ```chart/templates/write/poddisruptionbudget-write.yaml```

- Ensure that there is no hard-coded spec for the PDB template

    ```yaml
      {{- with .Values.write.podDisruptionBudget.maxUnavailable }}
      maxUnavailable: {{ . }}
      {{- else }}
      minAvailable: {{ .Values.write.podDisruptionBudget.minAvailable | default 0 }}
      {{- end }}
    ```

### ```chart/templates/write/service-write.yaml```

- Ensure that the `grpc` port specifies an `appProtocol` of `tcp`, as in:

  ```yaml
  - name: grpc
    port: {{ .Values.loki.server.grpc_listen_port }}
    targetPort: grpc
    appProtocol: tcp
    protocol: TCP
  ```

### ```chart/templates/_helpers.tpl```

- For the `$default` function, remove the `ternary` function and ensure the definition looks just like:

  ```yaml
  {{- $default := "loki" }
  ```

- Ensure the following block for minio looks like:

  ```yaml
  {{- if .Values.minio.enabled -}}
  s3:
    endpoint: {{ include "loki.minio" $ }}
    bucketnames: {{ $.Values.loki.storage.bucketNames.chunks }}
    secret_access_key: {{ $.Values.minio.tenant.configSecret.secretKey }}
    access_key_id: {{ $.Values.minio.tenant.configSecret.accessKey }}
    s3forcepathstyle: true
    insecure: true
  ```

- In the `Storage config for ruler` section, ensure that `s3.bucketnames` looks like:

  ```yaml
  s3:
    bucketnames: {{ $.Values.loki.storage.bucketNames.ruler }}
  ```

### ```chart/templates/service-memberlist.yaml```

- Ensure that the `tcp` port specifies an `appProtocol` of `tcp`, as in:

  ```yaml
  - name: tcp
    port: 7946
    targetPort: http-memberlist
    protocol: TCP
    appProtocol: tcp
  ```

## automountServiceAccountToken

The mutating Kyverno policy named [update-automountserviceaccounttokens](https://repo1.dso.mil/big-bang/bigbang/-/blob/master/chart/templates/kyverno-policies/values.yaml?ref_type=heads#L679) is leveraged to harden all ServiceAccounts in this package with `automountServiceAccountToken: false`.

This policy revokes access to the K8s API for Pods utilizing said ServiceAccounts. If a Pod truly requires access to the K8s API (for app functionality), the Pod is added to the `pods:` array of the same mutating policy. This grants the Pod access to the API, and creates a Kyverno PolicyException to prevent an alert.

## Testing new Loki Version

> NOTE: For these testing steps it is good to do them on both a clean install and an upgrade. For clean install, point Loki to your branch. For an upgrade do an install with Loki pointing to the latest tag, then perform a helm upgrade with Loki pointing to your branch.

### Deploy Loki Scalable as a part of BigBang

You will want to install with:

- Loki, Alloy, Fluentbit, Tempo, Monitoring, MinioOperator and Istio packages enabled

`overrides/testing-loki-scalable.yaml`

```yaml
istiod:
  enabled: true
  values:
    hardened:
      enabled: true
istioCRDs:
  enabled: true
istioGateway:
  enabled: true

gatekeeper:
  enabled: false

monitoring:
  enabled: true
  values:
    istio:
      enabled: true

loki:
  enabled: true
  git:
    tag: ""
    branch: "renovate/ironbank"
  strategy: scalable
  values:
    minio:
      enabled: true
    istio:
      enabled: true

alloy:
  enabled: true
  alloyLogs: 
    enabled: true
  values:
    k8s-monitoring:
      destinations:
        - name: loki
          type: loki
          url: http://logging-loki-write.logging.svc.cluster.local:3100/loki/api/v1/push

tempo:
  enabled: true

twistlock:
  enabled: false

kyvernoPolicies:
  values:
    exclude:
      any:
      # Allows k3d load balancer to bypass policies.
      - resources:
          namespaces:
          - istio-system
          names:
          - svclb-*
    policies:
      restrict-host-path-mount-pv:
        parameters:
          allow:
          - /var/lib/rancher/k3s/storage/pvc-*

addons:
  minioOperator:
    enabled: true
```

- Visit `https://grafana.dev.bigbang.mil` and login with [default credentials](https://repo1.dso.mil/big-bang/bigbang/-/blob/master/docs/guides/using-bigbang/default-credentials.md)
- Navigate to `Connections -> Data Sources -> Loki`
  - Click `Save & Test` to ensure Data Source changes can be saved successfully.
- Search dashboards for `Loki Dashboard Quick Search` and confirm log data is being populated/no error messages.

### Deploy Loki Monolith as a part of BigBang (Without Object Storage)

> Loki Monolith is tested during the "package tests" stage of loki pipelines.

You will want to install with:

- Loki, Alloy, Tempo, Monitoring and Istio packages enabled

`overrides/testing-loki-monolith.yaml`

```yaml
istiod:
  enabled: true
  values:
    hardened:
      enabled: true
istioCRDs:
  enabled: true
istioGateway:
  enabled: true

gatekeeper:
  enabled: false

monitoring:
  enabled: true

loki:
  enabled: true
  strategy: monolith
  git:
    tag: ""
    branch: "renovate/ironbank"
  values:
    minio:
      enabled: false
    read:
      replicas: 0
    write:
      replicas: 0
    backend:
      replicas: 0

alloy:
  enabled: true
  alloyLogs: 
    enabled: true
  values:
    k8s-monitoring:
      destinations:
        - name: loki
          type: loki
          url: http://logging-loki.logging.svc.cluster.local:3100/loki/api/v1/push

tempo:
  enabled: true

twistlock:
  enabled: false

kyvernoPolicies:
  values:
    exclude:
      any:
      # Allows k3d load balancer to bypass policies.
      - resources:
          namespaces:
          - istio-system
          names:
          - svclb-*
    policies:
      restrict-host-path-mount-pv:
        parameters:
          allow:
          - /var/lib/rancher/k3s/storage/pvc-*

addons:
  minioOperator:
    enabled: false
```

- Visit `https://grafana.dev.bigbang.mil` and login with [default credentials](https://repo1.dso.mil/big-bang/bigbang/-/blob/master/docs/guides/using-bigbang/default-credentials.md)
- Navigate to `Connections -> Data Sources -> Loki`
  - Click `Save & Test` to ensure Data Source changes can be saved successfully.
- Search dashboards for `Loki Dashboard Quick Search` and confirm log data is being populated/no error messages.

> When in doubt with any testing or upgrade steps, reach out to the CODEOWNERS for assistance.
