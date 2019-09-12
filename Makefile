SPARK_HOME    := /opt/spark
SPARK_VERSION := spark-2.4.4
STARTUP_SCRIPT := $(abspath ./startup-script.sh)
export
WORKERS       := w0 w1 w2

# Create VMs (assuming that key file already exists)
workers:${WORKERS}
${WORKERS}:
	./create-vm.sh $@
	gcloud compute scp ~/.ssh/id_rsa.pub $@:~/.ssh/authorized_keys

# Update config
config-master:
	echo ${WORKERS} | sed 's/\s\+/\n/' > ${SPARK_HOME}/conf/slave
	cp config/* ${SPARK_HOME}/conf/
config-slave:
	# Copy config files to workers
	for i in ${WORKERS}; do gcloud compute scp --recurse conf $$i:${SPARK_HOME}; done

# Run clusterj
start-cluster:config-slave config-master
	${SPARK_HOME}/bin/start-master.sh
	${SPARK_HOME}/bin/start-slave.sh

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

