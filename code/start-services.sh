# /bin/bash

. conf/env.conf
 

avn --auth-token $TOKEN                     \
    service create demo-kafka               \
    --service-type kafka                    \
    --cloud google-europe-west3             \
    --plan business-4                       \
    --project $PROJECT_NAME                 \
    -c kafka_rest=true                      \
    -c kafka_connect=true                   \
    -c schema_registry=true                 \
    -c kafka.auto_create_topics_enable=true 

avn --auth-token $TOKEN                     \
    service user-creds-download demo-kafka  \
    --project $PROJECT_NAME                 \
    --username avnadmin                     \
    -d certs

avn --auth-token $TOKEN                             \
    service wait demo-kafka                         \
    --project $PROJECT_NAME                         \

avn --auth-token $TOKEN                             \
    service topic-create demo-kafka pizza-orders    \
    --project $PROJECT_NAME                         \
    --replication 3                                 \
    --partitions 2


HOST=$(avn --auth-token $TOKEN service get demo-kafka --project $PROJECT_NAME --json | jq -r '.components[] | select( .component=="kafka").host')
PORT=$(avn --auth-token $TOKEN service get demo-kafka --project $PROJECT_NAME --json | jq -r '.components[] | select( .component=="kafka").port')

echo "HOST=\"$HOST\"" >  code/kafkaEndpointConf.py
echo "PORT=$PORT" >> code/kafkaEndpointConf.py
