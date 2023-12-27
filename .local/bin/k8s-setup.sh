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
 
HELM_REPOS=(
  "prometheus-community https://prometheus-community.github.io/helm-charts"
  "metrics-server       https://kubernetes-sigs.github.io/metrics-server/"
  "ingress-nginx        https://kubernetes.github.io/ingress-nginx"
  "kyverno              https://kyverno.github.io/kyverno/"
  "aqua                 https://aquasecurity.github.io/helm-charts/"
  "getupcloud           https://charts.getup.io/getupcloud/"
  "bitnami              https://charts.bitnami.com/bitnami"
  "autoscaler           https://kubernetes.github.io/autoscaler"
  "jetstack             https://charts.jetstack.io"
  "velero               https://vmware-tanzu.github.io/helm-charts"
  "grafana              https://grafana.github.io/helm-charts"
  "elastic              https://helm.elastic.co"
  "harbor               https://helm.goharbor.io"
  "teleport             https://charts.releases.teleport.dev"
  "external-dns         https://kubernetes-sigs.github.io/external-dns/"
  "jenkins              https://charts.jenkins.io"
  "openebs              https://openebs.github.io/charts"
  "falcosecurity        https://falcosecurity.github.io/charts"
  "kong                 https://charts.konghq.com"
  "linkerd              https://helm.linkerd.io/stable"
  "gitlab               https://charts.gitlab.io"
  "istio                https://istio-release.storage.googleapis.com/charts"
  "kiali                https://kiali.org/helm-charts"
  "metallb              https://metallb.github.io/metallb"
  "appscode             https://charts.appscode.com/stable/"
  "minio                https://operator.min.io/"
  "strimzi              https://strimzi.io/charts/"
  "undistro             https://charts.undistro.io"
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
for plugin in "${KREW_PLUGINS[@]}"; do
  kubectl krew install "$plugin"
done

# Installing Teleport client
if [ "$(tsh version | awk '{sub(/v/, ""); printf $2}')" == "$TELEPORT_VERSION" ]; then
  echo "Teleport client already installed"
else
  curl https://goteleport.com/static/install.sh | bash -s "$TELEPORT_VERSION"
fi

# Installing some helm repositories
for repo in "${HELM_REPOS[@]}"; do
  helm repo add $repo
done
helm repo update
