FROM openjdk:8u111-jdk
MAINTAINER Mike Trepanier michael.p.trepanier@gmail.com

RUN apt-get update --fix-missing && apt-get install -y \
    ca-certificates \
    cmake \
    g++ \
    git \
    libc6-compat \
    wget

ENV SPARK_HOME=/usr/spark/spark-2.1.0-bin-hadoop2.7 \
    HAIL_HOME=/usr/hail \
    PATH=/opt/conda/bin:$PATH:/usr/spark/spark-2.1.0-bin-hadoop2.7/bin:/usr/hail/build/install/hail/bin/

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda2-4.1.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    pip install lxml && \
    pip install py4j && \
    pip install jupyter-spark

RUN mkdir /usr/spark && \
    curl -sL --retry 3 \
    "https://archive.apache.org/dist/spark/spark-2.1.0/spark-2.1.0-bin-hadoop2.7.tgz" \
    | gzip -d \
    | tar x -C /usr/spark && \
    chown -R root:root $SPARK_HOME

RUN wget -P /usr/ https://storage.googleapis.com/hail-common/distributions/hail-0.1-latest-spark2.1.0.zip && \
	unzip /usr/Hail-0.1-20613ed50c74-Spark-2.1.0.zip -d /usr && \
	zip -r /usr/hail/python/pyhail.zip /usr/hail/python/hail

RUN mkdir /opt/conda/share/jupyter/kernels/ && \
	mkdir /opt/conda/share/jupyter/kernels/hail && \
	echo '{"display_name": "Hail", "language": "python", "argv": ["/opt/conda/bin/python", "-m", "ipykernel", "-f", "{connection_file}"], "env": {"SPARK_HOME": "/usr/lib/spark/", "PYTHONHASHSEED": "0", "SPARK_CONF_DIR": "/usr/hail/conf/", "PYTHONPATH": "/usr/spark/spark-2.1.0-bin-hadoop2.7/python/:/usr/spark/spark-2.1.0-bin-hadoop2.7/python/lib/py4j-0.10.3-src.zip:/usr/hail/python/pyhail.zip"}}' > /opt/conda/share/jupyter/kernels/hail/kernel.json

