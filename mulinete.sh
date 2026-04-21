#!/bin/bash

# ==============================================================================
# BLOCK: ENVIRONMENT_AND_INFRASTRUCTURE [v12]
# WHAT IT DOES: Resolves absolute paths and prepares the logs folder.
# ==============================================================================
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
readonly TOOL_ROOT="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
readonly CURRENT_INVOCATION_DIR=$(pwd)
readonly SANDBOX_PATH="$CURRENT_INVOCATION_DIR/mulinete_tmp"
readonly LOGS_DIR="$TOOL_ROOT/logs"

mkdir -p "$LOGS_DIR"

# UI Colors
readonly PINK='\033[38;5;206m'; readonly BLUE='\033[38;5;39m'; readonly DEFAULT='\033[0m'
readonly BOLD='\033[1m'; readonly CYAN='\033[38;5;51m'; readonly YELLOW='\033[38;5;226m'; readonly RED='\033[0;31m'

# ==============================================================================
# BLOCK: PROJECT_DISPATCHER [v2]
# WHAT IT DOES: Prepares the sandbox and launches test.sh with the correct log.
# ==============================================================================
prepare_and_run() {
    local project=$1
    local log_path="$LOGS_DIR/${project}.txt"

    # Cleanup and Setup
    rm -rf "$SANDBOX_PATH" &>/dev/null
    mkdir -p "$SANDBOX_PATH"

    # Copy the engine folder into the sandbox
    if [[ -d "$TOOL_ROOT/mulinete" ]]; then
        cp -R "$TOOL_ROOT/mulinete/." "$SANDBOX_PATH/"
    else
        printf "${RED}❌ Critical Error: 'mulinete' engine folder not found.${DEFAULT}\n"
        exit 1
    fi

    # Handshake with the Engine
    if [[ -f "$SANDBOX_PATH/test.sh" ]]; then
        cd "$SANDBOX_PATH" || exit 1
        bash ./test.sh "$project" 0 "$log_path"
        cd "$CURRENT_INVOCATION_DIR" || exit 1
    else
        printf "${RED}❌ Error: test.sh not found in sandbox.${DEFAULT}\n"
    fi
    rm -rf "$SANDBOX_PATH" &>/dev/null
}

# ==============================================================================
# BLOCK: UI_MENU_SYSTEM [v2]
# WHAT IT DOES: Interface for projects outside the Piscine auto-detection flow.
# ==============================================================================
show_common_core_submenu() {
    printf "\n${BLUE}--- Common Core - Milestones ---${DEFAULT}\n"
    printf "1. Milestone 0 (Libft)\n"
    printf "2. Back\n"
    printf "Choice: "
    read -r sub
    case $sub in
        1) prepare_and_run "Libft" ;;
        2) show_main_menu ;;
    esac
}

show_main_menu() {
    clear
    printf "${PINK}${BOLD}╔══════════════════════════════════════════════════════════════╗${DEFAULT}\n"
    printf "${PINK}${BOLD}║              🌊  MULINETE - COMMAND CENTER                   ║${DEFAULT}\n"
    printf "${PINK}${BOLD}╚══════════════════════════════════════════════════════════════╝${DEFAULT}\n"
    printf "${CYAN}1. Piscine (Auto-Detect)${DEFAULT}\n"
    printf "${CYAN}2. Piscine Reloaded${DEFAULT}\n"
    printf "${CYAN}3. Common Core (Milestones)${DEFAULT}\n"
    printf "${YELLOW}0. Exit${DEFAULT}\n"
    printf "\n${BOLD}Choose an option: ${DEFAULT}"
    read -r option

    case $option in
        1) prepare_and_run "$(basename "$CURRENT_INVOCATION_DIR")" ;;
        2) prepare_and_run "Reloaded" ;;
        3) show_common_core_submenu ;;
        0) exit 0 ;;
        *) show_main_menu ;;
    esac
}

# ==============================================================================
# BLOCK: CONTEXT_AGENT [v2]
# WHAT IT DOES: If inside a CXX or ShellXX folder, runs directly.
# ==============================================================================
CURRENT_DIR=$(basename "$CURRENT_INVOCATION_DIR")
if [[ $CURRENT_DIR =~ ^(C(0[0-9]|1[0-3])|Shell0[0-9])$ ]]; then
    prepare_and_run "$CURRENT_DIR"
else
    show_main_menu
fi
