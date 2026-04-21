#!/bin/sh
# ex03: count_files.sh deve contar arquivos regulares e directorys (incluindo ".")

PASS=0
FAIL=1
SCRIPT="../ex03/count_files.sh"

if [ ! -f "$SCRIPT" ]; then
    echo "[ex03] FAIL: 'count_files.sh' not found em ex03/"
    exit $FAIL
fi

TMPDIR=$(mktemp -d)
ERRORS=0

# Cria estrutura controlada:
# "." (1) + subdir1 (1) + subdir2 (1) + file1 (1) + file2 (1) + subdir1/file3 (1) = 6
mkdir -p "$TMPDIR/subdir1"
mkdir -p "$TMPDIR/subdir2"
touch "$TMPDIR/file1"
touch "$TMPDIR/file2"
touch "$TMPDIR/subdir1/file3"
EXPECTED=6

SCRIPT_ABS=$(cd "$(dirname "$SCRIPT")" && pwd)/$(basename "$SCRIPT")
OUTPUT=$(cd "$TMPDIR" && sh "$SCRIPT_ABS" 2>/dev/null)

# Teste 2: saida e um numero
if ! echo "$OUTPUT" | grep -qE '^[0-9]+$'; then
    echo "[ex03] FAIL: saida deve ser um numero, got: '$OUTPUT'"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

# Teste 3: numero correto
if [ "$OUTPUT" != "$EXPECTED" ]; then
    echo "[ex03] FAIL: contagem incorreta. Expected $EXPECTED, got $OUTPUT"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

# Teste 4: saida e uma unica line
linecount=$(echo "$OUTPUT" | wc -l | tr -d ' ')
if [ "$linecount" != "1" ]; then
    echo "[ex03] FAIL: saida deve ter 1 line, got $linecount"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

# Teste 5: testa com estrutura diferente para garantir que nao e hardcoded
mkdir -p "$TMPDIR/extra_dir"
touch "$TMPDIR/extra_file"
EXPECTED2=8
OUTPUT2=$(cd "$TMPDIR" && sh "$SCRIPT_ABS" 2>/dev/null)
if [ "$OUTPUT2" != "$EXPECTED2" ]; then
    echo "[ex03] FAIL: contagem incorreta apos adicionar itens. Expected $EXPECTED2, got $OUTPUT2"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

rm -rf "$TMPDIR"
echo "[ex03] PASS"
exit $PASS
