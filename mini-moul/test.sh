#!/bin/bash

# ==============================================================================
# BLOCO 1: AMBIENTE E ESTADO GLOBAL [v18]
# O QUE FAZ: Inicializa contadores, cores, e deteta o contexto do projeto.
# OBJETIVO FUNCIONAL: Configurar as constantes necessárias para todo o ciclo.
# ==============================================================================
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
source "$SCRIPT_DIR/config.sh"

MODULE_NAME=$1
VERBOSE=$2
LOG_FILE=$3

# Definição de Base de Busca (Suporte para Piscina e Reloaded)
STUDENT_BASE_DIR="../"
[[ "$MODULE_NAME" == "Reloaded" ]] && STUDENT_BASE_DIR="/home/renan/reloaded"

# Determinação do Motor de Avaliação (Polimorfismo)
IS_SHELL_MODULE=0
[[ "$MODULE_NAME" == Shell* || "$MODULE_NAME" == "Reloaded" ]] && IS_SHELL_MODULE=1

# Variáveis de Estado de Execução
QUESTIONS_TOTAL=0
QUESTIONS_PASSED=0
HAS_FAILED_FLAG=0
GLOBAL_RESULTS=""
START_TIME=$(date +%s)

# Reset do ficheiro de log
> "$LOG_FILE"

# Definição de Componentes Visuais (Double Line Style)
readonly B_TL="╔"; readonly B_TR="╗"; readonly B_BL="╚"; readonly B_BR="╝"
readonly B_V="║"; readonly B_H="═"

# ==============================================================================
# BLOCO 2: COMPONENTES DE INTERFACE AVANÇADA [v18]
# O QUE FAZ: Gere a apresentação visual do "Vibe Check" e a tabela de sumário.
# OBJETIVO FUNCIONAL: Proporcionar feedback claro e alinhado ao utilizador.
# ==============================================================================
print_header() {
    clear
    printf "${PINK}${BOLD}${B_TL}$(printf '%.0s═' {1..60})${B_TR}${DEFAULT}\n"
    printf "${PINK}${BOLD}${B_V}            🌊  MULINETCHII RAPÁ! - VIBE CHECK              ${B_V}${DEFAULT}\n"
    printf "${PINK}${BOLD}${B_BL}$(printf '%.0s═' {1..60})${B_BR}${DEFAULT}\n"
    printf "${BLUE} 📂 Projeto: ${BOLD}%-12s${DEFAULT} ${GREY}║${DEFAULT} ${BLUE}🚀 Log: ${BOLD}%-18s${DEFAULT}\n\n" "$MODULE_NAME" "$(basename "$LOG_FILE")"
}

print_summary_table() {
    printf "\n${PURPLE}${BOLD}╔$(printf '%.0s═' {1..16})╦$(printf '%.0s═' {1..17})╦$(printf '%.0s═' {1..25})╗${DEFAULT}\n"
    printf "${PURPLE}${BOLD}║  EXERCÍCIO     ║  STATUS         ║  DETALHES DA AVALIAÇÃO  ║${DEFAULT}\n"
    printf "${PURPLE}${BOLD}╠$(printf '%.0s═' {1..16})╬$(printf '%.0s═' {1..17})╬$(printf '%.0s═' {1..25})╣${DEFAULT}\n"

    IFS=', ' read -ra ADDR <<< "$GLOBAL_RESULTS"
    for item in "${ADDR[@]}"; do
        local ex=$(echo $item | cut -d: -f1)
        local st=$(echo $item | cut -d: -f2)
        local color_st="${RED}"; local text_st="KO"; local color_dt="${RED}"; local text_dt="Falha"

        case $st in
            "OK")       color_st="${GREEN}"; text_st="PASS (OK)"; color_dt="${GREY}"; text_dt="Ponto Atribuído!" ;;
            "GHOST_OK") color_st="${RED}";   text_st="PASS (OK)"; color_dt="${RED}";  text_dt="Lógica OK / Locked" ;;
            "NORM_KO")  color_st="${RED}";   text_st="NORM ERROR"; color_dt="${RED}";  text_dt="Violação de Estilo" ;;
            "BUILD_KO") color_st="${RED}";   text_st="BUILD ERROR";color_dt="${RED}";  text_dt="Erro de Ficheiros" ;;
            "SKIP")     color_st="${CYAN}";  text_st="SKIPPED";   color_dt="${GREY}"; text_dt="Ambiente Git Requerido" ;;
        esac

        printf "${PURPLE}║${DEFAULT}  %-14s ${PURPLE}║${DEFAULT}  " "$ex"
        printf "%b%-15s%b  ${PURPLE}║${DEFAULT}  " "$color_st" "$text_st" "${DEFAULT}"
        printf "%b%-23s%b  ${PURPLE}║${DEFAULT}\n" "$color_dt" "$text_dt" "${DEFAULT}"
    done
    printf "${PURPLE}${BOLD}╚$(printf '%.0s═' {1..16})╩$(printf '%.0s═' {1..17})╩$(printf '%.0s═' {1..25})╝${DEFAULT}\n"
}

