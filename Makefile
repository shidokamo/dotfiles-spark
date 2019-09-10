SPARK_HOME    := /opt/spark
SPARK_VERSION := spark-2.4.4

# Update config
.PHONY:config
config:
	cp config/* ${SPARK_HOME}/conf/

# Install
install:install-jdk install-spark
install-jdk:
	apt-get install -y openjdk-8-jdk
install-spark:
	wget http://apache.cs.utah.edu/spark/${SPARK_VERSION}/${SPARK_VERSION}-bin-hadoop2.7.tgz
	tar xvzf ${SPARK_VERSION}-bin-hadoop2.7.tgz
	rm ${SPARK_VERSION}-bin-hadoop2.7.tgz
	mkdir -p /opt
	mv ${SPARK_VERSION}-bin-hadoop2.7 ${SPARK_HOME}

