#!/bin/bash

# ==============================================================================
# BLOCO: DEFINICOES_VISUAIS [v2]
# O QUE FAZ: Define a paleta de cores e ícones compatíveis (256 cores).
# OBJETIVO FUNCIONAL: Garantir consistência visual em diferentes terminais.
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

# Ícones de Status
readonly ICON_PASS="✅"
readonly ICON_FAIL="❌"
readonly ICON_NORM="📜"
readonly ICON_LEAK="💧"
readonly ICON_INFO="ℹ️"

# ==============================================================================
# BLOCO: CONFIGURACOES_MOTOR [v2]
# O QUE FAZ: Define flags de compilação e limites de execução.
# OBJETIVO FUNCIONAL: Padronizar o rigor dos testes.
# ==============================================================================

readonly CFLAGS="-Wall -Werror -Wextra"
readonly VALGRIND_ASSIGNMENTS="C11 C12 C13"
readonly TIMEOUT_SECONDS=5