#!/bin/bash
export AWS_PAGER=""
export AWS_DEFAULT_OUTPUT="table"
export JENKINS_INSTANCE="i-0391c79eb1e34922b"
export SONARQUBE_INSTANCE="i-015ba44adfc9a2a9d"
export DATABASE="utopia-prod"
export CLUSTER_NAME="UtopiaCluster"
export CLUSTER_ARN="arn:aws:ecs:us-east-1:038778514259:cluster/$CLUSTER_NAME"
export MICRO_SERVICES="TicketPaymentMS DiscoveryMS OrchestratorMS FlightPlaneMS"

cd "$(dirname "${BASH_SOURCE[0]}")"

get_status_bool () {
  echo "Checking..."
  status=$(./status.sh)
  arr=(${status})
  retval="${arr[0]}"
}

arg=$1
if [[ "$arg" == "status" ]] || [[ "$arg" == "" ]]
then
  echo "Checking..."
  ./status.sh
elif [[ "$arg" == "startup" ]] || [[ "$arg" == "start" ]]
then
  export STARTING_UP=true
  get_status_bool
  if [[ "$retval" == "false" ]]
  then
    ./startup.sh
  else
    echo "Already running"
  fi
elif [[ "$arg" == "shutdown" ]] || [[ "$arg" == "stop" ]]
then
export SHUTTING_DOWN=true
  get_status_bool
  if [[ "$retval" == "false" ]]
  then
    ./shutdown.sh
  else
    echo "Already stopped"
  fi
else
  echo "invalid"
fi