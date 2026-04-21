#!/bin/bash

# ==============================================================================
# BLOCK 1: ENVIRONMENT AND GLOBAL STATE [v18]
# WHAT IT DOES: Initializes counters, colors, and detects the project context.
# FUNCTIONAL GOAL: Set up constants needed for the full evaluation cycle.
# ==============================================================================
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
source "$SCRIPT_DIR/config.sh"

MODULE_NAME=$1
VERBOSE=$2
LOG_FILE=$3

# Student directory base path (Piscine and Reloaded support)
STUDENT_BASE_DIR="../"

# ==============================================================================
# BLOCK: PROJECT_AUTO_CONFIG [v19]
# WHAT IT DOES: Dynamically sets the search path using the $HOME variable.
# ==============================================================================
STUDENT_BASE_DIR="../"

case "$MODULE_NAME" in
    "Reloaded")
        # Locate the reloaded folder in the user's home directory (~/PISCINE_RELOADED)
        if [ -d "${HOME}/PISCINE_RELOADED" ]; then
            STUDENT_BASE_DIR="${HOME}/PISCINE_RELOADED"
        else
            # If not found in Home, keep the Piscine default
            STUDENT_BASE_DIR="../"
        fi
        ;;
    "Libft")
        # Placeholder for future Common Core projects
        STUDENT_BASE_DIR="../"
        ;;
esac

# Evaluation engine selection (Polymorphism)
IS_SHELL_MODULE=0
[[ "$MODULE_NAME" == Shell* || "$MODULE_NAME" == "Reloaded" ]] && IS_SHELL_MODULE=1

# Runtime state variables
QUESTIONS_TOTAL=0
QUESTIONS_PASSED=0
HAS_FAILED_FLAG=0
GLOBAL_RESULTS=""
START_TIME=$(date +%s)

# Reset the log file
> "$LOG_FILE"

# Visual component definitions (Double Line Style)
readonly B_TL="╔"; readonly B_TR="╗"; readonly B_BL="╚"; readonly B_BR="╝"
readonly B_V="║"; readonly B_H="═"

# ==============================================================================
# BLOCK 2: ADVANCED INTERFACE COMPONENTS [v18]
# WHAT IT DOES: Manages the visual presentation of the Vibe Check and summary table.
# FUNCTIONAL GOAL: Provide clear, aligned feedback to the user.
# ==============================================================================
print_header() {
    clear
    printf "${PINK}${BOLD}${B_TL}$(printf '%.0s═' {1..60})${B_TR}${DEFAULT}\n"
    printf "${PINK}${BOLD}${B_V}            🌊  MULINETCHII RAPÁ! - VIBE CHECK              ${B_V}${DEFAULT}\n"
    printf "${PINK}${BOLD}${B_BL}$(printf '%.0s═' {1..60})${B_BR}${DEFAULT}\n"
    printf "${BLUE} 📂 Project: ${BOLD}%-12s${DEFAULT} ${GREY}║${DEFAULT} ${BLUE}🚀 Log: ${BOLD}%-18s${DEFAULT}\n\n" "$MODULE_NAME" "$(basename "$LOG_FILE")"
}

print_summary_table() {
    printf "\n${PURPLE}${BOLD}╔$(printf '%.0s═' {1..16})╦$(printf '%.0s═' {1..17})╦$(printf '%.0s═' {1..25})╗${DEFAULT}\n"
    printf "${PURPLE}${BOLD}║  EXERCISE      ║  STATUS         ║  EVALUATION DETAILS     ║${DEFAULT}\n"
    printf "${PURPLE}${BOLD}╠$(printf '%.0s═' {1..16})╬$(printf '%.0s═' {1..17})╬$(printf '%.0s═' {1..25})╣${DEFAULT}\n"

    IFS=', ' read -ra ADDR <<< "$GLOBAL_RESULTS"
    for item in "${ADDR[@]}"; do
        local ex=$(echo $item | cut -d: -f1)
        local st=$(echo $item | cut -d: -f2)
        local color_st="${RED}"; local text_st="KO"; local color_dt="${RED}"; local text_dt="Fail"

        case $st in
            "OK")       color_st="${GREEN}"; text_st="PASS (OK)"; color_dt="${GREY}"; text_dt="Point Awarded!" ;;
            "GHOST_OK") color_st="${RED}";   text_st="PASS (OK)"; color_dt="${RED}";  text_dt="Logic OK / Locked" ;;
            "NORM_KO")  color_st="${RED}";   text_st="NORM ERROR"; color_dt="${RED}";  text_dt="Style Violation" ;;
            "BUILD_KO") color_st="${RED}";   text_st="BUILD ERROR";color_dt="${RED}";  text_dt="File Error" ;;
            "SKIP")     color_st="${CYAN}";  text_st="SKIPPED";   color_dt="${GREY}"; text_dt="Git Env Required" ;;
        esac

        printf "${PURPLE}║${DEFAULT}  %-14s ${PURPLE}║${DEFAULT}  " "$ex"
        printf "%b%-15s%b  ${PURPLE}║${DEFAULT}  " "$color_st" "$text_st" "${DEFAULT}"
        printf "%b%-23s%b  ${PURPLE}║${DEFAULT}\n" "$color_dt" "$text_dt" "${DEFAULT}"
    done
    printf "${PURPLE}${BOLD}╚$(printf '%.0s═' {1..16})╩$(printf '%.0s═' {1..17})╩$(printf '%.0s═' {1..25})╝${DEFAULT}\n"
}

