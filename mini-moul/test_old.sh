#!/bin/bash

# ==============================================================================
# MULINETCHII RAPÁ! - Test Engine 
# ==============================================================================

# Loads color settings and global variables
# Attempts to load from the current directory or from the script directory
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
if [ -f "$SCRIPT_DIR/config.sh" ]; then
    source "$SCRIPT_DIR/config.sh"
else
    echo "Erro: config.sh não encontrado!"
    exit 1
fi

# ─── GLOBAL STATE ────────────────────────────────────────────────────────────
# Variables to track score and tests
QUESTIONS_TOTAL=0
QUESTIONS_PASSED=0
MODULE_FOUND=0
GLOBAL_RESULTS=""
START_TIME=0

# Visual symbols for the terminal
ICON_PASS="✅"
ICON_FAIL="❌"
ICON_LEAK="💧"
ICON_TIME="⏳"
ICON_WARN="⚠️"

# ─── UI FUNCTIONS (USER INTERFACE) ─────────────────────────────────────

# Prints a blank line
space() { echo ""; }

# Checks if the current module is Shell
is_shell() { [[ "$1" =~ ^Shell ]]; }

# Prints the cool script header
print_header() {
    printf "${PINK}"
    printf " ███▄           ███▄   ██  ██  ██       ██ ███▄    ██  ████████  ████████  ██ \n"
    printf " ██▀██▄       ██▀ ██   ██  ██  ██       ██ ██▀██   ██  ██           ██     ██ \n"
    printf " ██  ▀██▄   ██▀   ██   ██  ██  ██       ██ ██  ▀██ ██  ██████       ██     ██ \n"
    printf " ██    ▀██▄██▀    ██   ██  ██  ██       ██ ██    ▀███  ██           ██     ██ \n"
    printf " ██      ▀█▀      ██   ▀████▀  ████████ ██ ██     ▀██  ████████     ██     ██ \n"
    
    printf "${PURPLE}"
    printf " ▒▒▒      ▒▒      ▒▒   ▒▒▒▒▒▒  ▒▒▒▒▒▒▒▒ ▒▒ ▒▒      ▒▒  ▒▒▒▒▒▒▒▒     ▒▒     ▒▒ \n"
    printf "${GREY}"
    printf " ░░░      ░░      ░░   ░░░░░░  ░░░░░░░░ ░░ ░░      ░░  ░░░░░░░░     ░░     ░░ \n"
    printf "          ░                ░        ░      ░                ░              ░  \n"

    printf "\n 🤙 ${BLUE}MULINETCHII RAPÁ! ${DEFAULT}v2.0\n"
    printf " 🌊 ${PINK}Real talk: ${DEFAULT}Heat up that code, the wave’s about to crash in.\n"
    printf " 🚀 ${BLUE}Status: ${DEFAULT}We vibin’, no stress, all set and locked in.\n"
    space
}

# Imprime o rodapé com a nota final e o tempo de execução
print_footer() {
    printf "${PURPLE}------------------------------------------------------------${DEFAULT}\n"
    space
    
    # Evita divisão por zero caso nenhum teste seja rodado
    local total=${QUESTIONS_TOTAL:-1}
    [ "$total" -eq 0 ] && total=1 
    
    local percent=$((100 * QUESTIONS_PASSED / total))
    local end_time=$(date +%s)
    local elapsed=$((end_time - START_TIME))

    printf " Recap:      %s\n" "$GLOBAL_RESULTS"
    
    if [ "$percent" -ge 50 ]; then
        printf " Final Grade:  ${GREEN}%d/100${DEFAULT} ${ICON_PASS}\n" "$percent"
        printf " Status:      ${BG_GREEN}${BLACK}${BOLD} APPROVED ${DEFAULT}\n"
    else
        printf " Nota Final:  ${RED}%d/100${DEFAULT} ${ICON_FAIL}\n" "$percent"
        printf " Status:      ${BG_RED}${BOLD} FAILED ${DEFAULT}\n"
    fi
    
    printf " Tempo:       ${GREY}%d secs${DEFAULT}\n" "$elapsed"
    printf "\n${BLUE} Mulineti ain’t getting updated. Chill, forget that git pull hustle.${DEFAULT}\n"
    space
}

