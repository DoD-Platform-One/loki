# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
