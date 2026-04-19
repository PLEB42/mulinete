#!/bin/sh
# ex00: arquivo z deve conter exatamente "Z\n"

PASS=0
FAIL=1

# Teste 1: Adicionado "../" para subir um nível e achar a pasta ex00 real
if [ ! -f "../ex00/z" ]; then
    echo "[ex00] FAIL: arquivo 'z' nao encontrado em ex00/"
    exit $FAIL
fi

# Teste 2: Ajustado para o path correto
content=$(cat "../ex00/z")
if [ "$content" != "Z" ]; then
    echo "[ex00] FAIL: conteudo incorreto. Esperado 'Z', obtido '$content'"
    exit $FAIL
fi

# Teste 3: Ajustado para o path correto
size=$(wc -c < "../ex00/z")
size=$(echo "$size" | tr -d ' ')
if [ "$size" != "2" ]; then
    echo "[ex00] FAIL: tamanho incorreto. Esperado 2 bytes, obtido $size bytes"
    exit $FAIL
fi

echo "[ex00] PASS"
exit $PASS