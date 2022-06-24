# Assumptions (5/5/2022)
* Running using BigBang branch https://repo1.dso.mil/platform-one/big-bang/bigbang/-/tree/loki-enterprise
* Running using Loki branch https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/loki/-/tree/feature/adjustable-service-ports

# Setup

## Installation
* Install BigBang with [values.yaml](#values)

## GEL Configuration in Grafana
* Navigate to https://grafana.bigbang.dev/plugins/grafana-enterprise-logs-app
* Populate fields with:
  - Access token: Admin token from `kubectl get secret/gel-admin-token -n logging -o json | jq -r '.data.token' | base64 --decode`
  - Grafana Enterprise Logs URL: http://logging-loki-gel-gateway.logging.svc.cluster.local
* Click "Enable"
* Navigate to https://grafana.bigbang.dev/a/grafana-enterprise-logs-app?path=tenants
* Click Create Tenant, and create a new Tenant

## Create Policy/Token for Promtail
* Navigate to https://grafana.bigbang.dev/a/grafana-enterprise-logs-app?path=access-policies and create an access policy with the `logs:write` scope, ensure you've selected the tenant you just created.
* Now create a token for that access policy by clicking 'Add Token' on the policy name. Copy the token and save it for the next step.

## Promtail Configuration
* Uncomment the promtail section in the [Values](#values)
* Set `basic_auth.password` to the token created above and use the **tenant name** as the username.
* Upgrade the BigBang Helm installation to enable promtail

For example:
```
promtail:
  enabled: true
  values:
    config:
      snippets:
        extraClientConfigs: |
          basic_auth:
            username: borg
            password: cHJvbXRhaWwtcHJvbXRhaWw6ODVzfiM6KkAvOjleMjNWNjNyODRZOFxf
          tenant_id: borg
          external_labels:
            environment: dev
```


## Create Grafana Datasource
* Navigate to https://grafana.bigbang.dev/a/grafana-enterprise-logs-app?path=access-policies and create an access policy, ensuring to tick the box that you intend to create a data source with this polcy. It should auto populate the required scopes.
* Click 'Add Token', and then click 'Create', and then click 'Create a datasource' which will create a new datasource pre-configured to use the token.


# Future Considerations
* Grafana Enterprise plugin should be configured automatically, [which is possible](https://grafana.com/docs/grafana/latest/administration/provisioning/#plugins), but enterprise plugin properites are undocumented and the admin token is not known until a `post-install` job is run.
* Promtail configuration to set auth and tenant info should be automatic, but this depends on the addition of a job to bootstrap a tenant and create a policy plus token.
* [Loki VirtualService for external cluster access.](https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/loki/-/merge_requests/22)
* Memberlist seems to be finicky in AWS with atypical internal subnets. [See Here](https://github.com/grafana/helm-charts/issues/157)

# Values
```
monitoring:
  enabled: true
  grafana:
    enterprise:
      enabled: true
      licenseContents: <GEX License>

loki:
  # -- Toggle deployment of Loki.
  enabled: true

  # -- Loki architecture.  Options are monolith and scalable
  strategy: scalable

  values:
    gel:
      enabled: true
      gateway:
        service:
          port: 3101
      license:
        contents: <GEL LICENSE>
        # Must match cluster name in GEL license
	cluster_name: <LICENSE CLUSTER NAME>

    minio:
      tenants:
        buckets:
          - name: loki-logs
          - name: loki-admin

    loki-simple-scalable:
      read:
        replicas: 1
      write:
        replicas: 1
      gateway:
        enabled: true

    global:
      objectStorage:
        endpoint: minio.logging.svc.cluster.local
        region: us-east-1
        bucketnames: loki-logs
        access_key_id: minio
        secret_access_key: minio123
        adminBucketName: loki-admin

      config: |
        auth:
          type: enterprise
        auth_enabled: true

        license:
          path: "/etc/enterprise-logs/license/license.jwt"

        cluster_name: {{ .Release.Name }}

        server:
          http_listen_port: 3100
          grpc_listen_port: 9095

        common:
          replication_factor: 1
          storage:
            filesystem: null
            s3:
              bucketnames: {{ .Values.global.objectStorage.bucketnames }}
              endpoint: {{ .Values.global.objectStorage.endpoint }}
              region: {{ .Values.global.objectStorage.region }}
              secret_access_key: {{ .Values.global.objectStorage.secret_access_key }}
              access_key_id: {{ .Values.global.objectStorage.access_key_id }}
              insecure: true
              s3forcepathstyle: true

        memberlist:
          join_members:
            - {{ include "loki.fullname" . }}-memberlist-tcp

        admin_client:
          storage:
            type: s3
            s3:
              bucket_name: {{ .Values.global.objectStorage.adminBucketName }}
              insecure: true
              endpoint: {{ .Values.global.objectStorage.endpoint }}
              secret_access_key: {{ .Values.global.objectStorage.secret_access_key }}
              access_key_id: {{ .Values.global.objectStorage.access_key_id }}

        compactor:
          shared_store: s3
          working_directory: /var/loki/boltdb-shipper-compactor
          compaction_interval: 30s

        ingester:
          lifecycler:
            num_tokens: 512
          chunk_idle_period: 30m
          chunk_block_size: 262144
          chunk_encoding: snappy
          chunk_retain_period: 1m
          wal:
            dir: /var/loki/wal

        ingester_client:
          grpc_client_config:
            max_recv_msg_size: 104857600
            max_send_msg_size: 104857600

        limits_config:
          enforce_metric_name: false
          reject_old_samples: true
          reject_old_samples_max_age: 168h
          max_cache_freshness_per_query: 10m

        frontend:
          log_queries_longer_than: 10s
          compress_responses: true
          tail_proxy_url: http://{{ include "loki.fullname" . }}:3100

        querier:
          query_ingesters_within: 12h

        query_range:
          split_queries_by_interval: 24h
          align_queries_with_step: true
          cache_results: true
          results_cache:
            cache:
              memcached:
                expiration: 1h
              memcached_client:
                timeout: 1s

        schema_config:
          configs:
            - from: 2021-01-01
              store: boltdb-shipper
              object_store: aws
              schema: v11
              index:
                prefix: index_
                period: 24h

        storage_config:
          aws:
            endpoint: {{ .Values.global.objectStorage.endpoint }}
            bucketnames: {{ .Values.global.objectStorage.bucketnames }}
            access_key_id: {{ .Values.global.objectStorage.access_key_id }}
            secret_access_key: {{ .Values.global.objectStorage.secret_access_key }}
            region: {{ .Values.global.objectStorage.region }}
            s3forcepathstyle: true
            insecure: true
          boltdb_shipper:
            active_index_directory: /var/loki/index
            cache_location: /var/loki/cache
            cache_ttl: 24h
            shared_store: s3

        ruler:
          storage:
            type: s3
            s3:
              bucketnames: {{ .Values.global.objectStorage.bucketnames }}
          enable_alertmanager_discovery: false
          enable_api: true
          enable_sharding: true
          rule_path: /var/loki

# promtail:
#   enabled: true
#   values:
#     config:
#       snippets:
#         extraClientConfigs: |
#           basic_auth:
#             username: <TENANT_NAME>
#             password: <TOKEN>
#           tenant_id: <TENANT_NAME>
#           external_labels:
#             environment: dev

addons:
  minioOperator:
    enabled: true
```
