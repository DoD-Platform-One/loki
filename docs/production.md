# Loki in Production

This chart supports running Loki in two architecture modes, monolith and simple-scalable. It is strongly encouraged to utilize the simple-scalable architecture in production environments as it allows more fine grained control over scaling of read/write nodes compared to the monolith. 


## Big Bang Simple Scalable Recommended Production Configuration
This example assumes external dependencies of: 
* AWS S3
```yaml
loki:
  strategy: "scalable"
  objectStorage: 
    type: s3
    endpoint: s3.amazonaws.com
    region: us-east-1
    accessKey: "XXXXXXXX"
    accessSecret: "XXXXXXXXXXXXXX"
    bucketnames:
      # Loki since their 1.0 Chart release allows you to specify separate buckets.
      chunks: chunks
      ruler: ruler
      admin: admin
  values:
    global:
      createGlobalConfig: true
      existingSecretForConfig: "loki-config"
      memcached:
        # configure how Loki will cache requests, chunks, and the index to a backing cach store.
        chunk_cache:
          enabled: true
          host: "elasticache.XXXX:6379"
          service: "memcached"
          batch_size: 256
          parallelism: 10
    loki-simple-scalable:
      write:
        replicas: 3
        persistence:
          size: 50Gi
      read:
        replicas: 5
        persistence:
          size: 50Gi
```

### Cloud Credential Configuration
While it is generally recommended in cloud environments to use instance roles/profiles where possible, currently the loki pods work best when access keys are fed in. If however you do want to use an instance profile, make sure it has appropriate access to the objectstorage and add the following values:
```yaml
loki-simple-scalable:
  loki:
    podAnnotations:
      sidecar.istio.io/inject: "false"
```

## Override A Custom Configuration
If the above recommended configuration is not enough, you would like to add in additional options or utilize something like AWS DynamoDB as a table-manager instead of boltdb-shipper, you can override in your own full configuration under the `global.config` value:
```yaml
loki:
  values:
    global:
      createGlobalConfig: true
      existingSecretForConfig: "loki-config"
      config: |
        auth_enabled: true
        server:
          http_listen_port: 3100
          log_level: debug
          http_server_read_timeout: 300s
          http_server_write_timeout: 300s
        ...
        storage_config:
          aws:
            s3: s3://access_key:secret_access_key@region/bucket_name
            dynamodb:
              dynamodb_url: dynamodb://access_key:secret_access_key@region
        schema_config:
          configs:
          - from: 2022-01-01 # Anything in the past
            store: aws
            object_store: s3
            schema: v12
            index:
              prefix: prefix_loki_logs_
              period: 24h
```
See the [Examples for cloud configuration provided by Grafana.](https://grafana.com/docs/loki/latest/configuration/examples/)

## Monolith Recommended Configuration
If you wish to use the monolith chart in production it is recommended that you instead utilize the simple-scalable-chart and external object storage, but you can deploy the monolith installation and point to object storage such as Minio: 
```yaml
loki:
  strategy: monolith
  values:
    global:
      createGlobalConfig: true
      existingSecretForConfig: loki-config
    
    minio:
      enabled: true
```

## New Global Value Options
Since Big Bang chart version 4.X, Loki-simple-scalable version 1.X there is the ability to configure some options via `global` value definitions, these options include:
| Value | Documentation |
| ------|---------------|
| `storage_config: {}` | https://grafana.com/docs/loki/latest/configuration/#storage_config |
| `schemaConfig: {}` | https://grafana.com/docs/loki/latest/configuration/#schema_config |
| `structuredConfig: {}` | Structured loki configuration, takes precedence over `global.config`, `global.schemaConfig`, `global.storageConfig` |
| `query_scheduler: {}` | https://grafana.com/docs/loki/latest/configuration/#query_scheduler |
| `commonConfig: {}` | https://grafana.com/docs/loki/latest/configuration/#common |
| `memcached.chunk_cache: {}` | https://grafana.com/docs/loki/latest/configuration/#cache_config |
| `memcached.results_cache: {}` | https://grafana.com/docs/loki/latest/configuration/#query_range |
