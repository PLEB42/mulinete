#!/bin/sh

# ==============================================================================
# BLOCO 1: AMBIENTE E RESOLUÇÃO DE CAMINHOS [v2]
# O QUE FAZ: Define constantes e localiza o script do aluno de forma absoluta.
# OBJETIVO FUNCIONAL: Garantir resiliência independente do diretório de execução.
# ==============================================================================
PASS=0
FAIL=1
ARQUIVO_ALUNO="../ex02/find_sh.sh"

# Resolução de path absoluto para execução segura dentro da sandbox
if [ ! -f "$ARQUIVO_ALUNO" ]; then
    echo "[ex02] FAIL: Arquivo 'find_sh.sh' não encontrado em ex02/."
    exit $FAIL
fi
SCRIPT_ABS=$(cd "$(dirname "$ARQUIVO_ALUNO")" && pwd)/$(basename "$ARQUIVO_ALUNO")

# ==============================================================================
# BLOCO 2: CRIAÇÃO DA SANDBOX HOSTIL [v2]
# O QUE FAZ: Cria uma estrutura de arquivos complexa para testar o 'find' recursivo.
# OBJETIVO FUNCIONAL: Validar se o aluno encontra arquivos em qualquer profundidade
# e se ignora arquivos que não terminam estritamente em '.sh'.
# ==============================================================================
TMPDIR=$(mktemp -d)
mkdir -p "$TMPDIR/a/b/c"
mkdir -p "$TMPDIR/.hidden_dir"

# Arquivos que DEVEM ser encontrados
touch "$TMPDIR/root_script.sh"
touch "$TMPDIR/a/deep_script.sh"
touch "$TMPDIR/a/b/c/very_deep.sh"
touch "$TMPDIR/.hidden_dir/hidden_script.sh"

# Arquivos que NÃO DEVEM ser encontrados (Edge Cases)
touch "$TMPDIR/not_sh.txt"           # Extensão errada
touch "$TMPDIR/wrong_ext.sh.txt"     # .sh no meio do nome
touch "$TMPDIR/.sh"                  # Apenas a extensão
touch "$TMPDIR/sh"                   # Sem ponto

# ==============================================================================
# BLOCO 3: EXECUÇÃO E CAPTURA [v1]
# O QUE FAZ: Entra na sandbox e executa o script do aluno.
# OBJETIVO FUNCIONAL: Isolar o ambiente de execução para evitar falsos positivos
# do próprio sistema operacional.
# ==============================================================================
OUTPUT=$(cd "$TMPDIR" && sh "$SCRIPT_ABS" 2>/dev/null | sort)
ERRORS=0

# ==============================================================================
# BLOCO 4: VALIDAÇÃO OSTENSIVA DE REQUISITOS [v1]
# O QUE FAZ: Aplica 4 testes rigorosos sobre a saída gerada.
# OBJETIVO FUNCIONAL: Garantir conformidade com o Subject (sem .sh, sem paths).
# ==============================================================================

# Teste A: Presença de nomes esperados (sem extensão)
for name in root_script deep_script very_deep hidden_script; do
    if ! echo "$OUTPUT" | grep -q "^$name$"; then
        echo "[ex02] FAIL: '$name' deveria estar na saída, mas não foi encontrado."
        ERRORS=$((ERRORS + 1))
    fi
done

# Teste B: Proibição de extensão '.sh' na saída 
if echo "$OUTPUT" | grep -q '\.sh'; then
    echo "[ex02] FAIL: A extensão '.sh' foi detectada na saída. Deve exibir apenas o nome."
    ERRORS=$((ERRORS + 1))
fi

# Teste C: Proibição de caminhos (paths) [cite: 329, 331]
if echo "$OUTPUT" | grep -q '/'; then
    echo "[ex02] FAIL: Caminhos de diretório detectados. Exiba apenas o nome do arquivo."
    ERRORS=$((ERRORS + 1))
fi

# Teste D: Filtragem de arquivos intrusos
for intruder in not_sh wrong_ext .sh sh; do
    if echo "$OUTPUT" | grep -q "^$intruder$"; then
        echo "[ex02] FAIL: O arquivo '$intruder' foi listado incorretamente."
        ERRORS=$((ERRORS + 1))
    fi
done

# ==============================================================================
# BLOCO 5: LIMPEZA E VEREDITO [v1]
# O QUE FAZ: Remove a sandbox e retorna o status final.
# ==============================================================================
rm -rf "$TMPDIR"

if [ $ERRORS -gt 0 ]; then
    exit $FAIL
fi

echo "[ex02] PASS"
exit $PASS