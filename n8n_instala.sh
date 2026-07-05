#!/bin/bash

# =====================================================================
# INSTALADOR AUTÓNOMO TOTAL Y AUTO-ARREGLO DE N8N (VERSION NPX RUN)
# =====================================================================

echo "🔄 Iniciando verificación y limpieza del entorno..."

# Auto-arreglo 1: Remover repositorios rotos de Yarn si existen
if [ -f /etc/apt/sources.list.d/yarn.list ]; then
    echo "🧹 Eliminando repositorio roto de Yarn para desbloquear la instalación..."
    sudo rm -f /etc/apt/sources.list.d/yarn.list
fi

# Auto-arreglo 2: Verificar o instalar Node.js v20
if ! command -v node &> /dev/null; then
    echo "📦 Node.js no detectado. Configurando NodeSource e instalando Node.js v20..."
    sudo apt-get update -y
    sudo apt-get install -y curl gnupg
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
    sudo apt-get update -y
    sudo apt-get install -y nodejs
else
    echo "✅ Node.js ya instalado: $(node --version)"
fi

# 3. Forzar instalación y configuración de rutas de PNPM
if ! command -v pnpm &> /dev/null; then
    echo "📦 Instalando PNPM globalmente de forma directa..."
    sudo npm install -g pnpm
else
    echo "✅ PNPM detectado: $(pnpm --version)"
fi

# Configurar directorio global explícito para evitar ERR_PNPM_NO_GLOBAL_BIN_DIR
export PNPM_HOME="/root/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
sudo pnpm config set global-bin-dir /usr/local/bin

# 4. Instalar n8n globalmente usando PNPM
if ! command -v n8n &> /dev/null; then
    echo "📦 Instalando n8n de forma global con PNPM..."
    sudo pnpm add -g n8n
else
    echo "✅ n8n ya se encuentra instalado."
fi

# 5. Inyectar variables de optimización de tu documentación para cuidar la memoria
export N8N_HOST="localhost"
export N8N_PORT=5678
export N8N_PROTOCOL="http"
export EXECUTIONS_PROCESS="main"             # Forzar proceso único
export EXECUTIONS_TIMEOUT=3600               # 1 hora máximo por flujo
export EXECUTIONS_DATA_SAVE_ON_ERROR="none"  # Cero acumulación de basura en disco

# Asignar límite de memoria directamente a las variables de Node antes del arranque
export NODE_OPTIONS="--max-old-space-size=4096"

# 6. Forzar visibilidad del puerto en tu Codespace
echo "🔓 Abriendo puerto 5678 en modo público..."
gh codespace ports visibility 5678:public >/dev/null 2>&1

# 7. Imprimir enlace final listo para usar
echo -e "\n=================================================================="
echo -e "🚀 ¡Todo listo! Tu entorno n8n se está ejecutando."
echo -e "🔗 Haz Ctrl + Clic (Cmd + Clic en Mac) en el siguiente enlace para abrir la interfaz:"
echo -e "   https://${CODESPACE_NAME}-5678.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
echo -e "==================================================================\n"

# 8. Arrancar usando npx de forma directa para evitar conflictos de rutas
npx n8n start