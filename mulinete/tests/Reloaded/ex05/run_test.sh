#!/bin/sh
# ex05: deve existir um arquivo de nome especial "\?$*'MaRViN'*$?\" contendo apenas "42"

PASS=0
FAIL=1
TARGET_NAME='"\?$*'"'"'MaRViN'"'"'*$?\"'
FILEPATH="../ex05/$TARGET_NAME"

# Teste 1: arquivo existe
if [ ! -f "$FILEPATH" ]; then
    echo "[ex05] FAIL: arquivo '$TARGET_NAME' not found em ex05/"
    exit $FAIL
fi

# Teste 2: conteudo e exatamente "42" seguido de newline
content=$(cat "$FILEPATH" 2>/dev/null)
if [ "$content" != "42" ]; then
    echo "[ex05] FAIL: incorrect content. Expected '42', got '$content'"
    exit $FAIL
fi

# Teste 3: tamanho exato = 3 bytes ("42\n")
size=$(wc -c < "$FILEPATH" | tr -d ' ')
if [ "$size" != "3" ]; then
    echo "[ex05] FAIL: incorrect size. Expected 3 bytes, got $size"
    exit $FAIL
fi

# Teste 4: permissoes -rw---xr-- (614) conforme exemplo do subject
perms=$(stat -c "%a" "$FILEPATH" 2>/dev/null || stat -f "%OLp" "$FILEPATH" 2>/dev/null)
if [ "$perms" != "614" ]; then
    echo "[ex05] WARN: permissoes sao $perms, subject sugere 614 (-rw---xr--)"
    # nao falha pois a moulinette pode variar neste ponto
fi

echo "[ex05] PASS"
exit $PASS
