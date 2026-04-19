#!/bin/bash

# ==============================================================================
# BLOCK: STATE_AND_ENVIRONMENT [v16]
# ALTERAÇÃO: Removida a conversão forçada de extensão de LOG para evitar confusão.
# ==============================================================================
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
source "$SCRIPT_DIR/config.sh"

MODULE_NAME=$1
VERBOSE=$2
LOG_FILE=${3:-"$SCRIPT_DIR/../mini-moul.txt"}

# Detecção de Tipo de Módulo
IS_SHELL_MODULE=0
[[ "$MODULE_NAME" == Shell* ]] && IS_SHELL_MODULE=1

# State Variables
QUESTIONS_TOTAL=0
QUESTIONS_PASSED=0
HAS_FAILED_FLAG=0
GLOBAL_RESULTS=""
START_TIME=$(date +%s)

> "$LOG_FILE"

readonly B_TL="╔"; readonly B_TR="╗"; readonly B_BL="╚"; readonly B_BR="╝"
readonly B_V="║"; readonly B_H="═"

# ==============================================================================
# BLOCK: ADVANCED_UI_COMPONENTS [v16]
# ALTERAÇÃO: Refatoração do printf para lidar com padding de cores ANSI.
# ==============================================================================
print_header() {
    clear
    printf "${PINK}${BOLD}${B_TL}$(printf '%.0s═' {1..60})${B_TR}${DEFAULT}\n"
    printf "${PINK}${BOLD}${B_V}            🌊  MULINETCHII RAPÁ! - VIBE CHECK              ${B_V}${DEFAULT}\n"
    printf "${PINK}${BOLD}${B_BL}$(printf '%.0s═' {1..60})${B_BR}${DEFAULT}\n"
    printf "${BLUE} 📂 Module: ${BOLD}%-12s${DEFAULT} ${GREY}║${DEFAULT} ${BLUE}🚀 Mode: ${BOLD}Full Evaluation${DEFAULT}\n" "$MODULE_NAME"
    printf "${GREY} 📄 Log: %-48s${DEFAULT}\n\n" "$(basename "$LOG_FILE")"
}

print_summary_table() {
    printf "\n${PURPLE}${BOLD}╔$(printf '%.0s═' {1..16})╦$(printf '%.0s═' {1..17})╦$(printf '%.0s═' {1..25})╗${DEFAULT}\n"
    printf "${PURPLE}${BOLD}║  EXERCISE      ║  STATUS         ║  EVALUATION DETAILS     ║${DEFAULT}\n"
    printf "${PURPLE}${BOLD}╠$(printf '%.0s═' {1..16})╬$(printf '%.0s═' {1..17})╬$(printf '%.0s═' {1..25})╣${DEFAULT}\n"

    IFS=', ' read -ra ADDR <<< "$GLOBAL_RESULTS"
    for item in "${ADDR[@]}"; do
        local ex=$(echo $item | cut -d: -f1)
        local st=$(echo $item | cut -d: -f2)
        local color_st="${RED}${BOLD}"
        local text_st="ERROR"
        local color_dt="${RED}"
        local text_dt="Unknown"

        case $st in
            "OK")       color_st="${GREEN}${BOLD}"; text_st="PASS (OK)";  color_dt="${GREY}"; text_dt="Score Added!" ;;
            "GHOST_OK") color_st="${RED}${BOLD}";   text_st="PASS (OK)";  color_dt="${RED}";  text_dt="Logic OK / Locked" ;;
            "NORM_KO")  color_st="${RED}${BOLD}";   text_st="NORM ERROR"; color_dt="${RED}";  text_dt="Style Violation" ;;
            "BUILD_KO") color_st="${RED}${BOLD}";   text_st="BUILD ERROR";color_dt="${RED}";  text_dt="Check Script/Files" ;;
            "SKIP")     color_st="${CYAN}${BOLD}";  text_st="SKIPPED";    color_dt="${GREY}"; text_dt="Git Env Required" ;;
            "KO")       color_st="${RED}${BOLD}";   text_st="FAILED (KO)"; color_dt="${RED}";  text_dt="Logic Failure" ;;
        esac

        # IMPRESSÃO COM PADDING FIXO (Cores aplicadas fora do alinhamento)
        printf "${PURPLE}║${DEFAULT}  %-14s ${PURPLE}║${DEFAULT}  " "$ex"
        printf "%b%-15s%b  ${PURPLE}║${DEFAULT}  " "$color_st" "$text_st" "${DEFAULT}"
        printf "%b%-23s%b  ${PURPLE}║${DEFAULT}\n" "$color_dt" "$text_dt" "${DEFAULT}"
    done
    printf "${PURPLE}${BOLD}╚$(printf '%.0s═' {1..16})╩$(printf '%.0s═' {1..17})╩$(printf '%.0s═' {1..25})╝${DEFAULT}\n"
}

