#!/bin/bash

# MULINETCHII RAPÁ! – Test Engine

# Loads color settings and global variables
# Attempts to load from the current directory or from the script directory
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
if [ -f "$SCRIPT_DIR/config.sh" ]; then
    source "$SCRIPT_DIR/config.sh"
else
    echo "Error: config.sh not found!"
    exit 1
fi

# ─── GLOBAL STATE ────────────────────────────────────────────────────────────
# Variables to track scoring and tests
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

# ─── USER INTERFACE ─────────────────────────────────────

# Prints a blank line
space() { echo ""; }

# Checks whether the current module is a Shell module
is_shell() { [[ "$1" =~ ^Shell ]]; }

# Prints the script's cool header
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
    printf " 🌊 ${PINK}Real talk:${DEFAULT}Warm up that code because the wave is coming.\n"
    printf " 🚀 ${BLUE}Status: ${DEFAULT}On point, no stress, everything lined up.\n"
    space
}

# Prints the footer with the final score and execution time
print_footer() {
    printf "${PURPLE}------------------------------------------------------------${DEFAULT}\n"
    space
    
    # Prevents division by zero in case no tests were executed
    local total=${QUESTIONS_TOTAL:-1}
    [ "$total" -eq 0 ] && total=1 
    
    local percent=$((100 * QUESTIONS_PASSED / total))
    local end_time=$(date +%s)
    local elapsed=$((end_time - START_TIME))

    printf " Summary:      %s\n" "$GLOBAL_RESULTS"
    
    if [ "$percent" -ge 50 ]; then
        printf " Final Grade:  ${GREEN}%d/100${DEFAULT} ${ICON_PASS}\n" "$percent"
        printf " Status:      ${BG_GREEN}${BLACK}${BOLD} APPROVED ${DEFAULT}\n"
    else
        printf " Final Grade:  ${RED}%d/100${DEFAULT} ${ICON_FAIL}\n" "$percent"
        printf " Status:      ${BG_RED}${BOLD} FAILED ${DEFAULT}\n"
    fi
    
    printf " Time:       ${GREY}%d seconds${DEFAULT}\n" "$elapsed"
    printf "\n${BLUE} Mulineti will not be updated. Don’t even worry about git pull.${DEFAULT}\n"
    space
}

# Records and displays the result of an individual exercise
# Usage: log_result <status (0=pass, 1=fail, 2=norm_error)> <exercise_name> <test_file_name>
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
        printf "${BG_RED}${BOLD} NORM ${DEFAULT} ${PURPLE}%s/${DEFAULT}%s ${GREY}(Logic OK, but failed the Norm)${DEFAULT}\n" "$ex_name" "$test_name"
    else
        GLOBAL_RESULTS+="${RED}${ex_name}: KO${DEFAULT}"
        printf "${BG_RED}${BOLD} FAIL ${DEFAULT} ${PURPLE}%s/${DEFAULT}%s\n" "$ex_name" "$test_name"
    fi
    space
}

# ─── UTILITY EXECUTION FUNCTIONS ──────────────────────────────────────────

# Runs a compiled C binary, applying Valgrind if the module requires it
run_binary() {
    local binary="$1"
    local module="$2"

    for vg_assign in $VALGRIND_ASSIGNMENTS; do
        if [ "$module" == "$vg_assign" ]; then
            if command -v valgrind &> /dev/null; then
                if ! valgrind --leak-check=full --error-exitcode=1 --quiet "$binary" 2>/dev/null; then
                    printf "    ${RED}${ICON_LEAK} Memory leak detected in: $(basename "$binary")${DEFAULT}\n"
                    return 1
                fi
                return 0
            fi
        fi
    done
    # If Valgrind is not needed, run normally
    "$binary" 2>/dev/null
}

# ─── TEST RUNNERS ────────────────────────────────────────────

