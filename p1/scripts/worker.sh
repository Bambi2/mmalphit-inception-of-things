#!/bin/sh
set -e

SERVER_IP="$1"
WORKER_IP="$2"

apt-get update -y
apt-get install -y curl

IFACE=$(ip -o -4 addr show | awk -v ip="$WORKER_IP" '$4 ~ "^"ip"/" {print $2; exit}')

while [! -f /vagrant/confs/node-token ]; do sleep 2; done
TOKEN=$(cat /vagrant/confs/node-token)

curl -fsSL https://get.k3s.io | \
	K3S_URL="https://${SERVER_IP}:6443" \
	K3S_TOKEN="${TOKEN}" \
	INSTALL_K3S_EXEC="--node-ip=${WORKER_IP} --flannel-iface=${IFACE}" \
	sh -


