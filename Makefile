SPARK_HOME    := /opt/spark
SPARK_VERSION := spark-2.4.4
STARTUP_SCRIPT := $(abspath ./startup-script.sh)
SPARK_USER    := ${USER}
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
	ssh ${USER}@localhost echo "Login test" || cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
	cp conf/* ${SPARK_HOME}/conf/
config-slave:
	# Copy config files to workers
	for i in ${WORKERS}; do gcloud compute scp --recurse conf $$i:${SPARK_HOME}; done

# Run clusterj
start-cluster:stop-cluster config-slave config-master
	${SPARK_HOME}/sbin/start-master.sh
	${SPARK_HOME}/sbin/start-slaves.sh
stop-cluster:
	-${SPARK_HOME}/sbin/stop-slaves.sh
	-${SPARK_HOME}/sbin/stop-master.sh

# Simple test
test:
	# cd ${SPARK_HOME} && ./bin/pyspark
	${SPARK_HOME}/bin/spark-submit \
		--master spark://localhost:7077 \
		${SPARK_HOME}/examples/src/main/python/pi.py 1000

# Install Spark to master
install:
	sudo -E ${STARTUP_SCRIPT}
uninstall:
	-sudo rm -rf ${SPARK_HOME}
