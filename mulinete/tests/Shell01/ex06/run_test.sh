#!/bin/sh
# ex06: skip.sh deve exibir apenas lines impares do ls -l (line 1, 3, 5...)

PASS=0
FAIL=1
SCRIPT="../ex06/skip.sh"

if [ ! -f "$SCRIPT" ]; then
    echo "[ex06] FAIL: 'skip.sh' not found em ex06/"
    exit $FAIL
fi

TMPDIR=$(mktemp -d)
ERRORS=0

# Cria ambiente controlado com arquivos conhecidos
touch "$TMPDIR/aaa"
touch "$TMPDIR/bbb"
touch "$TMPDIR/ccc"
touch "$TMPDIR/ddd"

SCRIPT_ABS=$(cd "$(dirname "$SCRIPT")" && pwd)/$(basename "$SCRIPT")

# Captura ls -l real do directory
LS_OUTPUT=$(cd "$TMPDIR" && ls -l 2>/dev/null)
SCRIPT_OUTPUT=$(cd "$TMPDIR" && sh "$SCRIPT_ABS" 2>/dev/null)

# Teste 2: saida nao pode ser vazia
if [ -z "$SCRIPT_OUTPUT" ]; then
    echo "[ex06] FAIL: saida vazia"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

# Teste 3: constroi o expected (lines 1, 3, 5... do ls -l)
EXPECTED=$(echo "$LS_OUTPUT" | awk 'NR % 2 == 1')

if [ "$SCRIPT_OUTPUT" != "$EXPECTED" ]; then
    echo "[ex06] FAIL: saida incorreta"
    echo "  Expected:"
    echo "$EXPECTED"
    echo "  Obtido:"
    echo "$SCRIPT_OUTPUT"
    ERRORS=$((ERRORS + 1))
fi

# Teste 4: numero de lines deve ser ceil(total/2)
TOTAL_LINES=$(echo "$LS_OUTPUT" | wc -l | tr -d ' ')
OUTPUT_LINES=$(echo "$SCRIPT_OUTPUT" | wc -l | tr -d ' ')
EXPECTED_LINES=$(( (TOTAL_LINES + 1) / 2 ))
if [ "$OUTPUT_LINES" != "$EXPECTED_LINES" ]; then
    echo "[ex06] FAIL: numero de lines incorreto. Expected $EXPECTED_LINES, got $OUTPUT_LINES"
    ERRORS=$((ERRORS + 1))
fi

rm -rf "$TMPDIR"

if [ $ERRORS -gt 0 ]; then
    exit $FAIL
fi

echo "[ex06] PASS"
exit $PASS
