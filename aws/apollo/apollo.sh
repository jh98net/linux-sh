#!/bin/bash

# 导入SQL
#   修改ApolloConfigDB > ServerConfig > eureka.service.url
#   修改ApolloPortalDB > ServerConfig > apollo.portal.envs apollo.portal.meta.servers

mysql_ip="192.168.1.120"
mysql_username="root"
mysql_password="root"
apollo_config_ip="192.168.1.120"
base_dir="/root/programs/apollo"
ver="latest"
env="dev"

docker run -p 8081:8081 -d \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://${mysql_ip}:3306/ApolloConfigDB_${env}?characterEncoding=utf8" \
  -e SPRING_DATASOURCE_USERNAME=${mysql_username} -e SPRING_DATASOURCE_PASSWORD=${mysql_password} \
  -e SERVER_PORT=8081 -e TZ='Asia/Shanghai' \
  -e EUREKA_INSTANCE_IP_ADDRESS=${apollo_config_ip} \
  -e EUREKA_INSTANCE_HOME_PAGE_URL=http://${apollo_config_ip}:8081 -e EUREKA_INSTANCE_PREFER_IP_ADDRESS=false \
  -v ${base_dir}/config_${env}/logs:/opt/logs \
  --name apollo-configservice-${env} apolloconfig/apollo-configservice:${ver}

docker run -p 8091:8091 -d \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://${mysql_ip}:3306/ApolloConfigDB_${env}?characterEncoding=utf8" \
  -e SPRING_DATASOURCE_USERNAME=${mysql_username} -e SPRING_DATASOURCE_PASSWORD=${mysql_password} \
  -e SERVER_PORT=8091 -e TZ='Asia/Shanghai' \
  -e EUREKA_INSTANCE_IP_ADDRESS=${apollo_config_ip} \
  -v ${base_dir}/admin_${env}/logs:/opt/logs \
  --name apollo-adminservice-${env} apolloconfig/apollo-adminservice:${ver}

env="fat"
docker run -p 8082:8082 -d \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://${mysql_ip}:3306/ApolloConfigDB_${env}?characterEncoding=utf8" \
  -e SPRING_DATASOURCE_USERNAME=${mysql_username} -e SPRING_DATASOURCE_PASSWORD=${mysql_password} \
  -e SERVER_PORT=8082 -e TZ='Asia/Shanghai' \
  -e EUREKA_INSTANCE_IP_ADDRESS=${apollo_config_ip} \
  -e EUREKA_INSTANCE_HOME_PAGE_URL=http://${apollo_config_ip}:8082 -e EUREKA_INSTANCE_PREFER_IP_ADDRESS=false \
  -v ${base_dir}/config_${env}/logs:/opt/logs \
  --name apollo-configservice-${env} apolloconfig/apollo-configservice:${ver}

docker run -p 8092:8092 -d \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://${mysql_ip}:3306/ApolloConfigDB_${env}?characterEncoding=utf8" \
  -e SPRING_DATASOURCE_USERNAME=${mysql_username} -e SPRING_DATASOURCE_PASSWORD=${mysql_password} \
  -e SERVER_PORT=8092 -e TZ='Asia/Shanghai' \
  -e EUREKA_INSTANCE_IP_ADDRESS=${apollo_config_ip} \
  -e EUREKA_INSTANCE_HOME_PAGE_URL=http://${apollo_config_ip}:8092 -e EUREKA_INSTANCE_PREFER_IP_ADDRESS=false \
  -v ${base_dir}/admin_${env}/logs:/opt/logs \
  --name apollo-adminservice-${env} apolloconfig/apollo-adminservice:${ver}

docker run -p 8070:8070 -d \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://${mysql_ip}:3306/ApolloPortalDB?characterEncoding=utf8" \
  -e SPRING_DATASOURCE_USERNAME=${mysql_username} -e SPRING_DATASOURCE_PASSWORD=${mysql_password} \
  -e APOLLO_PORTAL_ENVS=dev,fat \
  -e DEV_META=http://${apollo_config_ip}:8081 \
  -e FAT_META=http://${apollo_config_ip}:8082 \
  -v ${base_dir}/portal/logs:/opt/logs \
  --name apollo-portal apolloconfig/apollo-portal:${ver}


{
  "DEV":"http://192.168.1.120:8081",
  "FAT":"http://192.168.1.120:8082"
}

# ==================== uat pro =============
{
  "UAT":"http://10.0.128.20:8081",
  "PRO":"http://10.0.128.20:8082"
}

