#!/bin/bash

# Teleport client version to download
# TELEPORT_VERSION="14.3.32"

# Default path to download binaries (it is listed in the .gitignore)
BIN_DIR="$HOME/.local/bin/download-binaries"
mkdir -p "$BIN_DIR"

# krew plugins to use in the system (https://krew.sigs.k8s.io/plugins/)
KREW_PLUGINS=(
  "access-matrix"     # https://github.com/corneliusweig/rakkess/blob/master/doc/USAGE.md 
  "ca-cert"           # https://github.com/ahmetb/kubectl-extras
  "deprecations"      # https://github.com/kubepug/kubepug 
  "explore"           # https://github.com/keisku/kubectl-explore
  "get-all"           # https://github.com/corneliusweig/ketall
  "ingress-nginx"     # https://kubernetes.github.io/ingress-nginx/kubectl-plugin/
  "kubescape"         # https://github.com/kubescape/kubescape/
  "marvin"            # https://github.com/undistro/marvin
  "popeye"            # https://popeyecli.io/
  "resource-capacity" # https://github.com/robscott/kube-capacity
  "view-cert")        # https://github.com/lmolas/kubectl-view-cert

# Helm repositories to use in the system
HELM_REPOS=(
  "appscode             https://charts.appscode.com/stable/"
  "aqua                 https://aquasecurity.github.io/helm-charts/"
  "argo                 https://argoproj.github.io/argo-helm"
  "autoscaler           https://kubernetes.github.io/autoscaler"
  "aws-ebs-csi-driver   https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  "aws-efs-csi-driver   https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  "bitnami              https://charts.bitnami.com/bitnami"
  "eks                  https://aws.github.io/eks-charts"
  "elastic              https://helm.elastic.co"
  "external-dns         https://kubernetes-sigs.github.io/external-dns/"
  "external-secrets     https://charts.external-secrets.io"
  "falcosecurity        https://falcosecurity.github.io/charts"
  "getupcloud           https://charts.getup.io/getupcloud/"
  "gitlab               https://charts.gitlab.io"
  "grafana              https://grafana.github.io/helm-charts"
  "harbor               https://helm.goharbor.io"
  "hashicorp            https://helm.releases.hashicorp.com"
  "ingress-nginx        https://kubernetes.github.io/ingress-nginx"
  "istio                https://istio-release.storage.googleapis.com/charts"
  "jenkins              https://charts.jenkins.io"
  "jetstack             https://charts.jetstack.io"
  "kedacore             https://kedacore.github.io/charts"
  "kiali                https://kiali.org/helm-charts"
  "kong                 https://charts.konghq.com"
  "kubernetes-dashboard https://kubernetes.github.io/dashboard"
  "kyverno              https://kyverno.github.io/kyverno/"
  "linkerd              https://helm.linkerd.io/stable"
  "metallb              https://metallb.github.io/metallb"
  "metrics-server       https://kubernetes-sigs.github.io/metrics-server/"
  "minio                https://operator.min.io/"
  "openebs              https://openebs.github.io/charts"
  "open-telemetry       https://open-telemetry.github.io/opentelemetry-helm-charts"
  "podinfo              https://stefanprodan.github.io/podinfo"
  "prometheus-community https://prometheus-community.github.io/helm-charts"
  "rancher-charts       https://charts.rancher.io"
  "rancher-stable       https://releases.rancher.com/server-charts/stable"
  "strimzi              https://strimzi.io/charts/"
  "teleport             https://charts.releases.teleport.dev"
  "undistro             https://charts.undistro.io"
  "velero               https://vmware-tanzu.github.io/helm-charts"
  )

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
source "$HOME"/.bashrc
for plugin in "${KREW_PLUGINS[@]}"; do
  if kubectl krew info "$plugin" >/dev/null 2>&1; then
    echo "$plugin plugin, for kubectl, is already installed"
  else
    kubectl krew install "$plugin"
  fi
done

# Installing Teleport client
# if [[ "$(tsh version | awk '{printf $2; sub(/v/, "")}')" = "$TELEPORT_VERSION" ]]; then
#   echo "Teleport client already installed"
# else
#   curl https://goteleport.com/static/install.sh | bash -s "$TELEPORT_VERSION"
# fi

# Installing some helm repositories
for repo in "${HELM_REPOS[@]}"; do
  helm repo add $repo
done
helm repo update

# Installing Flux client


# Installing hcl2json
if [ "$(command -v hcl2json)" ]; then
  echo "hcl2json already installed"
else
  DOWNLOAD_URL_HCL2JSON=$(curl -s https://api.github.com/repos/tmccombs/hcl2json/releases/latest \
    | jq -r --arg name "hcl2json_linux_amd64" '.assets[] | select(.name == $name) | .browser_download_url')
  curl -fsSL "$DOWNLOAD_URL_HCL2JSON" -o "$BIN_DIR/hcl2json"
  chmod +x "$BIN_DIR"/hcl2json
  ln -sf "$BIN_DIR"/hcl2json "$HOME"/.local/bin/hcl2json
  echo "hcl2json instalado em $HOME/.local/bin/"
fi

# Installing kubescape
if [ "$(command -v kubescape)" ]; then
  echo "kubescape already installed"
else
  DOWNLOAD_URL_KUBESCAPE=$(curl -s https://api.github.com/repos/kubescape/kubescape/releases/latest \
    | jq -r --arg name "kubescape-ubuntu-latest" '.assets[] | select(.name == $name) | .browser_download_url')
  curl -fsSL "$DOWNLOAD_URL_KUBESCAPE" -o "$BIN_DIR/kubescape"
  chmod +x "$BIN_DIR"/kubescape
  ln -sf "$BIN_DIR"/kubescape "$HOME"/.local/bin/kubescape
  echo "kubescape instalado em $HOME/.local/bin/"
fi
