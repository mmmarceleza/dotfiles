#!/usr/bin/env bash
#
# k8s-setup.sh - Bootstrap Kubernetes development tooling
#
# Author:      Marcelo Marques Melo
#
# --------------------------------------------------------------
# Sets up a Kubernetes development environment by installing:
#   - krew (kubectl plugin manager) and selected plugins
#   - Helm chart repositories
#   - hcl2json (HCL to JSON converter)
#   - kubescape (Kubernetes security scanner)
#
# Binaries are downloaded to ~/.local/bin/download-binaries and
# symlinked into ~/.local/bin for PATH availability.
#
# Usage:
#   ./k8s-setup.sh [options]
#
# Examples:
#   ./k8s-setup.sh                # Install everything
#   ./k8s-setup.sh --skip-krew    # Skip krew and plugins
#   ./k8s-setup.sh --skip-helm    # Skip helm repositories
#   ./k8s-setup.sh --dry-run      # Show what would be done
#
# Dependencies:
#   - curl
#   - jq
#   - kubectl
#   - helm
#   - tar
#
# --------------------------------------------------------------
# Changelog:
#
#   v2.0 2026-03-30, Marcelo Marques Melo:
#       - Rewrite following bash best practices
#       - Add argument parsing, dependency checks, dry-run mode
#       - Detect architecture automatically for all downloads
#       - Add structured logging and error handling
#
#   v1.0 2024-01-01, Marcelo Marques Melo:
#       - Initial version
#
# License: MIT
# --------------------------------------------------------------

set -euo pipefail

# --- Global constants ---------------------------------------------------------

readonly SCRIPT_NAME="${BASH_SOURCE[0]##*/}"

readonly BIN_DIR="${HOME}/.local/bin/download-binaries"
readonly LINK_DIR="${HOME}/.local/bin"
readonly KREW_DIR="${HOME}/.krew/bin"

readonly KREW_PLUGINS=(
  "access-matrix"      # https://github.com/corneliusweig/rakkess
  "ca-cert"            # https://github.com/ahmetb/kubectl-extras
  "deprecations"       # https://github.com/kubepug/kubepug
  "explore"            # https://github.com/keisku/kubectl-explore
  "get-all"            # https://github.com/corneliusweig/ketall
  "ingress-nginx"      # https://kubernetes.github.io/ingress-nginx/kubectl-plugin/
  "kubescape"          # https://github.com/kubescape/kubescape/
  "marvin"             # https://github.com/undistro/marvin
  "popeye"             # https://popeyecli.io/
  "resource-capacity"  # https://github.com/robscott/kube-capacity
  "view-cert"          # https://github.com/lmolas/kubectl-view-cert
)

readonly HELM_REPOS=(
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

# --- Runtime state ------------------------------------------------------------

SKIP_KREW=false
SKIP_HELM=false
SKIP_BINARIES=false
DRY_RUN=false
OS=""
ARCH=""

# --- Utility functions --------------------------------------------------------

die() {
  printf '%s: error: %s\n' "${SCRIPT_NAME}" "$1" >&2
  exit "${2:-1}"
}

log_info() {
  printf '[INFO]  %s\n' "$1"
}

log_warn() {
  printf '[WARN]  %s\n' "$1" >&2
}

log_skip() {
  printf '[SKIP]  %s\n' "$1"
}

# --- Dependency checks --------------------------------------------------------

check_dependencies() {
  local deps=("curl" "jq")
  local missing=()

  if [[ "${SKIP_KREW}" == false ]]; then
    deps+=("kubectl")
  fi
  if [[ "${SKIP_HELM}" == false ]]; then
    deps+=("helm")
  fi

  for dep in "${deps[@]}"; do
    if ! command -v "${dep}" &>/dev/null; then
      missing+=("${dep}")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    die "missing required commands: ${missing[*]}"
  fi
}

# --- Detect platform ----------------------------------------------------------

detect_platform() {
  OS="$(uname | tr '[:upper:]' '[:lower:]')"
  local machine
  machine="$(uname -m)"

  case "${machine}" in
    x86_64)  ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    arm*)    ARCH="arm" ;;
    *)       die "unsupported architecture: ${machine}" ;;
  esac

  log_info "detected platform: ${OS}/${ARCH}"
}

# --- Usage --------------------------------------------------------------------

usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [options]

Bootstrap Kubernetes development tooling.

Options:
  --skip-krew       Skip krew and plugin installation
  --skip-helm       Skip helm repository setup
  --skip-binaries   Skip binary downloads (hcl2json, kubescape)
  --dry-run         Show what would be done without executing
  -h, --help        Show this help message

EOF
}

# --- Argument parsing ---------------------------------------------------------

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skip-krew)     SKIP_KREW=true ;;
      --skip-helm)     SKIP_HELM=true ;;
      --skip-binaries) SKIP_BINARIES=true ;;
      --dry-run)       DRY_RUN=true ;;
      -h|--help)       usage; exit 0 ;;
      --)              shift; break ;;
      -*)              die "unknown option: $1 (use --help for usage)" ;;
      *)               die "unexpected argument: $1 (use --help for usage)" ;;
    esac
    shift
  done
}

