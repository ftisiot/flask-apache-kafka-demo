# /bin/bash

. conf/env.conf
 

avn --auth-token $TOKEN                     \
    service terminate demo-kafka --force    \
    --project $PROJECT_NAME

avn --auth-token $TOKEN                          \
    service terminate demo-opensearch --force    \
    --project $PROJECT_NAME