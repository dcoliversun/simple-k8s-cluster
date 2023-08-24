#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

CLUSTER_NAME=simple-k8s

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd -P)

main() {
    pushd "$SCRIPT_DIR" > /dev/null

    shutdown_cluster

    popd > /dev/null
}

shutdown_cluster() {
    if ! (kind get clusters | grep --silent "$CLUSTER_NAME") &> /dev/null; then
        echo
        echo 'Kind cluster already exits.'
        echo
    else
        echo
        echo 'Closing kind cluster'
        echo

        kind delete cluster --name "$CLUSTER_NAME"

        echo
        echo 'Finished closing kind cluster'
        echo
    fi
}

main "$@"