#!/bin/bash
if [ -d 'directory' ];                                                                           # create a dir ones dir sis there it create  dir 
then
  echo 'directory is there'
else                                                                                              # 
  mkdir subbu
fi                                                                                                # fi means end..
echo 'List the pod names...'                                                                      # ehco means it show jsut print 
PODS_LIST=$(kubectl get pods | awk '{print  $1 }' | sed '1d')                                     # d means delete 
# display pod names one by one  # it show the one bye one                                         # in this for  pod list show
for get_the_pod_name in $PODS_LIST
do                                                                                                # do means more command in side run do  ..ex kubectl.....
   kubectl logs $get_the_pod_name | grep error > dir :wq!/$get_the_pod_name-$(date +'%Y-%m-%d').log    # in this one show the logs and errors in the pods >  > K8s/$get_the_pod_name-$(date +'%Y-%m-%d').log
   aws s3 cp K8s/$get_the_pod_name-$(date +'%Y-%m-%d').log s3://data-log-k                        # in this one cp the s3 in folder  all pods logs 
   echo $get_the_pod_name
done                                                                                              # done means completed
~                                                                                                                                                                                                          
~            
