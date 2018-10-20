#!/bin/sh

docker build . -t gtexslte-builder
mkdir -p $(pwd)/work
docker run -v $(pwd)/work:/home/android/lineage -w /home/android/lineage -it gtexslte-builder /bin/bash