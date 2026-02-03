# Grafana Enterprise Logs (GEL) with BigBang

Grafana Enterprise Logs (GEL) extends Loki with enterprise features including:

- Multi-tenancy with isolated log streams
- Access policies and token-based authentication
- Admin API for programmatic management
- Usage tracking and cost management

This guide covers deploying GEL with BigBang and configuring log collection with Alloy.

## Prerequisites

- Valid GEL license (must match the configured cluster name)
- BigBang deployment (3.0+)
- Object storage (S3 or MinIO)
- Grafana Enterprise license (for the GEL plugin)

## Installation

### Step 1: Create Admin Token Secret

Before deploying GEL, you must create an admin token secret. This token is used to authenticate with the GEL Admin API.

Generate a secure token and create the secret:

```bash
# Generate a secure random token
ADMIN_TOKEN=$(openssl rand -base64 32)

# Create the secret in the logging namespace
kubectl create namespace logging --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic loki-admin-token \
  --namespace logging \
  --from-literal=token="${ADMIN_TOKEN}"

# Save the token for later use (you'll need it to configure the GEL plugin)
echo "Admin token: ${ADMIN_TOKEN}"
```

> **Important**: Save this token securely. You will need it to configure the GEL plugin in Grafana.

### Step 2: Deploy BigBang with GEL

