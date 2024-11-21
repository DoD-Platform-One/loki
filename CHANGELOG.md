# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [6.18.0-bb.2] - 2024-11-19

### Changed

- Modified cypress test `id` field value to accommodate latest Grafana updates.

## [6.18.0-bb.1] - 2024-11-06

### Changed

- Now setting `istio.loki.enabled` to `false` by default

## [6.18.0-bb.0] - 2024-10-18

### Updated

- Updated `loki` from `v3.1.1` -> `v3.2.0`
- Updated `gluon` from `0.5.4` -> `0.5.8`
- Updated `k8s-sidecar` from `1.27.5` -> `1.28.0`
- Updated `kubectl` from `v1.29.8` -> `v1.30.5`
- Updated `memcached` from `1.6.30` -> `1.6.31`
- Updated `nginx` from `1.26.2` -> `1.27.2`

## [6.12.0-bb.7] - 2024-10-07

### Changed

- Updated hardcoded minio matchLabels

## [6.12.0-bb.6] - 2024-10-7

### Changed

- Modify loki-cypress-test to increase timeout and retry, while adding a skip logic for grafana login

## [6.12.0-bb.5] - 2024-09-24

### Changed

- Give grafana an extra minute to check for loki datasource connection in cypress testing

## [6.12.0-bb.4] - 2024-09-18

### Fixed

- Fixed cypress formatting/phrasing

## [6.12.0-bb.3] - 2024-09-18

### Fixed

- Fixed dashboard regular expressions for new grafana format

## [6.12.0-bb.2] - 2024-09-18

### Fixed

- Fixed cypress test relating to grafana upgrade

## [6.12.0-bb.1] - 2024-09-12

### Added

- Added a network policy allowing ingress from Grafana Alloy

## [6.12.0-bb.0] - 2024-09-08

### Updated

- Updated `gluon` from `0.5.3` -> `0.5.4`
- Updated `minio-instance` from `5.0.16-bb.0` -> `6.0.2-bb.0`
- Updated `k8s-sidecar` from `1.27.5` -> `1.27.6`
- Updated `kubectl` from `v1.29.7` -> `v1.29.8`
- Updated `memcached` from `1.6.29` -> `1.6.30`
- Updated `nginx` from `1.26.1` -> `1.26.2`

## [6.10.0-bb.0] - 2024-08-14

### Updated

- Updated `loki-canary` from `v3.1.0` -> `v3.1.1`
- Updated `loki` from `v3.1.0` -> `v3.1.1`
- Updated `gluon` from `v0.5.0` -> `v0.5.3`
- Updated `grafana-agent-operator` from `v0.4.0` -> `v0.4.1`

## [6.7.1-bb.2] - 2024-08-12

### Changed

- Pass input pod labels through tpl function

## [6.7.1-bb.1] - 2024-07-19

### Added

- Add support for toggling dashboard sets between deployment strategies

## [6.7.1-bb.0] - 2024-07-19

### Updated

- Updated `loki-canary` from `v3.0.0` -> `v3.1.0`
- Updated `loki` from `v3.0.0` -> `v3.1.0`
- Updated `minio-instance` from `5.0.15-bb.0` -> `5.0.16-bb.0`
- Updated `k8s-sidecar` from `1.27.4` -> `1.27.5`
- Updated `kubectl` from `v1.29.6` -> `v1.29.7`

## [6.6.4-bb.6] - 2024-07-17

### Fixed

- Disable Loki VirtualService by default.

## [6.6.4-bb.5] - 2024-07-17

### Added

- Add support for the deletion of log entries from a specified stream and set retention to forever.

## [6.6.4-bb.4] - 2024-07-16

### Fixed

- Fixed Loki VirtualService for `scalable` and `monolith` deployments

## [6.6.4-bb.3] - 2024-07-15

### Changed

- Consolidated redundant simple/scalable loki peerauth

## [6.6.4-bb.2] - 2024-07-11

### Fixed

