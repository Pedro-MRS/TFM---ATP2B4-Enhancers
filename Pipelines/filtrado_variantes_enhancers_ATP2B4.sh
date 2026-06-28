#!/bin/bash

# ===========================================================================================
# PIPELINE DE BIOINFORMÁTICA: Análisis de variantes de enhancers del Gen ATP2B4 (Cromosoma 1)
# Poblaciones objeto de estudio: Sierra Leona (MSL) y USA
# TFM - Universidad Internacional de La Rioja (UNIR)
# ===========================================================================================

# Detener el script si ocurre algún error
set -e

# --- 1. DEFINICION DE VARIABLES Y URL ---
# --------------------------------------------------------------
URL_VCF="https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/20201028_3202_raw_GT_with_annot/20201028_CCDG_14151_B01_GRM_WGS_2020-08-05_chr1.recalibrated_variants.vcf.gz"
REGIONES="chr1:203674063-203674413,chr1:203682652-203683001,chr1:203650434-203650784,chr1:203682483-203682652,chr1:203628800-203629147,chr1:203629509-203629793,chr1:203626961-203627130,chr1:203673776-203673947,chr1:203650110-203650300,chr1:203655610-203675957,chr1:203653169-203653514,chr1:203629172-203629428"

echo "=== [1/6] Extrayendo regiones de enhancers de ATP2B4 vía bcftools ==="
bcftools view -r "$REGIONES" "$URL_VCF" -Ov -o ATP2B4_enhancers.vcf 

echo "=== [2/6] Control de Calidad y Filtrado con vcftools ==="
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

echo "=== [3/6] Filtrado por Población: Sierra Leona (MSL) ==="
# Extracción de IDs de muestra desde el metadato geográfico obtenidos de 1000 Genomes Project mediante la descarga de los archivos igsr_mls.tsv y igsr_usa.tsv con los identificadores de las muestras para cada 
población
tail -n +2 igsr_msl.tsv.tsv | cut -f1 > MSL.samples
bcftools query -l ATP2B4_enhancers_filtrado.recode.vcf > vcf_samples_ATP2B4.txt
grep -Fwf vcf_samples_ATP2B4.txt MSL.samples > MSL_present_ATP2B4.samples

# Generación del VCF exclusivo para la población MSL
bcftools view \
  -S MSL_present_ATP2B4.samples \
  -Ov \
  -o ATP2B4_enhancers_MSL.vcf \
  ATP2B4_enhancers_filtrado.recode.vcf

echo "=== [4/6] Filtrado por Población: USA ==="
tail -n +2 igsr_usa.tsv.tsv | cut -f1 > MSL.samples
bcftools query -l ATP2B4_enhancers_filtrado.recode.vcf > vcf_samples_ATP2B4.txt
grep -Fwf vcf_samples_ATP2B4.txt USA.samples > USA_present_ATP2B4.samples

# Generación del VCF exclusivo para la población USA
bcftools view \
  -S USA_present_ATP2B4.samples \
  -Ov \
  -o ATP2B4_enhancers_USA.vcf \
  ATP2B4_enhancers_filtrado.recode.vcf


# 2. PROCESAMIENTO Y COMBINACION DE VCFS (MSL & USA) PARA UTILIZARLO EN PCADAPT
# -------------------------------------------------------------------------------
echo "Comprimiendo archivos VCF..."
bgzip -c ATP2B4_enhancers_MSL.vcf > ATP2B4_enhancers_MSL.vcf.gz
bgzip -c ATP2B4_enhancers_USA.vcf > ATP2B4_enhancers_USA.vcf.gz

# 2. INDEXAR LOS ARCHIVOS COMPRIMIDOS
# -------------------------------------------------------------------------------
echo "Indexando archivos VCF comprimidos..."
bcftools index ATP2B4_enhancers_MSL.vcf.gz
bcftools index ATP2B4_enhancers_USA.vcf.gz

# 3. FUSIONAR AMBOS ARCHIVOS EN UN SOLO VCF CONJUNTO
# -------------------------------------------------------------------------------
echo "Fusionando poblaciones (Sierra Leona + USA)..."
bcftools merge \
  -Ov \
  -o ATP2B4_enhancers_USA_MSL.vcf \
  ATP2B4_enhancers_USA.vcf.gz \
  ATP2B4_enhancers_MSL.vcf.gz

# 4. CONVERTIR EL ARCHIVO CONJUNTO A FORMATO PLINK (.bed/.bim/.fam)
# -------------------------------------------------------------------------------
echo "Convirtiendo VCF final a formato binario de PLINK..."
plink --vcf ATP2B4_enhancers_USA_MSL.vcf \
      --keep-allele-order \
      --make-bed \
      --out F:/UNIVERSIDAD/UNIR/TFM/ARCHIVOS/ATP2B4_USA_MSL

echo "¡Proceso completado con éxito!"
