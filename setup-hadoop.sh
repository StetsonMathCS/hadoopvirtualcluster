#!/bin/sh

cd /home/jeckroth/cinf401-vagrant


JAVA_HOME=/usr/java/latest
LOGDIR=/opt/hadoop-2.6.0/logs
DATADIR=/opt/hadoop-2.6.0/data

# args: hostname
IP=""
function getip() {
	SCPOPTS=`vagrant ssh-config $1 | grep -v '^Host ' | grep -v '^$' | awk -v ORS=' ' '{print "-o " $1 "=" $2}'`
	IP=`echo ${SCPOPTS} | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])'`
}

# args: hostname ip
function updatemunin() {
	echo "[Hadoop;$1]" >> /etc/munin/conf.d/hadoop.conf
	echo "    address $2" >> /etc/munin/conf.d/hadoop.conf
	echo >> /etc/munin/conf.d/hadoop.conf
}

# args: hostname ip
function updatehosts() {
	echo "$2 $1" >> ./hosts
}

#echo "Erasing /etc/munin/conf.d/hadoop.conf"
#echo > /etc/munin/conf.d/hadoop.conf

echo "Erasing ./hosts"
echo "127.0.0.1 localhost" > ./hosts

getip "namenode"
NAMENODEIP=$IP
echo "namenode: $NAMENODEIP"
#updatemunin "namenode" $NAMENODEIP
updatehosts "namenode" $NAMENODEIP

getip "resourcemanager"
RESOURCEMANAGERIP=$IP
echo "resourcemanager: $RESOURCEMANAGERIP"
#updatemunin "resourcemanager" $RESOURCEMANAGERIP
updatehosts "resourcemanager" $RESOURCEMANAGERIP

getip "mrjobhistory"
MRJOBHISTORYIP=$IP
echo "mrjobhistory: $MRJOBHISTORYIP"
#updatemunin "mrjobhistory" $MRJOBHISTORYIP
updatehosts "mrjobhistory" $MRJOBHISTORYIP

for f in `ls local-hadoop-etc`;
do
	sed "s/___NAMENODEIP___/$NAMENODEIP/g" < ./local-hadoop-etc/$f | \
	sed "s/___RESOURCEMANAGERIP___/$RESOURCEMANAGERIP/g" | \
	sed "s/___MRJOBHISTORYIP___/$MRJOBHISTORYIP/g" | \
        sed "s!___JAVA_HOME___!$JAVA_HOME!g" | \
        sed "s!___LOGDIR___!$LOGDIR!g" | \
        sed "s!___DATADIR___!$DATADIR!g" \
        > /opt/hadoop-2.6.0/etc/hadoop/$f
done

for j in `vagrant status | grep -oE '(slave[0-9]+)'`
do
  getip $j
  #updatemunin $j $IP
  updatehosts $j $IP
done

vagrant reload

echo "Restarting namenode daemon..."
vagrant ssh namenode -- "sudo /vagrant/vm-update-hadoop-ips.sh $NAMENODEIP $RESOURCEMANAGERIP $MRJOBHISTORYIP /usr/lib/jvm/jdk1.7.0_71 /home/vagrant/logs /home/vagrant/data"
vagrant ssh namenode -- "sudo /home/vagrant/hadoop/hadoop-2.6.0/bin/hdfs --config /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/ namenode -format -nonInteractive"
vagrant ssh namenode -- "sudo /home/vagrant/hadoop/hadoop-2.6.0/sbin/hadoop-daemon.sh --config /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/ --script hdfs stop namenode"
vagrant ssh namenode -- "sudo /home/vagrant/hadoop/hadoop-2.6.0/sbin/hadoop-daemon.sh --config /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/ --script hdfs start namenode"

echo "Restarting resourcemanager daemon..."
vagrant ssh resourcemanager -- "sudo /vagrant/vm-update-hadoop-ips.sh $NAMENODEIP 0.0.0.0 $MRJOBHISTORYIP /usr/lib/jvm/jdk1.7.0_71 /home/vagrant/logs /home/vagrant/data"
vagrant ssh resourcemanager -- "sudo /home/vagrant/hadoop/hadoop-2.6.0/sbin/yarn-daemon.sh --config /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/ stop resourcemanager"
vagrant ssh resourcemanager -- "sudo /home/vagrant/hadoop/hadoop-2.6.0/sbin/yarn-daemon.sh --config /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/ start resourcemanager"

echo "Restarting mrjobhistory daemon..."
vagrant ssh mrjobhistory -- "sudo /vagrant/vm-update-hadoop-ips.sh $NAMENODEIP $RESOURCEMANAGERIP 0.0.0.0 /usr/lib/jvm/jdk1.7.0_71 /home/vagrant/logs /home/vagrant/data"
vagrant ssh mrjobhistory -- "sudo /home/vagrant/hadoop/hadoop-2.6.0/sbin/mr-jobhistory-daemon.sh stop historyserver --config /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/"
vagrant ssh mrjobhistory -- "sudo /home/vagrant/hadoop/hadoop-2.6.0/sbin/mr-jobhistory-daemon.sh start historyserver --config /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/"

for j in `vagrant status | grep -oE '(slave[0-9]+)'`
do
  echo "Restarting datanode and nodemanager daemons on $j"
  vagrant ssh $j -- "sudo /vagrant/vm-update-hadoop-ips.sh $NAMENODEIP $RESOURCEMANAGERIP $MRJOBHISTORYIP /usr/lib/jvm/jdk1.7.0_71 /home/vagrant/logs /home/vagrant/data"
  vagrant ssh $j -- "sudo /home/vagrant/hadoop/hadoop-2.6.0/sbin/hadoop-daemon.sh --config /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/ --script hdfs stop datanode"
  vagrant ssh $j -- "sudo /home/vagrant/hadoop/hadoop-2.6.0/sbin/hadoop-daemon.sh --config /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/ --script hdfs start datanode"
  vagrant ssh $j -- "sudo /home/vagrant/hadoop/hadoop-2.6.0/sbin/yarn-daemon.sh --config /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/ stop nodemanager"
  vagrant ssh $j -- "sudo /home/vagrant/hadoop/hadoop-2.6.0/sbin/yarn-daemon.sh --config /home/vagrant/hadoop/hadoop-2.6.0/etc/hadoop/ start nodemanager"
done


#sudo /sbin/service munin-node restart