# ==============================================================================
# BLOCK: SHELL_ENGINE_V2 [v16]
# ALTERAÇÃO: Adicionado feedback visual para diretórios ausentes.
# ==============================================================================
run_shell_exercise() {
    local ex_path="$1"
    local ex_name=$(basename "$ex_path")
    local student_dir="../$ex_name"
    local test_script="$ex_path/run_test.sh"

    # --- STAGE 0: GIT GUARD ---
    if [[ "$ex_name" == "ex05" || "$ex_name" == "ex06" ]]; then
        GLOBAL_RESULTS+="${ex_name}:SKIP, "
        return
    fi

    # --- STAGE 1: DIR CHECK ---
    if [ ! -d "$student_dir" ]; then
        printf "\r${RED}${ICON_FAIL} Failed: ${BOLD}[%s]${DEFAULT} - Directory not found.         \n" "$ex_name"
        echo "$ex_name: missing_directory" >> "$LOG_FILE"
        GLOBAL_RESULTS+="${ex_name}:KO, "
        HAS_FAILED_FLAG=1
        return
    fi

    # --- STAGE 2: EXECUTION ---
    printf "\r${BLUE}🔍 Checking: ${BOLD}[%s]${DEFAULT} - Running Shell Test...        " "$ex_name"
    if [ -f "$test_script" ]; then
        if bash "$test_script" >> "$LOG_FILE" 2>&1; then
             echo "$ex_name: OK" >> "$LOG_FILE"
             if [ "$HAS_FAILED_FLAG" -eq 0 ]; then
                 printf "\r${GREEN}${ICON_PASS} Passed: ${BOLD}[%s]${DEFAULT} - Perfect! Vibe Check OK.   \n" "$ex_name"
                 GLOBAL_RESULTS+="${ex_name}:OK, "
                 ((QUESTIONS_PASSED++))
             else
                 printf "\r${RED}${ICON_PASS} Passed: ${BOLD}[%s]${DEFAULT} - Logic OK but Chain Failed. \n" "$ex_name"
                 GLOBAL_RESULTS+="${ex_name}:GHOST_OK, "
             fi
        else
             echo "$ex_name: KO" >> "$LOG_FILE"
             printf "\r${RED}${ICON_FAIL} Failed: ${BOLD}[%s]${DEFAULT} - Functional KO detected.      \n" "$ex_name"
             GLOBAL_RESULTS+="${ex_name}:KO, "
             HAS_FAILED_FLAG=1
        fi
    else
        printf "\r${RED}${ICON_FAIL} Failed: ${BOLD}[%s]${DEFAULT} - run_test.sh not found.         \n" "$ex_name"
        GLOBAL_RESULTS+="${ex_name}:BUILD_KO, "
        HAS_FAILED_FLAG=1
    fi
}

