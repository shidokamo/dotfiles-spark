#!/bin/sh
PROJECT=$(gcloud config get-value project)

INSTANCE_NAME=${1:?Please specify instance name}
MACHINE=${MACHINE:-n1-highcpu-2}
IMAGE_PROJECT=${IMAGE_FAMILY:-ubuntu-os-cloud}
IMAGE_FAMILY=${IMAGE_FAMILY:-ubuntu-1804-lts}
DISK_SIZE=${DISK_SIZE:-100}
DISK_TYPE=${DISK_TYPE:-pd-standard}
SERVICE_ACCOUNT=${SERVICE_ACCOUNT:-owner-service@${PROJECT}.iam.gserviceaccount.com}

SPARK_VERSION=${SPARK_VERSION:-spark-2.4.4}
SPARK_HOME=${SPARK_HOME:-/opt/spark}

STARTUP_SCRIPT="
  #!/bin/sh
  ## System
  apt-get update
  apt-get -y upgrade

  ## NTP
  cat <<EOF > /etc/systemd/timesyncd.conf
  [Time]
  NTP=metadata.google.internal
  EOF
  systemctl daemon-reload
  systemctl enable systemd-timesyncd
  systemctl start systemd-timesyncd

  ## Java
  apt-get install -y openjdk-8-jdk

  ## Spark
  wget http://apache.cs.utah.edu/spark/${SPARK_VERSION}/${SPARK_VERSION}-bin-hadoop2.7.tgz
  tar xvzf ${SPARK_VERSION}-bin-hadoop2.7.tgz
  rm ${SPARK_VERSION}-bin-hadoop2.7.tgz
  mkdir -p /opt
  mv ${SPARK_VERSION}-bin-hadoop2.7 ${SPARK_HOME}

  # Change owner and add full access
  chown ${USER} -R /opt/spark
  chmod 755 -R /opt/spark
"

gcloud compute instances create \
  ${INSTANCE_NAME} \
  --machine-type ${MACHINE} \
  --service-account ${SERVICE_ACCOUNT} \
  --image-project ${IMAGE_PROJECT} \
  --image-family ${IMAGE_FAMILY} \
  --boot-disk-size ${DISK_SIZE} \
  --boot-disk-type ${DISK_TYPE} \
  --metadata startup-script="${STARTUP_SCRIPT}"

