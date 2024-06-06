# Definir variáveis
REPO_URL="https://github.com/GuiZucyszyn/update_zabbix_config"
REPO_DIR="/tmp/zabbix-config-repo"
CONFIG_FILE_PATH="$REPO_DIR/zabbix_agentd.conf"
DEST_CONFIG_PATH="/etc/zabbix/zabbix_agentd.conf"
SERVICE_NAME="zabbix-agent"

# Adicionar o usuário zabbix ao grupo adm
echo "Adicionando o usuário zabbix ao grupo adm..."
usermod -aG adm zabbix

# Reiniciar o serviço auditd se ele existir
if systemctl is-active --quiet auditd; then
    echo "Reiniciando o serviço auditd..."
    service auditd restart
else
    echo "O serviço auditd não está presente ou não está ativo."
fi

# Renomear o arquivo de configuração atual do Zabbix
if [ -f "$DEST_CONFIG_PATH" ]; then
    echo "Renomeando o arquivo de configuração atual do Zabbix..."
    mv "$DEST_CONFIG_PATH" "${DEST_CONFIG_PATH}.old"
else
    echo "O arquivo de configuração do Zabbix não foi encontrado."
fi

# Clonar o repositório Git ou atualizar se já existe
if [ ! -d "$REPO_DIR" ]; then
    echo "Clonando o repositório Git..."
    git clone "$REPO_URL" "$REPO_DIR"
else
    echo "Atualizando o repositório Git..."
    git -C "$REPO_DIR" pull
fi

# Copiar o novo arquivo de configuração para o caminho correto
if [ -f "$CONFIG_FILE_PATH" ]; then
    echo "Copiando o novo arquivo de configuração para o diretório..."
    cp "$CONFIG_FILE_PATH" "$DEST_CONFIG_PATH"
else
    echo "O novo arquivo de configuração não foi encontrado no repositório."
    exit 1
fi

# Reiniciar o serviço do agente do Zabbix
if systemctl is-active --quiet $SERVICE_NAME; then
    echo "Reiniciando o serviço do agente do Zabbix..."
    /etc/init.d/$SERVICE_NAME restart
else
    echo "O serviço do agente do Zabbix não está presente ou não está ativo."
fi

echo "Script concluído com sucesso."
