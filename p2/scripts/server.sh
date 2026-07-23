#!/bin/bash
set -e

SERVER_IP="$1"

apt-get update -y
apt-get install -y curl

IFACE=$(ip -o -4 addr show | awk -v ip="$SERVER_IP" '$4 ~ "^"ip"/" {print $2; exit}')

curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="--node-ip=${SERVER_IP} --flannel-iface=${IFACE} --write-kubeconfig-mode=644" \
  sh -

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done
kubectl apply -f /vagrant/confs/

for i in $(seq 60); do
  if curl -s -o /dev/null "http://${SERVER_IP}"; then
    echo "ingress is serving; cluster ready"
    break
  fi
  sleep 3
done
