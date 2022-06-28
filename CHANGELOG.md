# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
