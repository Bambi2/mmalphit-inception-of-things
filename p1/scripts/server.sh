#!/bin/bash
set -e

SERVER_IP="$1"

apt-get update -y
apt-get install -y curl

IFACE=$(ip -o -4 addr show | awk -v ip="$SERVER_IP" '$4 ~ "^"ip"/" {print $2; exit}')

curl -fsSL https://get.k3s.io | \
 INSTALL_K3S_EXEC="--node-ip ${SERVER_IP} --flannel-iface=${IFACE} --write-kubeconfig-mode=644" \
 sh -

while [ ! -f /var/lib/rancher/k3s/server/node-token ]; do sleep 2; done

mkdir -p /vagrant/confs
cp /var/lib/rancher/k3s/server/node-token /vagrant/confs/node-token