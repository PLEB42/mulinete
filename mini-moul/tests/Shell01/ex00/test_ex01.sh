#!/bin/sh
# ex01: print_groups.sh deve exibir grupos do FT_USER separados por virgula, sem espacos

PASS=0
FAIL=1
SCRIPT="../ex01/print_groups.sh"

# Teste 1: arquivo existe
if [ ! -f "$SCRIPT" ]; then
    echo "[ex01] FAIL: 'print_groups.sh' nao encontrado em ex01/"
    exit $FAIL
fi

# Teste 2: FT_USER precisa existir no sistema para testar
# Usa o usuario atual como referencia garantida
TEST_USER=$(whoami)
OUTPUT=$(FT_USER="$TEST_USER" sh "$SCRIPT" 2>/dev/null)

if [ -z "$OUTPUT" ]; then
    echo "[ex01] FAIL: saida vazia para FT_USER=$TEST_USER"
    exit $FAIL
fi

# Teste 3: saida nao deve conter espacos
if echo "$OUTPUT" | grep -q ' '; then
    echo "[ex01] FAIL: saida contem espacos (deve ser separada apenas por virgulas)"
    echo "  Obtido: '$OUTPUT'"
    exit $FAIL
fi

# Teste 4: saida deve conter virgulas separando os grupos (se usuario tiver mais de 1 grupo)
EXPECTED_GROUPS=$(id -Gn "$TEST_USER" 2>/dev/null | tr ' ' ',')
if [ "$OUTPUT" != "$EXPECTED_GROUPS" ]; then
    echo "[ex01] FAIL: grupos incorretos para $TEST_USER"
    echo "  Esperado: '$EXPECTED_GROUPS'"
    echo "  Obtido:   '$OUTPUT'"
    exit $FAIL
fi

# Teste 5: nao deve haver newline extra (saida numa unica linha)
linecount=$(echo "$OUTPUT" | wc -l | tr -d ' ')
if [ "$linecount" != "1" ]; then
    echo "[ex01] FAIL: saida deve ser uma unica linha, obtido $linecount linhas"
    exit $FAIL
fi

echo "[ex01] PASS"
exit $PASS
