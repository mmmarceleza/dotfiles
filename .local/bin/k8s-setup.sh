#!/bin/bash

TELEPORT_VERSION="14.1.3"
KREW_PLUGINS=(
  "access-matrix"     # https://github.com/corneliusweig/rakkess/blob/master/doc/USAGE.md 
  "ca-cert"           # https://github.com/ahmetb/kubectl-extras
  "deprecations"      # https://github.com/kubepug/kubepug 
  "explore"           # https://github.com/keisku/kubectl-explore
  "get-all"           # https://github.com/corneliusweig/ketall
  "kubescape"         # https://github.com/kubescape/kubescape/
  "marvin"            # https://github.com/undistro/marvin
  "popeye"            # https://popeyecli.io/
  "resource-capacity" # https://github.com/robscott/kube-capacity
  "view-cert")        # https://github.com/lmolas/kubectl-view-cert


# Install krew (https://krew.sigs.k8s.io/docs/user-guide/setup/install/)
if [ -d ~/.krew/bin/ ]; then
  echo "krew already installed"
else
  cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
fi

# Installing some plugins via krew
for plugin in "${KREW_PLUGINS[@]}"; do
  kubectl krew install "$plugin"
done

# Installing Teleport client
if [ "$(tsh version | awk '{sub(/v/, ""); printf $2}')" == "$TELEPORT_VERSION" ]; then
  echo "Teleport client already installed"
else
  curl https://goteleport.com/static/install.sh | bash -s "$TELEPORT_VERSION"
fi