# ==============================================================================
# BLOCK: EVALUATION_ENGINE_V14 (PRESERVADO)
# ==============================================================================
run_c_exercise() {
    local ex_path="$1"
    local ex_name=$(basename "$ex_path")
    local student_dir="../$ex_name"
    local student_file=$(ls "$student_dir"/*.c 2>/dev/null | head -n 1)
    local rel_file="$ex_name/$(basename "$student_file")"

    printf "\r${BLUE}🔍 Checking: ${BOLD}[%s]${DEFAULT} - Analyzing context...          " "$ex_name"

    if [ ! -f "$student_file" ]; then
        echo "$ex_name: missing_file" >> "$LOG_FILE"
        GLOBAL_RESULTS+="${ex_name}:KO, "
        HAS_FAILED_FLAG=1
        return
    fi

    if ! norminette "$student_dir" &> /dev/null; then
        echo "$rel_file: KO (Norme)" >> "$LOG_FILE"
        norminette "$student_dir" | sed 's/^/\t/' >> "$LOG_FILE"
        printf "\r${RED}${ICON_FAIL} Failed: ${BOLD}[%s]${DEFAULT} - Norminette rejected the code.\n" "$ex_name"
        GLOBAL_RESULTS+="${ex_name}:NORM_KO, "
        HAS_FAILED_FLAG=1
        return
    fi

    local ld_flags="-Wl,--allow-multiple-definition"
    [[ "$OSTYPE" == "darwin"* ]] && ld_flags="-z muldefs"
    
    if ! cc $CFLAGS -o test_bin "$student_file" "$ex_path"/*.c $ld_flags &> .comp_err; then
        echo "$rel_file: KO (Compilation)" >> "$LOG_FILE"
        sed 's/^/\t/' .comp_err >> "$LOG_FILE"
        printf "\r${RED}${ICON_FAIL} Failed: ${BOLD}[%s]${DEFAULT} - Compilation failed.         \n" "$ex_name"
        GLOBAL_RESULTS+="${ex_name}:BUILD_KO, "
        HAS_FAILED_FLAG=1
        return
    fi

    if ! ./test_bin &> .test_out; then
         echo "$rel_file: KO" >> "$LOG_FILE"
         sed 's/^/\t/' .test_out >> "$LOG_FILE"
         printf "\r${RED}${ICON_FAIL} Failed: ${BOLD}[%s]${DEFAULT} - Functional KO detected.      \n" "$ex_name"
         GLOBAL_RESULTS+="${ex_name}:KO, "
         HAS_FAILED_FLAG=1
    else
         echo "$rel_file: OK" >> "$LOG_FILE"
         [ "$VERBOSE" -eq 1 ] && sed 's/^/\t/' .test_out >> "$LOG_FILE"
         
         if [ "$HAS_FAILED_FLAG" -eq 0 ]; then
             printf "\r${GREEN}${ICON_PASS} Passed: ${BOLD}[%s]${DEFAULT} - Perfect! Vibe Check OK.   \n" "$ex_name"
             GLOBAL_RESULTS+="${ex_name}:OK, "
             ((QUESTIONS_PASSED++))
         else
             printf "\r${RED}${ICON_PASS} Passed: ${BOLD}[%s]${DEFAULT} - Logic OK but Chain Failed. \n" "$ex_name"
             GLOBAL_RESULTS+="${ex_name}:GHOST_OK, "
         fi
    fi
    rm -f .test_out .comp_err test_bin
}

# ==============================================================================
# BLOCK: FINALIZATION_AND_GRADING [v14] (PRESERVADO COM DESVIO LÓGICO)
# ==============================================================================

finalizar_execucao() {
    print_summary_table
    [[ -f "$LOG_FILE" ]] && sed -i "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" "$LOG_FILE" 2>/dev/null
    
    local end_time=$(date +%s)
    local total=${QUESTIONS_TOTAL:-1}
    [ "$total" -eq 0 ] && total=1
    local final_grade=$(( (QUESTIONS_PASSED * 100) / total ))

    printf "\n${PURPLE}${BOLD}╔══════════════════════════════════════════════════════════════╗${DEFAULT}\n"
    printf "${PURPLE}${BOLD}║                     FINAL EVALUATION REPORT                  ║${DEFAULT}\n"
    printf "${PURPLE}${BOLD}╠══════════════════════════════════════════════════════════════╣${DEFAULT}\n"
    
    if [ "$HAS_FAILED_FLAG" -eq 1 ]; then
        printf "  ${RED}${BOLD}FINAL GRADE: %3d / 100${DEFAULT} ${RED}(Chain Failure Detected)${DEFAULT}\n" "$final_grade"
        printf "  ${RED}STATUS: FAILED${DEFAULT} ${GREY}- One or more exercises blocked the flow.${DEFAULT}\n"
    else
        printf "  ${GREEN}${BOLD}FINAL GRADE: %3d / 100${DEFAULT}${DEFAULT}\n" "$final_grade"
        printf "  ${GREEN}STATUS: SUCCESS${DEFAULT} ${GREY}- Everything is clean like the tide.${DEFAULT}\n"
    fi
    
    printf "  ${GREY}Time Elapsed: %d seconds | Results exported to .txt${DEFAULT}\n" $((end_time - START_TIME))
    printf "${PURPLE}${BOLD}╚══════════════════════════════════════════════════════════════╝${DEFAULT}\n"
}

run_all_tests() {
    print_header
    for ex_dir in ./tests/"$MODULE_NAME"/*/; do
        [ ! -d "$ex_dir" ] && continue
        ((QUESTIONS_TOTAL++))
        
        # Desvio Polimórfico (v15)
        if [ "$IS_SHELL_MODULE" -eq 1 ]; then
            run_shell_exercise "$ex_dir"
        else
            run_c_exercise "$ex_dir"
        fi
    done
    finalizar_execucao
}

run_all_tests