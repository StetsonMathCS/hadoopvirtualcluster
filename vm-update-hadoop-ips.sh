#!/bin/sh

NAMENODEIP=$1
RESOURCEMANAGERIP=$2
NODEMANAGERIP=$3
MRJOBHISTORYIP=$4
JAVA_HOME=$5
LOGDIR=$6
DATADIR=$7

cd /vagrant

for f in `ls local-hadoop-etc`;
do
        sed "s/___NAMENODEIP___/$NAMENODEIP/g" < ./local-hadoop-etc/$f | \
        sed "s/___RESOURCEMANAGERIP___/$RESOURCEMANAGERIP/g" | \
        sed "s/___NODEMANAGERIP___/$NODEMANAGERIP/g" | \
        sed "s/___MRJOBHISTORYIP___/$MRJOBHISTORYIP/g" | \
        sed "s!___JAVA_HOME___!$JAVA_HOME!g" | \
        sed "s!___LOGDIR___!$LOGDIR!g" | \
        sed "s!___DATADIR___!$DATADIR!g" \
        > /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/$f
done

