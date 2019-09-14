#!/bin/sh
if [ -e SPARK_INSTALLED ]; then
  echo "SPARK is already installed."
  exit
fi

echo '----- Update system -----'
apt-get update
apt-get -y upgrade

echo '----- Setup NTP ----'
cat <<EOF > /etc/systemd/timesyncd.conf
[Time]
NTP=metadata.google.internal
EOF
systemctl daemon-reload
systemctl enable systemd-timesyncd
systemctl start systemd-timesyncd

echo '----- Install Java -----'
apt-get install -y openjdk-8-jdk

echo '----- Install Python -----'
apt-get install -y python3-pip python3-dev
apt-get install -y python-pip python-dev
## Use the latest PIP
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py
python3 -m pip install pyspark

echo '----- Install Spark -----'
cd /tmp
wget http://apache.cs.utah.edu/spark/${SPARK_VERSION}/${SPARK_VERSION}-bin-hadoop2.7.tgz
tar xvzf ${SPARK_VERSION}-bin-hadoop2.7.tgz
rm ${SPARK_VERSION}-bin-hadoop2.7.tgz
mkdir -p ${SPARK_HOME}
mv ${SPARK_VERSION}-bin-hadoop2.7/* ${SPARK_HOME}/

# Change owner and add full access
chown ${SPARK_USER} -R ${SPARK_HOME}
chmod 755 -R ${SPARK_HOME}

# Prevent next execution
echo "This is a flag file to prevent repeated installation." > SPARK_INSTALLED
