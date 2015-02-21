#!/bin/sh

echo "ProxyRequests Off"
echo "ProxyHTMLEnable On"
echo "ProxyPass /jmx http://namenode:50070/jmx"
echo "ProxyPass /webhdfs http://namenode:50070/webhdfs"
echo "ProxyPass /startupProgress http://namenode:50070/startupProgress"
for host in `vagrant ssh-config | grep '^Host ' | awk -v ORS=' ' '{print $2}'`
do
	port=8042
	if [ "$host" = "resourcemanager" ]; then port=8088; fi
	if [ "$host" = "namenode" ]; then port=50070; fi
	if [ "$host" = "mrjobhistory" ]; then port=19888; fi
	echo "ProxyPass /hadoop/$host/ http://$host:$port/"
	echo "ProxyPassReverse /hadoop/$host/ http://$host:$port/"
	echo "<Location /hadoop/$host/>"
	echo "ProxyHTMLURLMap //(resourcemanager|namenode|mrjobhistory|slave\d+):?\d*(.*)$ /hadoop/\$1/\$2 R"
	echo "ProxyHTMLURLMap / /hadoop/$host/"
	echo "</Location>"
done

