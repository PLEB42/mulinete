#!/bin/sh
# ex07: r_dwssap.sh - processa /etc/passwd com multiplas transformacoes
# Passos: remove comentarios > 1 linha sim 1 nao (a partir da 2a) > inverte login
#         > ordena inverso > filtra FT_LINE1..FT_LINE2 > join ", " > termina com "."

PASS=0
FAIL=1
SCRIPT="../ex07/r_dwssap.sh"

if [ ! -f "$SCRIPT" ]; then
    echo "[ex07] FAIL: 'r_dwssap.sh' nao encontrado em ex07/"
    exit $FAIL
fi

if [ ! -f /etc/passwd ]; then
    echo "[ex07] SKIP: /etc/passwd nao disponivel"
    exit $PASS
fi

ERRORS=0

# Computa manualmente o resultado esperado para FT_LINE1=1 FT_LINE2=3
EXPECTED=$(cat /etc/passwd \
    | grep -v '^#' \
    | awk 'NR % 2 == 0' \
    | cut -d: -f1 \
    | rev \
    | sort -r \
    | sed -n '1,3p' \
    | tr '\n' ',' \
    | sed 's/,$//' \
    | sed 's/,/, /g')
EXPECTED="${EXPECTED}."

OUTPUT=$(FT_LINE1=1 FT_LINE2=3 sh "$SCRIPT" 2>/dev/null)

# Teste 2: saida nao vazia
if [ -z "$OUTPUT" ]; then
    echo "[ex07] FAIL: saida vazia"
    exit $FAIL
fi

# Teste 3: termina com "."
if ! echo "$OUTPUT" | grep -q '\.$'; then
    echo "[ex07] FAIL: saida deve terminar com '.'"
    echo "  Obtido: '$OUTPUT'"
    ERRORS=$((ERRORS + 1))
fi

# Teste 4: resultado correto para FT_LINE1=1 FT_LINE2=3
if [ "$OUTPUT" != "$EXPECTED" ]; then
    echo "[ex07] FAIL: resultado incorreto para FT_LINE1=1 FT_LINE2=3"
    echo "  Esperado: '$EXPECTED'"
    echo "  Obtido:   '$OUTPUT'"
    ERRORS=$((ERRORS + 1))
fi

# Teste 5: sem newline no meio (saida numa linha so)
linecount=$(printf '%s' "$OUTPUT" | wc -l | tr -d ' ')
if [ "$linecount" != "0" ] && [ "$linecount" != "1" ]; then
    echo "[ex07] FAIL: saida deve ser uma linha, obtido $linecount"
    ERRORS=$((ERRORS + 1))
fi

# Teste 6: separadores sao ", " (virgula espaco)
stripped=$(echo "$OUTPUT" | sed 's/\.$//')
if [ $(echo "$stripped" | tr ',' '\n' | wc -l | tr -d ' ') -gt 1 ]; then
    if ! echo "$OUTPUT" | grep -q ', '; then
        echo "[ex07] FAIL: separador deve ser ', ' (virgula espaco)"
        ERRORS=$((ERRORS + 1))
    fi
fi

if [ $ERRORS -gt 0 ]; then
    exit $FAIL
fi

echo "[ex07] PASS"
exit $PASS
