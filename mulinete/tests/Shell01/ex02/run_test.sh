#!/bin/sh
# ex02: find_sh.sh deve listar todos os .sh no dir atual e subdirectorys, sem extensao

PASS=0
FAIL=1
SCRIPT="../ex02/find_sh.sh"

if [ ! -f "$SCRIPT" ]; then
    echo "[ex02] FAIL: 'find_sh.sh' not found em ex02/"
    exit $FAIL
fi

TMPDIR=$(mktemp -d)
ERRORS=0

# Cria estrutura de teste
mkdir -p "$TMPDIR/subdir/nested"
touch "$TMPDIR/file1.sh"
touch "$TMPDIR/file2.sh"
touch "$TMPDIR/not_a_script.c"
touch "$TMPDIR/subdir/file3.sh"
touch "$TMPDIR/subdir/nested/file4.sh"
touch "$TMPDIR/subdir/not_shell.txt"

SCRIPT_ABS=$(cd "$(dirname "$SCRIPT")" && pwd)/$(basename "$SCRIPT")
OUTPUT=$(cd "$TMPDIR" && sh "$SCRIPT_ABS" 2>/dev/null)

# Teste 2: arquivos .sh aparecem SEM extensao
for name in file1 file2 file3 file4; do
    if ! echo "$OUTPUT" | grep -q "^$name$"; then
        echo "[ex02] FAIL: '$name' not found na saida (sem extensao .sh)"
        ERRORS=$((ERRORS + 1))
    fi
done

# Teste 3: extensao .sh NAO deve aparecer na saida
if echo "$OUTPUT" | grep -q '\.sh'; then
    echo "[ex02] FAIL: extensao '.sh' nao deve aparecer na saida"
    ERRORS=$((ERRORS + 1))
fi

# Teste 4: arquivos nao-.sh NAO devem aparecer
for name in not_a_script not_shell; do
    if echo "$OUTPUT" | grep -q "$name"; then
        echo "[ex02] FAIL: '$name' nao deveria aparecer na saida"
        ERRORS=$((ERRORS + 1))
    fi
done

# Teste 5: cada entrada e uma unica line (sem paths, so o nome)
while IFS= read -r line; do
    [ -z "$line" ] && continue
    if echo "$line" | grep -q '/'; then
        echo "[ex02] FAIL: saida deve exibir apenas o nome, nao o path: '$line'"
        ERRORS=$((ERRORS + 1))
    fi
done << EOF
$OUTPUT
EOF

rm -rf "$TMPDIR"

if [ $ERRORS -gt 0 ]; then
    exit $FAIL
fi

echo "[ex02] PASS"
exit $PASS