- Update retention grafana dashbaord

## [6.6.4-bb.1] - 2024-07-03

### Removed

- Removed shared authPolicies set at the Istio level

## [6.6.4-bb.0] - 2024-07-01

### Updated

- Update `k8s-sidecar` from `1.27.2` -> `1.27.4`
- Update `kubectl` from `v1.29.5` -> `v1.29.6`
- Update `memcached` from `1.6.27` -> `1.6.29`
- Update `nginx` from `1.26.0` -> `1.26.1`

## [6.6.2-bb.7] - 2024-07-01

### Fixed

- Fixed minio pool to use required pool name

## [6.6.2-bb.6] - 2024-06-28

### Fixed

- Cypress intermittent failures fix

## [6.6.2-bb.5] - 2024-06-27

### Fixed

- Removes the `service_name` default label

## [6.6.2-bb.4] - 2024-06-24

### Added

- Cypress retries and wait added to tests

## [6.6.2-bb.3] - 2024-06-13

### Fix

- Synchronize chart with upstream version 6.6.2

## [6.6.2-bb.2] - 2024-06-5

### Fix

- Set from date for `v13` schema to date of bb release

## [6.6.2-bb.1] - 2024-05-29

### Fixed

- Fix Gateway deployment
- Fix VirtualService Routing

## [6.6.2-bb.0] - 2024-05-29

### Upgrade

- Upgraded kiwigrid/k8s-sidecar from 1.27.1 to 1.27.2

## [6.5.2-bb.2] - 2024-05-24

### Fixed

- Added Kyverno Policy values to loki override-values.yaml in the DEVELOPMENT_MAINTENANCE.md

## [6.5.2-bb.1] - 2024-05-20

### Fixed

- Fixed typo in README.md

## [6.5.2-bb.0] - 2024-05-17

### Upgrade

- Updated k8s-sidecar 1.26.1 -> 1.27.1
- Updated kubectl 1.29.3 -> 1.29.5
- Updated memcached 1.6.23 -> 1.6.27
- Updated nginx 1.25.4 -> 1.26.0
- Updated rollout-operator 0.13.0 -> 0.15.0
- Updated grafana-agent-operator 0.3.21 -> 0.3.22

## [6.3.4-bb.0] - 2024-05-14

### Upgrade

- Updated loki 2.9.6 -> 3.0.0
- Updated minio-instance 5.0.12-bb.6 -> 5.0.12-bb.13
- Updated grafana-agent-operator 0.3.19 -> 0.3.20
- Updated gluon 0.4.9 -> 0.5.0
- Added rollout-operator 0.13.0

## [5.47.2-bb.4] - 2024-05-07

### Fixed

- Match minIO chart version to it's pinned image

## [5.47.2-bb.3] - 2024-05-06

### Added

- Disabled anonymous usage statistics

## [5.47.2-bb.2] - 2024-04-04

### Added

- Added custom network policies

## [5.47.2-bb.1] - 2024-04-03

### Added

- Removed matchLabels for allow-intranamespace authorizationPolicy

## [5.47.2-bb.0] - 2024-04-01

### Upgrade

- Updated loki 2.9.4 -> 2.9.6
- Updated minio-instance 5.0.11-bb.3 -> 5.0.12-bb.6
- Updated grafana-agent-operator 0.3.15 -> 0.3.19
- Updated k8s-sidecar 1.25.3 -> 1.26.1
- Updated kubectl v1.28.6 -> v1.28.8
- Updated nginx 1.25.3 -> 1.25.4

## [5.42.0-bb.11] - 2024-03-29

### Added

- Add drop all capabilities to minio

## [5.42.0-bb.10] - 2024-03-11

### Added

- Added workloadSelector for Loki Sidecar

## [5.42.0-bb.9] - 2024-03-05

### Added

- Added Openshift updates for deploying loki into Openshift cluster

## [5.42.0-bb.8] - 2024-02-28

### Added

