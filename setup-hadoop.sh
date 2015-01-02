#!/bin/sh

cd /home/jeckroth/cinf401-vagrant

JAVA_HOME=/usr/java/latest
LOGDIR=/opt/hadoop-2.6.0/logs
DATADIR=/opt/hadoop-2.6.0/data

IP=""
function getip() {
	SCPOPTS=`vagrant ssh-config $1 | grep -v '^Host ' | grep -v '^$' | awk -v ORS=' ' '{print "-o " $1 "=" $2}'`
	IP=`echo ${SCPOPTS} | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])'`
}

getip "namenode"
NAMENODEIP=$IP
echo "namenode: $NAMENODEIP"

getip "resourcemanager"
RESOURCEMANAGERIP=$IP
echo "resourcemanager: $RESOURCEMANAGERIP"

getip "nodemanager"
NODEMANAGERIP=$IP
echo "nodemanager: $NODEMANAGERIP"

for f in `ls local-hadoop-etc`;
do
	sed "s/___NAMENODEIP___/$NAMENODEIP/g" < ./local-hadoop-etc/$f | \
	sed "s/___RESOURCEMANAGERIP___/$RESOURCEMANAGERIP/g" | \
	sed "s/___NODEMANAGERIP___/$NODEMANAGERIP/g" | \
        sed "s!___JAVA_HOME___!$JAVA_HOME!g" | \
        sed "s!___LOGDIR___!$LOGDIR!g" | \
        sed "s!___DATADIR___!$DATADIR!g" \
        > /opt/hadoop-2.6.0/etc/hadoop/$f
done

echo "Restarting namenode daemon..."
vagrant ssh namenode -- "sudo /vagrant/vm-update-hadoop-ips.sh 0.0.0.0 $RESOURCEMANAGERIP $NODEMANAGERIP /usr/lib/jvm/jdk1.7.0_71 /home/vagrant/logs /home/vagrant/data"
vagrant ssh namenode -- "sudo /home/vagrant/hadoop/hadoop-2.6.0/sbin/hadoop-daemon.sh --config /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/ --script hdfs stop namenode"
vagrant ssh namenode -- "sudo /home/vagrant/hadoop/hadoop-2.6.0/sbin/hadoop-daemon.sh --config /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/ --script hdfs start namenode"

echo "Restarting resourcemanager daemon..."
vagrant ssh resourcemanager -- "sudo /vagrant/vm-update-hadoop-ips.sh $NAMENODEIP 0.0.0.0 $NODEMANAGERIP /usr/lib/jvm/jdk1.7.0_71 /home/vagrant/logs /home/vagrant/data"
vagrant ssh resourcemanager -- "sudo /home/vagrant/hadoop/hadoop-2.6.0/sbin/yarn-daemon.sh --config /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/ stop resourcemanager"
vagrant ssh resourcemanager -- "sudo /home/vagrant/hadoop/hadoop-2.6.0/sbin/yarn-daemon.sh --config /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/ start resourcemanager"

echo "Restarting nodemanager daemon..."
vagrant ssh nodemanager -- "sudo /vagrant/vm-update-hadoop-ips.sh $NAMENODEIP $RESOURCEMANAGERIP $NODEMANAGERIP /usr/lib/jvm/jdk1.7.0_71 /home/vagrant/logs /home/vagrant/data"
vagrant ssh nodemanager -- "sudo /home/vagrant/hadoop/hadoop-2.6.0/sbin/yarn-daemon.sh --config /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/ stop nodemanager"
vagrant ssh nodemanager -- "sudo /home/vagrant/hadoop/hadoop-2.6.0/sbin/yarn-daemon.sh --config /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/ start nodemanager"

echo "Restarting mrjobhistory daemon..."
vagrant ssh resourcemanager -- "sudo /vagrant/vm-update-hadoop-ips.sh $NAMENODEIP $RESOURCEMANAGERIP $NODEMANAGERIP /usr/lib/jvm/jdk1.7.0_71 /home/vagrant/logs /home/vagrant/data"
vagrant ssh mrjobhistory -- "sudo /home/vagrant/hadoop/hadoop-2.6.0/sbin/mr-jobhistory-daemon.sh stop historyserver --config /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/"
vagrant ssh mrjobhistory -- "sudo /home/vagrant/hadoop/hadoop-2.6.0/sbin/mr-jobhistory-daemon.sh start historyserver --config /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/"

for j in `vagrant status | grep -oE '(slave[0-9]+)'`
do
  echo "Restarting datanode daemon on $j"
  vagrant ssh $j -- "sudo /vagrant/vm-update-hadoop-ips.sh $NAMENODEIP $RESOURCEMANAGERIP $NODEMANAGERIP /usr/lib/jvm/jdk1.7.0_71 /home/vagrant/logs /home/vagrant/data"
  vagrant ssh $j -- "sudo /home/vagrant/hadoop/hadoop-2.6.0/sbin/hadoop-daemon.sh --config /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/ --script hdfs stop datanode"
  vagrant ssh $j -- "sudo /home/vagrant/hadoop/hadoop-2.6.0/sbin/hadoop-daemon.sh --config /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/ --script hdfs start datanode"
done

