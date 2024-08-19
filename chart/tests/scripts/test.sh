#!/bin/bash

set -e

loki_timeout=$((6*60))
echo "Hitting loki /ready endpoint..."
time curl --retry-delay 2 --retry-max-time ${loki_timeout} --retry $((loki_timeout/2)) --retry-connrefused -sIS "${LOKI_URL}/ready" 1>/dev/null || loki_ec=$?
# time output shows up a bit after the next two echoes, sleep for formatting
sleep .1
if [ -n "${loki_ec}" ]; then
  echo "curl returned exit code ${loki_ec}, see above for error message and curl's elapsed wait time (timeout is ${loki_timeout}s)"
  exit 1
fi
echo "Test 1 Success: loki is up, see above for curl's elapsed wait time."

echo "Hitting loki /metrics endpoint..."
time curl --retry-delay 2 --retry-max-time ${loki_timeout} --retry $((loki_timeout/2)) --retry-connrefused -sIS "${LOKI_URL}/metrics" 1>/dev/null || loki_ec=$?
# time output shows up a bit after the next two echoes, sleep for formatting
sleep .1
if [ -n "${loki_ec}" ]; then
  echo "curl returned exit code ${loki_ec}, see above for error message and curl's elapsed wait time (timeout is ${loki_timeout}s)"
  exit 1
fi
echo "Test 2 Success: loki metrics endpoint returned "

## This test might be good for extending to check appVersion etc
echo "Hitting loki /loki/api/v1/status/buildinfo endpoint..."
time curl --retry-delay 2 --retry-max-time ${loki_timeout} --retry $((loki_timeout/2)) --retry-connrefused -sIS "${LOKI_URL}/loki/api/v1/status/buildinfo" 1>/dev/null || loki_ec=$?
# time output shows up a bit after the next two echoes, sleep for formatting
sleep .1
if [ -n "${loki_ec}" ]; then
  echo "curl returned exit code ${loki_ec}, see above for error message and curl's elapsed wait time (timeout is ${loki_timeout}s)"
  exit 1
fi
echo "Test 3 Success: loki buildinfo endpoint returned "

echo "Checking for loki version"
loki_response=$(curl "${LOKI_URL}/loki/api/v1/status/buildinfo" 2>/dev/null)
current_version=$(echo ${loki_response} | jq -r '.version')
if [ ! "${LOKI_VERSION}" == "${current_version}" ]; then
  arrLOKI_VERSION=(${LOKI_VERSION//./ })
  regex_pattern="(^HEAD|release-)${arrLOKI_VERSION[0]}.${arrLOKI_VERSION[1]}.*"
  if [[ "${current_version}" =~ $regex_pattern ]]; then
    echo "WARNING Loki buildinfo returning pre-release version"
    exit 0
  fi
  echo "Test 4 Failure: Loki version does not match."
  echo "Debug information (deployed build info):"
  echo "${loki_response}"
  echo "/${LOKI_VERSION}/${current_version}/"
  exit 1
fi

echo "Test 4 Success: Loki version matches expected version"
