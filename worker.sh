#Determine the nebula IP
WORKERIP=`ip addr sh | grep 192.168.100 | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -v 255`
#Use this IP as interface parameter for cluster communication
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.100.1:6443 K3S_TOKEN=$(cat /vagrant/node-token) INSTALL_K3S_EXEC="--node-external-ip $WORKERIP -i $WORKERIP --node-label=flannel.alpha.coreos.com/public-ip=$WORKERIP --node-label=flannel.alpha.coreos.com/public-ip-overwrite=$WORKERIP --flannel-iface nebula" sh -