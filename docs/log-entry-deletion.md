- Reference: https://grafana.com/docs/loki/latest/operations/storage/logs-deletion/

## Log entry deletion
Grafana Loki supports the deletion of log entries from a specified stream. Log entries that fall within a specified time window and match an optional line filter are those that will be deleted.

Log entry deletion is supported only when TSDB or BoltDB shipper is configured as the index store.

The compactor component exposes REST [endpoints](https://grafana.com/docs/loki/latest/reference/loki-http-api#compactor) that process delete requests. Hitting the endpoint specifies the streams and the time window. The deletion of the log entries takes place after a configurable cancellation time period expires.

Log entry deletion relies on configuration of the custom logs retention workflow as defined for the compactor. The compactor looks at unprocessed requests which are past their cancellation period to decide whether a chunk is to be deleted or not.

- Configuration details are found [here](https://grafana.com/docs/loki/latest/operations/storage/logs-deletion/#configuration)

## How to delete logs for stream within BigBang
- Port-forward the `logging/logging-loki-gateway` nginx container to port 8080
- Shell into the `logging/logging-loki-gateway` nginx container and execute command
`curl -g -X POST 'http://localhost:8080/loki/api/v1/delete?query={container="alertmanager"}&start=1721053200' -H 'X-Scope-OrgID: 1'`
- Check grafana dashboard to see if alertmanager logs are gone