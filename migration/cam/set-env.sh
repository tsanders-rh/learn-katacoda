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

#Update CORS config
dahn=mig-ui-mig.[[HOST_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com
dahn=$(echo $dahn | sed 's/\./\\./g')
awk 'FNR==NR{ if (/(?i)/) p=NR; next} 1; FNR==p{ print "- (?i)//'"$dahn"'(:|\\z)" }' /etc/origin/master/master-config.yaml /etc/origin/master/master-config.yaml > tmpfile && mv -f tmpfile /etc/origin/master/master-config.yaml

/usr/local/bin/launch.sh
stty -echo
echo "export HOST1_IP=[[HOST_IP]]; export HOST2_IP=[[HOST2_IP]]" >> ~/.env; source ~/.env

#Install CRs
curl -LOs https://raw.githubusercontent.com/fusor/mig-controller/master/hack/deploy/deploy_mig.sh &> /dev/null
chmod +x deploy_mig.sh
./deploy_mig.sh

curl -LOs https://raw.githubusercontent.com/fusor/mig-controller/master/hack/deploy/deploy_velero.sh &> /dev/null
chmod +x deploy_velero.sh
./deploy_velero.sh

#Install UI
#git clone https://github.com/fusor/mig-ui
git clone -b http-deployment --single-branch https://github.com/eriknelson/mig-ui.git
cd ./mig-ui/deploy
#dadomain=$(oc get routes -n mig | grep ^mig-ui | awk '{print $2}' | cut -d . -f 2- -) | sed 's/^/https:\/\//'
#HOSTAPI=$dadomain ./deploy.sh
dahostname=https://[[HOST_SUBDOMAIN]]-[[KATACODA_HOST]].environments.katacoda.com
HOSTAPI=$dahostname ./deploy.sh

echo "CAM and OpenShift Ready"
stty echo
