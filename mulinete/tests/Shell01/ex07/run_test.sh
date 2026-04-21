#!/bin/sh

# ==============================================================================
# BLOCK: DEFINIÇÕES DE AMBIENTE E CONSTANTES [v2]
# WHAT IT DOES: Define códigos de saída e localiza o arquivo alvo do estudante.
# FUNCTIONAL GOAL: Centralizar parâmetros para facilitar a portabilidade.
# ==============================================================================
SUCCESS=0
FAIL=1
STUDENT_FILE="../ex07/b"

# ==============================================================================
# BLOCK: VALIDAÇÃO DE PRÉ-REQUISITOS (EDGE CASES DE SISTEMA) [v1]
# WHAT IT DOES: Verifica se o arquivo existe e se o estudante tem permissão de leitura.
# FUNCTIONAL GOAL: Garantir que o teste não quebre por erros de permissão.
# ==============================================================================
if [ ! -f "$STUDENT_FILE" ]; then
    echo "[ex07] FAIL: Arquivo 'b' not found no directory ex07/[cite: 110, 207]."
    exit $FAIL
fi

if [ ! -r "$STUDENT_FILE" ]; then
    echo "[ex07] FAIL: No read permission no arquivo 'b'."
    exit $FAIL
fi

# ==============================================================================
# BLOCK: GERAÇÃO DA REFERÊNCIA "A" (STRICT CONTENT) [v3]
# WHAT IT DOES: Recria o arquivo 'a' com precisão cirúrgica de bytes e newlines.
# FUNCTIONAL GOAL: Servir de gabarito para a comparação do diff [cite: 211-220].
# ALTERAÇÃO: Uso de printf para garantir que não existam espaços fantasmas.
# ==============================================================================
TEMP_DIR=$(mktemp -d)
REFERENCE_FILE="$TEMP_DIR/a"

# O texto abaixo segue rigorosamente os caracteres e quebras de line do subject [cite: 212-220]
printf "STARWARS\n" > "$REFERENCE_FILE"
printf "Episode IV, A NEW HOPE It is a period of civil war.\n" >> "$REFERENCE_FILE"
printf "\n" >> "$REFERENCE_FILE"
printf "Rebel spaceships, striking from a hidden base, have won their first victory against the evil Galactic Empire.\n" >> "$REFERENCE_FILE"
printf "During the battle, Rebel spies managed to steal secret plans to the Empire's ultimate weapon, the DEATH STAR, \n" >> "$REFERENCE_FILE"
printf "an armored space station with enough power to destroy an entire planet.\n" >> "$REFERENCE_FILE"
printf "\n" >> "$REFERENCE_FILE"
printf "Pursued by the Empire's sinister agents, Princess Leia races home aboard her starship, custodian of the stolen plans that can save her people and restore freedom to the galaxy...\n" >> "$REFERENCE_FILE"
printf "\n" >> "$REFERENCE_FILE"

# ==============================================================================
# BLOCK: VALIDAÇÃO LÓGICA (DIFF ANALYZER) [v2]
# WHAT IT DOES: Executa o diff e captura diferenças em modo texto (-a).
# FUNCTIONAL GOAL: Identificar discrepâncias entre o arquivo do aluno e o original.
# ==============================================================================
DIFERENCAS=$(diff -a "$REFERENCE_FILE" "$STUDENT_FILE" 2>/dev/null)

if [ -n "$DIFERENCAS" ]; then
    echo "[ex07] FAIL: O arquivo 'b' is not identical ao arquivo 'a'[cite: 210]."
    echo "--- Diff Details (diff a b) ---"
    echo "$DIFERENCAS"
    rm -rf "$TEMP_DIR"
    exit $FAIL
fi

# ==============================================================================
# BLOCK: SIMULAÇÃO DO COMANDO DO SUBJECT [v1]
# WHAT IT DOES: Simula o comando 'diff a b > sw.diff' e valida o tamanho do output.
# FUNCTIONAL GOAL: Garantir que o comando pedido gera um arquivo de 0 bytes.
# ==============================================================================
diff "$REFERENCE_FILE" "$STUDENT_FILE" > "$TEMP_DIR/sw.diff" 2>/dev/null
TAMANHO_SW_DIFF=$(wc -c < "$TEMP_DIR/sw.diff" | tr -d ' ')

if [ "$TAMANHO_SW_DIFF" -ne 0 ]; then
    echo "[ex07] FAIL: sw.diff should have 0 bytes, but got $TAMANHO_SW_DIFF."
    rm -rf "$TEMP_DIR"
    exit $FAIL
fi

# ==============================================================================
# BLOCK: LIMPEZA E ENCERRAMENTO [v1]
# WHAT IT DOES: Remove arquivos temporários e retorna o status de sucesso.
# FUNCTIONAL GOAL: Manter a sandbox limpa após o teste.
# ==============================================================================
rm -rf "$TEMP_DIR"
echo "[ex07] PASS"
exit $SUCCESS