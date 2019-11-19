#!/bin/bash
docker run\
    --mount type=bind,source=$(pwd)/config,target=/config\
    --network=host\
    -it honeytrap