# ==============================================================================
# BLOCO 3: MOTOR DE AVALIAÇÃO SHELL [v18]
# O QUE FAZ: Executa scripts de teste (run_test.sh) para módulos Shell/Reloaded.
# OBJETIVO FUNCIONAL: Validar lógica sem necessidade de compilação.
# ==============================================================================
run_shell_exercise() {
    local ex_path=$1
    local std_dir=$2
    local ex_name=$(basename "$ex_path")
    local test_script="$ex_path/run_test.sh"

    # Verificação de Exercícios de Git (Shell 00)
    if [[ "$MODULE_NAME" == "Shell00" && ("$ex_name" == "ex05" || "$ex_name" == "ex06") ]]; then
        GLOBAL_RESULTS+="${ex_name}:SKIP, "; return
    fi

    printf "\r${BLUE}🔍 Verificando: ${BOLD}[%s]${DEFAULT} - Executando Shell...        " "$ex_name"
    
    if [ ! -d "$std_dir" ]; then
        printf "\r${RED}${ICON_FAIL} Falhou: ${BOLD}[%s]${DEFAULT} - Pasta não encontrada.       \n" "$ex_name"
        GLOBAL_RESULTS+="${ex_name}:KO, "; HAS_FAILED_FLAG=1; return
    fi

    if [ -f "$test_script" ]; then
        if bash "$test_script" >> "$LOG_FILE" 2>&1; then
            echo "$ex_name: OK" >> "$LOG_FILE"
            if [ "$HAS_FAILED_FLAG" -eq 0 ]; then
                printf "\r${GREEN}${ICON_PASS} Passou: ${BOLD}[%s]${DEFAULT} - Vibe Check Perfeito.      \n" "$ex_name"
                GLOBAL_RESULTS+="${ex_name}:OK, "; ((QUESTIONS_PASSED++))
            else
                printf "\r${RED}${ICON_PASS} Passou: ${BOLD}[%s]${DEFAULT} - Lógica OK / Locked.       \n" "$ex_name"
                GLOBAL_RESULTS+="${ex_name}:GHOST_OK, "
            fi
        else
            printf "\r${RED}${ICON_FAIL} Falhou: ${BOLD}[%s]${DEFAULT} - KO Funcional Detetado.      \n" "$ex_name"
            GLOBAL_RESULTS+="${ex_name}:KO, "; HAS_FAILED_FLAG=1
        fi
    else
        GLOBAL_RESULTS+="${ex_name}:BUILD_KO, "; HAS_FAILED_FLAG=1
    fi
}

