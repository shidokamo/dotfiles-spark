SPARK_HOME    := /opt/spark
SPARK_VERSION := spark-2.4.4
WORKERS       := w0 w1 w2

# Create VMs (assuming that key file already exists)
workers:${WORKERS}
${WORKERS}:
	./create-vm.sh $@
	gcloud compute scp ~/.ssh/id_rsa.pub $@:~/.ssh/authorized_keys
	gcloud compute scp --recurse conf $@:${SPARK_HOME}

# Update config
.PHONY:config
config:config-master
config-master:
	echo ${WORKERS} | sed 's/\s\+/\n/' > ${SPARK_HOME}/conf/slave
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

