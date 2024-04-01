#!/bin/bash
. local/config.txt
docker image build --no-cache --progress=plain -t $imagename context
