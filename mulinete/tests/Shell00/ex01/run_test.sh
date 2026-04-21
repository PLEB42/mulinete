#!/bin/sh
# ex01: testShell00.tar deve conter arquivo com permissoes -r--r-xr-x (0455)

PASS=0
FAIL=1

TARFILE="../ex01/testShell00.tar"
TMPDIR=$(mktemp -d)

# Teste 1: arquivo tar existe
if [ ! -f "$TARFILE" ]; then
    echo "[ex01] FAIL: arquivo 'testShell00.tar' not found em ex01/"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

# Teste 2: tar e valido e contem testShell00
if ! tar -xf "$TARFILE" -C "$TMPDIR" 2>/dev/null; then
    echo "[ex01] FAIL: could not extract o tar"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

if [ ! -f "$TMPDIR/testShell00" ]; then
    echo "[ex01] FAIL: arquivo 'testShell00' not found dentro do tar"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

# Teste 3: permissoes corretas -r--r-xr-x (0455)
perms=$(stat -c "%a" "$TMPDIR/testShell00" 2>/dev/null || stat -f "%OLp" "$TMPDIR/testShell00" 2>/dev/null)
if [ "$perms" != "455" ]; then
    echo "[ex01] FAIL: incorrect permissions. Expected 455, got $perms"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

# Teste 4: nao deve haver arquivos extras no tar (apenas testShell00)
filecount=$(tar -tf "$TARFILE" 2>/dev/null | grep -v '/$' | wc -l | tr -d ' ')
if [ "$filecount" != "1" ]; then
    echo "[ex01] FAIL: tar contem $filecount arquivo(s), expected apenas 1 (testShell00)"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

rm -rf "$TMPDIR"
echo "[ex01] PASS"
exit $PASS
