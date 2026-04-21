#!/bin/sh

# ==============================================================================
# BLOCK: RESOLUÇÃO DE AMBIENTE E PATHS [v2]
# WHAT IT DOES: Localiza o directory de entrega de forma absoluta.
# FUNCTIONAL GOAL: Garantir que o teste funcione independente de onde
# o script mulinete is launched.
# ==============================================================================
PASS=0
FAIL=1

# Localiza o directory ex00 relativo ao script de teste
TEST_DIR=$(cd "$(dirname "$0")" && pwd)
STUDENT_DIR=$(cd "$TEST_DIR/../ex00" 2>/dev/null && pwd)
TARGET_FILE="$STUDENT_DIR/z"

# ==============================================================================
# BLOCK: VALIDAÇÃO DE LIMPEZA DE DIRETÓRIO (MOULINETTE STYLE) [v1]
# WHAT IT DOES: Verifica se existe APENAS o arquivo 'z' na pasta.
# FUNCTIONAL GOAL: Cumprir a regra de "nenhum arquivo adicional"[cite: 74, 270].
# ==============================================================================
if [ ! -d "$STUDENT_DIR" ]; then
    echo "[ex00] FAIL: Directory 'ex00' not found."
    exit $FAIL
fi

# Conta todos os arquivos, incluindo ocultos, exceto '.' e '..'
FILE_COUNT=$(ls -A "$STUDENT_DIR" | wc -l | tr -d ' ')

if [ "$FILE_COUNT" -ne 1 ]; then
    echo "[ex00] FAIL: O directory should contain ONLY the file 'z'[cite: 74]."
    echo "       Arquivos detectados: $(ls -A "$STUDENT_DIR" | tr '\n' ' ')"
    exit $FAIL
fi

if [ ! -f "$TARGET_FILE" ]; then
    echo "[ex00] FAIL: The only file found is not named 'z'[cite: 111]."
    exit $FAIL
fi

# ==============================================================================
# BLOCK: INTEGRIDADE BINÁRIA E HEXADECIMAL [v1]
# WHAT IT DOES: Valida os bytes exatos (5a 0a) e o tamanho do arquivo.
# FUNCTIONAL GOAL: Garantir que não existam espaços ou caracteres nulos.
# ==============================================================================
# Requisito: 'Z' (0x5a) seguido de '\n' (0x0a) = 2 bytes.
HEX_CONTENT=$(hexdump -ve '1/1 "%.2x"' "$TARGET_FILE")
EXPECTED_HEX="5a0a"

if [ "$HEX_CONTENT" != "$EXPECTED_HEX" ]; then
    echo "[ex00] FAIL: Incorrect hexadecimal content."
    echo "       Expected: 5a 0a (Z + newline)"
    echo "       Obtido:   $(echo "$HEX_CONTENT" | sed 's/../& /g')"
    exit $FAIL
fi

SIZE=$(wc -c < "$TARGET_FILE" | tr -d ' ')
if [ "$SIZE" -ne 2 ]; then
    echo "[ex00] FAIL: Incorrect size. Expected 2 bytes, got $SIZE."
    exit $FAIL
fi

# ==============================================================================
# BLOCK: VALIDAÇÃO DE PERMISSÕES [v1]
# WHAT IT DOES: Verifica se o arquivo é legível.
# FUNCTIONAL GOAL: Garantir que a Moulinette consiga ler o arquivo[cite: 66, 262].
# ==============================================================================
if [ ! -r "$TARGET_FILE" ]; then
    echo "[ex00] FAIL: O arquivo 'z' has no read permission."
    exit $FAIL
fi

echo "[ex00] PASS"
exit $PASS