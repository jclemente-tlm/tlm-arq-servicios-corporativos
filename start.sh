# docker run -d --rm -p 8090:8080 \
#     -v $PWD/design:/usr/local/structurizr structurizr/lite

# # docker compose up -d

#! /bin/bash

if [ -z $1 ]; then
    echo "You should provide a file name"
    exit 1
fi

docker run -d --rm -it -p 8090:8080 \
    -e STRUCTURIZR_WORKSPACE_FILENAME=$1 \
    -v ./design:/usr/local/structurizr structurizr/lite
    
