TOKEN=`ssh x3i@x3i-desktop "cat /opt/development/master-thesis/node-token"`
echo "Found token: $TOKEN"
if [ "$1" == "edge" ] ; then
	SEQUENCE="11 12 13 14"
elif [ "$1" == "cloud" ] ; then
	SEQUENCE="21 22"
else
	SEQUENCE="11 12 13 14 21 22"
fi
for CLIENT in $SEQUENCE
do
	if [ $CLIENT -lt 15 ]; then
		LOGIN=ubuntu
	else
		LOGIN=francisco
	fi
	if [ $1 == 'uninstall' ]; then
		echo "Uninstalling client with IP $CLIENT..."
		ssh $LOGIN@192.168.100.$CLIENT "/usr/local/bin/k3s-agent-uninstall.sh"
	else
		echo "Configuring client with IP $CLIENT..."
		ssh $LOGIN@192.168.100.$CLIENT "./add_worker.sh $TOKEN"
	fi
done
