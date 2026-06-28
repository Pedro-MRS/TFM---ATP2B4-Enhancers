#!/bin/bash

# ==============================================================================
# PIPELINE DE BIOINFORMÁTICA: Análisis de variantes del Gen ATP2B4 (Cromosoma 1)
# Filtrado de regiones de enhancers obtenidas en ENCODE/SCREEN
# TFM - Universidad Internacional de La Rioja (UNIR)
# ==============================================================================

# Detener el script si ocurre algún error
set -e

# --- 1. Definición de Variables y URL ---
URL_VCF="https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/20201028_3202_raw_GT_with_annot/20201028_CCDG_14151_B01_GRM_WGS_2020-08-05_chr1.recalibrated_variants.vcf.gz"
REGIONES="chr1:203674063-203674413,chr1:203682652-203683001,chr1:203650434-203650784,chr1:203682483-203682652,chr1:203628800-203629147,chr1:203629509-203629793,chr1:203626961-203627130,chr1:203673776-203673947,chr1:203650110-203650300,chr1:203655610-203675957,chr1:203653169-203653514,chr1:203629172-203629428"

echo "=== [1/2] Extrayendo regiones de enhancers de ATP2B4 vía bcftools ==="
bcftools view -r "$REGIONES" "$URL_VCF" -Ov -o ATP2B4_enhancers.vcf 

echo "=== [2/2] Control de Calidad y Filtrado con vcftools ==="
vcftools \
  --vcf ATP2B4_enhancers.vcf \
  --max-alleles 2 \
  --remove-indels \
  --min-meanDP 10 \
  --max-meanDP 50 \
  --minQ 30 \
  --maf 0.01 \
  --max-missing 0.90 \
  --recode \
  --recode-INFO-all \
  --out ATP2B4_enhancers_filtrado
