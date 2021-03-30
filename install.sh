#Configure K3s DNS service to use hostmachine's system resolv.conf
export K3S_RESOLV_CONF=/run/systemd/resolve/resolv.conf
echo "export K3S_RESOLV_CONF=/run/systemd/resolve/resolv.conf" >> /home/vagrant/.bashrc
#Some default configuration required for Docker inside Vagrant environment
usermod -aG docker vagrant
echo "vm.max_map_count=262144" >> vm.conf
sudo mv vm.conf /etc/sysctl.d/
#Copy the nebula certificate files and install the client
sudo mkdir -p /etc/nebula
sudo cp /vagrant/nebula/$HOSTNAME.yml /etc/nebula/nebula.yml
sudo cp /vagrant/nebula/$HOSTNAME.crt /etc/nebula/nebula.crt
sudo cp /vagrant/nebula/$HOSTNAME.key /etc/nebula/nebula.key
/vagrant/nebula/install_nebula.sh
sleep 10