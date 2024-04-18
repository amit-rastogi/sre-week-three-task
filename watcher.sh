#!/bin/bash

namespace="sre"
deployment="swype-app"
max_restarts=3

while [ true ]
do

pod_name=$(kubectl get pod -l app=$deployment -n $namespace 2> /dev/null | awk 'NR=="2" {print $1}')

if [ -z "$pod_name" ]
then
  echo "Pod not found in deployment $deployment"
  exit 1
fi

restarts=$(kubectl get pod -l app=$deployment -n $namespace | awk 'NR=="2" {print $4}')
echo "Pod $pod_name restarted $restarts times"

if [ $restarts -gt $max_restarts ]
then
  echo "Restart count exceeded for Pod $pod_name. Scaling down the deployment $deployment to zero replicas "
  kubectl scale --replicas=0 deployment $deployment -n $namespace &> /dev/null
  break
else
  sleep 60
fi

done 