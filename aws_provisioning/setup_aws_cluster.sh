#!/bin/bash

set -e
set -x

## generated_cluster_name="$(whoami).$(date +'%m-%d-%Y')"
generated_cluster_name="ffernand.$(date +'%m-%d-%Y')"

## CLUSTER_DIR="${CLUSTER_DIR:-${HOME}/clusters/aws}"
CLUSTER_DIR="/vagrant/aws_provisioning"
TEMPLATE="${TEMPLATE:-${CLUSTER_DIR}/install-config.yaml.template}"
INSTALL_CONFIG="${INSTALL_CONFIG:-${CLUSTER_DIR}/install-config.yaml}"

#https://openshift-release.apps.ci.l2s4.p1.openshiftapps.com/
#TODO: Extract the latest? Nightly would be nice
#https://github.com/openshift/ci-chat-bot/blob/a56ad688cb83c32d37ebec0e30af982710168752/manager.go#L660
CI_VER=$(curl -vs https://openshift-release.apps.ci.l2s4.p1.openshiftapps.com/  2>&1 | grep "<a class=\"text-success\" href=\"/releasestream/4.13.0-0.ci/release/" -m1 | pup 'a text{}')
OCP_VER="${OCP_VER:-${CI_VER}}"
OCP_URL="${OCP_URL:-registry.ci.openshift.org/ocp/release:${OCP_VER}}"
# vs OpenshiftSDN
export CNI="${CNI:-OVNKubernetes}"
export CLUSTER_NAME="${CLUSTER_NAME:-${generated_cluster_name}}"
export WORKERS="${WORKERS:-3}"
export MASTERS="${MASTERS:-3}"
export REGION="${REGION:-us-east-1}"
export PULL_SECRET=$(jq -r tostring ~/.docker/config.json)

if [ -f "${CLUSTER_DIR}/metadata.json" ]; then
    echo "Some cluster already deployed, exiting..."
    exit 1
fi

echo "Saving install config to ${INSTALL_CONFIG}"
envsubst < "${TEMPLATE}" > "${INSTALL_CONFIG}"
echo "Setting up the cluster(${OCP_URL}):${CLUSTER_NAME} in ${CLUSTER_DIR}"
oc adm release extract --command openshift-install "${OCP_URL}" --to "${CLUSTER_DIR}"
"${CLUSTER_DIR}"/openshift-install create cluster --dir="${CLUSTER_DIR}"
