#!/usr/bin/env bash
. local/config.txt

docker stop $containername-work >/dev/null
docker rm $containername-work >/dev/null
