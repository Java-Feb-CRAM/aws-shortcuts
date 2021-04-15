#!/bin/bash
running=true

if [[ "$STARTING_UP" == "true" ]]
then
  running=true
elif [[ "$SHUTTING_DOWN" == "true" ]]
then
  running=false
fi

statusText=""
get_ec2_status () {
  retval=$(aws ec2 describe-instance-status \
  --instance-ids $1 \
  --include-all-instances --output json \
  | jq -r .InstanceStatuses[0].InstanceState.Name)
  if [[ "$retval" != "running" ]]
  then
    if [[ "$STARTING_UP" == "true" ]]
    then
      running=false
    else
      running=true
    fi
  fi
}

get_ec2_status $JENKINS_INSTANCE
jenkinsStatus=$retval
statusText="Jenkins: $jenkinsStatus ) $statusText"
get_ec2_status $SONARQUBE_INSTANCE
sonarStatus=$retval
statusText="SonarQube: $sonarStatus, $statusText"

get_rds_status () {
  retval=$(aws rds describe-db-instances \
  --db-instance-identifier $DATABASE \
  --output json | jq -r .DBInstances[0].DBInstanceStatus)
  if [[ "$retval" != "available" ]]
  then
    if [[ "$STARTING_UP" == "true" ]]
    then
      running=false
    else
      running=true
    fi
  fi
}
get_rds_status
rdsStatus=$retval
statusText="RDS: $rdsStatus, $statusText"

get_service_status () {
  retval=$(aws ecs describe-services \
  --cluster $CLUSTER_ARN --services $1 \
  --output json | jq -r .services[0].runningCount)
  if [[ "$retval" != "1" ]]
  then
    if [[ "$STARTING_UP" == "true" ]]
    then
      running=false
    else
      running=true
    fi
  fi
}

arr=(${MICRO_SERVICES})
for s in "${arr[@]}"
do
  get_service_status $s
  msStatus=$retval
  statusText="$s: $msStatus, $statusText"
done

echo "$running ( $statusText"