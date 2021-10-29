# Loki

## Overview

This package contains an extensible and configurable installation of Grafana Loki based on the upstream chart provided by grafana.

## Loki

[Loki](https://grafana.com/oss/loki/) is a horizontally-scalable, highly-available, multi-tenant log aggregation system inspired by Prometheus. It is designed to be very cost effective and easy to operate. It does not index the contents of the logs, but rather a set of labels for each log stream. Loki is like Prometheus, but for logs: we prefer a multidimensional label-based approach to indexing, and want a single-binary, easy to operate system with no dependencies. Loki differs from Prometheus by focusing on logs instead of metrics, and delivering logs via push, instead of pull.

## How it works

Loki is the main server in the PLG stack, responsible for storing logs and processing queries. The other items in the PLG stack are Promtail: the agent, responsible for gathering logs and sending them to Loki; and Grafana: the frontend, for querying and displaying the logs. Loki also can accept log streams and is a supported output from fluent-bit.
