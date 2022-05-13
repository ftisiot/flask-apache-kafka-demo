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
    service create demo-opensearch          \
    --service-type opensearch               \
    --cloud google-europe-west3             \
    --plan business-4                       \
    --project $PROJECT_NAME                 

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

HOST_OS=$(avn --auth-token $TOKEN service get demo-opensearch --project $PROJECT_NAME --json | jq -r '.components[] | select( .component=="opensearch").host')
PORT_OS=$(avn --auth-token $TOKEN service get demo-opensearch --project $PROJECT_NAME --json | jq -r '.components[] | select( .component=="opensearch").port')
PWD_OS=$(avn --auth-token $TOKEN service get demo-opensearch --project $PROJECT_NAME --json | jq -r '.users[] | select(.username="avnadmin").password')

echo """
{
    \"name\": \"test-sink-connector\",
    \"connector.class\": \"io.aiven.kafka.connect.opensearch.OpensearchSinkConnector\",
    \"topics\": \"pizza-orders\",
    \"key.converter\": \"org.apache.kafka.connect.storage.StringConverter\",
    \"value.converter\": \"org.apache.kafka.connect.json.JsonConverter\",
    \"value.converter.schemas.enable\": \"false\",
    \"schema.ignore\": \"true\",
    \"connection.url\": \"https://$HOST_OS:$PORT_OS\",
    \"connection.username\": \"avnadmin\",
    \"connection.password\": \"$PWD_OS\",
    \"type.name\": \"pizza1\",
    \"transforms\": \"InsertMessageTime,ConvertTimeValue,ValueToKey,extractString\",
    \"transforms.InsertMessageTime.type\":\"org.apache.kafka.connect.transforms.InsertField$Value\",
    \"transforms.InsertMessageTime.timestamp.field\":\"timestamp\",
    \"transforms.ConvertTimeValue.format\": \"yyyy/MM/dd HH:mm:ss\",
    \"transforms.ConvertTimeValue.type\": \"org.apache.kafka.connect.transforms.TimestampConverter$Value\",
    \"transforms.ConvertTimeValue.field\": \"timestamp\",
    \"transforms.ConvertTimeValue.target.type\": \"string\",
    \"transforms.ValueToKey.type\": \"org.apache.kafka.connect.transforms.ValueToKey\",
    \"transforms.ValueToKey.fields\": \"timestamp\",
    \"transforms.extractString.type\": \"org.apache.kafka.connect.transforms.ExtractField$Key\",
    \"transforms.extractString.field\": \"timestamp\"
}
""" > code/opensearch_sink.json

