#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

INGRESS_NGINX_VERSION=4.7.0
PROMETHEUS_VERSION=23.4.0
GRAFANA_VERSION=6.58.9
MINIO_VERSION=12.7.0
LOKI_VERSION=5.15.0
PROMTAIL_VERSION=6.15.0

CLUSTER_NAME=simple-k8s

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd -P)

main() {
    pushd "$SCRIPT_DIR" > /dev/null

    setup_cluster
    setup_ingress_nginx
    setup_prometheus
    setup_grafana
    setup_loki
    setup_promtail
    show_grafana_password

    popd > /dev/null
}

setup_cluster() {
    if ! (kind get clusters | grep --silent "$CLUSTER_NAME") &> /dev/null; then
        echo
        echo 'Create kind cluster'
        echo

        kind create cluster --name="$CLUSTER_NAME" --config=config/kind/config.yaml

        echo
        echo 'Finished creating kind cluster'
        echo
    else
        echo
        echo 'Kind cluster already exists. Re-using it'
        echo
    fi
}

setup_ingress_nginx() {
    log_start ingress_nginx

    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx --force-update

    helm upgrade ingress-nginx ingress-nginx/ingress-nginx --install --wait \
        --version="$INGRESS_NGINX_VERSION" \
        --namespace=ingress --create-namespace \
        --values=config/ingress-nginx/values.yaml

    log_finished ingress_nginx
}

setup_prometheus() {
    log_start prometheus

    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts --force-update

    helm upgrade prometheus prometheus-community/prometheus --install --wait \
        --version="$PROMETHEUS_VERSION" \
        --namespace=monitoring --create-namespace \
        --values=config/monitoring/prometheus/values.yaml

    log_finished prometheus
}

setup_grafana() {
    log_start grafana

    helm repo add grafana https://grafana.github.io/helm-charts --force-update
    helm upgrade grafana grafana/grafana --install --wait \
        --version="$GRAFANA_VERSION" \
        --namespace=monitoring --create-namespace \
        --values=config/monitoring/grafana/values.yaml

    log_finished grafana
}

setup_loki() {
    log_start loki
    
    helm repo add grafana https://grafana.github.io/helm-charts --force-update
    helm upgrade loki grafana/loki --install --wait \
        --version="$LOKI_VERSION" \
        --namespace=logging --create-namespace \
        --values=config/loki/values.yaml

    log_finished loki
}

setup_promtail() {
    log_start promtail

    kubectl apply --filename=charts/promtail/promtail.yaml
    # helm repo add grafana https://grafana.github.io/helm-charts --force-update
    # helm upgrade promtail grafana/promtail --install --wait \
    #     --version="$PROMTAIL_VERSION" \
    #     --namespace=logging --create-namespace


    log_finished promtail
}

show_grafana_password() {
    echo
    echo "User admin password is "
    kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
    echo
}

log_start() {
    echo
    echo "Installing $1"
    echo
}

log_finished() {
    echo
    echo "Finished installing $1"
    echo
}

main "$@"
