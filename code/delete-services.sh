# /bin/bash

. conf/env.conf
 

avn --auth-token $TOKEN                     \
    service terminate demo-flask-kafka --force    \
    --project $PROJECT_NAME

avn --auth-token $TOKEN                          \
    service terminate demo-flask-opensearch --force    \
    --project $PROJECT_NAME