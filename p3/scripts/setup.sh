#!/bin/bash
set -e

CLUSTER=iot

# ── Create the K3d cluster ────────────────────────────────────
# Each "node" is a Docker container. The -p flag maps port 8888 on the
# VM to port 8888 of the cluster's loadbalancer, so the app is
# reachable from outside the cluster (curl localhost:8888).
if ! k3d cluster list | grep -q "^${CLUSTER}"; then
	k3d cluster create "${CLUSTER}" -p "8888:8888@loadbalancer"
fi

# Make kubectl work for the vagrant user too (k3d wrote root's config).
if id vagrant >/dev/null 2>&1; then
	mkdir -p /home/vagrant/.kube
	k3d kubeconfig get "${CLUSTER}" > /home/vagrant/.kube/config
	chown -R vagrant:vagrant /home/vagrant/.kube
	chmod 600 /home/vagrant/.kube/config
fi

until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

# ── The two required namespaces ───────────────────────────────
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace dev    --dry-run=client -o yaml | kubectl apply -f -

# ── Install Argo CD into the argocd namespace ─────────────────
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait until the Argo CD API server is actually up.
kubectl -n argocd rollout status deployment/argocd-server --timeout=300s

echo "=== cluster ready ==="
kubectl get ns
kubectl get pods -n argocd
