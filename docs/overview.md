# Loki

## Overview

This package contains an extensible and configurable abstract installation of Grafana Loki based on the [upstream chart](https://github.com/grafana/loki/tree/main/production/helm/loki) provided by grafana.

## Loki

[Loki](https://grafana.com/oss/loki/) is a horizontally-scalable, highly-available, multi-tenant log aggregation system inspired by Prometheus. It is designed to be very cost effective and easy to operate. It does not index the contents of the logs, but rather a set of labels for each log stream. Loki is like Prometheus, but for logs: we prefer a multidimensional label-based approach to indexing, and want a single-binary, easy to operate system with no dependencies. Loki differs from Prometheus by focusing on logs instead of metrics, and delivering logs via push, instead of pull.

## How it works

Loki is the main server in the ALG stack, responsible for storing logs and processing queries. The other items in the ALG stack are Alloy: the agent, responsible for gathering logs and sending them to Loki; and Grafana: the frontend, for querying and displaying the logs. Loki also can accept log streams and is a supported output from fluent-bit. Loki operates in a reverse pattern to Elasticsearch (ECK), where logs are tagged and ingested immediately and only processed and indexed when searched and gathered for a query, making it more of a lightweight alternative.

**- NOTE:** You may still often see the acronym "PLG"(Promtail, Loki, Grafana) - However Grafana has deprecated Promtail in favor of Alloy.

## Deployment Modes

Loki can be deployed through the provided helm chart with one of three architectures: Monolithic, Simple Scalable, or Microservices.

These modes can be configured through the `.Values.loki.strategy` key:

```yaml
loki:
  strategy: "scalable"  # Options: "monolithic", "scalable", "distributed"
```

### Monolithic Mode (Default)

**Architecture:** All Loki components run within a single pod.

**Object Storage:** Not required

**Use Cases:**

- Getting started with Loki quickly
- Development and testing environments
- Small-scale deployments (<1000 logs/second)
- Single-node environments

Monolithic mode has a simple setup, minimal resource overhead, but has limited scalability, and single point of failure

### Simple Scalable Mode

**Architecture:**  Loki components are combined into read, write, and backend pods.

**Object Storage:** Required

**Use Cases:**

- Production workloads with moderate to high log volumes
- Environments requiring horizontal scaling
- Balanced complexity vs. performance requirements

Simple Scalable is the recommended configuration provided by the chart and what Big Bang tests with by default. This architecture is considered to be a good balance between monolithic and microservices modes, allowing easier scalability without adding too much additional complexity.


### Microservices Mode (Distributed)

**Architecture:** Each Loki component runs as a separate pod (ingester, distributor, querier, query-frontend, etc.).

**Object Storage:** Required

**Use Cases:**

- Large-scale, high-throughput environments
- Scenarios requiring fine-grained scaling of individual components
- Advanced users comfortable with complex architectures

Distributed mode provides fine-grain scalability and component-level control, however has increased operational complexity, and more resource overhead.

**⚠️ WARNING:** Microservices mode has limited support from Big Bang and is not recommended for production use without thorough testing and operational expertise. Due to the experimental nature of this mode, an additional value is required to allow the enabling of this architecture `.Values.loki.values.experimentalMode.enabled`

```yaml
loki:
  strategy: distributed
  values:
    experimentalMode:
      enabled: true
```