- Added istio sidecar to set outboundTrafficPolicy to REGISTRY_ONLY
- Added customServiceEntries to explicitly allow egress for external hosts

## [5.42.0-bb.7] - 2024-02-20

### Fixed

- Fixed loki dashboard json UID

## [5.42.0-bb.6] - 2024-02-20

### Added

- Add support for fluentbit AuthPolicies

## [5.42.0-bb.5] - 2024-02-08

### Changed

- Change testing to check for log data

## [5.42.0-bb.4] - 2024-02-06

### Changed

- Added testing to check for log data

## [5.42.0-bb.3] - 2024-02-02

### Changed

- Updated loki to gluon 0.4.8

## [5.42.0-bb.2] - 2024-01-31

### Changed

- Renamed the authorization policies to prevent conflicts in the logging namespace

## [5.42.0-bb.1] - 2024-01-31

### Changed

- Changed loki commonConfig replication_factor to 1 from 3

## [5.42.0-bb.0] - 2024-01-30

### Upgrade

- docker.io/grafana/loki-canary 2.9.3 -> 2.9.4
- ironbank/opensource/grafana/loki 2.9.3 -> 2.9.4
- registry1.dso.mil/ironbank/kiwigrid/k8s-sidecar 1.25.2 -> 1.25.3
- registry1.dso.mil/ironbank/opensource/grafana/loki 2.9.3 -> 2.9.4
- registry1.dso.mil/ironbank/opensource/kubernetes/kubectl v1.28.4 -> v1.28.6

## [5.41.4-bb.5] - 2024-01-18

### Changed

- removed a restriction on the allow-intranet authorization policy

## [5.41.4-bb.3] - 2024-01-17

### Changed

- removed Istio.enabled from test-values

## [5.41.4-bb.2] - 2024-01-16

### Changed

- Istio.enabled as false in test-values

## [5.41.4-bb.2] - 2024-01-12

### Changed

- Enabled istio hardening in tests

## [5.41.4-bb.1] - 2024-1-2

### Added

- Istio virtual service
- network policy for virtual service
- allow-intranamespace policy
- allow-nothing-policy
- ingressgateway-authz-policy
- monitoring-authz-policy
- promtail-authz-policy
- template for adding user defined policies

## [5.41.4-bb.0] - 2023-12-29

### Changed

- loki image 2.9.2 -> 2.9.3

## [5.31.0-bb.10] - 2023-12-04

### Changed

- registry1.dso.mil/ironbank/opensource/kubernetes/kubectl v1.28.3 -> v1.28.4

## [5.31.0-bb.9] - 2023-11-28

### Added

- Updating OSCAL Component file.

## [5.31.0-bb.8] - 2023-11-27

### Added

- `loki.ingester.autoforget_unhealthy: true` set by default for ingester values.

## [5.31.0-bb.7] - 2023-11-20

### Removed

- Removed automounting Service Account Tokens

## [5.31.0-bb.6] - 2023-11-20

### Changed

- Fix a bug where the hardcoded ingester value was overriding kustomize/override values.

## [5.31.0-bb.5] - 2023-11-17

### Changed

- Made Cypress test more verbose

## [5.31.0-bb.4] - 2023-11-07

### Changed

- Updated registry1.dso.mil/ironbank/big-bang/base 2.0.0 -> 2.1.0

## [5.31.0-bb.3] - 2023-11-02

### Removed

- Remove portLevelException

## [5.31.0-bb.2] - 2023-10-31

### Changed

- Service Template changes for all 3 components to force TCP convention for the GRCP gossip ports

## [5.31.0-bb.1] - 2023-10-31

### Changed

- Updated registry1.dso.mil/ironbank/opensource/kubernetes/kubectl v1.28.2 -> v1.28.3
- Updated registry1.dso.mil/ironbank/opensource/nginx/nginx 1.25.2 -> 1.25.3

## [5.31.0-bb.0] - 2023-10-17

### Changed

