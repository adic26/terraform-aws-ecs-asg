#!/bin/bash
echo ECS_CLUSTER=${ecs_cluster_name} >> /etc/ecs/ecs.config
echo ECS_ENGINE_AUTH_TYPE=docker >> /etc/ecs/ecs.config
echo ECS_ENGINE_AUTH_DATA="{\"${ecs_private_registry}\":{\"username\":\"${ecs_private_registry_username}\",\"password\":\"${ecs_private_registry_password}\",\"email\":\"\"}}" >> /etc/ecs/ecs.config
