#!/bin/sh
# ex02: exo2.tar deve conter arquivos/dirs com permissoes e tipos corretos

PASS=0
FAIL=1

TARFILE="../ex02/exo2.tar"
TMPDIR=$(mktemp -d)
ERRORS=0

check_perms() {
    local file="$1"
    local expected="$2"
    local name="$3"
    local perms
    perms=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%OLp" "$file" 2>/dev/null)
    if [ "$perms" != "$expected" ]; then
        echo "[ex02] FAIL: $name - incorrect permissions. Expected $expected, got $perms"
        ERRORS=$((ERRORS + 1))
    fi
}

check_type() {
    local file="$1"
    local type="$2"  # f=file, d=dir, l=link
    local name="$3"
    if [ "$type" = "f" ] && [ ! -f "$file" ]; then
        echo "[ex02] FAIL: $name - should be a regular file"
        ERRORS=$((ERRORS + 1))
    elif [ "$type" = "d" ] && [ ! -d "$file" ]; then
        echo "[ex02] FAIL: $name - should be a directory"
        ERRORS=$((ERRORS + 1))
    elif [ "$type" = "l" ] && [ ! -L "$file" ]; then
        echo "[ex02] FAIL: $name - should be a symbolic link"
        ERRORS=$((ERRORS + 1))
    fi
}

# Teste 1: tar existe
if [ ! -f "$TARFILE" ]; then
    echo "[ex02] FAIL: arquivo 'exo2.tar' not found em ex02/"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

# Teste 2: extrai corretamente
if ! tar -xf "$TARFILE" -C "$TMPDIR" 2>/dev/null; then
    echo "[ex02] FAIL: could not extract o tar"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

# Teste 3: verifica tipos
check_type "$TMPDIR/test0" "d" "test0"
check_type "$TMPDIR/test1" "f" "test1"
check_type "$TMPDIR/test2" "d" "test2"
check_type "$TMPDIR/test3" "f" "test3"
check_type "$TMPDIR/test4" "f" "test4"
check_type "$TMPDIR/test5" "f" "test5"
check_type "$TMPDIR/test6" "l" "test6"

# Teste 4: verifica permissoes
# drwx--xr-x = 711? Nao - vamos detalhar:
# d rwx --x r-x = owner:rwx group:--x other:r-x = 715
check_perms "$TMPDIR/test0" "715" "test0 (drwx--xr-x)"
# -rwx--xr-- = owner:rwx group:--x other:r-- = 714
check_perms "$TMPDIR/test1" "714" "test1 (-rwx--xr--)"
# dr-x---r-- = owner:r-x group:--- other:r-- = 504
check_perms "$TMPDIR/test2" "504" "test2 (dr-x---r--)"
# -r-----r-- = owner:r-- group:--- other:r-- = 404
check_perms "$TMPDIR/test3" "404" "test3 (-r-----r--)"
# -rw-r----x = owner:rw- group:r-- other:--x = 641
check_perms "$TMPDIR/test4" "641" "test4 (-rw-r----x)"
# -r-----r-- = 404 (hard link de test3)
check_perms "$TMPDIR/test5" "404" "test5 (-r-----r--)"

# Teste 5: test3 e test5 devem ser hard links (mesmo inode)
inode3=$(stat -c "%i" "$TMPDIR/test3" 2>/dev/null || stat -f "%i" "$TMPDIR/test3" 2>/dev/null)
inode5=$(stat -c "%i" "$TMPDIR/test5" 2>/dev/null || stat -f "%i" "$TMPDIR/test5" 2>/dev/null)
if [ "$inode3" != "$inode5" ]; then
    echo "[ex02] FAIL: test3 e test5 should be hard links (mesmo inode)"
    ERRORS=$((ERRORS + 1))
fi

# Teste 6: test6 deve apontar para test0
link_target=$(readlink "$TMPDIR/test6" 2>/dev/null)
if [ "$link_target" != "test0" ]; then
    echo "[ex02] FAIL: test6 should point to 'test0', aponta para '$link_target'"
    ERRORS=$((ERRORS + 1))
fi

# Teste 7: tamanhos de arquivo
size1=$(wc -c < "$TMPDIR/test1" 2>/dev/null | tr -d ' ')
if [ "$size1" != "4" ]; then
    echo "[ex02] FAIL: test1 should have 4 bytes, got $size1"
    ERRORS=$((ERRORS + 1))
fi

size3=$(wc -c < "$TMPDIR/test3" 2>/dev/null | tr -d ' ')
if [ "$size3" != "1" ]; then
    echo "[ex02] FAIL: test3 should have 1 byte, tem $size3"
    ERRORS=$((ERRORS + 1))
fi

size4=$(wc -c < "$TMPDIR/test4" 2>/dev/null | tr -d ' ')
if [ "$size4" != "2" ]; then
    echo "[ex02] FAIL: test4 should have 2 bytes, got $size4"
    ERRORS=$((ERRORS + 1))
fi

rm -rf "$TMPDIR"

if [ $ERRORS -gt 0 ]; then
    exit $FAIL
fi

echo "[ex02] PASS"
exit $PASS