- Updated docker.io/grafana/loki-canary 2.9.1 -> 2.9.2
- Updated ironbank/opensource/grafana/loki 2.9.1 -> 2.9.2
- Updated registry1.dso.mil/ironbank/opensource/kubernetes/kubectl 1.27.6 -> v1.28.2
- Updated registry1.dso.mil/ironbank/kiwigrid/k8s-sidecar 1.25.1 -> 1.25.2

## [5.23.1-bb.2] - 2023-10-17

### Changed

- Update OSCAL version from 1.0.0 to 1.1.1

## [5.23.1-bb.1] - 2023-10-13

### Added

- Helm validation for backend scaling requirements introduced with loki 2.9.\*

## [5.23.1-bb.0] - 2023-09-29

### Changed

- Updated docker.io/grafana/loki-canary 2.9.0 -> 2.9.1
- Updated ironbank/opensource/grafana/loki 2.9.0 -> 2.9.1
- Updated registry1.dso.mil/ironbank/opensource/kubernetes/kubectl 1.27.5 -> 1.27.6
- Updated registry1.dso.mil/ironbank/kiwigrid/k8s-sidecar 1.22.4 -> 1.25.1
- Updated to latest upstream chart 5.23.1

## [5.21.0-bb.3] - 2023-09-28

### Changed

- Fixed minor bug with cypress tests

## [5.21.0-bb.2] - 2023-09-27

### Changed

- Updated gluon to 0.4.1
- Modified cypress structure to accommodate cypress 13.X+ testing

## [5.21.0-bb.1] - 2023-09-15

### Changed

- Indentation fixes for new rules sidecar YAML

## [5.21.0-bb.0] - 2023-09-14

### Changed

- Updated docker.io/grafana/loki-canary 2.8.4 -> 2.9.0
- Updated ironbank/opensource/grafana/loki 2.8.4 -> 2.9.0
- Updated registry1.dso.mil/ironbank/opensource/grafana/loki 2.8.4 -> 2.9.0

## [5.15.0-bb.0] - 2023-08-30

### Changed

- Updated docker.io/grafana/loki-canary 2.8.3 -> 2.8.4
- Updated ironbank/opensource/grafana/loki 2.8.3 -> 2.8.4
- Updated registry1.dso.mil/ironbank/opensource/grafana/loki 2.8.3 -> 2.8.4
- Updated registry1.dso.mil/ironbank/opensource/kubernetes/kubectl 1.27.4 -> 1.27.5
- Updated registry1.dso.mil/ironbank/opensource/nginx/nginx 1.25.1 -> 1.25.2

## [5.9.2-bb.1] - 2023-08-24

### Changed

- Cypress test locations for datasources in Grafana 10.X

## [5.9.2-bb.0] - 2023-08-03

### Changed

- Updated to latest upstream chart 5.9.2

## [5.8.9-bb.0] - 2023-07-05

### Changed

- Updated to latest upstream chart 5.8.9

## [5.5.0-bb.4] - 2023-06-22

### Changed

- Update grafana-enterprise-logs from v1.6.0 -> v1.7.1
- Update kubectl from v1.26.4 -> 1.27.3
- Update nginx from 1.23.3 -> 1.25.1

## [5.5.0-bb.1] - 2023-06-21

### Changed

- Updated `schema_config` with valid date for tsdb index

## [5.5.0-bb.1] - 2023-05-23

### Changed

- Updated `schema_config` with tsdb index default
- Updated `storage_config` with `tsdb-shipper` default

## [5.5.0-bb.0] - 2023-05-19

### Added

- Updated chart to `helm-loki-5.5.0`
- Update loki from 2.8.0 -> 2.8.2
- Update lokiCanary from 2.8.0 -> 2.8.2

## [5.0.0-bb.4] - 2023-05-15

### Added

- updated cypress test for monitoring package update

## [5.0.0-bb.3] - 2023-05-10

### Added

- Added a networkpolicy for egress from minio to the controlplane

