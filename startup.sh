#!/bin/bash

echo "Starting Jenkins and SonarQube"
aws ec2 start-instances --instance-ids $JENKINS_INSTANCE $SONARQUBE_INSTANCE
echo "Starting MySQL DB"
aws rds start-db-instance --db-instance-identifier $DATABASE
echo "Starting micro-services"

start_microservices () {
  arr=(${MICRO_SERVICES})
  for s in "${arr[@]}"
  do
    echo "Starting $s"
    aws application-autoscaling register-scalable-target \
    --service-namespace ecs --scalable-dimension ecs:service:DesiredCount \
    --resource-id service/$CLUSTER_NAME/$s \
    --min-capacity 1 --max-capacity 2 --region us-east-1
  done
}

start_microservices
echo "Startup complete"