Deploy BigBang with GEL enabled using the example values in the [Values](#values) section below. Key configuration points:

1. Set `loki.values.enterprise.enabled: true`
2. Provide your GEL license contents
3. Ensure `cluster_name` matches your license
4. Reference the admin token secret you created
5. Configure object storage for log data

## GEL Configuration in Grafana

### Install and Enable GEL Plugin

1. Navigate to the Grafana Enterprise Logs plugin page:
   `https://grafana.dev.bigbang.mil/plugins/grafana-enterprise-logs-app`

2. Populate the configuration fields:
   - **Access token**: Use the admin token you created in Step 1
   - **Grafana Enterprise Logs URL**: `http://logging-loki-gateway.logging.svc.cluster.local`

3. Click **Enable**

### Create Tenant

1. Navigate to the tenants page:
   `https://grafana.dev.bigbang.mil/a/grafana-enterprise-logs-app?path=tenants`

2. Click **Create Tenant** and configure your new tenant

> **Note**: You can also use the provisioner job to automatically create tenants. Set `enterprise.provisioner.enabled: true` and configure `enterprise.provisioner.additionalTenants` in your values.

### Create Access Policy and Token for Alloy

1. Navigate to access policies:
   `https://grafana.dev.bigbang.mil/a/grafana-enterprise-logs-app?path=access-policies`

2. Create an access policy with the `logs:write` scope, selecting the tenant you created

3. Click **Add Token** on the policy name and save the generated token for Alloy configuration

## Alloy Configuration

BigBang 3.0+ uses Alloy as the default log shipper (replacing the deprecated Promtail). Configure Alloy to authenticate with GEL using basic auth.

Add the following to your BigBang values to configure Alloy for GEL:

```yaml
alloy:
  enabled: true
  values:
    upstream:
      destinations:
        - name: loki
          type: loki
          url: http://logging-loki-gateway.logging.svc.cluster.local:3100/loki/api/v1/push
          auth:
            type: basic
            username: <TENANT_NAME>
            password: <TOKEN>
          extraHeaders:
            X-Scope-OrgID: <TENANT_NAME>
```

Replace `<TENANT_NAME>` with your GEL tenant name and `<TOKEN>` with the token created in the previous step.

> **Migration Note**: If you have existing Promtail configurations, use the Alloy conversion tool:
> ```bash
> alloy convert --source-format=promtail --output=<OUTPUT_CONFIG_PATH> <INPUT_CONFIG_PATH>
> ```
> See [ADR-0004](https://repo1.dso.mil/big-bang/bigbang/-/blob/master/docs/community/adrs/0004-alloy-replacing-promtail.md) for migration details.

## Create Grafana Datasource

1. Navigate to access policies:
   `https://grafana.dev.bigbang.mil/a/grafana-enterprise-logs-app?path=access-policies`

2. Create an access policy and tick the box indicating you intend to create a datasource with this policy (this auto-populates the required `logs:read` scopes)

3. Click **Add Token**, then **Create**, then **Create a datasource** to create a pre-configured Loki datasource

## Values

Complete BigBang values example with GEL, Alloy, and MinIO object storage:

```yaml
monitoring:
  enabled: true
  grafana:
    enterprise:
      enabled: true
      licenseContents: <GEX_LICENSE>

loki:
  enabled: true
  # Options: monolith, scalable, distributed
  strategy: scalable

  values:
    enterprise:
      enabled: true
      cluster_name: <LICENSE_CLUSTER_NAME>
      license:
        contents: <GEL_LICENSE>
      # GEL gateway provides enterprise auth features
      gelGateway: true
      # Admin API for tenant/policy management
      adminApi:
        enabled: true
      # Reference the manually-created admin token secret
      adminToken:
        secret: loki-admin-token
      # Disable tokengen - admin token is created manually (see Step 1)
      tokengen:
        enabled: false
      # Optional: Auto-provision tenants after deployment
      provisioner:
        enabled: false
        # additionalTenants:
        #   - name: mytenant
        #     secretNamespace: logging

    gateway:
      enabled: true

    loki:
      storage:
        type: s3
        s3:
          endpoint: minio.logging.svc.cluster.local
          bucketNames:
            chunks: loki-logs
            ruler: loki-ruler
            admin: loki-admin
          accessKeyId: minio
          secretAccessKey: minio123

    minio:
      enabled: true

    read:
      replicas: 3
    write:
      replicas: 3
    backend:
      replicas: 3

alloy:
  enabled: true
  values:
    alloyLogs:
      enabled: true
    podLogs:
      enabled: true
    # For GEL, override the default destination with auth
    upstream:
      destinations:
        - name: loki
          type: loki
          url: http://logging-loki-gateway.logging.svc.cluster.local:3100/loki/api/v1/push
          auth:
            type: basic
            username: <TENANT_NAME>
            password: <TOKEN>
          extraHeaders:
            X-Scope-OrgID: <TENANT_NAME>

addons:
  minioOperator:
    enabled: true
```

## Troubleshooting

### Admin Token Secret Missing

The admin token must be created manually before deploying GEL. If you see errors about missing secrets:

```bash
# Verify the secret exists
kubectl get secret loki-admin-token -n logging

# If missing, create it (see Step 1 in Installation)
ADMIN_TOKEN=$(openssl rand -base64 32)
kubectl create secret generic loki-admin-token \
  --namespace logging \
  --from-literal=token="${ADMIN_TOKEN}"
```

### Alloy Not Sending Logs

1. Verify Alloy pods are running:
   ```bash
   kubectl get pods -n alloy
   ```

2. Check Alloy logs for authentication errors:
   ```bash
   kubectl logs -n alloy -l app.kubernetes.io/name=alloy-logs
   ```

3. Verify the tenant name and token are correct in your configuration

### GEL Plugin Not Connecting

1. Verify the GEL gateway service is accessible:
   ```bash
   kubectl get svc -n logging | grep gateway
   ```

2. Test connectivity from within the cluster:
   ```bash
   kubectl run curl-test --rm -it --image=curlimages/curl -- \
     curl -v http://logging-loki-gateway.logging.svc.cluster.local/ready
   ```

### License Issues

Ensure your `cluster_name` exactly matches the cluster name in your GEL license. Check the Loki logs for license validation errors:

```bash
kubectl logs -n logging -l app.kubernetes.io/name=loki | grep -i license
```

## Additional Resources

- [Grafana Enterprise Logs Documentation](https://grafana.com/docs/enterprise-logs/latest/)
- [BigBang Loki Package](https://repo1.dso.mil/big-bang/product/packages/loki)
- [Alloy Migration Guide](https://grafana.com/docs/alloy/latest/set-up/migrate/from-promtail/)
- [ADR-0004: Alloy Replacing Promtail](https://repo1.dso.mil/big-bang/bigbang/-/blob/master/docs/community/adrs/0004-alloy-replacing-promtail.md)