## [5.0.0-bb.2] - 2023-04-19

### Added

- Added `fluentbit` network policy
- Added conditional for `fluentbit` and `promtail` network policies

## [5.0.0-bb.1] - 2023-04-19

### Added

- Updated kubectl versson from 1.26.3 to 1.26.4

## [5.0.0-bb.0] - 2023-04-11

### Added

- Updated chart to `helm-loki-5.0.0`
- Update loki from 2.7.5 -> 2.8.0
- Update lokiCanary from 2.7.5 -> 2.8.0

## [4.10.0-bb.0] - 2023-04-06

### Added

- Updated chart to `helm-loki-4.10.0`
- Update loki from 2.7.4 -> 2.7.5
- Update lokiCanary from 2.7.4 -> 2.7.5
- Update kubectl from 1.26.2 -> 1.26.3

## [4.8.0-bb.2] - 2023-04-03

### Added

- Added ingress policy for promtail -> loki

## [4.8.0-bb.1] - 2023-03-30

### Added

- Add helm test egress policy

## [4.8.0-bb.0] - 2023-03-14

### Changed

- Update loki from 2.7.3 -> 2.7.4
- Update kubectl from 1.26.1 -> 1.26.2
- Update nginx from 1.23.2 -> 1.23.3
- Update minio from 4.5.4-bb.2 -> 4.5.4-bb.3

## [4.4.2-bb.2] - 2023-02-23

### Changed

- Backend, Read, Write PodDisruptionBudget template is now configurable

### Added

- `write|read|backend.podDisruptionBudget` values added to chart

## [4.4.2-bb.1] - 2023-02-22

### Changed

- Update kubectl from 1.25.6 -> 1.26.1

## [4.4.2-bb.0] - 2023-02-07

### Changed

- loki chart major version upgrade from 3.7.0 -> 4.4.2
- Update loki from 2.7.0 -> 2.7.3
- Update kubectl from 1.25.5 -> 1.25.6

## [3.7.0-bb.2] - 2023-02-08

### Fixed

- Fixed image tags in Chart.yaml image annotations

## [3.7.0-bb.1] - 2023-01-17

### Changed

- Update gluon to new registry1 location + latest version (0.3.2)

## [3.7.0-bb.0]

### Changed

- Updated chart to `helm-loki-3.7.0`
- Updated kubectl image to `v1.25.5`

## [3.6.0-bb.0]

### Changed

- Updated chart to `helm-loki-3.6.0`
- Updated minio image to `4.5.4-bb.2`

## [3.3.4-bb.0]

### Changed

- Updated chart to `helm-loki-3.3.4`
- Updated kubectl image to `v1.25.4`
- Updated nginx image to `1.23.2`

## [3.2.1-bb.3]

### Fixed

- Fixed loki monolith peerauthentication labels

## [3.2.1-bb.2]

### Changed

- Updated loki-health cypress configuration to be more resilient to updates and CSS changes.

## [3.2.1-bb.1]

### Changed

- Updated istiod egress NetworkPolicy template to be open podSelector `{}`.

## [3.2.1-bb.0]

### Changed

- Matching chart base to upstream `loki` instead of previous `loki-simple-scalable`
- Updated references of `monolith` to `singleBinary`

## [1.8.10-bb.2]

### Changed

- Re-adding changes that didn't seem to persist from previous update
- Cleaning up NetworkPolicies, kube-api egress isn't required
- gluon 0.3.0 update wooo

## [1.8.10-bb.1]

### Changed

- Enabled servicemonitor/podmonitor for TLS scraping
- removed mTLS exception for metrics port

## [1.8.10-bb.0]

### Changed

- Updating chart to `loki-simple-scalable` `1.8.10` chart base
- Updating loki images to `2.6.1` tag
- Updating monolith `loki` chart to `2.14.1` chart base

## [1.7.6-bb.2]

### Changed

- Updated default containerSecurityContext for monolith

## [1.7.6-bb.1]

### Added

