#!/bin/sh
# ex01: arquivo z deve conter exatamente "Z\n"

PASS=0
FAIL=1

# Teste 1: Adicionado "../" para subir um nível e achar a pasta ex01 real
if [ ! -f "../ex01/z" ]; then
    echo "[ex01] FAIL: arquivo 'z' not found em ex01/"
    exit $FAIL
fi

# Teste 2: Ajustado para o path correto
content=$(cat "../ex01/z")
if [ "$content" != "Z" ]; then
    echo "[ex01] FAIL: incorrect content. Expected 'Z', got '$content'"
    exit $FAIL
fi

# Teste 3: Ajustado para o path correto
size=$(wc -c < "../ex01/z")
size=$(echo "$size" | tr -d ' ')
if [ "$size" != "2" ]; then
    echo "[ex01] FAIL: incorrect size. Expected 2 bytes, got $size bytes"
    exit $FAIL
fi

echo "[ex01] PASS"
exit $PASS