#!/bin/bash
set -e

k3d cluster create iot -p "8888:8888@loadbalancer" -p "80:80@loadbalancer"

until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

echo "127.0.0.1 gitlab.gitlab.svc.cluster.local" >> /etc/hosts

kubectl create namespace gitlab
kubectl create namespace argocd
kubectl create namespace dev

kubectl apply -f /home/mmalphit/bonus/confs/gitlab.yaml

kubectl apply -n argocd --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl -n argocd rollout status deployment/argocd-server --timeout=300s

kubectl -n gitlab rollout status deployment/gitlab --timeout=900s
