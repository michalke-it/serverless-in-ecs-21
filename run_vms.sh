vagrant destroy headnode worker1 worker2 -f
vagrant box update
vagrant up headnode
vagrant ssh -c "sudo -E kubectl get nodes"
echo "currently configured default routes:"
vagrant ssh -c "ip route sh | grep default"
K3S_TOKEN=$(cat node-token)
if [ "$#" -eq 1 ] ; then
    if [ $1 == 'local' ]; then
	vagrant up worker1 worker2
    echo "Deploying locally..."
    elif [ $1 == 'all' ]; then
	vagrant up worker1 worker2
    read -p "Press any key when you're done.. " -n1 -s
    fi
    sleep 15
else
    echo "Please add nodes now, token:"
    echo $K3S_TOKEN
    read -p "Press any key when you're done.. " -n1 -s
fi
vagrant ssh -c /vagrant/headnode.sh
