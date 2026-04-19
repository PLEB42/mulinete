#!/bin/sh
# ex05: git_commit.sh deve exibir exatamente os ultimos 5 commits (SHA completo, um por linha)

PASS=0
FAIL=1

SCRIPT="../ex05/git_commit.sh"

# Teste 1: arquivo existe
if [ ! -f "$SCRIPT" ]; then
    echo "[ex05] FAIL: arquivo 'git_commit.sh' nao encontrado em ex05/"
    exit $FAIL
fi

# Teste 2: precisa estar dentro de um repositorio git
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "[ex05] SKIP: nao esta dentro de um repositorio git"
    exit $PASS
fi

# Conta quantos commits existem
commit_count=$(git log --oneline 2>/dev/null | wc -l | tr -d ' ')
if [ "$commit_count" -lt 5 ]; then
    echo "[ex05] SKIP: repositorio tem menos de 5 commits ($commit_count)"
    exit $PASS
fi

# Executa o script
OUTPUT=$(bash "$SCRIPT" 2>/dev/null)

# Teste 3: exatamente 5 linhas
linecount=$(echo "$OUTPUT" | wc -l | tr -d ' ')
if [ "$linecount" != "5" ]; then
    echo "[ex05] FAIL: deveria exibir 5 linhas, exibiu $linecount"
    exit $FAIL
fi

# Teste 4: cada linha e um SHA valido (40 caracteres hexadecimais)
ERRORS=0
line_num=0
echo "$OUTPUT" | while IFS= read -r line; do
    line_num=$((line_num + 1))
    if ! echo "$line" | grep -qE '^[0-9a-f]{40}$'; then
        echo "[ex05] FAIL: linha $line_num nao e um SHA valido: '$line'"
        ERRORS=$((ERRORS + 1))
    fi
done

# Teste 5: os SHAs conferem com o git log real
EXPECTED=$(git log --pretty=format:"%H" -5 2>/dev/null)
if [ "$OUTPUT" != "$EXPECTED" ]; then
    echo "[ex05] FAIL: SHAs nao correspondem aos ultimos 5 commits"
    echo "  Esperado:"
    echo "$EXPECTED"
    echo "  Obtido:"
    echo "$OUTPUT"
    exit $FAIL
fi

echo "[ex05] PASS"
exit $PASS
