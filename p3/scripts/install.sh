#!/bin/bash
set -e

# Installs every tool p3 needs on a fresh Debian/Ubuntu machine.
# Idempotent: each install is skipped if the tool is already present.

apt-get update -y
apt-get install -y curl ca-certificates

# ── Docker ────────────────────────────────────────────────────
if ! command -v docker >/dev/null; then
	curl -fsSL https://get.docker.com | sh
fi
# let the vagrant user run docker without sudo (takes effect on next login)
if id vagrant >/dev/null 2>&1; then
	usermod -aG docker vagrant
fi

# ── kubectl ───────────────────────────────────────────────────
# (K3s bundled kubectl in p1/p2; K3d does not — separate binary.)
if ! command -v kubectl >/dev/null; then
	KUBECTL_VERSION=$(curl -Ls https://dl.k8s.io/release/stable.txt)
	curl -Lo /usr/local/bin/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
	chmod +x /usr/local/bin/kubectl
fi

# ── K3d ───────────────────────────────────────────────────────
if ! command -v k3d >/dev/null; then
	curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

# ── Argo CD CLI ───────────────────────────────────────────────
# (The CLI only; Argo CD itself is installed into the cluster by setup.sh.)
if ! command -v argocd >/dev/null; then
	curl -sSLo /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
	chmod +x /usr/local/bin/argocd
fi

echo "=== installed versions ==="
docker --version
kubectl version --client
k3d version
argocd version --client | head -1
