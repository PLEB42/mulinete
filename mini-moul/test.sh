#!/bin/bash

# ==============================================================================
# BLOCK: STATE_AND_ENVIRONMENT [v14]
# DESCRIPTION: Initializes counters, colors, and the "Fail-Fast" ghost state.
# OBJECTIVE: Track real progress vs. logical correctness after a failure.
# ==============================================================================

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
source "$SCRIPT_DIR/config.sh"

MODULE_NAME=$1
VERBOSE=$2
LOG_FILE=${3:-"$SCRIPT_DIR/../mini-moul.txt"}
LOG_FILE="${LOG_FILE%.*}.txt"

# State Variables
QUESTIONS_TOTAL=0
QUESTIONS_PASSED=0    # Only counts if no failure occurred yet
LOGICAL_SUCCESSES=0   # Counts all OKs regardless of chain failure
HAS_FAILED_FLAG=0     # 0 = Perfect Run, 1 = Score Locked
GLOBAL_RESULTS=""
START_TIME=$(date +%s)

# Reset log for plain text
> "$LOG_FILE"

# Advanced Box-Drawing Characters (Double Line Style)
readonly B_TL="╔"; readonly B_TR="╗"; readonly B_BL="╚"; readonly B_BR="╝"
readonly B_H="═"; readonly B_V="║"; readonly B_D="╬"; readonly B_L="╠"; readonly B_R="╣"; readonly B_SEP="╦"

# ==============================================================================
# BLOCK: ADVANCED_UI_COMPONENTS [v14]
# DESCRIPTION: Large, high-impact English UI for the 42 environment.
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
    local col_ex_w=16
    local col_st_w=17
    local col_dt_w=25

    # Cabeçalho original (mantido)
    printf "\n${PURPLE}${BOLD}╔$(printf '%.0s═' {1..16})╦$(printf '%.0s═' {1..17})╦$(printf '%.0s═' {1..25})╗${DEFAULT}\n"
    printf "${PURPLE}${BOLD}║  EXERCISE      ║  STATUS         ║  EVALUATION DETAILS     ║${DEFAULT}\n"
    printf "${PURPLE}${BOLD}╠$(printf '%.0s═' {1..16})╬$(printf '%.0s═' {1..17})╬$(printf '%.0s═' {1..25})╣${DEFAULT}\n"

    IFS=', ' read -ra ADDR <<< "$GLOBAL_RESULTS"
    for item in "${ADDR[@]}"; do
        local ex=$(echo $item | cut -d: -f1)
        local st=$(echo $item | cut -d: -f2)
        
        local display_st=""
        local display_dt=""
        # Definimos o tamanho da compensação ANSI (geralmente 9 a 13 caracteres por cor)
        # Vamos usar um padding manual para garantir o alinhamento
        
        case $st in
            "OK")       display_st="${GREEN}${BOLD}PASS (OK)${DEFAULT}";  display_dt="${GREY}Score Added!${DEFAULT}" ;;
            "GHOST_OK") display_st="${RED}${BOLD}PASS (OK)${DEFAULT}";   display_dt="${RED}Logic OK / Locked${DEFAULT}" ;;
            "NORM_KO")  display_st="${RED}${BOLD}NORM ERROR${DEFAULT}";  display_dt="${RED}Style Violation${DEFAULT}" ;;
            "BUILD_KO") display_st="${RED}${BOLD}BUILD ERROR${DEFAULT}"; display_dt="${RED}Compile Conflict${DEFAULT}" ;;
            "KO")       display_st="${RED}${BOLD}FAILED (KO)${DEFAULT}"; display_dt="${RED}Logic Failure${DEFAULT}" ;;
            *)          display_st="${RED}${BOLD}ERROR${DEFAULT}";       display_dt="${RED}Unknown State${DEFAULT}" ;;
        esac

        # IMPRESSÃO CORRIGIDA:
        # 1. Coluna Exercise: %-14s com 2 espaços de margem interna (total 16)
        printf "${PURPLE}║${DEFAULT}  %-14s ${PURPLE}║${DEFAULT}  " "$ex"
        
        # 2. Coluna Status: Usamos %-26s para compensar os bytes de cor e manter os 17 de largura
        # Se a cor mudar o tamanho, ajustamos o valor 26 para mais ou menos
        printf "%-26b ${PURPLE}║${DEFAULT}  " "$display_st"
        
        # 3. Coluna Details: Mesma lógica, %-34b para manter os 25 de largura
        printf "%-34b ${PURPLE}║${DEFAULT}\n" "$display_dt"
    done

    printf "${PURPLE}${BOLD}╚$(printf '%.0s═' {1..16})╩$(printf '%.0s═' {1..17})╩$(printf '%.0s═' {1..25})╝${DEFAULT}\n"
}


