function timeout() {
  SECONDS=0; TIMEOUT=$1; shift
  until eval $*; do
    sleep 5
    [[ $SECONDS -gt $TIMEOUT ]] && echo "ERROR: Timed out" && exit -1
  done
}

function wait_for_all_pods {
  timeout 300 "oc get pods -n $1 && [[ \$(oc get pods -n $1 -o jsonpath='{.items[*].status.containerStatuses[*].ready}' | grep -c 'false') -eq 0 ]]"
}
clear
/usr/local/bin/launch.sh
stty -echo
echo "export HOST1_IP=[[HOST_IP]]; export HOST2_IP=[[HOST2_IP]]" >> ~/.env; source ~/.env

curl -LOs https://raw.githubusercontent.com/fusor/mig-controller/master/hack/deploy/deploy_mig.sh &> /dev/null

echo "CAM and OpenShift Ready"
stty echo