- Added appVersion annotation to Chart.yaml

## [1.7.6-bb.0]

### Changed

- Matching chart base to upstream `loki-simple-scalable` instead of utilizing as sub-chart
- `loki` value updated to `monolith`
- `gel` values migrated to `enterprise` for better native support of Grafana Enterprise Logs

## [4.0.0-bb.0]

### Changed

- Upgraded loki image from `2.5.0` to version `2.6.0`
- Upgraded dependency chart loki from `2.11.1` to `2.13.1`
- Upgraded dependency chart loki-simple-scalable from `0.4.0` to `1.7.5`

## [3.0.5-bb.3]

### Added

- Adds configuration for tolerations on GEL tokengen job

## [3.0.5-bb.3]

### Added

- Grafana Dasboard JSON & ConfigMap template

## [3.0.5-bb.2]

### Changed

- Updated GEL image to 1.4.1

## [3.0.5-bb.1]

### Changed

- Updated bb base image to 2.0.0
- Updated gluon to 0.2.10

## [3.0.5-bb.0]

### Added

- Bumped grafana-enterprise-logs tag to 1.4.0
- Bumped big-bang/base tag to 1.18.0

## [3.0.4-bb.5]

### Added

- Added configuration overrides to the GEL values to allow port configuration on the gateway and admin-api services.

## [3.0.4-bb.4]

### Added

- Added configuration for setting the `kubectl` image

## [3.0.4-bb.3]

### Updated

- Added mTLS exception for GRPC communication

## [3.0.4-bb.2]

### Updated

- Update loki-simple-scalable PeerAuthentication template to use matchLabels

## [3.0.4-bb.1]

### Added

- Added cypress and script testing to the chart
- Added `bbtests` values to the `values.yaml`

## [3.0.4-bb.0]

### Changed

- Updated `chart/` base to upstream chart version `loki-2.11.1`
- Updated Loki image to version `2.5.0`

## [3.0.3-bb.0]

### Changed

- Updated Grafana Enterprise Logs image to use image tag `1.3.0`

## [3.0.2-bb.1]

### Added

- Added OSCAL Component with NIST 800-53 control mapping

## [3.0.2-bb.0]

### Changed

- Updated Grafana Enterprise Logs image to IronBank

## [3.0.1-bb.1]

### Added

- Added default PeerAuthentication to enable STRICT mTLS

## [3.0.1-bb.0]

### Added

- Fixed Network policy to work for both architecture modes

## [3.0.0-bb.0]

### Added

- Added simple-scalable deployment option
- Added Grafana Enterprise Logging support

## [2.5.1-bb.3]

### Added

- added optional scalable deployment for loki

## [2.10.1-bb.4] - 2022-04-04

### Changed

- Corrected Network Policy naming conflict with logging-ek

## [2.10.1-bb.3] - 2022-03-28

### Added

- Added Tempo Zipkin Egress Policy

## [2.10.1-bb.2] - 2022-03-15

### Added

- Documentation for operational/production settings

### Changed

- modified default resource limits/requests

## [2.10.1-bb.1]

### Added

- allow-sidecar-scraping networkpolicy template to allow prometheus to scrape istio-proxy sidecar metrics

## [2.10.1-bb.0]

### Changed

- Updated `chart/` base to upstream chart version `loki-2.10.1`
- Updated Loki image to version `2.4.2`

## [2.5.1-bb.4]

### Changed

- Updated NetworkPolicy to allow Prometheus to query Loki

## [2.5.1-bb.3]

### Changed

- Update Chart.yaml to follow new standardization for release automation

## [2.5.1-bb.2]

### Changed

- Changed a few network policy names to avoid name collisions with the efk installs

## [2.5.1-bb.1]

### Changed

- Changed resources.requests to equal limits

## [2.5.1-bb.0]

### Added

- Initial creation of the chart
- Added BigBang package specific README
- Added NetworkPolicy templates following BigBang outline
- Added gluon dependency to run all related CI