# ==============================================================================
# BLOCK: EVALUATION_ENGINE_V14
# DESCRIPTION: Executes tests and manages the Chain-Fail logic.
# ==============================================================================

run_c_exercise() {
    local ex_path="$1"
    local ex_name=$(basename "$ex_path")
    local student_dir="../$ex_name"
    local student_file=$(ls "$student_dir"/*.c 2>/dev/null | head -n 1)
    local rel_file="$ex_name/$(basename "$student_file")"
    local current_pass=0

    printf "\r${BLUE}🔍 Checking: ${BOLD}[%s]${DEFAULT} - Analyzing context...          " "$ex_name"

    # --- STAGE 0: FILE CHECK ---
    if [ ! -f "$student_file" ]; then
        echo "$ex_name: missing_file" >> "$LOG_FILE"
        GLOBAL_RESULTS+="${ex_name}:KO, "
        HAS_FAILED_FLAG=1
        return
    fi

    # --- STAGE 1: NORMINETTE ---
    if ! norminette "$student_dir" &> /dev/null; then
        echo "$rel_file: KO (Norme)" >> "$LOG_FILE"
        norminette "$student_dir" | sed 's/^/\t/' >> "$LOG_FILE"
        printf "\r${RED}${ICON_FAIL} Failed: ${BOLD}[%s]${DEFAULT} - Norminette rejected the code.\n" "$ex_name"
        GLOBAL_RESULTS+="${ex_name}:NORM_KO, "
        HAS_FAILED_FLAG=1
        return
    fi

    # --- STAGE 2: COMPILATION ---
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

    # --- STAGE 3: LOGIC EXECUTION ---
    if ! ./test_bin &> .test_out; then
         echo "$rel_file: KO" >> "$LOG_FILE"
         sed 's/^/\t/' .test_out >> "$LOG_FILE"
         printf "\r${RED}${ICON_FAIL} Failed: ${BOLD}[%s]${DEFAULT} - Functional KO detected.      \n" "$ex_name"
         GLOBAL_RESULTS+="${ex_name}:KO, "
         HAS_FAILED_FLAG=1
    else
         echo "$rel_file: OK" >> "$LOG_FILE"
         [ "$VERBOSE" -eq 1 ] && sed 's/^/\t/' .test_out >> "$LOG_FILE"
         
         # --- CHAIN-FAIL LOGIC ---
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
# BLOCK: FINALIZATION_AND_GRADING [v14]
# ==============================================================================

finalizar_execucao() {
    print_summary_table
    
    # ANSI Clean
    [[ -f "$LOG_FILE" ]] && sed -i "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" "$LOG_FILE" 2>/dev/null
    
    local end_time=$(date +%s)
    local total=${QUESTIONS_TOTAL:-1}
    [ "$total" -eq 0 ] && total=1
    local final_grade=$(( (QUESTIONS_PASSED * 100) / total ))

    # Final Report UI
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
        run_c_exercise "$ex_dir"
    done
    finalizar_execucao
}

run_all_tests