#!/bin/sh

arg1="$1"
shift 1

docker build . -t gtexslte-build
docker run -v work:/home/android/lineage -w /home/android/lineage -it gtexslte-build /bin/bash