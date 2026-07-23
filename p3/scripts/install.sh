#!/bin/bash
set -e

apt-get update -y
apt-get install -y curl ca-certificates

if ! command -v docker >/dev/null; then
	curl -fsSL https://get.docker.com | sh
fi

if ! command -v kubectl >/dev/null; then
	KUBECTL_VERSION=$(curl -Ls https://dl.k8s.io/release/stable.txt)
	curl -Lo /usr/local/bin/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
	chmod +x /usr/local/bin/kubectl
fi

if ! command -v k3d >/dev/null; then
	curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

if ! command -v argocd >/dev/null; then
	curl -sSLo /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
	chmod +x /usr/local/bin/argocd
fi

docker --version
kubectl version --client
k3d version
argocd version --client | head -1
