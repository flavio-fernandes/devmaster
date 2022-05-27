#!/bin/bash
set -eo pipefail
set -x

OVNK="/home/vagrant/dev/ovn-kubernetes.git.ds/dist/images"

[ -z "$1" ] && echo "need tag" && exit 1

tag=$1
echo "tag used: $tag"
cd "$OVNK"
make fedora
docker tag ovn-kube-f:latest quay.io/ffernand/ovnk:$tag
docker push quay.io/ffernand/ovnk:$tag

oc patch clusterversion version --type json -p '[{"op":"add","path":"/spec/overrides","value":[{"kind":"Deployment","group":"apps","name":"network-operator","namespace":"openshift-network-operator","unmanaged":true}]}]'
oc -n openshift-network-operator delete deployment network-operator || true
# oc -n openshift-ovn-kubernetes set image ds/ovnkube-node ovnkube-node=quay.io/ffernand/ovnk:$tag
oc -n openshift-ovn-kubernetes set image ds/ovnkube-master ovnkube-master=quay.io/ffernand/ovnk:$tag

oc get pods -n openshift-ovn-kubernetes

