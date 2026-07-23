#!/bin/bash
set -e

apt-get update -y
apt-get install -y curl

curl -fsSL https://get.docker.com | sh

KUBECTL_VERSION=$(curl -Ls https://dl.k8s.io/release/stable.txt)
curl -Lo /usr/local/bin/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x /usr/local/bin/kubectl

curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

curl -sSLo /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd
