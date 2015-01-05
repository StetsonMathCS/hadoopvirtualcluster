#!/bin/sh

NAMENODEIP=$1
RESOURCEMANAGERIP=$2
MRJOBHISTORYIP=$3
JAVA_HOME=$4
LOGDIR=$5
DATADIR=$6

cd /vagrant

for f in `ls local-hadoop-etc`;
do
        sed "s/___NAMENODEIP___/$NAMENODEIP/g" < ./local-hadoop-etc/$f | \
        sed "s/___RESOURCEMANAGERIP___/$RESOURCEMANAGERIP/g" | \
        sed "s/___MRJOBHISTORYIP___/$MRJOBHISTORYIP/g" | \
        sed "s!___JAVA_HOME___!$JAVA_HOME!g" | \
        sed "s!___LOGDIR___!$LOGDIR!g" | \
        sed "s!___DATADIR___!$DATADIR!g" \
        > /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/$f
done