# ==============================================================================
# BLOCK 3: SHELL EVALUATION ENGINE [v18]
# WHAT IT DOES: Runs test scripts (run_test.sh) for Shell/Reloaded modules.
# FUNCTIONAL GOAL: Validate logic without requiring compilation.
# ==============================================================================
run_shell_exercise() {
    local ex_path=$1
    local std_dir=$2
    local ex_name=$(basename "$ex_path")
    local test_script="$ex_path/run_test.sh"

    # Skip Git exercises (Shell00 ex05 and ex06 require a git environment)
    if [[ "$MODULE_NAME" == "Shell00" && ("$ex_name" == "ex05" || "$ex_name" == "ex06") ]]; then
        GLOBAL_RESULTS+="${ex_name}:SKIP, "; return
    fi

    printf "\r${BLUE}🔍 Checking: ${BOLD}[%s]${DEFAULT} - Running Shell...        " "$ex_name"

    if [ ! -d "$std_dir" ]; then
        printf "\r${RED}${ICON_FAIL} Failed: ${BOLD}[%s]${DEFAULT} - Directory not found.       \n" "$ex_name"
        GLOBAL_RESULTS+="${ex_name}:KO, "; HAS_FAILED_FLAG=1; return
    fi

    if [ -f "$test_script" ]; then
        if bash "$test_script" >> "$LOG_FILE" 2>&1; then
            echo "$ex_name: OK" >> "$LOG_FILE"
            if [ "$HAS_FAILED_FLAG" -eq 0 ]; then
                printf "\r${GREEN}${ICON_PASS} Passed: ${BOLD}[%s]${DEFAULT} - Vibe Check Perfect.      \n" "$ex_name"
                GLOBAL_RESULTS+="${ex_name}:OK, "; ((QUESTIONS_PASSED++))
            else
                printf "\r${RED}${ICON_PASS} Passed: ${BOLD}[%s]${DEFAULT} - Logic OK / Locked.       \n" "$ex_name"
                GLOBAL_RESULTS+="${ex_name}:GHOST_OK, "
            fi
        else
            printf "\r${RED}${ICON_FAIL} Failed: ${BOLD}[%s]${DEFAULT} - Functional KO Detected.      \n" "$ex_name"
            GLOBAL_RESULTS+="${ex_name}:KO, "; HAS_FAILED_FLAG=1
        fi
    else
        GLOBAL_RESULTS+="${ex_name}:BUILD_KO, "; HAS_FAILED_FLAG=1
    fi
}