# Handles exclusively C exercises (C00 to C13)
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
        printf "    ${RED}${ICON_WARN} No .c file found for testing.${DEFAULT}\n"
        log_result 1 "$ex_name" "N/A"
        return
    fi

    # 2. Norminette check (Silent in the real directory)
    if command -v norminette &> /dev/null; then
        if ! norminette "../$ex_name" &> /dev/null; then
            norm_failed=1
        fi
    fi

    # 3. Strict Compilation Test
    local first_c_file=$(echo "$c_files" | head -n 1)
    if ! cc -Wall -Werror -Wextra -o test_bin "$first_c_file" 2>/dev/null; then
        printf "    ${RED}${ICON_FAIL} Compilation error in %s (Flags: -Wall -Werror -Wextra).${DEFAULT}\n" "$test_name"
        log_result 1 "$ex_name" "$test_name"
        return
    fi
    rm -f test_bin # Cleans up if compilation succeeded

    # 4. Execution of the folder's internal tests
    for test_file in "$folder_path"/*.[csh]; do
        # If the test is an additional .sh script
        if [[ "$test_file" == *.sh ]]; then
            if ! sh "$test_file" 2>/dev/null; then
                is_failed=1
            fi
        # If it's a C file
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

    # 5. Final evaluation of the exercise (Applies the Norminette penalty)
    if [ "$is_failed" -eq 0 ] && [ "$norm_failed" -eq 1 ]; then
        log_result 2 "$ex_name" "$test_name"
    else
        log_result "$is_failed" "$ex_name" "$test_name"
    fi
}

# Handles exclusively Shell exercises (Shell00 and Shell01)
run_shell_exercise() {
    local folder_path="$1"
    local ex_name="$(basename "$folder_path")"
    
    # Gets the first .sh script found in the test folder
    local test_scripts=$(ls "$folder_path"/*.sh 2>/dev/null)
    local test_name="$(basename "$(echo "$test_scripts" | head -n 1)")"
    
    local is_failed=0

    # 1. Validates whether the dev prepared the test script
    if [ -z "$test_scripts" ]; then
        printf "    ${RED}${ICON_WARN} No test script (.sh) found in %s.${DEFAULT}\n" "$ex_name"
        log_result 1 "$ex_name" "N/A"
        return
    fi

    # 2. Runs each test script found
    for script in $test_scripts; do
        # Attention: The script is expected to return exit 0 (PASS)
        if ! sh "$script" 2>/dev/null; then
            is_failed=1
        fi
    done

    # 3. Final evaluation of the exercise
    log_result "$is_failed" "$ex_name" "$test_name"
}

# ─── MAIN ENGINE ──────────────────────────────────────────────────────────

# Central function that orchestrates scanning and testing
run_all_tests() {
    local target_module="$1"
    local available_modules=""
    
    START_TIME=$(date +%s)

    # Scans the tests folder to find available modules
    for dir in ./tests/*; do
        [ ! -d "$dir" ] && continue
        
        local dir_name="$(basename "$dir")"
        available_modules+="$dir_name "

        # Found the test folder for the requested module (e.g., C01, Shell00)
        if [ "$dir_name" == "$target_module" ]; then
            MODULE_FOUND=1
            print_header
            printf "${GREEN} Preparing test environment for [ %s ]...${DEFAULT}\n" "$target_module"
            space

            # Iterates over each exercise (ex00, ex01...) inside the module folder
            # Iterates over each exercise (ex00, ex01...) inside the module folder
            for assignment_dir in "$dir"/*/; do
                [ ! -d "$assignment_dir" ] && continue
                
                # Remove a barra no final do diretório para ficar limpo (ex: ex00)
                local clean_dir="${assignment_dir%/}"
                local ex_name="$(basename "$clean_dir")"
                
                # Verifica se é um módulo de Shell ou C para chamar o runner correto
                if is_shell "$target_module"; then
                    run_shell_exercise "$clean_dir"
                else
                    run_c_exercise "$clean_dir" "$target_module"
                fi
            done
            break
        fi
    done

    # Error handling in case the module has no programmed tests
    if [ "$MODULE_FOUND" -eq 0 ]; then
        printf "\n${RED}${ICON_WARN} Tests for module '%s' are not yet available/configured.${DEFAULT}\n" "$target_module"
        printf "${GREY}Available: ${PURPLE}%s${DEFAULT}\n\n" "$available_modules"
        exit 1
    fi
    print_footer
}

# ─── SCRIPT START ───────────────────────────────────────────

# 1. Checks if the user passed an argument
if [ -z "$1" ]; then
    printf "${RED}Error: You need to select a module.${DEFAULT}\n"
    printf "Usage example: ${GREEN}./test.sh C01${DEFAULT}\n"
    exit 1
fi

# 2. Strict Security Filter (Prevents injection and protects the directory)
# Now accepts C00 to C13, Shell00 to Shell01, and prepared for Rush00 to Rush02
if [[ "$1" =~ ^(C(0[0-9]|1[0-3])|Shell0[0-1]|Rush0[0-2])$ ]]; then
    run_all_tests "$1"
    
    # 3. Terminal Cleanup: Ensures the console returns to the original color
    echo -e "${DEFAULT}"
    exit 0
else
    printf "${RED}Invalid argument: '%s'${DEFAULT}\n" "$1"
    printf "Choose between:${PURPLE}C00 a C13${DEFAULT}, ${PURPLE}Shell00 and Shell01${DEFAULT} or ${PURPLE}Rush00 to Rush02${DEFAULT}.\n"
    exit 1
fi