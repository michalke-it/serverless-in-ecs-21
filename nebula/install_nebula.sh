echo "Configuring Nebula lighthouse..."
#./nebula-cert ca -name "Openfaas network"
#./nebula-cert sign -name "lighthouse" -ip "192.168.100.100/24"
#./nebula-cert sign -name "headnode" -ip "192.168.100.1/24"
#./nebula-cert sign -name "worker1" -ip "192.168.100.2/24"
#./nebula-cert sign -name "worker2" -ip "192.168.100.3/24"
#./nebula-cert sign -name "rpi1" -ip "192.168.100.11/24"
#./nebula-cert sign -name "rpi2" -ip "192.168.100.12/24"
#./nebula-cert sign -name "rpi3" -ip "192.168.100.13/24"
#./nebula-cert sign -name "rpi4" -ip "192.168.100.14/24"
#./nebula-cert sign -name "testnode" -ip "192.168.100.31/24"
sudo cp /vagrant/nebula/nebula.service /etc/systemd/system/
sudo systemctl start nebula
echo "Nebula started"
