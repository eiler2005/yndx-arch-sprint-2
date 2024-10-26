#!/bin/bash

name: mongo-sharding-repl-cache

INIT_MODE=true

echo "Init docker mode configuration = ${INIT_MODE} with sharding and replicas"

if [ "${INIT_MODE}" == "true" ]; then
  docker compose up -d

  echo "Starting docker..."
  sleep 15s

  echo "Initializing config server..."
  docker compose exec -T configSrv mongosh --port 27017 --quiet --eval "rs.initiate({_id: 'config_server', configsvr: true, members: [{ _id: 0, host: 'configSrv:27017' }]})"

  sleep 20s

  echo "Initializing shard1..."
  docker compose exec -T shard11 mongosh --port 27018 --quiet --eval "rs.initiate({_id: 'shard1ReplicaSet', members: [{ _id: 1, host: 'shard11:27018', priority: 1},{ _id: 2, host: 'shard12:27021', priority: 2},{ _id: 3, host: 'shard13:27022', priority: 3}]})"

  echo "Initializing shard2..."
  docker compose exec -T shard21 mongosh --port 27019 --quiet --eval "rs.initiate({_id: 'shard2ReplicaSet', members: [{ _id: 1, host: 'shard21:27019', priority: 1},{ _id: 2, host: 'shard22:27023', priority: 2},{ _id: 3, host: 'shard23:27024', priority: 3}]})"

  echo "Waiting for config server and shards (with replicas) to initialize..."
  sleep 10s

  echo "Initializing MongoDB router and adding shards and replicas..."
  docker compose exec -T mongos_router mongosh --port 27020 --quiet --eval "sh.addShard('shard1ReplicaSet/shard11:27018')"
  docker compose exec -T mongos_router mongosh --port 27020 --quiet --eval "sh.addShard('shard2ReplicaSet/shard21:27019')"

  echo "Waiting for MongoDB router to initialize..."
  sleep 30s
fi

## db inserting and check distribution to shard 1 and shard 2

echo "Inserting documents to the DB... ('helloDoc' collection)"
docker compose exec -T mongos_router mongosh --port 27020 --quiet --eval "sh.enableSharding('somedb');"
docker compose exec -T mongos_router mongosh --port 27020 --quiet --eval "sh.shardCollection('somedb.helloDoc', { 'name' : 'hashed' })"
docker compose exec -T mongos_router mongosh --port 27020 --quiet --eval "db.getSiblingDB('somedb').helloDoc.insertMany([...Array(1000).keys()].map(i => ({ age: i, name: 'ly' + i })))"

echo "Counting documents in MongoDB router..."
docker compose exec -T mongos_router mongosh --port 27020 --quiet --eval "db.getSiblingDB('somedb').helloDoc.countDocuments()"

echo "Counting documents in mongo shard1..."
docker compose exec -T shard11 mongosh --port 27018 --quiet --eval "db.getSiblingDB('somedb').helloDoc.countDocuments()"

echo "Counting documents in mongo shard2..."
docker compose exec -T shard21 mongosh --port 27019 --quiet --eval "db.getSiblingDB('somedb').helloDoc.countDocuments()"

echo "Goodbye :)"