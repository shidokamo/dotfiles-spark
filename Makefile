SPARK_HOME    := /opt/spark
SPARK_VERSION := spark-2.4.4
STARTUP_SCRIPT := $(abspath ./startup-script.sh)
export
WORKERS       := w0

# Create VMs (assuming that key file already exists)
workers:${WORKERS}
${WORKERS}:
	./create-vm.sh $@
	gcloud compute scp ~/.ssh/id_rsa.pub $@:~/.ssh/authorized_keys

# Update config
config-master:
	echo ${WORKERS} | sed 's/\s\+/\n/' > ${SPARK_HOME}/conf/slave
	echo "localhost" >> ${SPARK_HOME}/conf/slave
	cp conf/* ${SPARK_HOME}/conf/
config-slave:
	# Copy config files to workers
	for i in ${WORKERS}; do gcloud compute scp --recurse conf $$i:${SPARK_HOME}; done

# Run clusterj
start-cluster:config-slave config-master
	${SPARK_HOME}/bin/start-master.sh
	${SPARK_HOME}/bin/start-slave.sh

# Install Spark to master
install:
	${STARTUP_SCRIPT}