# --- Krew setup ---------------------------------------------------------------

install_krew() {
  if [[ "${SKIP_KREW}" == true ]]; then
    log_skip "krew installation (--skip-krew)"
    return
  fi

  if [[ -d "${KREW_DIR}" ]]; then
    log_info "krew already installed"
  else
    log_info "installing krew..."
    if [[ "${DRY_RUN}" == true ]]; then
      log_info "(dry-run) would install krew"
      return
    fi

    local tmpdir
    tmpdir="$(mktemp -d)"
    local krew_file="krew-${OS}_${ARCH}"

    curl -fsSL \
      "https://github.com/kubernetes-sigs/krew/releases/latest/download/${krew_file}.tar.gz" \
      -o "${tmpdir}/${krew_file}.tar.gz" \
      || die "failed to download krew"

    tar -xzf "${tmpdir}/${krew_file}.tar.gz" -C "${tmpdir}" \
      || die "failed to extract krew"

    "${tmpdir}/${krew_file}" install krew \
      || die "failed to install krew"

    rm -rf -- "${tmpdir}"
  fi

  # Ensure krew is in PATH for the rest of this script
  export PATH="${KREW_DIR}:${PATH}"
}

install_krew_plugins() {
  if [[ "${SKIP_KREW}" == true ]]; then
    return
  fi

  log_info "installing krew plugins..."
  for plugin in "${KREW_PLUGINS[@]}"; do
    if kubectl krew list 2>/dev/null | grep -q "^${plugin}$"; then
      log_info "krew plugin already installed: ${plugin}"
    else
      if [[ "${DRY_RUN}" == true ]]; then
        log_info "(dry-run) would install krew plugin: ${plugin}"
      else
        log_info "installing krew plugin: ${plugin}"
        kubectl krew install "${plugin}" || log_warn "failed to install plugin: ${plugin}"
      fi
    fi
  done
}

# --- Helm setup ---------------------------------------------------------------

setup_helm_repos() {
  if [[ "${SKIP_HELM}" == true ]]; then
    log_skip "helm repositories (--skip-helm)"
    return
  fi

  log_info "adding helm repositories..."
  for entry in "${HELM_REPOS[@]}"; do
    local name url
    read -r name url <<< "${entry}"

    if [[ "${DRY_RUN}" == true ]]; then
      log_info "(dry-run) would add helm repo: ${name} -> ${url}"
    else
      helm repo add "${name}" "${url}" 2>/dev/null \
        || log_warn "failed to add helm repo: ${name}"
    fi
  done

  if [[ "${DRY_RUN}" == false ]]; then
    log_info "updating helm repositories..."
    helm repo update || log_warn "helm repo update failed"
  fi
}

# --- Binary downloads ---------------------------------------------------------

download_github_binary() {
  local name="$1"
  local repo="$2"
  local asset_name="$3"

  if command -v "${name}" &>/dev/null; then
    log_info "${name} already installed"
    return
  fi

  if [[ "${DRY_RUN}" == true ]]; then
    log_info "(dry-run) would download ${name} from ${repo}"
    return
  fi

  log_info "downloading ${name}..."
  local download_url
  download_url=$(
    curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" \
      | jq -r --arg name "${asset_name}" \
        '.assets[] | select(.name == $name) | .browser_download_url'
  ) || die "failed to fetch release info for ${name}"

  if [[ -z "${download_url}" ]]; then
    die "could not find asset '${asset_name}' in ${repo} releases"
  fi

  curl -fsSL "${download_url}" -o "${BIN_DIR}/${name}" \
    || die "failed to download ${name}"

  chmod +x "${BIN_DIR}/${name}"
  ln -sf "${BIN_DIR}/${name}" "${LINK_DIR}/${name}"

  log_info "${name} installed to ${LINK_DIR}/${name}"
}

install_binaries() {
  if [[ "${SKIP_BINARIES}" == true ]]; then
    log_skip "binary downloads (--skip-binaries)"
    return
  fi

  mkdir -p "${BIN_DIR}"

  download_github_binary \
    "hcl2json" \
    "tmccombs/hcl2json" \
    "hcl2json_${OS}_${ARCH}"

  download_github_binary \
    "kubescape" \
    "kubescape/kubescape" \
    "kubescape-${OS}-latest"
}

# --- Main ---------------------------------------------------------------------

main() {
  parse_args "$@"

  if [[ "${DRY_RUN}" == true ]]; then
    log_info "running in dry-run mode (no changes will be made)"
  fi

  check_dependencies
  detect_platform

  install_krew
  install_krew_plugins
  setup_helm_repos
  install_binaries

  log_info "k8s-setup complete"
}

main "$@"
