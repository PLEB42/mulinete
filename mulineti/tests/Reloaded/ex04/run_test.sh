#!/bin/sh
# ex04: MAC.sh deve exibir enderecos MAC da maquina, um por linha

PASS=0
FAIL=1
SCRIPT="../ex04/MAC.sh"

if [ ! -f "$SCRIPT" ]; then
    echo "[ex04] FAIL: 'MAC.sh' nao encontrado em ex04/"
    exit $FAIL
fi

# Verifica se ha interfaces com MAC real disponivel
if command -v ip > /dev/null 2>&1; then
    REAL_MACS=$(ip link show 2>/dev/null | grep -oiE '([0-9a-f]{2}:){5}[0-9a-f]{2}' \
        | grep -iv 'ff:ff:ff:ff:ff:ff' | grep -iv '00:00:00:00:00:00')
elif command -v ifconfig > /dev/null 2>&1; then
    REAL_MACS=$(ifconfig 2>/dev/null | grep -oiE '([0-9a-f]{2}:){5}[0-9a-f]{2}' \
        | grep -iv 'ff:ff:ff:ff:ff:ff' | grep -iv '00:00:00:00:00:00')
fi

if [ -z "$REAL_MACS" ]; then
    echo "[ex04] SKIP: nenhuma interface de rede com MAC disponivel neste ambiente"
    exit $PASS
fi

OUTPUT=$(sh "$SCRIPT" 2>/dev/null)

# Teste 2: saida nao vazia
if [ -z "$OUTPUT" ]; then
    echo "[ex04] FAIL: saida vazia — nenhum endereco MAC exibido"
    exit $FAIL
fi

ERRORS=0

# Teste 3: cada linha e um MAC valido
while IFS= read -r line; do
    [ -z "$line" ] && continue
    if ! echo "$line" | grep -qiE '^([0-9a-f]{2}[:\-]){5}[0-9a-f]{2}$'; then
        echo "[ex04] FAIL: linha nao e um MAC valido: '$line'"
        ERRORS=$((ERRORS + 1))
    fi
done << EOF
$OUTPUT
EOF

# Teste 4: MACs batem com os da maquina
while IFS= read -r mac; do
    [ -z "$mac" ] && continue
    if ! echo "$REAL_MACS" | grep -qi "^${mac}$"; then
        echo "[ex04] FAIL: MAC '$mac' nao corresponde a nenhuma interface"
        ERRORS=$((ERRORS + 1))
    fi
done << EOF
$OUTPUT
EOF

if [ $ERRORS -gt 0 ]; then
    exit $FAIL
fi

echo "[ex04] PASS"
exit $PASS
