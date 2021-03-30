echo "Wrapping up the installation..."
K3S_TOKEN=$(cat /vagrant/node-token)
FUNCTION_NAMESPACE=openfaas-fn
echo "Installing faas-cli"
curl -sL https://cli.openfaas.com | sudo -E sh

echo "Deploying openfaas"
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> /home/vagrant/.bashrc
WORKERNUMBER=0
for worker in $(sudo -E kubectl get nodes | grep -v headnode | grep -v NAME \
    | sed 's/\s.*$//')
do
sudo -E kubectl label node $worker node-role.kubernetes.io/worker=worker
WORKERNUMBER=$((WORKERNUMBER+1))
done
sudo -E kubectl label node headnode env=ingress
sed -i "/replicas/c\ \ replicas: $WORKERNUMBER" /vagrant/nats7/values.yaml
sed -i "/replicas/creplicas: $WORKERNUMBER" /vagrant/values/elastic.yaml
curl -sSLf https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
    | bash
sudo -E kubectl apply -f /vagrant/values/namespaces.yml
#Remove the limits
source /vagrant/remove_limits.sh
sudo -E helm repo add openfaas https://openfaas.github.io/faas-netes/
sudo -E helm repo update
sleep 2
sudo -E kubectl -n openfaas create secret generic basic-auth \
    --from-literal=basic-auth-user=admin \
    --from-literal=basic-auth-password=password
sleep 5
TIMEOUT=2m
sudo -E helm upgrade openfaas --install openfaas/openfaas --namespace openfaas \
    --set functionNamespace=$FUNCTION_NAMESPACE --set basic_auth=true \
    --set gateway.upstreamTimeout=$TIMEOUT \
    --set gateway.writeTimeout=$TIMEOUT \
    --set gateway.readTimeout=$TIMEOUT \
    --set faasnetes.writeTimeout=$TIMEOUT \
    --set faasnetes.readTimeout=$TIMEOUT \
    --set queueWorker.ackWait=$TIMEOUT
if [ $? -ne 0 ]; then echo "There was an error while deploying OpenFaaS. Aborting..." \
    && exit; fi
sleep 120
sudo -E kubectl -n openfaas rollout status -w deployment/faas-idler
sudo -E kubectl autoscale deployment -n openfaas gateway --min=10 --max=10

echo "Testing OpenFaaS..."
sudo -E kubectl -n openfaas get deployments -l "release=openfaas, app=openfaas"
FAASPORT=$(sudo -E kubectl get service gateway-external -n openfaas \
    | grep -oP '(?<=8080:).*(?=/TCP)')
export OPENFAAS_URL=http://127.0.0.1:$FAASPORT
echo "export OPENFAAS_URL=http://127.0.0.1:$FAASPORT" >> /home/vagrant/.bashrc
sudo -E faas-cli login --username admin --password password

echo "Adding Elasticsearch..."
sudo -E helm repo add elastic https://Helm.elastic.co
sudo -E helm repo update
sudo -E helm upgrade elasticsearch -f /vagrant/values/elastic.yaml --install \
    elastic/elasticsearch --namespace $FUNCTION_NAMESPACE --version 7.9.3

echo "Adding Grafana..."
sudo -E helm upgrade grafana --install /vagrant/grafana --namespace openfaas
echo "Done."

echo "Deploying benchmarking functions..."
sudo -E faas-cli deploy -f /vagrant/values/img-classifier-hub.yml
sudo -E faas-cli deploy -f /vagrant/values/figlet.yml
sudo -E faas-cli deploy -f /vagrant/values/sentiment.yml
sleep 5
sudo -E kubectl apply -f /vagrant/values/classifier-hpa.yml
echo "Waiting for all elastic pods to be ready..."
for INSTANCE in $(seq 1 $WORKERNUMBER)
do
ELASTIC=elasticsearch-master-$((INSTANCE-1))
OUTPUT='jsonpath={..status.conditions[?(@.type=="Ready")].status}'
while [[ $(sudo -E kubectl -n openfaas-fn get pod $ELASTIC -o $OUTPUT) != "True" ]];
    do sleep 2; done
done
echo "Done."

echo "Summarizing setup:"
sudo -E kubectl -n default get pods --all-namespaces
sudo -E k3s kubectl get nodes
echo "token:"
echo $K3S_TOKEN
#rm /vagrant/node-token
