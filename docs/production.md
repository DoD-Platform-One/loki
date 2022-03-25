# Loki in Production

This chart and the upstream Loki chart have `persistence.enabled=false` though the default storage schema is a local `boltdb_shipper` because their recommendations for production recommendations are to make use of options available from your cloud storage provider. Please review the following doc for values to update or insert to point your Loki installation to object or key-value-DB storage which will also allow for the number of `replicas` to be increased above 1.

https://grafana.com/docs/loki/latest/configuration/examples

## Recommended Production Configuration
This example assumes AWS cloud services: S3 and DynamoDB
```
loki:
  values:
    replicas: 3
    extraArgs:
      # https://github.com/grafana/loki/issues/5021
      target: all,table-manager
    resources:
      requests:
        cpu: 125m
        memory: 1Gi
      limits:
        cpu: 400m
        memory: 3Gi
    config:
      auth_enabled: false
      ingester:
        chunk_target_size: 196608
        lifecycler:
          ring:
            kvstore:
              store: inmemory
            replication_factor: 1
      schema_config:
        configs:
        - from: 2022-01-01 # Anything in the past
          store: aws
          object_store: s3
          schema: v11
          index:
            prefix: loki_
            period: 168h
      table_manager:
        retention_deletes_enabled: true
        retention_period: 8736h
      common:
        storage:
          s3:
            region: "us-gov-west-1"
            sse_encryption: true
      storage_config:
        aws:
          region: "us-gov-west-1"
          sse_encryption: true
          dynamodb:
            dynamodb_url: "dynamodb://us-gov-west-1"
      compactor:
        working_directory: /data/loki/boltdb-shipper-compactor
        shared_store: s3
```
