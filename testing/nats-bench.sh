NUM_MSGS=10000
MESSAGE_SIZE=64
SUBSCRIPTIONSTARTPOINT=192.168.41.225:30041
MAX=5

ssh x3i@x3i-desktop "cd /opt/development/master-thesis && vagrant ssh -c 'sudo -E KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm install nats /vagrant/nats7 --namespace openfaas-fn --wait --timeout=600s'"
sleep 300
docker run michalkeit/nats-bench -s 192.168.41.225:30041 -np 1 -ns 1 -n 200 subject

for CLIENTS in 1 2 3 4
    do
    case $CLIENTS in
    1)
        SUBSCRIBERS=1
        PUBLISHERS=1
        ;;

    2)
        SUBSCRIBERS=1
        PUBLISHERS=$MAX
        ;;

    3)
        SUBSCRIBERS=$MAX
        PUBLISHERS=1
        ;;

    4)
        SUBSCRIBERS=$MAX
        PUBLISHERS=$MAX
        ;;
    esac
    echo "sleeping 2 mins..."
    sleep 120
    
    CSVNAME=sub$SUBSCRIBERS-pub$PUBLISHERS
    CSVFILE="nats/$CSVNAME.csv"
    echo "starting at $(date +%y%m%d-%H-%M-%S)"
    nats-bench -s $SUBSCRIPTIONSTARTPOINT -np $PUBLISHERS -ns $SUBSCRIBERS -n $NUM_MSGS -ms $MESSAGE_SIZE -csv $CSVFILE subject$CLIENTS
    echo "ending at $(date +%y%m%d-%H-%M-%S)"
done

ssh x3i@x3i-desktop "cd /opt/development/master-thesis && vagrant ssh -c 'sudo -E KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm delete nats -n openfaas-fn'"
sleep 60

TIMESTAMP=$(date +%y%m%d-%H-%M-%S)
cp nats.log nats/
sleep 10