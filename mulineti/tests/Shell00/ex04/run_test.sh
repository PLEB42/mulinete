#!/bin/sh
# ex04: midLS deve listar arquivos/dirs ordenados por data de modificacao,
# separados por ", ", diretorios com "/" no final, sem arquivos ocultos

PASS=0
FAIL=1

MIDLS="../ex04/midLS"

# Teste 1: arquivo existe
if [ ! -f "$MIDLS" ]; then
    echo "[ex04] FAIL: arquivo 'midLS' nao encontrado em ex04/"
    exit $FAIL
fi

# Prepara ambiente de teste isolado
TMPDIR=$(mktemp -d)
mkdir -p "$TMPDIR/subdir1"
mkdir -p "$TMPDIR/subdir2"
touch "$TMPDIR/.hidden_file"
touch "$TMPDIR/.hidden_dir"

# Cria arquivos com timestamps controlados
sleep 0 # garante ordenacao
touch -t 202301010001 "$TMPDIR/file_a"
touch -t 202301010002 "$TMPDIR/subdir1"
touch -t 202301010003 "$TMPDIR/file_b"
touch -t 202301010004 "$TMPDIR/subdir2"

# Executa o midLS no diretorio de teste
SCRIPT_CONTENT=$(cat "$MIDLS")
OUTPUT=$(cd "$TMPDIR" && eval "$SCRIPT_CONTENT" 2>/dev/null)

# Teste 2: nao lista arquivos ocultos
if echo "$OUTPUT" | grep -q "hidden"; then
    echo "[ex04] FAIL: listando arquivos ocultos (comecam com '.')"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

# Teste 3: diretorios terminam com /
if ! echo "$OUTPUT" | grep -q "subdir1/"; then
    echo "[ex04] FAIL: diretorios deveriam terminar com '/'"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

# Teste 4: separados por ", " (virgula espaco)
if ! echo "$OUTPUT" | grep -q ", "; then
    echo "[ex04] FAIL: entradas deveriam ser separadas por ', '"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

# Teste 5: ordenado por data de modificacao (mais antigo primeiro)
# file_a(01) < subdir1(02) < file_b(03) < subdir2(04)
expected="subdir2/, file_b, subdir1/, file_a"

if [ "$OUTPUT" != "$expected" ]; then
    echo "[ex04] FAIL: ordem ou formato incorreto"
    echo "  Esperado: '$expected'"
    echo "  Obtido:   '$OUTPUT'"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

# Teste 6: nao deve listar "." e ".."
if echo "$OUTPUT" | grep -qE '(^|, )\.\.' || echo "$OUTPUT" | grep -qE '(^|, )\.(,|$)'; then
    echo "[ex04] FAIL: nao deve listar '.' ou '..'"
    rm -rf "$TMPDIR"
    exit $FAIL
fi

rm -rf "$TMPDIR"
echo "[ex04] PASS"
exit $PASS
