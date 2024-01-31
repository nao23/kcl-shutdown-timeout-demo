#!/bin/bash

awslocal kinesis create-stream --stream-name demo --shard-count 1
awslocal kinesis wait stream-exists --stream-name demo
awslocal kinesis split-shard --stream-name demo --shard-to-split shardId-000000000000 --new-starting-hash-key 10000000000000000000000
awslocal dynamodb create-table \
  --table-name demo \
  --attribute-definitions AttributeName=leaseKey,AttributeType=S \
  --key-schema AttributeName=leaseKey,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
awslocal dynamodb batch-write-item --request-items file:///etc/localstack/init/ready.d/dynamodb.json
