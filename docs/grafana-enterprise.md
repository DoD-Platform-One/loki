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
* Navigate to https://grafana.bigbang.dev/a/grafana-enterprise-logs-app?path=access-policies and create an access policy, ensuring to tick the box that you intend to create a data source with this policy. It should auto populate the required scopes.
* Click 'Add Token', and then click 'Create', and then click 'Create a datasource' which will create a new datasource pre-configured to use the token.


# Future Considerations
* Grafana Enterprise plugin should be configured automatically, [which is possible](https://grafana.com/docs/grafana/latest/administration/provisioning/#plugins), but enterprise plugin properites are undocumented and the admin token is not known until a `post-install` job is run. This job is called `tokengen` in the `logging` namespace, once complete this token is stored in secret `logging-loki-admin-token`.
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
    enterprise:
      enabled: true
      license:
        contents: <GEL LICENSE>
        # Must match cluster name in GEL license
	    cluster_name: <LICENSE CLUSTER NAME>
    gateway:
      enabled: true
      service:
        port: 3101
    minio:
      tenants:
        buckets:
          - name: loki-logs
          - name: loki-admin

    read:
      replicas: 1
    write:
      replicas: 1

    loki:
      storage:
        endpoint: minio.logging.svc.cluster.local
        bucketNames:
          chunks: loki-logs
          admin: loki-admin
        access_key_id: minio
        secret_access_key: minio123

# Get value of `logging-loki-admin-token` secret once loki with `enterprise.enabled=true` rolls out and `tokengen` job completes.
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
