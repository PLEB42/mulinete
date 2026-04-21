#!/bin/sh

# ==============================================================================
# BLOCK: TRADUÇÃO PARA DÍGITOS NUMÉRICOS [v2]
# WHAT IT DOES: Converte os caracteres das bases customizadas em algarismos de 0 a 4.
# FUNCTIONAL GOAL: Preparar a string aritmética para processamento no 'bc'.
# ALTERAÇÃO: Removidos comentários de fim de line que causavam o travamento.
# ==============================================================================
# FT_NBR1 base: ' \ " ? !  ->  0 1 2 3 4
# FT_NBR2 base: m r d o c  ->  0 1 2 3 4
VALOR_PROCESSADO=$(echo "$FT_NBR1 + $FT_NBR2" | \
    sed "s/'/0/g" | \
    tr '\\"?!' 1234 | \
    tr 'mrdoc' 01234)

# ==============================================================================
# BLOCK: CÁLCULO ARITMÉTICO E CONVERSÃO [v2]
# WHAT IT DOES: Define as bases de entrada (5) e saída (13) e executa a soma.
# FUNCTIONAL GOAL: Utilizar a precisão do 'bc' para lidar com números grandes.
# ==============================================================================
# Nota: 'ibase' deve ser a última definição para não afetar o valor de 'obase'.
SOMA_BASE_13=$(echo "obase=13; ibase=5; $VALOR_PROCESSADO" | bc)

# ==============================================================================
# BLOCK: MAPEAMENTO DE SAÍDA CUSTOMIZADA [v2]
# WHAT IT DOES: Converte os dígitos hexadecimais da base 13 para o dicionário final.
# FUNCTIONAL GOAL: Entregar o resultado no formato "gtaio luSnemf".
# ==============================================================================
echo "$SOMA_BASE_13" | \
    tr '0123456789ABC' 'gtaio luSnemf' | \
    tr -d '\n'