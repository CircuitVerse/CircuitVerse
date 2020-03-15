#!/bin/sh

# Source variables
. $(dirname $0)/_dynamodblocal

cd $DIST_DIR

if [ ! -f $PIDFILE ]; then
  echo 'ERROR: There is no pidfile, so if DynamoDBLocal is running you will need to kill it yourself.'
  exit 1
fi

pid=$(<$PIDFILE)

echo "Killing DynamoDBLocal at pid $pid..."
kill $pid

counter=0
while [ $counter -le 5 ]; do
  kill -0 $pid 2>/dev/null
  if [ $? -ne 0 ]; then
    echo 'Successfully shut down DynamoDBLocal.'
    rm -f $PIDFILE
    exit 0
  else
    echo 'Still waiting for DynamoDBLocal to shut down...'
    counter=$(($counter + 1))
    sleep 1
  fi
done

echo 'Unable to shut down DynamoDBLocal; you may need to kill it yourself.'
rm -f $PIDFILE
exit 1
