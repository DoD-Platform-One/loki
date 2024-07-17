# Loki in Production

This chart supports running Loki in two architecture modes, monolith and simple-scalable. It is strongly encouraged to utilize the simple-scalable architecture in production environments as it allows more fine grained control over scaling of read/write nodes compared to the monolith. 


## Big Bang Simple Scalable Recommended Production Configuration
This example assumes external dependencies of: 
* AWS S3
```yaml
loki:
  strategy: "scalable"
  objectStorage:
    #If using Grafana enterprise, dropping the `https://` is required
    endpoint: https://s3.us-gov-west-1.amazonaws.com
    region: us-gov-west-1
    bucketnames:
      # Loki since their 1.0 Chart release allows you to specify separate buckets.
      chunks: loki-logs  #For storage of log data in 'chunks'
      ruler: loki-logs   #For Loki configured rules https://grafana.com/docs/loki/latest/rules/
      admin: loki-admin  #For Grafana Enterprise configuration/persistence only
      deletion: loki-deletion #The storage bucket that stores the delete requests
  values:
    loki:
      memcached:
        # configure how Loki will cache requests, chunks, and the index to a backing cach store.
        chunk_cache:
          enabled: true
          host: "elasticache.XXXX:6379"
          service: "memcached"
          batch_size: 256
          parallelism: 10
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
Loki is able to use IAM Profiles attached to nodes on your instances, if you don't specify `loki.objectStorage.accessKey` or `loki.objectStorage.accessSecret` loki will use the Profile attached to the instance. If you specify `accessKey` & `accessSecret` they will be mounted within a non encrypted/obfuscated configMap via the loki-simple-scalable chart so it is encouraged to utilize instance profiles where possible.

## AWS IRSA Configuration
To use AWS IRSA within Loki, ensure the following values are set along with the usual `loki.objectStorage` values via BigBang:
  ```
  loki:
    values:
      loki:
        storage:
          s3:
            endpoint: ""
      serviceAccount:
        annotations: 
          eks.amazonaws.com/role-arn: "my-role-arn"
  ```

## Override A Custom Configuration
If the above recommended configuration is not enough, you would like to add in additional options or utilize something like AWS DynamoDB as a table-manager instead of tsdb-shipper, you can override in your own full configuration under the `global.config` value:
```yaml
loki:
  values:
    loki:
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
If you wish to use the monolith chart in production it is recommended that you instead utilize the simple-scalable-chart and external object storage, but you can deploy the monolith installation which is a single loki pod which writes/stores to local PVC storage: 
```yaml
loki:
  strategy: monolith
  values:
    singleBinary:
      persistence:
	      size: 40Gi
```

## New Config Value Options
Since Big Bang chart version 4.X, Loki-simple-scalable version 1.X there is the ability to configure some options via `loki` value definitions, these options include:
| Value | Documentation |
| ------|---------------|
| `storage_config: {}` | https://grafana.com/docs/loki/latest/configuration/#storage_config |
| `schemaConfig: {}` | https://grafana.com/docs/loki/latest/configuration/#schema_config |
| `structuredConfig: {}` | Structured loki configuration, takes precedence over `global.config`, `global.schemaConfig`, `global.storageConfig` |
| `query_scheduler: {}` | https://grafana.com/docs/loki/latest/configuration/#query_scheduler |
| `commonConfig: {}` | https://grafana.com/docs/loki/latest/configuration/#common |
| `memcached.chunk_cache: {}` | https://grafana.com/docs/loki/latest/configuration/#cache_config |
| `memcached.results_cache: {}` | https://grafana.com/docs/loki/latest/configuration/#query_range |

An example of using these new values is the `memcached` example in the Simple Scalable Recommended Production Configuration section above.
