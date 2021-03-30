./latency-test.sh
script -c ./nats-bench.sh nats.log
script -c ./rally.sh rally.log
script -c ./openfaas.sh openfaas.log
