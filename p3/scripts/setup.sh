#!/bin/bash
set -e

CLUSTER=iot

if ! k3d cluster list | grep -q "^${CLUSTER}"; then
	k3d cluster create "${CLUSTER}" -p "8888:8888@loadbalancer"
fi

until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl -n argocd rollout status deployment/argocd-server --timeout=300s

kubectl get ns
kubectl get pods -n argocd
