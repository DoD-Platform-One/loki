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

