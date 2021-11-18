#!/bin/bash

wget https://s3-us-west-2.amazonaws.com/dynamodb-local/dynamodb_local_latest.zip --quiet -O spec/dynamodb_temp.zip
unzip -qq spec/dynamodb_temp.zip -d spec/DynamoDBLocal-latest
rm spec/dynamodb_temp.zip
