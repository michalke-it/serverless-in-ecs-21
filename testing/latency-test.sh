COUNT=100
echo "Testing latencies at $(date +%y%m%d-%H-%M-%S)..."
echo cloud > latency-cloud.lat
echo edge > latency-edge.lat
tcp-latency -r $COUNT 192.168.31.21 -p 19766 | grep -Po 'time=\K[^ ]+' >> worker-test-direct.lat
tcp-latency -r $COUNT 192.168.100.31 -p 19766 | grep -Po 'time=\K[^ ]+' >> worker-test-nebula.lat
tcp-latency -r $COUNT 192.168.31.227 -p 19766 | grep -Po 'time=\K[^ ]+' >> worker-worker-direct.lat
tcp-latency -r $COUNT 192.168.100.3 -p 19766 | grep -Po 'time=\K[^ ]+' >> worker-worker-nebula.lat
echo "Done at $(date +%y%m%d-%H-%M-%S)."
