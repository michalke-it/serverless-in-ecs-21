ENDPOINT=192.168.41.225:31112
IMG_REQUESTS="-n 25000"
REQUESTS="-n 200000"
TIMEOUT=0

test_function () {
    echo "Testing function $1 for correct response: "
    if [ "$1" == "figlet" ] ; then
        DATA="OpenFaaS"
        EFF_REQUESTS="$REQUESTS"
    elif [ "$1" == "sentiment" ] ; then
        DATA="Personally I like functions to do one thing and only one thing well," \
            +" it makes them more readable."
        EFF_REQUESTS="$REQUESTS"
    elif [ "$1" == "img-classifier-hub" ] ; then
        DATA="https://upload.wikimedia.org/wikipedia/commons/6/61/" \
            +"Humpback_Whale_underwater_shot.jpg"
        EFF_REQUESTS="$IMG_REQUESTS"
    fi
    while : ; do
        curl -d "$DATA" http://$ENDPOINT/function/$1.openfaas-fn
        if [ $? -eq 0 ]; then
            RESPONSE=`curl -d "$DATA" http://$ENDPOINT/function/$1.openfaas-fn`
            if [[ "$RESPONSE" != *"rror"* ]]; then
                if [[ "$RESPONSE" != *"annot"* ]]; then
                    echo "RESPONSE:"
                    echo $RESPONSE
                    break
                fi
            fi
            echo "Invalid response for function $1. Trying again..."
        fi
        sleep 2
    done
    echo ""
    echo "Received valid respose."
    echo "Benchmarking function $1 with $2 threads, starting at $(date +%y%m%d-%H-%M-%S)..."
    hey -c $2 $EFF_REQUESTS -disable-compression -disable-keepalive -t $TIMEOUT -o csv \
        -d "$DATA" http://$ENDPOINT/function/$1.openfaas-fn > openfaas/$1_$2.csv
    echo "ending at $(date +%y%m%d-%H-%M-%S)"

    TOTAL="$(cat openfaas/$1_$2.csv | wc -l)"
    FAILED="$(cat openfaas/$1_$2.csv | grep ",500," | wc -l)"
    NOTFOUND="$(cat openfaas/$1_$2.csv | grep ",404," | wc -l)"
    FAILED="$(($FAILED + $NOTFOUND))"
    FAILED="$(($FAILED * 100))"
    RATE="$(($FAILED / $TOTAL))"
    echo "Rate in percent: $RATE"
    echo "Not found: $NOTFOUND of $TOTAL"
    echo "Cooldown..."
    sleep 900
}

ssh x3i@x3i-desktop "cd /opt/development/master-thesis && vagrant ssh -c 'sudo -E 
KUBECONFIG=/etc/rancher/k3s/k3s.yaml kubectl scale -n openfaas deploy/alertmanager 
--replicas=0'"
sleep 60

test_function img-classifier-hub 30
test_function img-classifier-hub 20
test_function img-classifier-hub 10
test_function img-classifier-hub 5
test_function img-classifier-hub 1

ssh x3i@x3i-desktop "cd /opt/development/master-thesis && vagrant ssh -c 'sudo -E 
KUBECONFIG=/etc/rancher/k3s/k3s.yaml kubectl scale -n openfaas deploy/alertmanager 
--replicas=1'"
sleep 60

test_function figlet 1
test_function figlet 50
test_function figlet 250
test_function figlet 500
test_function figlet 1000

test_function sentiment 1
test_function sentiment 50
test_function sentiment 250
test_function sentiment 500
test_function sentiment 1000

TIMESTAMP=$(date +%y%m%d-%H-%M-%S)
cp openfaas.log ../openfaas/
echo "Done."
