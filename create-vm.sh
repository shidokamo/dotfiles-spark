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

STARTUP_SCRIPT=${STARTUP_SCRIPT:-startup-script.sh}

# This is required since we can't path environment variable to VM
STARTUP_SCRIPT=$(cat ${STARTUP_SCRIPT} | envsubst)

gcloud compute instances create \
  ${INSTANCE_NAME} \
  --machine-type ${MACHINE} \
  --service-account ${SERVICE_ACCOUNT} \
  --image-project ${IMAGE_PROJECT} \
  --image-family ${IMAGE_FAMILY} \
  --boot-disk-size ${DISK_SIZE} \
  --boot-disk-type ${DISK_TYPE} \
  --metadata startup-script="${STARTUP_SCRIPT}"

