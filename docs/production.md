# Loki in Production

This chart supports running Loki in two architecture modes, monolith and simple-scalable. It is strongly encouraged to utilize the simple-scalable architecture in production environments as it allows more fine grained control over scaling of read/write nodes compared to the monolith. 


## Simple Scalable Recommended Production Configuration
This example assumes external dependencies of: 
* AWS S3
```yaml
global:
  objectStorage: 
    endpoint: s3.amazonaws.com
    region: us-east-1
    bucketnames: loki-logs

    # Access should generally given via an AWS Instance Profile but can be specified here
    # access_key_id: <ACCESS_KEY>
    # secret_access_key: <SECRET>

  createGlobalConfig: true
  existingSecretForConfig: loki-config

loki-simple-scalable:
  enabled: true

loki:
  enabled: false
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
global:
  createGlobalConfig: true
  existingSecretForConfig: "loki-config"
  config: |
    auth_enabled: false
    server:
      http_listen_port: 3100
    ...
    storage_config:
      aws:
        s3: s3://access_key:secret_access_key@region/bucket_name
	dynamodb:
	  dynamodb_url: dynamodb://access_key:secret_access_key@region
```
See the [Examples for cloud configuration provided by Grafana.](https://grafana.com/docs/loki/latest/configuration/examples/)

## Monolith Recommended Configuration
If you wish to use the monolith chart in production it is recommended that you instead utilize the simple-scalable-chart and external object storage, but you can deploy the monolith installation and point to object storage such as Minio: 
```yaml
global:
  createGlobalConfig: true
  existingSecretForConfig: loki-config

loki-simple-scalable:
  enabled: false

loki:
  enabled: true

minio:
  enabled: true
```
