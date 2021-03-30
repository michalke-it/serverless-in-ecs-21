#Apply the changed defaults to openfaas namespace (and thus to all core components)
sudo -E kubectl apply -f /vagrant/memory-defaults.yaml --namespace=openfaas
#Apply the changed defaults to function namespace (and thus to all deployed containers)
sudo -E kubectl apply -f /vagrant/memory-defaults.yaml --namespace=$FUNCTION_NAMESPACE