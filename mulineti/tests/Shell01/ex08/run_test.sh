#!/bin/sh

# ==============================================================================
# BLOCO 1: TRADUÇÃO PARA DÍGITOS NUMÉRICOS [v2]
# O QUE FAZ: Converte os caracteres das bases customizadas em algarismos de 0 a 4.
# OBJETIVO FUNCIONAL: Preparar a string aritmética para processamento no 'bc'.
# ALTERAÇÃO: Removidos comentários de fim de linha que causavam o travamento.
# ==============================================================================
# FT_NBR1 base: ' \ " ? !  ->  0 1 2 3 4
# FT_NBR2 base: m r d o c  ->  0 1 2 3 4
VALOR_PROCESSADO=$(echo "$FT_NBR1 + $FT_NBR2" | \
    sed "s/'/0/g" | \
    tr '\\"?!' 1234 | \
    tr 'mrdoc' 01234)

# ==============================================================================
# BLOCO 2: CÁLCULO ARITMÉTICO E CONVERSÃO [v2]
# O QUE FAZ: Define as bases de entrada (5) e saída (13) e executa a soma.
# OBJETIVO FUNCIONAL: Utilizar a precisão do 'bc' para lidar com números grandes.
# ==============================================================================
# Nota: 'ibase' deve ser a última definição para não afetar o valor de 'obase'.
SOMA_BASE_13=$(echo "obase=13; ibase=5; $VALOR_PROCESSADO" | bc)

# ==============================================================================
# BLOCO 3: MAPEAMENTO DE SAÍDA CUSTOMIZADA [v2]
# O QUE FAZ: Converte os dígitos hexadecimais da base 13 para o dicionário final.
# OBJETIVO FUNCIONAL: Entregar o resultado no formato "gtaio luSnemf".
# ==============================================================================
echo "$SOMA_BASE_13" | \
    tr '0123456789ABC' 'gtaio luSnemf' | \
    tr -d '\n'