# ==============================================================================
# BLOCO 4: MOTOR DE AVALIAÇÃO C [v18]
# O QUE FAZ: Valida Norminette, compila e executa binários de teste.
# OBJETIVO FUNCIONAL: Garantir integridade de exercícios em linguagem C.
# ==============================================================================
run_c_exercise() {
    local ex_path=$1
    local std_dir=$2
    local ex_name=$(basename "$ex_path")
    local std_file=$(ls "$std_dir"/*.c 2>/dev/null | head -n 1)

    printf "\r${BLUE}🔍 Verificando: ${BOLD}[%s]${DEFAULT} - Analisando C...            " "$ex_name"

    # Validação de existência de ficheiro
    if [ ! -f "$std_file" ]; then
        echo "$ex_name: missing_file" >> "$LOG_FILE"
        GLOBAL_RESULTS+="${ex_name}:KO, "; HAS_FAILED_FLAG=1; return
    fi

    # Validação de Norminette
    if ! norminette "$std_dir" &> /dev/null; then
        echo "$ex_name: KO (Norme)" >> "$LOG_FILE"
        printf "\r${RED}${ICON_FAIL} Falhou: ${BOLD}[%s]${DEFAULT} - Erro de Norminette.         \n" "$ex_name"
        GLOBAL_RESULTS+="${ex_name}:NORM_KO, "; HAS_FAILED_FLAG=1; return
    fi

    # Compilação
    if cc -Wall -Wextra -Werror -o bin "$std_file" "$ex_path"/*.c &>> "$LOG_FILE"; then
        if ./bin >> "$LOG_FILE" 2>&1; then
            echo "$ex_name: OK" >> "$LOG_FILE"
            if [ "$HAS_FAILED_FLAG" -eq 0 ]; then
                printf "\r${GREEN}${ICON_PASS} Passou: ${BOLD}[%s]${DEFAULT} - Vibe Check Perfeito.      \n" "$ex_name"
                GLOBAL_RESULTS+="${ex_name}:OK, "; ((QUESTIONS_PASSED++))
            else
                printf "\r${RED}${ICON_PASS} Passou: ${BOLD}[%s]${DEFAULT} - Lógica OK / Locked.       \n" "$ex_name"
                GLOBAL_RESULTS+="${ex_name}:GHOST_OK, "
            fi
        else
            printf "\r${RED}${ICON_FAIL} Falhou: ${BOLD}[%s]${DEFAULT} - KO Funcional Detetado.      \n" "$ex_name"
            GLOBAL_RESULTS+="${ex_name}:KO, "; HAS_FAILED_FLAG=1
        fi
    else
        printf "\r${RED}${ICON_FAIL} Falhou: ${BOLD}[%s]${DEFAULT} - Erro de Compilação.          \n" "$ex_name"
        GLOBAL_RESULTS+="${ex_name}:BUILD_KO, "; HAS_FAILED_FLAG=1
    fi
    rm -f bin
}

# ==============================================================================
# BLOCO 5: FINALIZAÇÃO E RELATÓRIO [v18]
# O QUE FAZ: Limpa o log e apresenta a nota final e tempo total.
# OBJETIVO FUNCIONAL: Concluir o ciclo de vida da avaliação.
# ==============================================================================
finalizar_avaliacao() {
    print_summary_table
    
    # Remoção de códigos ANSI do ficheiro de log para leitura limpa
    [[ -f "$LOG_FILE" ]] && sed -i "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" "$LOG_FILE" 2>/dev/null
    
    local total=${QUESTIONS_TOTAL:-1}
    local final_grade=$(( (QUESTIONS_PASSED * 100) / total ))
    local end_time=$(date +%s)

    printf "\n${PURPLE}${BOLD}╔══════════════════════════════════════════════════════════════╗${DEFAULT}\n"
    printf "${PURPLE}${BOLD}║                     RELATÓRIO DE AVALIAÇÃO                   ║${DEFAULT}\n"
    printf "${PURPLE}${BOLD}╠══════════════════════════════════════════════════════════════╣${DEFAULT}\n"
    
    if [ "$HAS_FAILED_FLAG" -eq 1 ]; then
        printf "  ${RED}${BOLD}NOTA FINAL: %3d / 100${DEFAULT} ${RED}(Chain Failure Detetado)${DEFAULT}\n" "$final_grade"
        printf "  ${RED}STATUS: FALHOU${DEFAULT} ${GREY}- Um ou mais exercícios bloquearam o fluxo.${DEFAULT}\n"
    else
        printf "  ${GREEN}${BOLD}NOTA FINAL: %3d / 100${DEFAULT}${DEFAULT}\n" "$final_grade"
        printf "  ${GREEN}STATUS: SUCESSO${DEFAULT} ${GREY}- Tudo limpo como a maré.${DEFAULT}\n"
    fi
    
    printf "  ${GREY}Tempo decorrido: %d segundos | Resultados em .txt${DEFAULT}\n" $((end_time - START_TIME))
    printf "${PURPLE}${BOLD}╚══════════════════════════════════════════════════════════════╝${DEFAULT}\n"
}

# ==============================================================================
# BLOCO 6: CICLO PRINCIPAL DE TESTES
# O QUE FAZ: Itera sobre o registo de testes e decide o motor de execução.
# ==============================================================================
run_all_tests() {
    print_header
    local registry="./tests/$MODULE_NAME"
    [[ ! -d "$registry" ]] && registry="./tests/Shell00" # Fallback de segurança

    for ex_dir in "$registry"/*/; do
        [ ! -d "$ex_dir" ] && continue
        ((QUESTIONS_TOTAL++))
        
        local ex_name=$(basename "$ex_dir")
        local std_ex_path="$STUDENT_BASE_DIR/$ex_name"

        # Decisão de motor baseada na existência de run_test.sh (Shell/Reloaded) ou C
        if [ -f "$ex_dir/run_test.sh" ]; then
            run_shell_exercise "$ex_dir" "$std_ex_path"
        else
            run_c_exercise "$ex_dir" "$std_ex_path"
        fi
    done
    finalizar_avaliacao
}

run_all_tests