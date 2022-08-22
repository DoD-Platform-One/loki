#!/bin/bash
set -ex

attempt_counter=0
max_attempts=25
until [ $(mc --config-dir /test config host add bigbang ${MINIO_HOST}$(if [ -n "${MINIO_PORT}" ] ; then echo ":";fi)${MINIO_PORT} ${ACCESS_KEY} ${SECRET_KEY} >/dev/null; echo $?) -eq 0 ]; do
  if [ ${attempt_counter} -eq ${max_attempts} ];then
    echo "Max attempts reached"
    exit 1
  fi
  attempt_counter=$(($attempt_counter+1))
  sleep 10
done
# cleanup from pervious runs
mc --config-dir /test rb bigbang/foobar --force || true
mc --config-dir /test mb bigbang/foobar
mc --config-dir /test ls bigbang/foobar
base64 /dev/urandom | head -c 10000000 > /test/file.txt
md5sum /test/file.txt > /test/filesig
mc --config-dir /test cp /test/file.txt bigbang/foobar/file.txt
mc --config-dir /test ls bigbang/foobar/file.txt
mc --config-dir /test cp bigbang/foobar/file.txt /test/file.txt
mc --config-dir /test rb bigbang/foobar --force
md5sum -c /test/filesig