mysql_ip="my-db.cvn4awncphwh.us-west-2.rds.amazonaws.com"
mysql_username="admin"
mysql_password="jfjptKzEg2JRMsnp3Xud0"
apollo_config_ip="10.0.128.20"
base_dir="/home/ec2-user/programs/apollo"
ver="latest"
env="uat"

docker run -p 8081:8081 -d \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://${mysql_ip}:3306/ApolloConfigDB_${env}?characterEncoding=utf8" \
  -e SPRING_DATASOURCE_USERNAME=${mysql_username} -e SPRING_DATASOURCE_PASSWORD=${mysql_password} \
  -e SERVER_PORT=8081 -e TZ='Asia/Shanghai' \
  -e EUREKA_INSTANCE_IP_ADDRESS=${apollo_config_ip} \
  -e EUREKA_INSTANCE_HOME_PAGE_URL=http://${apollo_config_ip}:8081 -e EUREKA_INSTANCE_PREFER_IP_ADDRESS=false \
  -v ${base_dir}/config_${env}/logs:/opt/logs \
  --name apollo-configservice-${env} apolloconfig/apollo-configservice:${ver}

docker run -p 8091:8091 -d \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://${mysql_ip}:3306/ApolloConfigDB_${env}?characterEncoding=utf8" \
  -e SPRING_DATASOURCE_USERNAME=${mysql_username} -e SPRING_DATASOURCE_PASSWORD=${mysql_password} \
  -e SERVER_PORT=8091 -e TZ='Asia/Shanghai' \
  -e EUREKA_INSTANCE_IP_ADDRESS=${apollo_config_ip} \
  -v ${base_dir}/admin_${env}/logs:/opt/logs \
  --name apollo-adminservice-${env} apolloconfig/apollo-adminservice:${ver}

env="pro"
docker run -p 8082:8082 -d \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://${mysql_ip}:3306/ApolloConfigDB_${env}?characterEncoding=utf8" \
  -e SPRING_DATASOURCE_USERNAME=${mysql_username} -e SPRING_DATASOURCE_PASSWORD=${mysql_password} \
  -e SERVER_PORT=8082 -e TZ='Asia/Shanghai' \
  -e EUREKA_INSTANCE_IP_ADDRESS=${apollo_config_ip} \
  -e EUREKA_INSTANCE_HOME_PAGE_URL=http://${apollo_config_ip}:8082 -e EUREKA_INSTANCE_PREFER_IP_ADDRESS=false \
  -v ${base_dir}/config_${env}/logs:/opt/logs \
  --name apollo-configservice-${env} apolloconfig/apollo-configservice:${ver}

docker run -p 8092:8092 -d \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://${mysql_ip}:3306/ApolloConfigDB_${env}?characterEncoding=utf8" \
  -e SPRING_DATASOURCE_USERNAME=${mysql_username} -e SPRING_DATASOURCE_PASSWORD=${mysql_password} \
  -e SERVER_PORT=8092 -e TZ='Asia/Shanghai' \
  -e EUREKA_INSTANCE_IP_ADDRESS=${apollo_config_ip} \
  -e EUREKA_INSTANCE_HOME_PAGE_URL=http://${apollo_config_ip}:8092 -e EUREKA_INSTANCE_PREFER_IP_ADDRESS=false \
  -v ${base_dir}/admin_${env}/logs:/opt/logs \
  --name apollo-adminservice-${env} apolloconfig/apollo-adminservice:${ver}

mysql_ip="my-db.cvn4awncphwh.us-west-2.rds.amazonaws.com"
mysql_username="admin"
mysql_password="jfjptKzEg2JRMsnp3Xud0"
apollo_config_ip="10.0.128.20"
base_dir="/home/ec2-user/programs/apollo"
ver="latest"
docker run -p 8070:8070 -d \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://${mysql_ip}:3306/ApolloPortalDB?characterEncoding=utf8" \
  -e SPRING_DATASOURCE_USERNAME=${mysql_username} -e SPRING_DATASOURCE_PASSWORD=${mysql_password} \
  -e APOLLO_PORTAL_ENVS=uat,pro \
  -e UAT_META=http://${apollo_config_ip}:8081 \
  -e PRO_META=http://${apollo_config_ip}:8082 \
  -v ${base_dir}/portal/logs:/opt/logs \
  --name apollo-portal apolloconfig/apollo-portal:${ver}

  