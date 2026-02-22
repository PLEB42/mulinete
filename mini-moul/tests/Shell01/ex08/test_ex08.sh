#!/bin/sh
# ex08: add_chelou.sh
# FT_NBR1 na base '\"?! (4 chars: ' " ? !)
# FT_NBR2 na base mrdoc (5 chars)
# Saida na base "gtaio luSnemf" (13 chars)

PASS=0
FAIL=1
SCRIPT="../ex08/add_chelou.sh"

if [ ! -f "$SCRIPT" ]; then
    echo "[ex08] FAIL: 'add_chelou.sh' nao encontrado em ex08/"
    exit $FAIL
fi

ERRORS=0

# Caso A: ' (=0) + m (=0) = 0 => "g"
OUTA=$(FT_NBR1="'" FT_NBR2="m" sh "$SCRIPT" 2>/dev/null)
if [ "$OUTA" != "g" ]; then
    echo "[ex08] FAIL: caso A - esperado 'g', obtido '$OUTA'"
    ERRORS=$((ERRORS + 1))
fi

# Caso B: " (=1) + m (=0) = 1 => "t"
OUTB=$(FT_NBR1='"' FT_NBR2="m" sh "$SCRIPT" 2>/dev/null)
if [ "$OUTB" != "t" ]; then
    echo "[ex08] FAIL: caso B - esperado 't', obtido '$OUTB'"
    ERRORS=$((ERRORS + 1))
fi

# Caso C: "' (1*4+0=4) + mm (0) = 4 => "o"
OUTC=$(FT_NBR1='"'"'" FT_NBR2="mm" sh "$SCRIPT" 2>/dev/null)
if [ "$OUTC" != "o" ]; then
    echo "[ex08] FAIL: caso C - esperado 'o', obtido '$OUTC'"
    ERRORS=$((ERRORS + 1))
fi

# Caso D: ! (=3) + c (=4) = 7 => "u"
OUTD=$(FT_NBR1="!" FT_NBR2="c" sh "$SCRIPT" 2>/dev/null)
if [ "$OUTD" != "u" ]; then
    echo "[ex08] FAIL: caso D - esperado 'u', obtido '$OUTD'"
    ERRORS=$((ERRORS + 1))
fi

# Caso E: ? (=2) + d (=2) = 4 => "o"
OUTE=$(FT_NBR1="?" FT_NBR2="d" sh "$SCRIPT" 2>/dev/null)
if [ "$OUTE" != "o" ]; then
    echo "[ex08] FAIL: caso E - esperado 'o', obtido '$OUTE'"
    ERRORS=$((ERRORS + 1))
fi

if [ $ERRORS -gt 0 ]; then
    exit $FAIL
fi

echo "[ex08] PASS"
exit $PASS
