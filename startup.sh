#!/bin/bash
export AWS_PAGER=""
echo "Starting Jenkins and SonarQube"
aws ec2 start-instances --instance-ids "i-0391c79eb1e34922b" "i-015ba44adfc9a2a9d" --no-paginate --output table
echo "Starting MySQL DB"
aws rds start-db-instance --db-instance-identifier "utopia-prod" --no-paginate --output table
echo "Starting micro-services"

start_microservices () {
  arr=("$@")
  for s in "${arr[@]}"
  do
    echo "Starting $s"
    aws application-autoscaling register-scalable-target \
    --service-namespace ecs --scalable-dimension ecs:service:DesiredCount \
    --resource-id service/UtopiaCluster/$s \
    --min-capacity 1 --max-capacity 2 --region us-east-1 \
    --no-paginate --output table
  done
}

micro_services=("TicketPaymentMS" "DiscoveryMS" "OrchestratorMS" "FlightPlaneMS")
start_microservices "${micro_services[@]}"
echo "Startup complete"