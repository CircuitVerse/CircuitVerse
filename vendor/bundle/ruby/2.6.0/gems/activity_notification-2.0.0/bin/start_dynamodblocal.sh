#!/bin/sh

# Source variables
. $(dirname $0)/_dynamodblocal

if [ -z $JAVA_HOME ]; then
  echo >&2 'ERROR: DynamoDBLocal requires JAVA_HOME to be set.'
  exit 1
fi

if [ ! -x $JAVA_HOME/bin/java ]; then
  echo >&2 'ERROR: JAVA_HOME is set, but I do not see the java executable there.'
  exit 1
fi

cd $DIST_DIR

if [ ! -f DynamoDBLocal.jar ] || [ ! -d DynamoDBLocal_lib ]; then
  echo >&2 "ERROR: Could not find DynamoDBLocal files in $DIST_DIR."
  exit 1
fi

mkdir -p $LOG_DIR
echo "DynamoDB Local output will save to ${DIST_DIR}/${LOG_DIR}/"
hash lsof 2>/dev/null && lsof -i :$LISTEN_PORT && { echo >&2 "Something is already listening on port $LISTEN_PORT; I will not attempt to start DynamoDBLocal."; exit 1; }

NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
nohup $JAVA_HOME/bin/java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -delayTransientStatuses -port $LISTEN_PORT -inMemory 1>"${LOG_DIR}/${NOW}.out.log" 2>"${LOG_DIR}/${NOW}.err.log" &
PID=$!

echo 'Verifying that DynamoDBLocal actually started...'

# Allow some seconds for the JDK to start and die.
counter=0
while [ $counter -le 5 ]; do
  kill -0 $PID
  if [ $? -ne 0 ]; then
    echo >&2 'ERROR: DynamoDBLocal died after we tried to start it!'
    exit 1
  else
    counter=$(($counter + 1))
    sleep 1
  fi
done

echo "DynamoDB Local started with pid $PID listening on port $LISTEN_PORT."
echo $PID > $PIDFILE
