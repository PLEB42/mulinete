#!/bin/sh
# ex09: ft_magic deve permitir que 'file' detecte arquivos com "42" no 42o byte

PASS=0
FAIL=1

MAGICFILE="../ex09/ft_magic"

# Teste 1: arquivo existe
if [ ! -f "$MAGICFILE" ]; then
    echo "[ex09] FAIL: arquivo 'ft_magic' not found em ex09/"
    exit $FAIL
fi

# Teste 2: verifica se o comando file esta disponivel
if ! command -v file > /dev/null 2>&1; then
    echo "[ex09] SKIP: comando 'file' nao disponivel"
    exit $PASS
fi

TMPDIR=$(mktemp -d)

# Cria arquivo de teste COM "42" no 42o byte (bytes 0-41 = 41 chars + "42")
# 41 bytes de padding + "42"
python3 -c "
data = b'A' * 41 + b'42'
with open('$TMPDIR/valid_42_file', 'wb') as f:
    f.write(data)
" 2>/dev/null || perl -e '
print "A" x 41;
print "42";
' > "$TMPDIR/valid_42_file"

# Cria arquivo SEM "42" no 42o byte
python3 -c "
data = b'A' * 41 + b'XX'
with open('$TMPDIR/invalid_42_file', 'wb') as f:
    f.write(data)
" 2>/dev/null || perl -e '
print "A" x 41;
print "XX";
' > "$TMPDIR/invalid_42_file"

# Teste 3: file com ft_magic detecta arquivo valido como "42 file"
OUTPUT=$(file -m "$MAGICFILE" "$TMPDIR/valid_42_file" 2>/dev/null)
if ! echo "$OUTPUT" | grep -qi "42"; then
    echo "[ex09] FAIL: arquivo valido nao foi detectado como '42 file'"
    echo "  Output: $OUTPUT"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

# Teste 4: arquivo invalido NAO deve ser detectado como "42 file"
OUTPUT2=$(file -m "$MAGICFILE" "$TMPDIR/invalid_42_file" 2>/dev/null)
if echo "$OUTPUT2" | grep -qi "42 file"; then
    echo "[ex09] FAIL: arquivo invalido foi incorretamente detectado como '42 file'"
    echo "  Output: $OUTPUT2"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

# Teste 5: magic file tem sintaxe valida
if ! file -m "$MAGICFILE" /dev/null > /dev/null 2>&1; then
    echo "[ex09] FAIL: ft_magic tem sintaxe invalida para o comando file"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

rm -rf "$TMPDIR"
echo "[ex09] PASS"
exit $PASS