# Registra e exibe o resultado de um exercício individual
# Uso: log_result <status (0=pass, 1=fail, 2=norm_error)> <nome_exercicio> <nome_arquivo_teste>
log_result() {
    local status=$1
    local ex_name=$2
    local test_name=$3

    [ -n "$GLOBAL_RESULTS" ] && GLOBAL_RESULTS+=", "

    if [ "$status" -eq 0 ]; then
        GLOBAL_RESULTS+="${GREEN}${ex_name}: OK${DEFAULT}"
        printf "${BG_GREEN}${BLACK}${BOLD} PASS ${DEFAULT} ${PURPLE}%s/${DEFAULT}%s\n" "$ex_name" "$test_name"
        ((QUESTIONS_PASSED++))
    elif [ "$status" -eq 2 ]; then
        GLOBAL_RESULTS+="${RED}${ex_name}: NORM${DEFAULT}"
        printf "${BG_RED}${BOLD} NORM ${DEFAULT} ${PURPLE}%s/${DEFAULT}%s ${GREY}(Logic’s tight, but you flunked the Norms.)${DEFAULT}\n" "$ex_name" "$test_name"
    else
        GLOBAL_RESULTS+="${RED}${ex_name}: KO${DEFAULT}"
        printf "${BG_RED}${BOLD} FAIL ${DEFAULT} ${PURPLE}%s/${DEFAULT}%s\n" "$ex_name" "$test_name"
    fi
    space
}

# ─── FUNÇÕES UTILITÁRIAS DE EXECUÇÃO ──────────────────────────────────────────

# Executa um binário C compilado, aplicando o Valgrind se o módulo exigir
run_binary() {
    local binary="$1"
    local module="$2"

    for vg_assign in $VALGRIND_ASSIGNMENTS; do
        if [ "$module" == "$vg_assign" ]; then
            if command -v valgrind &> /dev/null; then
                if ! valgrind --leak-check=full --error-exitcode=1 --quiet "$binary" 2>/dev/null; then
                    printf "    ${RED}${ICON_LEAK} Memory leak spotted at: $(basename "$binary")${DEFAULT}\n"
                    return 1
                fi
                return 0
            fi
        fi
    done
    # Se não precisa de valgrind, roda normal
    "$binary" 2>/dev/null
}

# ─── CORREDORES DE TESTE (RUNNERS) ────────────────────────────────────────────

