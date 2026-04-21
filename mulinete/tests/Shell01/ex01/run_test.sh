#!/bin/sh

# ==============================================================================
# BLOCK: AMBIENTE E RESOLUÇÃO DE CAMINHOS [v2]
# WHAT IT DOES: Define constantes e localiza o script do aluno de forma absoluta.
# FUNCTIONAL GOAL: Garantir resiliência independente do directory de execução.
# ==============================================================================
PASS=0
FAIL=1
ARQUIVO_ALUNO="../ex02/find_sh.sh"

# Resolução de path absoluto para execução segura dentro da sandbox
if [ ! -f "$ARQUIVO_ALUNO" ]; then
    echo "[ex02] FAIL: Arquivo 'find_sh.sh' not found em ex02/."
    exit $FAIL
fi
SCRIPT_ABS=$(cd "$(dirname "$ARQUIVO_ALUNO")" && pwd)/$(basename "$ARQUIVO_ALUNO")

# ==============================================================================
# BLOCK: CRIAÇÃO DA SANDBOX HOSTIL [v2]
# WHAT IT DOES: Cria uma estrutura de arquivos complexa para testar o 'find' recursivo.
# FUNCTIONAL GOAL: Validar se o aluno encontra arquivos em qualquer profundidade
# e se ignora arquivos que não terminam estritamente em '.sh'.
# ==============================================================================
TMPDIR=$(mktemp -d)
mkdir -p "$TMPDIR/a/b/c"
mkdir -p "$TMPDIR/.hidden_dir"

# Arquivos que DEVEM ser encontrados
touch "$TMPDIR/root_script.sh"
touch "$TMPDIR/a/deep_script.sh"
touch "$TMPDIR/a/b/c/very_deep.sh"
touch "$TMPDIR/.hidden_dir/hidden_script.sh"

# Arquivos que NÃO DEVEM ser encontrados (Edge Cases)
touch "$TMPDIR/not_sh.txt"           # Extensão errada
touch "$TMPDIR/wrong_ext.sh.txt"     # .sh no meio do nome
touch "$TMPDIR/.sh"                  # Apenas a extensão
touch "$TMPDIR/sh"                   # Sem ponto

# ==============================================================================
# BLOCK: EXECUÇÃO E CAPTURA [v1]
# WHAT IT DOES: Entra na sandbox e executa o script do aluno.
# FUNCTIONAL GOAL: Isolar o ambiente de execução para evitar falsos positivos
# do próprio sistema operacional.
# ==============================================================================
OUTPUT=$(cd "$TMPDIR" && sh "$SCRIPT_ABS" 2>/dev/null | sort)
ERRORS=0

# ==============================================================================
# BLOCK: VALIDAÇÃO OSTENSIVA DE REQUISITOS [v1]
# WHAT IT DOES: Aplica 4 testes rigorosos sobre a saída gerada.
# FUNCTIONAL GOAL: Garantir conformidade com o Subject (sem .sh, sem paths).
# ==============================================================================

# Teste A: Presença de nomes expecteds (sem extensão)
for name in root_script deep_script very_deep hidden_script; do
    if ! echo "$OUTPUT" | grep -q "^$name$"; then
        echo "[ex02] FAIL: '$name' should be in the output, mas não foi encontrado."
        ERRORS=$((ERRORS + 1))
    fi
done

# Teste B: Proibição de extensão '.sh' na saída 
if echo "$OUTPUT" | grep -q '\.sh'; then
    echo "[ex02] FAIL: A extensão '.sh' was detected in the output. Should display only the name."
    ERRORS=$((ERRORS + 1))
fi

# Teste C: Proibição de caminhos (paths) [cite: 329, 331]
if echo "$OUTPUT" | grep -q '/'; then
    echo "[ex02] FAIL: Caminhos de directory detectados. Display only the filename."
    ERRORS=$((ERRORS + 1))
fi

# Teste D: Filtragem de arquivos intrusos
for intruder in not_sh wrong_ext .sh sh; do
    if echo "$OUTPUT" | grep -q "^$intruder$"; then
        echo "[ex02] FAIL: O arquivo '$intruder' was listed incorrectly."
        ERRORS=$((ERRORS + 1))
    fi
done

# ==============================================================================
# BLOCK: LIMPEZA E VEREDITO [v1]
# WHAT IT DOES: Remove a sandbox e retorna o status final.
# ==============================================================================
rm -rf "$TMPDIR"

if [ $ERRORS -gt 0 ]; then
    exit $FAIL
fi

echo "[ex02] PASS"
exit $PASS