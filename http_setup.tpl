#!/bin/bash

sudo apt-get update -yy

sudo apt-get install -yy git curl

curl -fsSL https://get.docker.com -o get-docker.sh

sudo sh get-docker.sh
cat <<EOT > .env
REDIS_HOST=${redis_host}
REDIS_PORT=6379
DB_HOST=${mysql_host}
DB_USER=user
DB_PASSWORD=password
DB_NAME=mydatabase
EOT

docker run -d -p 80:5000 --name web \
  --env-file .env \
  rawanalanazi/capstone-project:latest \
  sh -c "python -c 'from app import init_db; init_db()' && flask run --host=0.0.0.0"
