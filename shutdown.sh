#!/bin/bash

echo "Stopping Jenkins and SonarQube"
aws ec2 stop-instances --instance-ids $JENKINS_INSTANCE $SONARQUBE_INSTANCE
echo "Stopping MySQL DB"
aws rds stop-db-instance --db-instance-identifier $DATABASE
echo "Stopping micro-services"

stop_task () {
  read output
  parts=(${output})
  taskArn=${parts[1]}
  echo "Stopping task $taskArn"
  aws ecs stop-task --cluster $CLUSTER_ARN --task $taskArn
  echo "Task stopped"
}

stop_microservices () {
  arr=(${MICRO_SERVICES})
  for s in "${arr[@]}"
  do
    echo "Stopping $s"
    aws application-autoscaling register-scalable-target \
    --service-namespace ecs --scalable-dimension ecs:service:DesiredCount \
    --resource-id service/$CLUSTER_NAME/$s \
    --min-capacity 0 --max-capacity 0 --region us-east-1
    aws ecs list-tasks --cluster $CLUSTER_ARN --service-name $s --output text | stop_task
  done
}

stop_microservices
echo "Shutdown complete"

