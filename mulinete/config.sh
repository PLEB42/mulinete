#!/bin/bash

# ==============================================================================
# BLOCK: VISUAL_DEFINITIONS [v2]
# WHAT IT DOES: Defines the color palette and compatible icons (256 colors).
# FUNCTIONAL GOAL: Ensure visual consistency across different terminals.
# ==============================================================================

readonly GREEN=$'\033[38;5;84m'
readonly RED=$'\033[38;5;197m'
readonly BLUE=$'\033[38;5;45m'
readonly PURPLE=$'\033[38;5;63m'
readonly PINK=$'\033[38;5;207m'
readonly BLACK=$'\033[38;5;0m'
readonly GREY=$'\033[38;5;244m'
readonly BOLD=$'\033[1m'
readonly DEFAULT=$'\033[0m'

# Status Icons
readonly ICON_PASS="✅"
readonly ICON_FAIL="❌"
readonly ICON_NORM="📜"
readonly ICON_LEAK="💧"
readonly ICON_INFO="ℹ️"

# ==============================================================================
# BLOCK: ENGINE_SETTINGS [v2]
# WHAT IT DOES: Defines compilation flags and execution limits.
# FUNCTIONAL GOAL: Standardize test rigor.
# ==============================================================================

readonly CFLAGS="-Wall -Werror -Wextra"
readonly VALGRIND_ASSIGNMENTS="C11 C12 C13"
readonly TIMEOUT_SECONDS=5