# Lida exclusivamente com exercícios em C (C00 a C13)
run_c_exercise() {
    local folder_path="$1"
    local module="$2"
    
    local ex_name="$(basename "$folder_path")"
    local c_files=$(ls "$folder_path"/*.c 2>/dev/null)
    local test_name="$(basename "$(echo "$c_files" | head -n 1)")"
    
    local is_failed=0
    local norm_failed=0

    # 1. Validação de existência de arquivo
    if [ -z "$c_files" ]; then
        printf "    ${RED}${ICON_WARN} No .c files found for testing.${DEFAULT}\n"
        log_result 1 "$ex_name" "N/A"
        return
    fi

    # 2. Verificação da Norminette (Silenciosa no diretório real)
    if command -v norminette &> /dev/null; then
        if ! norminette "../$ex_name" &> /dev/null; then
            norm_failed=1
        fi
    fi

    # 3. Teste de Compilação Rígida
    local first_c_file=$(echo "$c_files" | head -n 1)
    if ! cc -Wall -Werror -Wextra -o test_bin "$first_c_file" 2>/dev/null; then
        printf "    ${RED}${ICON_FAIL} Compilation fail at %s (Flags: -Wall -Werror -Wextra).${DEFAULT}\n" "$test_name"
        log_result 1 "$ex_name" "$test_name"
        return
    fi
    rm -f test_bin # Limpa se compilou com sucesso

    # 4. Execução dos testes internos da pasta
    for test_file in "$folder_path"/*.[csh]; do
        # Se o teste for um script .sh complementar
        if [[ "$test_file" == *.sh ]]; then
            if ! sh "$test_file" 2>/dev/null; then
                is_failed=1
            fi
        # Se for um arquivo C
        elif [[ "$test_file" == *.c ]]; then
            local bin_name="${test_file%.c}"
            if cc -Wall -Werror -Wextra -o "$bin_name" "$test_file" 2>/dev/null; then
                if ! run_binary "./$bin_name" "$module"; then
                    is_failed=1
                fi
                rm -f "$bin_name"
            else
                is_failed=1
            fi
        fi
    done

    # 5. Avaliação final do exercício (Aplica a punição da Norminette)
    if [ "$is_failed" -eq 0 ] && [ "$norm_failed" -eq 1 ]; then
        log_result 2 "$ex_name" "$test_name"
    else
        log_result "$is_failed" "$ex_name" "$test_name"
    fi
}

# Lida exclusivamente com exercícios de Shell (Shell00 a Shell09)
run_shell_exercise() {
    local folder_path="$1"
    local ex_name="$(basename "$folder_path")"
    
    # Pega o primeiro script .sh encontrado na pasta de testes
    local test_scripts=$(ls "$folder_path"/*.sh 2>/dev/null)
    local test_name="$(basename "$(echo "$test_scripts" | head -n 1)")"
    
    local is_failed=0

    # 1. Valida se o dev preparou o script de teste
    if [ -z "$test_scripts" ]; then
        printf "    ${RED}${ICON_WARN} No test script (.sh) found in %s.${DEFAULT}\n" "$ex_name"
        log_result 1 "$ex_name" "N/A"
        return
    fi

    # 2. Roda cada script de teste encontrado
    for script in $test_scripts; do
        # Atenção: O script roda esperando que retorne exit 0 (PASS)
        if ! sh "$script" 2>/dev/null; then
            is_failed=1
        fi
    done

    # 3. Avaliação final do exercício
    log_result "$is_failed" "$ex_name" "$test_name"
}

# ─── MOTOR PRINCIPAL ──────────────────────────────────────────────────────────

# Função central que orquestra a varredura e testes
run_all_tests() {
    local target_module="$1"
    local available_modules=""
    
    START_TIME=$(date +%s)

    # Varre a pasta de testes para encontrar os módulos disponíveis
    for dir in ./tests/*; do
        [ ! -d "$dir" ] && continue
        
        local dir_name="$(basename "$dir")"
        available_modules+="$dir_name "

        # Encontrou a pasta de testes do módulo solicitado (ex: C01, Shell00)
        if [ "$dir_name" == "$target_module" ]; then
            MODULE_FOUND=1
            print_header
            printf "${GREEN} Setting up the test playground for [ %s ]...${DEFAULT}\n" "$target_module"
            space

            # Itera sobre cada exercício (ex00, ex01...) dentro da pasta do módulo
            for assignment_dir in "$dir"/*/; do
                [ ! -d "$assignment_dir" ] && continue
                
                ((QUESTIONS_TOTAL++))

                if is_shell "$target_module"; then
                    run_shell_exercise "$assignment_dir"
                else
                    run_c_exercise "$assignment_dir" "$target_module"
                fi
            done
            break
        fi
    done

    # Tratamento de erro caso o módulo não possua testes programados
    if [ "$MODULE_FOUND" -eq 0 ]; then
        printf "\n${RED}${ICON_WARN} Tests for module '%s' ain’t ready/set up yet.${DEFAULT}\n" "$target_module"
        printf "${GREY}Available: ${PURPLE}%s${DEFAULT}\n\n" "$available_modules"
        exit 1
    fi

    print_footer
}

# ─── INÍCIO DO SCRIPT ───────────────────────────────────────────

# 1. Checa se o usuário passou um argumento
if [ -z "$1" ]; then
    printf "${RED}Error: You gotta pick a module.${DEFAULT}\n"
    printf "Usage example: ${GREEN}./test.sh C01${DEFAULT}\n"
    exit 1
fi

# 2. Filtro Rigoroso de Segurança (Evita injeção e protege o diretório)
# Agora aceita C00 a C13, Shell00 a Shell01 e preparado para o Rush00 a Rush02
if [[ "$1" =~ ^(C(0[0-9]|1[0-3])|Shell0[0-1]|Rush0[0-2])$ ]]; then
    run_all_tests "$1"
    
    # 3. Limpeza do Terminal: Garante que o console volte a cor original
    echo -e "${DEFAULT}"
    exit 0
else
    printf "${RED}Invalid argument: '%s'${DEFAULT}\n" "$1"
    printf "Pick one of: ${PURPLE}C00 to C13${DEFAULT}, ${PURPLE}Shell00 and Shell01${DEFAULT} or ${PURPLE}Rush00 to Rush02${DEFAULT}.\n"
    exit 1
fi