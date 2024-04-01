#!/bin/bash
. local/config.txt
# if ! test -d context/opt; then
#   bin/download-tomcat.sh
# fi
docker image build --progress=plain -t $imagename context
