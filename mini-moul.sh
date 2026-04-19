#!/bin/bash

# ==============================================================================
# BLOCO: AMBIENTE_E_INFRAESTRUTURA [v10]
# O QUE FAZ: Resolve o caminho absoluto da ferramenta e define constantes.
# OBJETIVO FUNCIONAL: Evitar 'diretório nulo' garantindo caminhos imutáveis.
# ==============================================================================

# Resolução de caminho absoluto (Blindada para Linux/macOS)
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
readonly TOOL_ROOT="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# Definições de Trabalho (Imutáveis)
readonly CURRENT_INVOCATION_DIR=$(pwd)
readonly SANDBOX_NAME="mini-moul_tmp"
readonly SANDBOX_PATH="$CURRENT_INVOCATION_DIR/$SANDBOX_NAME"
readonly ABSOLUTE_LOG_PATH="$TOOL_ROOT/mini-moul.log"

# ==============================================================================
# BLOCO: GERENCIADOR_DE_ESTADO [v10]
# O QUE FAZ: Controla a criação e destruição da sandbox de testes.
# OBJETIVO FUNCIONAL: Limpeza garantida sem comandos órfãos.
# ==============================================================================

limpar_sandbox() {
    # Garante que só tenta remover se o caminho não for nulo e existir
    if [[ -n "$SANDBOX_PATH" && -d "$SANDBOX_PATH" ]]; then
        rm -rf "$SANDBOX_PATH" &>/dev/null
    fi
}

encerrar_com_seguranca() {
    printf "\n${RED}🚨 Execução interrompida.${DEFAULT} Limpando rastros...\n"
    limpar_sandbox
    exit 1
}

trap encerrar_com_seguranca SIGINT SIGTERM

# ==============================================================================
# BLOCO: FLUXO_PRINCIPAL [v10]
# O QUE FAZ: Valida, prepara a sandbox e dispara o motor de testes.
# ==============================================================================

executar_moulinette() {
    local modulo_alvo=$(basename "$CURRENT_INVOCATION_DIR")
    local verbose_flag=0
    [[ "$1" == "-v" || "$1" == "--verbose" ]] && verbose_flag=1

    # 1. Validação de Contexto (Piscina 42)
    if [[ ! $modulo_alvo =~ ^(C(0[0-9]|1[0-3])|Shell0[0-9]|Rush0[0-2])$ ]]; then
        printf "❌ Erro: O diretório atual '%s' não é um módulo válido.\n" "$modulo_alvo"
        exit 1
    fi

    # 2. Preparação da Sandbox
    limpar_sandbox
    
    # Valida se a pasta da engine existe na 'Home' da ferramenta
    if [[ ! -d "$TOOL_ROOT/mini-moul" ]]; then
        printf "❌ Erro Crítico: Pasta 'mini-moul' não encontrada em: %s\n" "$TOOL_ROOT"
        exit 1
    fi

    # Cópia isolada para a sandbox
    cp -R "$TOOL_ROOT/mini-moul" "$SANDBOX_PATH"

    # 3. Handshake com o Engine (test.sh)
    if [[ -f "$SANDBOX_PATH/test.sh" ]]; then
        cd "$SANDBOX_PATH" || exit 1
        bash ./test.sh "$modulo_alvo" "$verbose_flag" "$ABSOLUTE_LOG_PATH"
        cd "$CURRENT_INVOCATION_DIR" || exit 1
    else
        printf "❌ Erro: Engine de teste (test.sh) não encontrada na sandbox.\n"
    fi

    # 4. Finalização
    limpar_sandbox
}

# Início da execução
executar_moulinette "$@"