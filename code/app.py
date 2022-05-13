# app.py

from kafkaEndpointConf import *
from flask import Flask, request, render_template
import json
from flask import Response
from flask_cors import CORS
from kafka import KafkaConsumer, KafkaProducer
import time

TOPIC_NAME = "pizza-orders"
TOPIC_DELIVERY_NAME = "pizza-delivery"
KAFKA_SERVER = HOST +":" +str(PORT)
CERTS_FOLDER = "certs"
CONSUMER_GROUP = "pizza-consumers"
CONSUMER_GROUP_DELIVERY = "pizza-consumers"
CONSUMER_GROUP_CALC = "pizza-calculators"


producer = KafkaProducer(
    bootstrap_servers=KAFKA_SERVER,
    security_protocol="SSL",
    ssl_cafile = CERTS_FOLDER+"/ca.pem",
    ssl_certfile = CERTS_FOLDER+"/service.cert",
    ssl_keyfile = CERTS_FOLDER+"/service.key",
    value_serializer=lambda v: json.dumps(v).encode('ascii'),
    key_serializer=lambda v: json.dumps(v).encode('ascii')
)

app = Flask(__name__, template_folder='templates')

@app.route('/', methods=['GET', 'POST'])
def index():

    if request.method == 'POST':
        producer.send(
            TOPIC_NAME,
            key={"caller":request.form.get("caller")},
            value={"caller":request.form.get("caller"), "pizza":request.form.get("pizza"),"address":request.form.get("address"), "timestamp": int(time.time())}
            )

        producer.flush()   
    elif request.method == 'GET':
        return render_template('index.html', form=request.form)
    
    return render_template("index.html")

    


@app.route('/pizza-makers')
def consume():
    consumer = KafkaConsumer(
        client_id = "client1",
        group_id = CONSUMER_GROUP,
        bootstrap_servers = KAFKA_SERVER,
        security_protocol = "SSL",
        ssl_cafile = CERTS_FOLDER+"/ca.pem",
        ssl_certfile = CERTS_FOLDER+"/service.cert",
        ssl_keyfile = CERTS_FOLDER+"/service.key",
        value_deserializer = lambda v: json.loads(v.decode('ascii')),
        key_deserializer = lambda v: json.loads(v.decode('ascii')),
        max_poll_records = 10,
        auto_offset_reset='earliest',
        session_timeout_ms=6000,
        heartbeat_interval_ms=3000
    )
    consumer.subscribe(topics=[TOPIC_NAME])
    def consume_msg():
        for message in consumer:
            print(message.value)
            yield [message.value["timestamp"], message.value["caller"],message.value["pizza"], message.value["address"], 1]
        
    return Response(stream_template('pizza-makers.html', data=consume_msg()))

@app.route('/pizza-calc')
def consumeCalc():
    consumerCalc = KafkaConsumer(
        client_id = "client3",
        group_id = CONSUMER_GROUP_CALC,
        bootstrap_servers = KAFKA_SERVER,
        security_protocol = "SSL",
        ssl_cafile = CERTS_FOLDER+"/ca.pem",
        ssl_certfile = CERTS_FOLDER+"/service.cert",
        ssl_keyfile = CERTS_FOLDER+"/service.key",
        value_deserializer = lambda v: json.loads(v.decode('ascii')),
        key_deserializer = lambda v: json.loads(v.decode('ascii')),
        max_poll_records = 10,
        auto_offset_reset='earliest',
        session_timeout_ms=6000,
        heartbeat_interval_ms=3000
    )
    consumerCalc.subscribe(topics=[TOPIC_NAME])
    def consume_msg():
        for message in consumerCalc:
            print(message.value)
            yield [message.value["timestamp"], message.value["caller"],message.value["pizza"], message.value["address"], 1]
        
    return Response(stream_template('pizza-calculators.html', data=consume_msg()))

@app.route('/pizza-delivery')
def consumeDelivery():
    consumerDelivery = KafkaConsumer(
        client_id = "clientDelivery",
        group_id = CONSUMER_GROUP_DELIVERY,
        bootstrap_servers = KAFKA_SERVER,
        security_protocol = "SSL",
        ssl_cafile = CERTS_FOLDER+"/ca.pem",
        ssl_certfile = CERTS_FOLDER+"/service.cert",
        ssl_keyfile = CERTS_FOLDER+"/service.key",
        value_deserializer = lambda v: json.loads(v.decode('ascii')),
        key_deserializer = lambda v: json.loads(v.decode('ascii')),
        max_poll_records = 10,
        auto_offset_reset='earliest',
        session_timeout_ms=6000,
        heartbeat_interval_ms=3000
    )
    consumerDelivery.subscribe(topics=[TOPIC_DELIVERY_NAME])
    def consume_msg_delivery():
        for message in consumerDelivery:
            print(message.value)
            yield [message.key["timestamp"], message.value["caller"], message.value["address"]]
        
    return Response(stream_template('pizza-delivery.html', data=consume_msg_delivery()))



@app.route('/pizza-ready/<id>', methods=['POST'])
def pizzaReady(id=None):
    print(id)
    producer.send(
        TOPIC_DELIVERY_NAME,
        key={"timestamp":id},
        value=request.json
        )
    producer.flush()
    return "OK" 

def stream_template(template_name, **context):
    app.update_template_context(context)
    t = app.jinja_env.get_template(template_name)
    rv = t.stream(context)
    return rv

if __name__ == "__main__":
    app.run(debug=True, port = 5000)
