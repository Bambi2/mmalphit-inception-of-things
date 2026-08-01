#!/bin/bash
set -e

k3d cluster create iot -p "8888:8888@loadbalancer"

until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

kubectl create namespace argocd
kubectl create namespace dev

kubectl apply -n argocd --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl -n argocd rollout status deployment/argocd-server --timeout=300s

kubectl apply -f /vagrant/confs/application.yaml
