#!/bin/sh

nodes=`virsh -c qemu:///system list | grep -o 'hadoopvirtualcluster_[a-zA-Z0-9]*'`
ctrlnodesjoined=`virsh -c qemu:///system list | grep -o 'hadoopvirtualcluster_[a-zA-Z0-9]*' | grep -v slave | paste -sd "," -`
slavenodesjoined=`virsh -c qemu:///system list | grep -o 'hadoopvirtualcluster_[a-zA-Z0-9]*' | grep slave | paste -sd "," -`
echo "<list>"
echo "0 = $ctrlnodesjoined"
echo "1 = $slavenodesjoined"
echo "</list>"
echo "<desc>"
for node in $nodes
do
    nodename=`echo $node | sed 's/hadoopvirtualcluster_//'`
    blks=`virsh -c qemu:///system domblklist $node | grep -o 'vd[a-z]' | paste -sd "," -`
    macs=`virsh -c qemu:///system domiflist $node | grep -o '[a-z0-9][a-z0-9]:.*' | paste -sd "," -`
    echo "<$node>"
    echo "  desc = \"$nodename\""
    echo "  disk = $blks"
    echo "  net = $macs"
    echo "</$node>"
done
echo "</desc>"