# ==============================================================================
# BLOCK 4: C EVALUATION ENGINE [v18]
# WHAT IT DOES: Validates Norminette, compiles, and runs test binaries.
# FUNCTIONAL GOAL: Ensure integrity of C language exercises.
# ==============================================================================
run_c_exercise() {
    local ex_path=$1
    local std_dir=$2
    local ex_name=$(basename "$ex_path")
    local std_file=$(ls "$std_dir"/*.c 2>/dev/null | head -n 1)

    printf "\r${BLUE}🔍 Checking: ${BOLD}[%s]${DEFAULT} - Analyzing C...            " "$ex_name"

    # Validate that the student file exists
    if [ ! -f "$std_file" ]; then
        echo "$ex_name: missing_file" >> "$LOG_FILE"
        GLOBAL_RESULTS+="${ex_name}:KO, "; HAS_FAILED_FLAG=1; return
    fi

    # Norminette validation
    if ! norminette "$std_dir" &> /dev/null; then
        echo "$ex_name: KO (Norme)" >> "$LOG_FILE"
        printf "\r${RED}${ICON_FAIL} Failed: ${BOLD}[%s]${DEFAULT} - Norminette Error.         \n" "$ex_name"
        GLOBAL_RESULTS+="${ex_name}:NORM_KO, "; HAS_FAILED_FLAG=1; return
    fi

    # Compilation
    if cc -Wall -Wextra -Werror -o bin "$ex_path"/*.c &>> "$LOG_FILE"; then
        if ./bin >> "$LOG_FILE" 2>&1; then
            echo "$ex_name: OK" >> "$LOG_FILE"
            if [ "$HAS_FAILED_FLAG" -eq 0 ]; then
                printf "\r${GREEN}${ICON_PASS} Passed: ${BOLD}[%s]${DEFAULT} - Vibe Check Perfect.      \n" "$ex_name"
                GLOBAL_RESULTS+="${ex_name}:OK, "; ((QUESTIONS_PASSED++))
            else
                printf "\r${RED}${ICON_PASS} Passed: ${BOLD}[%s]${DEFAULT} - Logic OK / Locked.       \n" "$ex_name"
                GLOBAL_RESULTS+="${ex_name}:GHOST_OK, "
            fi
        else
            printf "\r${RED}${ICON_FAIL} Failed: ${BOLD}[%s]${DEFAULT} - Functional KO Detected.      \n" "$ex_name"
            GLOBAL_RESULTS+="${ex_name}:KO, "; HAS_FAILED_FLAG=1
        fi
    else
        printf "\r${RED}${ICON_FAIL} Failed: ${BOLD}[%s]${DEFAULT} - Compilation Error.          \n" "$ex_name"
        GLOBAL_RESULTS+="${ex_name}:BUILD_KO, "; HAS_FAILED_FLAG=1
    fi
    rm -f bin
}

# ==============================================================================
# BLOCK 5: FINALIZATION AND REPORT [v18]
# WHAT IT DOES: Cleans the log and displays the final grade and total time.
# FUNCTIONAL GOAL: Conclude the evaluation lifecycle.
# ==============================================================================
finalize_evaluation() {
    print_summary_table

    # Strip ANSI color codes from the log file for clean plain-text reading
    [[ -f "$LOG_FILE" ]] && sed -i 's/\x1B\[[0-9;]*[mGKHFJA-Za-z]//g' "$LOG_FILE" 2>/dev/null

    local total=${QUESTIONS_TOTAL:-1}
    local final_grade=$(( (QUESTIONS_PASSED * 100) / total ))
    local end_time=$(date +%s)

    printf "\n${PURPLE}${BOLD}╔══════════════════════════════════════════════════════════════╗${DEFAULT}\n"
    printf "${PURPLE}${BOLD}║                      EVALUATION REPORT                       ║${DEFAULT}\n"
    printf "${PURPLE}${BOLD}╠══════════════════════════════════════════════════════════════╣${DEFAULT}\n"

    if [ "$HAS_FAILED_FLAG" -eq 1 ]; then
        printf "  ${RED}${BOLD}FINAL GRADE: %3d / 100${DEFAULT} ${RED}(Chain Failure Detected)${DEFAULT}\n" "$final_grade"
        printf "  ${RED}STATUS: FAILED${DEFAULT} ${GREY}- One or more exercises blocked the flow.${DEFAULT}\n"
    else
        printf "  ${GREEN}${BOLD}FINAL GRADE: %3d / 100${DEFAULT}${DEFAULT}\n" "$final_grade"
        printf "  ${GREEN}STATUS: SUCCESS${DEFAULT} ${GREY}- All clean like the tide.${DEFAULT}\n"
    fi

    printf "  ${GREY}Elapsed time: %d seconds | Results in .txt${DEFAULT}\n" $((end_time - START_TIME))
    printf "${PURPLE}${BOLD}╚══════════════════════════════════════════════════════════════╝${DEFAULT}\n"
}

# ==============================================================================
# BLOCK 6: MAIN TEST LOOP
# WHAT IT DOES: Iterates over the test registry and decides the evaluation engine.
# ==============================================================================
run_all_tests() {
    print_header
    local registry="./tests/$MODULE_NAME"
    [[ ! -d "$registry" ]] && registry="./tests/Shell00" # Safety fallback

    for ex_dir in "$registry"/*/; do
        [ ! -d "$ex_dir" ] && continue
        ((QUESTIONS_TOTAL++))

        local ex_name=$(basename "$ex_dir")
        local std_ex_path="$STUDENT_BASE_DIR/$ex_name"

        # Engine decision based on presence of run_test.sh (Shell/Reloaded) or C
        if [ -f "$ex_dir/run_test.sh" ]; then
            run_shell_exercise "$ex_dir" "$std_ex_path"
        else
            run_c_exercise "$ex_dir" "$std_ex_path"
        fi
    done
    finalize_evaluation
}

run_all_tests
