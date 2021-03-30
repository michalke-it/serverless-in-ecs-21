# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define "headnode", primary: true do |headnode|
    headnode.vm.box = "generic/ubuntu2004"
    headnode.vm.hostname = "headnode"
    headnode.disksize.size = '50GB'
    #This is the default network, it provides internet access:
    headnode.vm.network "public_network", bridge: "enp4s0",
      use_dhcp_assigned_default_route: true,
      :mac => "080027014243"
    #This interface is linked directly to the testmachine (optional):
    headnode.vm.network "public_network",
      bridge: "enx3c18a075b820", 
      ip: "192.168.41.225"
    headnode.vm.synced_folder ".", "/vagrant"
    headnode.vm.provider "virtualbox" do |v3|
      v3.name = "headnode"
      v3.memory = 8192
      v3.cpus = 4
      v3.gui = false
    end

  #disable all the shell beeps
    headnode.vm.provision :shell, 
      inline: "echo 'set bell-style none' >> /etc/inputrc \
        && echo 'set visualbell' >> /home/vagrant/.vimrc"
    headnode.vm.provision :shell, 
      inline: "DEBIAN_FRONTEND=noninteractive apt-get update \
        && apt-get install docker.io build-essential -y"
  #delete the default NAT route to avoid issues with 'docker pull' through double NAT environments
    headnode.vm.provision "shell",
      run: "always",
      inline: "ip route del default dev eth0"
      headnode.vm.provision :shell, path: "install.sh"
    #Install K3s server and move the authentication token to an accessible location
    headnode.vm.provision "shell",
      run: "always",
      inline: 'curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-external-ip 192.168.100.1 \
        -i 192.168.100.1 --node-label=flannel.alpha.coreos.com/public-ip-overwrite=192.168.100.1 \
        --flannel-iface nebula" sh -'
    headnode.vm.provision :shell,
      inline: "cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token"
    #Restart Nebula as it sometimes advertises incorrectly after K3s installation
    headnode.vm.provision :shell,
      inline: "sudo systemctl stop nebula && sleep 3 && sudo systemctl start nebula"
    #Override the K3s service file to guarantee presence of all needed parameters
    headnode.vm.provision :shell,
      inline: "sudo cp /vagrant/values/k3s.service /etc/systemd/system/ \
        && sudo systemctl daemon-reload && sudo systemctl restart k3s"
    headnode.vm.provision :shell, inline: "chmod 777 /vagrant/node-token"
  end

  config.vm.define "worker1" do |worker1|
    worker1.vm.box = "generic/ubuntu2004"
    worker1.vm.hostname = "worker1"
    worker1.disksize.size = '50GB'
    worker1.vm.network "public_network", bridge: "enp4s0",
      use_dhcp_assigned_default_route: true,
      :mac => "080027014244"
    worker1.vm.synced_folder ".", "/vagrant"
    worker1.vm.provider "virtualbox" do |v1|
      v1.name = "worker1"
      v1.memory = 8192
      v1.cpus = 2
      v1.gui = false
    end

    worker1.vm.provision "shell",
      run: "always",
      inline: "ip route del default dev eth0"
    worker1.vm.provision :shell,
      inline: "echo 'set bell-style none' >> /etc/inputrc \
        && echo 'set visualbell' >> /home/vagrant/.vimrc"
    worker1.vm.provision :shell,
      inline: "DEBIAN_FRONTEND=noninteractive apt-get update \
        && apt-get install docker.io build-essential -y"
    worker1.vm.provision :shell, path: "install.sh"
    #Join the K3s cluster
    worker1.vm.provision :shell, path: "worker.sh"
  end

  config.vm.define "worker2" do |worker2|
      worker2.vm.box = "generic/ubuntu2004"
      worker2.vm.hostname = "worker2"
      worker2.disksize.size = '50GB'
      worker2.vm.network "public_network", bridge: "enp4s0",
        use_dhcp_assigned_default_route: true,
        :mac => "080027014245"
      worker2.vm.synced_folder ".", "/vagrant"
      worker2.vm.provider "virtualbox" do |v2|
        v2.name = "worker2"
        v2.memory = 8192
        v2.cpus = 2
        v2.gui = false
      end

      worker2.vm.provision "shell",
        run: "always",
        inline: "ip route del default dev eth0"
      worker2.vm.provision :shell,
        inline: "echo 'set bell-style none' >> /etc/inputrc \
          && echo 'set visualbell' >> /home/vagrant/.vimrc"
      worker2.vm.provision :shell,
        inline: "sudo apt update \
          && sudo apt install docker.io build-essential --yes"
      worker2.vm.provision :shell, path: "install.sh"
      worker2.vm.provision :shell, path: "worker.sh"
  end
end
