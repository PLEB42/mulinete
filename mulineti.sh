#!/bin/bash

# ==============================================================================
# BLOCO: AMBIENTE_E_INFRAESTRUTURA [v12]
# O QUE FAZ: Resolve caminhos absolutos e prepara a pasta de logs.
# ==============================================================================
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
readonly TOOL_ROOT="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
readonly CURRENT_INVOCATION_DIR=$(pwd)
readonly SANDBOX_PATH="$CURRENT_INVOCATION_DIR/mulineti_tmp"
readonly LOGS_DIR="$TOOL_ROOT/logs"

mkdir -p "$LOGS_DIR"

# Cores para UI
readonly PINK='\033[38;5;206m'; readonly BLUE='\033[38;5;39m'; readonly DEFAULT='\033[0m'
readonly BOLD='\033[1m'; readonly CYAN='\033[38;5;51m'; readonly YELLOW='\033[38;5;226m'; readonly RED='\033[0;31m'

# ==============================================================================
# BLOCO: PROJECT_DISPATCHER [v2]
# O QUE FAZ: Prepara a sandbox e dispara o test.sh com o log correto.
# ==============================================================================
preparar_e_executar() {
    local projeto=$1
    local log_path="$LOGS_DIR/${projeto}.txt"
    
    # Limpeza e Preparação
    rm -rf "$SANDBOX_PATH" &>/dev/null
    mkdir -p "$SANDBOX_PATH"
    
    # Copia a pasta interna da engine para a sandbox
    if [[ -d "$TOOL_ROOT/mulineti" ]]; then
        cp -R "$TOOL_ROOT/mulineti/." "$SANDBOX_PATH/"
    else
        printf "${RED}❌ Erro Crítico: Pasta 'mulineti' (engine) não encontrada.${DEFAULT}\n"
        exit 1
    fi

    # Handshake com a Engine
    if [[ -f "$SANDBOX_PATH/test.sh" ]]; then
        cd "$SANDBOX_PATH" || exit 1
        bash ./test.sh "$projeto" 0 "$log_path"
        cd "$CURRENT_INVOCATION_DIR" || exit 1
    else
        printf "${RED}❌ Erro: test.sh não encontrado na sandbox.${DEFAULT}\n"
    fi
    rm -rf "$SANDBOX_PATH" &>/dev/null
}

# ==============================================================================
# BLOCO: UI_MENU_SYSTEM [v2]
# O QUE FAZ: Interface para projetos fora do fluxo automático da Piscina.
# ==============================================================================
exibir_submenu_common_core() {
    printf "\n${BLUE}--- Common Core - Milestones ---${DEFAULT}\n"
    printf "1. Milestone 0 (Libft)\n"
    printf "2. Voltar\n"
    printf "Escolha: "
    read -r sub
    case $sub in
        1) preparar_e_executar "Libft" ;;
        2) exibir_menu_principal ;;
    esac
}

exibir_menu_principal() {
    clear
    printf "${PINK}${BOLD}╔══════════════════════════════════════════════════════════════╗${DEFAULT}\n"
    printf "${PINK}${BOLD}║              🌊  MULINETI - COMMAND CENTER                   ║${DEFAULT}\n"
    printf "${PINK}${BOLD}╚══════════════════════════════════════════════════════════════╝${DEFAULT}\n"
    printf "${CYAN}1. Piscina (Auto-Detect)${DEFAULT}\n"
    printf "${CYAN}2. Piscine Reloaded${DEFAULT}\n"
    printf "${CYAN}3. Common Core (Milestones)${DEFAULT}\n"
    printf "${YELLOW}0. Sair${DEFAULT}\n"
    printf "\n${BOLD}Escolha uma opção: ${DEFAULT}"
    read -r opcao

    case $opcao in
        1) preparar_e_executar "$(basename "$CURRENT_INVOCATION_DIR")" ;;
        2) preparar_e_executar "Reloaded" ;;
        3) exibir_submenu_common_core ;;
        0) exit 0 ;;
        *) exibir_menu_principal ;;
    esac
}

# ==============================================================================
# BLOCO: CONTEXT_AGENT [v2] - RECUPERADO
# O QUE FAZ: Se estiver em pasta CXX ou ShellXX, roda direto.
# ==============================================================================
DIRETORIO_ATUAL=$(basename "$CURRENT_INVOCATION_DIR")
if [[ $DIRETORIO_ATUAL =~ ^(C(0[0-9]|1[0-3])|Shell0[0-9])$ ]]; then
    preparar_e_executar "$DIRETORIO_ATUAL"
else
    exibir_menu_principal
fi