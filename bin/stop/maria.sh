#!/usr/bin/env bash
. local/config.txt

docker stop $containername-data >/dev/null
docker rm $containername-data >/dev/null
