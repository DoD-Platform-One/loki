# Loki

## Overview

This package contains an extensible and configurable abstract installation of Grafana Loki based on multiple of the upstream charts provided by grafana.

Within this chart we provide the following Grafana charts which are all fully configurable as if they were deploying on their own:
  - [loki-simple-scalable](https://github.com/grafana/helm-charts/tree/main/charts/loki-simple-scalable). For use in medium to large environments where log volume is around the hundreds of gigabytes a day
  - [loki](https://github.com/grafana/helm-charts/tree/main/charts/loki). For use in dev and small environments. This is the "single-binary" installation of Loki and best for use talking to local or in-cluster storage rather than cloud endpoints.
  - [gel](https://github.com/grafana/helm-charts/tree/main/charts/enterprise-logs). Enterprise logs installation of Loki that requires a Grafana Enterprise license and in-cluster or cloud object storage.

## Loki

[Loki](https://grafana.com/oss/loki/) is a horizontally-scalable, highly-available, multi-tenant log aggregation system inspired by Prometheus. It is designed to be very cost effective and easy to operate. It does not index the contents of the logs, but rather a set of labels for each log stream. Loki is like Prometheus, but for logs: we prefer a multidimensional label-based approach to indexing, and want a single-binary, easy to operate system with no dependencies. Loki differs from Prometheus by focusing on logs instead of metrics, and delivering logs via push, instead of pull.

## How it works

Loki is the main server in the PLG stack, responsible for storing logs and processing queries. The other items in the PLG stack are Promtail: the agent, responsible for gathering logs and sending them to Loki; and Grafana: the frontend, for querying and displaying the logs. Loki also can accept log streams and is a supported output from fluent-bit. Loki operates in a reverse pattern to Elasticsearch (ECK), where logs are tagged and ingested immediately and only processed and indexed when searched and gathered for a query, making it more of a lightweight alternative.
