# Loki in Production

This chart and the upstream Loki chart have `persistence.enabled=false` though the default storage schema is a local `boltdb_shipper` because their recommendations for production recommendations are to make use of options available from your cloud storage provider. Please review the following doc for values to update or insert to point your Loki installation to object or key-value-DB storage which will also allow for the number of `replicas` to be increased above 1.

https://grafana.com/docs/loki/latest/configuration/examples
