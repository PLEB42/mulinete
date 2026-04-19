#!/bin/bash

# ==============================================================================
# MULINETI RAPÁ! - Main Orchestrator (Wrapper)
# ==============================================================================
# This script is the entry point. It detects where you are, prepares an 
# isolated (temporary) environment, and calls the official test engine.
# The Norminette is now evaluated silently inside test.sh per exercise.
# ==============================================================================

# ─── ENVIRONMENT CONFIGURATION ─────────────────────────────────────────────────

# Gets the exact directory where this script (.sh) is stored
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# Attempts to load visual and global configurations
CONFIG_FILE="$SCRIPT_DIR/mini-moul/config.sh"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    # Basic fallback in case config.sh is not found
    RED=$'\033[38;5;197m'
    DEFAULT=$'\033[0m'
    echo -e "${RED}Critical Error: config.sh file not found in ${CONFIG_FILE}${DEFAULT}"
    exit 1
fi

# Global State Variables
ASSIGNMENT_NAME=""
TMP_DIR="./mini-moul_tmp"

# Icons for interface
ICON_SEARCH="🔍"
ICON_CLEAN="🧹"
ICON_ALERT="🚨"
ICON_RUN="🚀"

# ─── CLEANUP AND SAFETY FUNCTIONS ───────────────────────────────────────────

# Removes the temporary test folder to avoid cluttering the user's repository
cleanup() {
    if [ -d "$TMP_DIR" ]; then
        rm -rf "$TMP_DIR"
    fi
}

# Captures CTRL+C (SIGINT) to ensure the temporary folder is deleted
# even if the user aborts the test midway
handle_sigint() {
    printf "\n${RED}${ICON_ALERT} Test aborted by user!${DEFAULT}\n"
    printf "${GREY}${ICON_CLEAN} Cleaning temporary files...${DEFAULT}\n"
    cleanup
    printf "${GREEN}Environment cleaned. See you, thanks! 🤙${DEFAULT}\n"
    exit 1
}

# ─── VALIDATION AND PREPARATION FUNCTIONS ────────────────────────────────────────

# Identifies which module the user is trying to test based on the current folder
detect_assignment() {
    ASSIGNMENT_NAME=$(basename "$(pwd)")
    
    # Strict regex: Accepts only valid Piscine folders (C, Shell or Rush)
    if [[ $ASSIGNMENT_NAME =~ ^(C(0[0-9]|1[0-3])|Shell0[0-9]|Rush0[0-2])$ ]]; then
        return 0 # Success
    else
        return 1 # Fail
    fi
}

# ─── MAIN FLOW ──────────────────────────────────────────────────────────

main() {
    # 1. Validates if the user is in the correct folder
    if ! detect_assignment; then
        printf "${RED}${ICON_ALERT} Current directory (%s) is not a valid exercise.${DEFAULT}\n" "$ASSIGNMENT_NAME"
        printf "${GREY}Please go to the module directory (e.g.: ${PURPLE}cd C01${GREY}) before running the software.${DEFAULT}\n"
        exit 1
    fi

    # 2. Registers the safety trigger (CTRL+C)
    trap handle_sigint SIGINT

    # 3. Prepares the sandbox environment (isolated area to avoid conflicts with user files)
    # Silently copies the engine folder into the current exercise
    cp -R "$SCRIPT_DIR/mini-moul" "$TMP_DIR"

    # 4. Enters the sandbox and triggers the Test Engine
    cd "$TMP_DIR" || exit 1
    
    # Calls the test.sh script passing the module name (e.g.: "C01")
    bash ./test.sh "$ASSIGNMENT_NAME"
    
    # 5. Returns to the exercise folder and performs cleanup
    cd .. || exit 1
    cleanup
}

# Starts the script by calling the main function
main