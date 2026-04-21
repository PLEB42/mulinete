#!/bin/sh
# ex02: 'clean' deve ser um unico comando find que:
# - encontra arquivos terminando com ~ ou comecando e terminando com #
# - exibe e deleta esses arquivos

PASS=0
FAIL=1

CLEANFILE="../ex02/clean"

# Teste 1: arquivo existe
if [ ! -f "$CLEANFILE" ]; then
    echo "[ex02] FAIL: arquivo 'clean' nao encontrado em ex02/"
    exit $FAIL
fi

# Teste 2: contem apenas UM comando (sem ; ou && ou ||)
content=$(cat "$CLEANFILE")
if echo "$content" | grep -qE '^\s*$'; then
    : # linhas vazias ok
fi
# Remove comentarios e linhas vazias para contar comandos reais
cmd_lines=$(echo "$content" | grep -v '^\s*#' | grep -v '^\s*$')
if echo "$cmd_lines" | grep -qE '(;|&&|\|\|)'; then
    echo "[ex02] FAIL: nao pode usar ';', '&&' ou '||'"
    exit $FAIL
fi

# Teste 3: cria ambiente com arquivos alvo e nao-alvo
TMPDIR=$(mktemp -d)
mkdir -p "$TMPDIR/subdir"

# Arquivos que DEVEM ser deletados
touch "$TMPDIR/file~"
touch "$TMPDIR/backup~"
touch "$TMPDIR/#draft#"
touch "$TMPDIR/#notes#"
touch "$TMPDIR/subdir/nested~"
touch "$TMPDIR/subdir/#temp#"

# Arquivos que NAO devem ser deletados
touch "$TMPDIR/normal_file"
touch "$TMPDIR/file.c"
touch "$TMPDIR/#incomplete"       # apenas comeca com #
touch "$TMPDIR/incomplete#"       # apenas termina com #
touch "$TMPDIR/subdir/keep_me"

# Executa o clean no diretorio de teste
cd "$TMPDIR" && sh "$(cd - > /dev/null && pwd)/$CLEANFILE" > /dev/null 2>&1
cd - > /dev/null

# Teste 4: arquivos alvo foram deletados
ERRORS=0
for f in "file~" "backup~" "#draft#" "#notes#" "subdir/nested~" "subdir/#temp#"; do
    if [ -e "$TMPDIR/$f" ]; then
        echo "[ex02] FAIL: '$f' deveria ter sido deletado mas ainda existe"
        ERRORS=$((ERRORS + 1))
    fi
done

# Teste 5: arquivos normais foram preservados
for f in "normal_file" "file.c" "#incomplete" "incomplete#" "subdir/keep_me"; do
    if [ ! -e "$TMPDIR/$f" ]; then
        echo "[ex02] FAIL: '$f' nao deveria ter sido deletado"
        ERRORS=$((ERRORS + 1))
    fi
done

rm -rf "$TMPDIR"

if [ $ERRORS -gt 0 ]; then
    exit $FAIL
fi

echo "[ex02] PASS"
exit $PASS
