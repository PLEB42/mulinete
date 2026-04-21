#!/bin/sh
# ex06: git_ignore.sh deve listar arquivos existentes ignorados pelo .gitignore

PASS=0
FAIL=1

SCRIPT="../ex06/git_ignore.sh"

# Teste 1: arquivo existe
if [ ! -f "$SCRIPT" ]; then
    echo "[ex06] FAIL: arquivo 'git_ignore.sh' not found em ex06/"
    exit $FAIL
fi

# Teste 2: precisa de repositorio git
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "[ex06] SKIP: nao esta dentro de um repositorio git"
    exit $PASS
fi

# Prepara arquivos ignorados temporarios para testar
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

# Cria arquivo temporario ignorado (usando padrao comum do .gitignore da 42)
echo "*.tmp_41test" >> "$REPO_ROOT/.gitignore"
touch "$REPO_ROOT/testfile_41test.tmp_41test"

OUTPUT=$(bash "$SCRIPT" 2>/dev/null)

# Teste 3: o arquivo criado deve aparecer na saida
if ! echo "$OUTPUT" | grep -q "testfile_41test.tmp_41test"; then
    echo "[ex06] FAIL: arquivo ignorado existente nao aparece na saida"
    # Cleanup
    sed -i '/\.tmp_41test/d' "$REPO_ROOT/.gitignore" 2>/dev/null
    rm -f "$REPO_ROOT/testfile_41test.tmp_41test"
    exit $FAIL
fi

# Teste 4: arquivos nao-ignorados NAO devem aparecer
touch "$REPO_ROOT/notignored_41test_file.xyz_unique"
OUTPUT2=$(bash "$SCRIPT" 2>/dev/null)
if echo "$OUTPUT2" | grep -q "notignored_41test_file.xyz_unique"; then
    echo "[ex06] FAIL: arquivo nao-ignorado aparece na saida"
    sed -i '/\.tmp_41test/d' "$REPO_ROOT/.gitignore" 2>/dev/null
    rm -f "$REPO_ROOT/testfile_41test.tmp_41test"
    rm -f "$REPO_ROOT/notignored_41test_file.xyz_unique"
    exit $FAIL
fi

# Teste 5: cada line deve ser um arquivo que realmente existe no disco
ERRORS=0
echo "$OUTPUT2" | while IFS= read -r line; do
    [ -z "$line" ] && continue
    filepath="$REPO_ROOT/$line"
    # tenta tambem caminho absoluto direto
    if [ ! -e "$filepath" ] && [ ! -e "$line" ]; then
        echo "[ex06] FAIL: '$line' listado mas nao existe no disco"
        ERRORS=$((ERRORS + 1))
    fi
done

# Cleanup
sed -i '/\.tmp_41test/d' "$REPO_ROOT/.gitignore" 2>/dev/null
rm -f "$REPO_ROOT/testfile_41test.tmp_41test"
rm -f "$REPO_ROOT/notignored_41test_file.xyz_unique"

if [ $ERRORS -gt 0 ]; then
    exit $FAIL
fi

echo "[ex06] PASS"
exit $PASS
