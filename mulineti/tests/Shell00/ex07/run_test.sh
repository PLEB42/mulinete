#!/bin/sh
# ex07: arquivo 'b' deve ser identico ao arquivo 'a' descrito no subject
# (diff a b deve gerar output vazio)

PASS=0
FAIL=1

BFILE="../ex07/b"

# Teste 1: arquivo b existe
if [ ! -f "$BFILE" ]; then
    echo "[ex07] FAIL: arquivo 'b' nao encontrado em ex07/"
    exit $FAIL
fi

# Recria o arquivo 'a' exatamente como descrito no subject
TMPDIR=$(mktemp -d)
cat > "$TMPDIR/a" << 'ENDOFFILE'
STARWARS
Episode IV, A NEW HOPE It is a period of civil war.

Rebel spaceships, striking from a hidden base, have won their first victory against the evil Galactic Empire.
During the battle, Rebel spies managed to steal secret plans to the Empire's ultimate weapon, the DEATH STAR,
an armored space station with enough power to destroy an entire planet.

Pursued by the Empire's sinister agents, Princess Leia races home aboard her starship, custodian of the stolen plans that can save her people and restore freedom to the galaxy...

ENDOFFILE

# Teste 2: diff entre a e b deve ser vazio
DIFF_OUTPUT=$(diff "$TMPDIR/a" "$BFILE" 2>/dev/null)
if [ -n "$DIFF_OUTPUT" ]; then
    echo "[ex07] FAIL: diff a b nao e vazio. Diferencas encontradas:"
    echo "$DIFF_OUTPUT"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

# Teste 3: valida que diff a b > sw.diff funciona (sw.diff fica vazio)
diff "$TMPDIR/a" "$BFILE" > "$TMPDIR/sw.diff" 2>/dev/null
swsize=$(wc -c < "$TMPDIR/sw.diff" | tr -d ' ')
if [ "$swsize" != "0" ]; then
    echo "[ex07] FAIL: sw.diff deveria ser vazio mas tem $swsize bytes"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

rm -rf "$TMPDIR"
echo "[ex07] PASS"
exit $PASS
