#!/bin/bash
set -e

SERVER_IP="$1"

apt-get update -y
apt-get install -y curl

IFACE=$(ip -o -4 addr show | awk -v ip="$SERVER_IP" '$4 ~ "^"ip"/" {print $2; exit}')

curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="--node-ip=${SERVER_IP} --flannel-iface=${IFACE} --write-kubeconfig-mode=644" \
  sh -

# Apply manifests with kubectl (NOT the auto-deploy folder, which
# silently drops malformed fields instead of reporting them).
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done
kubectl apply -f /vagrant/confs/
