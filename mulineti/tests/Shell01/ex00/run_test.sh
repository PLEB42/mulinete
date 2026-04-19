#!/bin/sh

# ==============================================================================
# BLOCO 1: RESOLUÇÃO DE AMBIENTE E PATHS [v2]
# O QUE FAZ: Localiza o diretório de entrega de forma absoluta.
# OBJETIVO FUNCIONAL: Garantir que o teste funcione independente de onde
# o script mulineti seja disparado.
# ==============================================================================
PASS=0
FAIL=1

# Localiza o diretório ex00 relativo ao script de teste
TEST_DIR=$(cd "$(dirname "$0")" && pwd)
STUDENT_DIR=$(cd "$TEST_DIR/../ex00" 2>/dev/null && pwd)
TARGET_FILE="$STUDENT_DIR/z"

# ==============================================================================
# BLOCO 2: VALIDAÇÃO DE LIMPEZA DE DIRETÓRIO (MOULINETTE STYLE) [v1]
# O QUE FAZ: Verifica se existe APENAS o arquivo 'z' na pasta.
# OBJETIVO FUNCIONAL: Cumprir a regra de "nenhum arquivo adicional"[cite: 74, 270].
# ==============================================================================
if [ ! -d "$STUDENT_DIR" ]; then
    echo "[ex00] FAIL: Diretório 'ex00' não encontrado."
    exit $FAIL
fi

# Conta todos os arquivos, incluindo ocultos, exceto '.' e '..'
FILE_COUNT=$(ls -A "$STUDENT_DIR" | wc -l | tr -d ' ')

if [ "$FILE_COUNT" -ne 1 ]; then
    echo "[ex00] FAIL: O diretório deve conter APENAS o arquivo 'z'[cite: 74]."
    echo "       Arquivos detectados: $(ls -A "$STUDENT_DIR" | tr '\n' ' ')"
    exit $FAIL
fi

if [ ! -f "$TARGET_FILE" ]; then
    echo "[ex00] FAIL: O arquivo único encontrado não se chama 'z'[cite: 111]."
    exit $FAIL
fi

# ==============================================================================
# BLOCO 3: INTEGRIDADE BINÁRIA E HEXADECIMAL [v1]
# O QUE FAZ: Valida os bytes exatos (5a 0a) e o tamanho do arquivo.
# OBJETIVO FUNCIONAL: Garantir que não existam espaços ou caracteres nulos.
# ==============================================================================
# Requisito: 'Z' (0x5a) seguido de '\n' (0x0a) = 2 bytes.
HEX_CONTENT=$(hexdump -ve '1/1 "%.2x"' "$TARGET_FILE")
EXPECTED_HEX="5a0a"

if [ "$HEX_CONTENT" != "$EXPECTED_HEX" ]; then
    echo "[ex00] FAIL: Conteúdo hexadecimal incorreto."
    echo "       Esperado: 5a 0a (Z + newline)"
    echo "       Obtido:   $(echo "$HEX_CONTENT" | sed 's/../& /g')"
    exit $FAIL
fi

SIZE=$(wc -c < "$TARGET_FILE" | tr -d ' ')
if [ "$SIZE" -ne 2 ]; then
    echo "[ex00] FAIL: Tamanho incorreto. Esperado 2 bytes, obtido $SIZE."
    exit $FAIL
fi

# ==============================================================================
# BLOCO 4: VALIDAÇÃO DE PERMISSÕES [v1]
# O QUE FAZ: Verifica se o arquivo é legível.
# OBJETIVO FUNCIONAL: Garantir que a Moulinette consiga ler o arquivo[cite: 66, 262].
# ==============================================================================
if [ ! -r "$TARGET_FILE" ]; then
    echo "[ex00] FAIL: O arquivo 'z' não tem permissão de leitura."
    exit $FAIL
fi

echo "[ex00] PASS"
exit $PASS