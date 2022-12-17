#!/bin/bash
set -eo pipefail
set -x

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. ${SCRIPT_DIR}/deploy_ocp_SDN.source

build_and_push_custom_sdn
