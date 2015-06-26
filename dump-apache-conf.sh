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
		echo "ProxyHTMLURLMap / /hadoop/$host:$port/"
		echo "ProxyHTMLURLMap /jmx /hadoop/$host:$port/jmx"
		echo "ProxyHTMLURLMap /webhdfs /hadoop/$host:50075/webhdfs"
		echo "ProxyHTMLURLMap /startupProgress /hadoop/$host:$port/startupProgress"
                echo "AddOutputFilterByType SUBSTITUTE text/html"
		echo "Substitute s!([\"'])/cluster/(.*?)([\"'])!\$1/hadoop/resourcemanager:8088/cluster/\$2\$3!"
		echo "Substitute s!([\"'])/proxy/(.*?)([\"'])!\$1/hadoop/resourcemanager:8088/proxy/\$2\$3!"
		echo "Substitute s!([\"'])//(resourcemanager|namenode|mrjobhistory|slave\d+):(\d+)(.*?)([\"'])!\$1/hadoop/\$2:\$3/\$4\$5!"
		echo "Substitute s!([\"'])http://(resourcemanager|namenode|mrjobhistory|slave\d+):(\d+)(.*?)([\"'])!\$1/hadoop/\$2:\$3/\$4\$5!"
                echo "Substitute s!http://resourcemanager!/hadoop/resourcemanager!"
                echo "Substitute s!([\"'])/jobhistory!\$1/hadoop/mrjobhistory:19888/jobhistory!"
                echo "Substitute s!([\"'])/hadoop/resourcemanager:8088//slave(\d+):(\d+)([\"'])!\$1/hadoop/slave\$2:\$3/\$4!"
		echo "</Location>"
	done
done

