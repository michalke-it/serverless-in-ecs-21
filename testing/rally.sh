TRACK=percolator
#TRACK=geopoint
BEGIN=$(date +%H-%M-%S)
docker run -v $PWD/config:/rally/.rally elastic/rally --track=$TRACK --pipeline=benchmark-only --target-hosts=192.168.41.225:30040 --report-format=csv --report-file=/rally/.rally/logs/rally.csv
curl -X DELETE http://192.168.41.225:30040/queries
#curl -X GET http://192.168.41.225:30040/_cat/indices?v=
TIMESTAMP=$(date +%y%m%d-%H-%M-%S)
mv config/logs/rally.csv config/logs/rally-$TIMESTAMP.csv
END=$(date +%H-%M-%S)
echo "From: $BEGIN to $END"