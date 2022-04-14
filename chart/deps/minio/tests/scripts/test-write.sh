#!/bin/bash
set -ex

attempt_counter=0
max_attempts=25
until [ $(mc config host add bigbang ${MINIO_HOST}$(if [ -n "${MINIO_PORT}" ] ; then echo ":";fi)${MINIO_PORT} ${ACCESS_KEY} ${SECRET_KEY} >/dev/null; echo $?) -eq 0 ]; do
  if [ ${attempt_counter} -eq ${max_attempts} ];then
    echo "Max attempts reached"
    exit 1
  fi
  attempt_counter=$(($attempt_counter+1))
  sleep 10
done
# cleanup from pervious runs
mc rb bigbang/foobar --force || true 
mc mb bigbang/foobar
mc ls bigbang/foobar
base64 /dev/urandom | head -c 10000000 > /tmp/file.txt
md5sum /tmp/file.txt > /tmp/filesig
mc cp /tmp/file.txt bigbang/foobar/file.txt
mc ls bigbang/foobar/file.txt
mc cp bigbang/foobar/file.txt /tmp/file.txt
mc rb bigbang/foobar --force
md5sum -c /tmp/filesig
