Apache Kafka® on Flask
======================
This repo contains a demo Flask app using Apache Kafka as backend

Overview
========

Features
============

Setup
============

1. Create a virtual environment

```
python3 -m venv kafka-flask
source kafka-flask/bin/activate
```

2. Install the required dependencies

```
pip install -r requirements.txt
```

3. Copy the `env.conf.example` to `env.conf` and customize the parameters for `TOKEN` and `PROJECT_NAME`

4. Create Aiven for Apache Kafka (requires [jq](https://stedolan.github.io/jq/) to be installed)

```
code/start-services.sh
```

This code will create:
    * An Aiven for Apache Kafka service named `demo-kafka` in the project passed as parameter
    * A local folder called `certs` containing the required SSL certificate files required for the connection
    * An environment file `code/kafka-endpoint-conf.py` containing the Aiven for Apache Kafka service endpoints


License
============
Apache Kafka® on Flask is licensed under the Apache license, version 2.0. Full license text is available in the [LICENSE](LICENSE) file.

Please note that the project explicitly does not require a CLA (Contributor License Agreement) from its contributors.

Contact
============
Bug reports and patches are very welcome, please post them as GitHub issues and pull requests at https://github.com/ftisiot/flask-apache-kafka-demo. 
To report any possible vulnerabilities or other serious issues please see our [security](SECURITY.md) policy.
