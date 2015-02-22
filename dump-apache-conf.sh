#!/bin/sh

echo "ProxyRequests Off"
echo "ProxyHTMLEnable On"
echo "ProxyPass /jmx http://namenode:50070/jmx"
echo "ProxyPass /webhdfs http://namenode:50070/webhdfs"
echo "ProxyPass /startupProgress http://namenode:50070/startupProgress"
for host in `vagrant ssh-config | grep '^Host ' | awk -v ORS=' ' '{print $2}'`
do
	for port in 8042 50075 50070 8088 19888
	do
		echo "ProxyPass /hadoop/$host:$port/ http://$host:$port/"
		echo "ProxyPassReverse /hadoop/$host:$port/ http://$host:$port/"
		echo "<Location /hadoop/$host:$port/>"
		echo "ProxyHTMLURLMap //(resourcemanager|namenode|mrjobhistory|slave\d+):(\d+)(.*)$ /hadoop/\$1:\$2/\$3 R"
		echo "ProxyHTMLURLMap //resourcemanager(.*)$ /hadoop/resourcemanager:8088/\$1 R"
		echo "ProxyHTMLURLMap / /hadoop/$host:$port/"
		echo "ProxyHTMLURLMap /jmx /hadoop/$host:$port/jmx"
		echo "ProxyHTMLURLMap /webhdfs /hadoop/$host:50075/webhdfs"
		echo "ProxyHTMLURLMap /startupProgress /hadoop/$host:$port/startupProgress"
		echo "</Location>"
	done
done

