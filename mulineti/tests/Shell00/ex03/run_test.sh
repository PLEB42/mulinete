#!/bin/sh
# ex03: Validar se id_rsa_pub existe e possui o formato correto de chave pública.
# Objetivo: Garantir a integridade do arquivo antes da submissão.

PASS=0
FAIL=1

ARQUIVO_PUBLICO="../ex03/id_rsa_pub"

# ==============================================================================
# BLOCO 1: VALIDAÇÃO DE EXISTÊNCIA
# O que faz: Verifica se o arquivo solicitado pelo subject está presente.
# Objetivo funcional: Evitar erros de execução por arquivo ausente.
# ==============================================================================
if [ ! -f "$ARQUIVO_PUBLICO" ]; then
    echo "[ex03] FAIL: Arquivo 'id_rsa_pub' não encontrado em ex03/" 
    exit $FAIL
fi

# ==============================================================================
# BLOCO 2: VALIDAÇÃO DE INTEGRIDADE (FORMATO SSH)
# O que faz: Utiliza o ssh-keygen com a flag -l (fingerprint) para validar o arquivo.
# Objetivo funcional: Confirmar se o conteúdo é uma chave SSH válida, não apenas texto.
# ==============================================================================
# O comando ssh-keygen -l -f retorna erro (exit code != 0) se o arquivo for inválido.
if ! ssh-keygen -l -f "$ARQUIVO_PUBLICO" > /dev/null 2>&1; then
    echo "[ex03] FAIL: O conteúdo de 'id_rsa_pub' não é uma chave pública SSH válida."
    exit $FAIL
fi

# ==============================================================================
# BLOCO 3: CHECK DE SEGURANÇA (IDENTIFICAÇÃO)
# O que faz: Extrai o tipo da chave para log de debug.
# Objetivo funcional: Informativo para o aluno.
# ==============================================================================
TIPO_CHAVE=$(awk '{print $1}' "$ARQUIVO_PUBLICO")
echo "[ex03] INFO: Chave do tipo '$TIPO_CHAVE' detectada e validada." 

echo "[ex03] PASS"
exit $PASS