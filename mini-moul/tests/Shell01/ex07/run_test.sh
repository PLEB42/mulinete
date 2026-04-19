#!/bin/sh

# ==============================================================================
# BLOCO 1: DEFINIÇÕES DE AMBIENTE E CONSTANTES [v2]
# O QUE FAZ: Define códigos de saída e localiza o arquivo alvo do estudante.
# OBJETIVO FUNCIONAL: Centralizar parâmetros para facilitar a portabilidade.
# ==============================================================================
SUCESSO=0
FALHA=1
ARQUIVO_ESTUDANTE="../ex07/b"

# ==============================================================================
# BLOCO 2: VALIDAÇÃO DE PRÉ-REQUISITOS (EDGE CASES DE SISTEMA) [v1]
# O QUE FAZ: Verifica se o arquivo existe e se o estudante tem permissão de leitura.
# OBJETIVO FUNCIONAL: Garantir que o teste não quebre por erros de permissão.
# ==============================================================================
if [ ! -f "$ARQUIVO_ESTUDANTE" ]; then
    echo "[ex07] FAIL: Arquivo 'b' não encontrado no diretório ex07/[cite: 110, 207]."
    exit $FALHA
fi

if [ ! -r "$ARQUIVO_ESTUDANTE" ]; then
    echo "[ex07] FAIL: Sem permissão de leitura no arquivo 'b'."
    exit $FALHA
fi

# ==============================================================================
# BLOCO 3: GERAÇÃO DA REFERÊNCIA "A" (STRICT CONTENT) [v3]
# O QUE FAZ: Recria o arquivo 'a' com precisão cirúrgica de bytes e newlines.
# OBJETIVO FUNCIONAL: Servir de gabarito para a comparação do diff [cite: 211-220].
# ALTERAÇÃO: Uso de printf para garantir que não existam espaços fantasmas.
# ==============================================================================
DIRETORIO_TEMPORARIO=$(mktemp -d)
ARQUIVO_REFERENCIA="$DIRETORIO_TEMPORARIO/a"

# O texto abaixo segue rigorosamente os caracteres e quebras de linha do subject [cite: 212-220]
printf "STARWARS\n" > "$ARQUIVO_REFERENCIA"
printf "Episode IV, A NEW HOPE It is a period of civil war.\n" >> "$ARQUIVO_REFERENCIA"
printf "\n" >> "$ARQUIVO_REFERENCIA"
printf "Rebel spaceships, striking from a hidden base, have won their first victory against the evil Galactic Empire.\n" >> "$ARQUIVO_REFERENCIA"
printf "During the battle, Rebel spies managed to steal secret plans to the Empire's ultimate weapon, the DEATH STAR, \n" >> "$ARQUIVO_REFERENCIA"
printf "an armored space station with enough power to destroy an entire planet.\n" >> "$ARQUIVO_REFERENCIA"
printf "\n" >> "$ARQUIVO_REFERENCIA"
printf "Pursued by the Empire's sinister agents, Princess Leia races home aboard her starship, custodian of the stolen plans that can save her people and restore freedom to the galaxy...\n" >> "$ARQUIVO_REFERENCIA"
printf "\n" >> "$ARQUIVO_REFERENCIA"

# ==============================================================================
# BLOCO 4: VALIDAÇÃO LÓGICA (DIFF ANALYZER) [v2]
# O QUE FAZ: Executa o diff e captura diferenças em modo texto (-a).
# OBJETIVO FUNCIONAL: Identificar discrepâncias entre o arquivo do aluno e o original.
# ==============================================================================
DIFERENCAS=$(diff -a "$ARQUIVO_REFERENCIA" "$ARQUIVO_ESTUDANTE" 2>/dev/null)

if [ -n "$DIFERENCAS" ]; then
    echo "[ex07] FAIL: O arquivo 'b' não é idêntico ao arquivo 'a'[cite: 210]."
    echo "--- Detalhes das Diferenças (diff a b) ---"
    echo "$DIFERENCAS"
    rm -rf "$DIRETORIO_TEMPORARIO"
    exit $FALHA
fi

# ==============================================================================
# BLOCO 5: SIMULAÇÃO DO COMANDO DO SUBJECT [v1]
# O QUE FAZ: Simula o comando 'diff a b > sw.diff' e valida o tamanho do output.
# OBJETIVO FUNCIONAL: Garantir que o comando pedido gera um arquivo de 0 bytes.
# ==============================================================================
diff "$ARQUIVO_REFERENCIA" "$ARQUIVO_ESTUDANTE" > "$DIRETORIO_TEMPORARIO/sw.diff" 2>/dev/null
TAMANHO_SW_DIFF=$(wc -c < "$DIRETORIO_TEMPORARIO/sw.diff" | tr -d ' ')

if [ "$TAMANHO_SW_DIFF" -ne 0 ]; then
    echo "[ex07] FAIL: sw.diff deveria ter 0 bytes, mas tem $TAMANHO_SW_DIFF."
    rm -rf "$DIRETORIO_TEMPORARIO"
    exit $FALHA
fi

# ==============================================================================
# BLOCO 6: LIMPEZA E ENCERRAMENTO [v1]
# O QUE FAZ: Remove arquivos temporários e retorna o status de sucesso.
# OBJETIVO FUNCIONAL: Manter a sandbox limpa após o teste.
# ==============================================================================
rm -rf "$DIRETORIO_TEMPORARIO"
echo "[ex07] PASS"
exit $SUCESSO