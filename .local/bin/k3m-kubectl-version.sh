#!/bin/bash

for page in {1..4}
do
  KUBECTL_VERSION_ARRAY+=($(curl -s https://api.github.com/repos/kubernetes/kubernetes/releases?page="$page" | jq -r '.[] | .tag_name'))
done

# Obtém a versão do kubectl fornecida como argumento
KUBECTL_VERSION=$(printf "%s\n" "${KUBECTL_VERSION_ARRAY[@]}" | fzf --prompt="Select kubectl version: ")

# Define a pasta de destino para os binários
BIN_DIR="$HOME/.local/bin/kubectl-binaries"

# Cria a pasta de destino se não existir
mkdir -p "$BIN_DIR"

# Define o nome do arquivo
KUBECTL_FILE="kubectl-$KUBECTL_VERSION"

# Verifica se o binário já existe na pasta
if [ -e "$BIN_DIR/$KUBECTL_FILE" ]; then
    # Se existir, apenas recria o link simbólico
    ln -sf "$BIN_DIR/$KUBECTL_FILE" "$HOME/.local/bin/kubectl"
    echo "Link simbólico recriado para $KUBECTL_FILE."
    exit 0
fi

# Define a URL para baixar o binário
KUBECTL_URL="https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"

# Baixa o binário para a pasta /tmp
curl -L "$KUBECTL_URL" -o "/tmp/$KUBECTL_FILE"

# Baixa o checksum
curl -L "$KUBECTL_URL.sha256" -o "/tmp/$KUBECTL_FILE.sha256"

# Valida o binário usando checksum
if sha256sum --status -c <<<"$(cat /tmp/"$KUBECTL_FILE".sha256)  /tmp/$KUBECTL_FILE"; then
    echo "Checksum OK. Binário válido."
else
    echo "Erro: Checksum falhou. Binário corrompido."
    exit 1
fi

# Move o binário para a pasta de destino
mv "/tmp/$KUBECTL_FILE" "$BIN_DIR/"

# Dá permissão de execução para o binário
chmod +x "$BIN_DIR/$KUBECTL_FILE"

# Cria um link simbólico para o binário na pasta ~/.local/bin/
ln -sf "$BIN_DIR/$KUBECTL_FILE" "$HOME/.local/bin/kubectl"

echo "$KUBECTL_FILE instalado com sucesso!"

