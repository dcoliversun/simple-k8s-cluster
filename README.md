# simple-k8s-cluster

Manage a kind cluster with Prometheus / Grafana / Loki for educational or experimental purposes.

## Pre-requisites

The following pre-requisites must be installed:

* [Helm 3](https://helm.sh/)
* [kubectl](https://kubernetes.io/de/docs/tasks/tools/install-kubectl/)
* [Docker](https://www.docker.com/)
* [kind](https://github.com/kubernetes-sigs/kind/)

## Usage

Run `bash ./setup.sh`.  
This will create a kind cluster and install all services.  

Run `bash ./shutdown.sh`.  
This will close a kind cluster.

## Components
* kind: one master and three workers
* ingress-nginx
* prometheus
* grafana
* loki
* promtail

## Reachable Service
* Grafana: http://localhost:30123/grafana