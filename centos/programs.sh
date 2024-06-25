#!/bin/bash

# RabbitMQ
RABBITMQ_VERSION='3.13-management'
docker run -d --privileged --restart=always --name rabbitmq --hostname my-rabbit \
  -p 5672:5672 -p 15672:15672 \
  rabbitmq:$RABBITMQ_VERSION
