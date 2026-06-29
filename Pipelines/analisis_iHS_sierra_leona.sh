#!/bin/bash

# ==============================================================================
# TFM: Cálculo y Normalización de iHS en Sierra Leona (MSL)
# ==============================================================================

# Detener el script si ocurre algún error intermedio
set -e

# 1. CONFIGURACIÓN DE VARIABLES Y RUTAS
# ------------------------------------------------------------------------------
# Mantenemos las rutas relativas dentro del proyecto
WORKDIR="archivos"
VCF_IN="${WORKDIR}/ATP2B4_enhancers_MSL.vcf"
VCF_GZ="${VCF_IN}.gz"
VCF_PHASED="${WORKDIR}/ATP2B4_enhancers_MSL_phased"
MAP_FILE="${WORKDIR}/ATP2B4_enhancers.map"
IHS_OUT="${WORKDIR}/ATP2B4_enhancers_MSL_iHS"

echo "=== Iniciando pipeline de análisis iHS ==="

# 2. COMPRESIÓN E INDEXADO DEL VCF ORIGINAL
# ------------------------------------------------------------------------------
echo "[1/6] Comprimiendo e indexando archivo VCF..."
bgzip -c "$VCF_IN" > "$VCF_GZ"
tabix -p vcf "$VCF_GZ"

# 3. DESCARGA DE BEAGLE Y FASEADO DE DATOS
# ------------------------------------------------------------------------------
echo "[2/6] Descargando y configurando Beagle 5.4..."
# Descarga silenciosa (-q) guardando en una carpeta temporal para no ensuciar la raíz
wget -q https://faculty.washington.edu/browning/beagle/beagle.5.4_18Mar22.zip
unzip -q -o beagle.5.4_18Mar22.zip -d bin/
rm -f beagle.5.4_18Mar22.zip

echo "[3/6] Faseando genotipos con Beagle..."
# Nota: Beagle requiere el archivo .jar ejecutable (asumimos la estructura del zip)
java -jar bin/beagle.22Mar22.401.jar \
    gt="$VCF_GZ" \
    out="$VCF_PHASED"

# Asegurar que el VCF faseado esté indexado para los siguientes pasos
tabix -p vcf "${VCF_PHASED}.vcf.gz"

# 4. GENERACIÓN DEL ARCHIVO DE MAPA GENÉTICO (.map)
# ------------------------------------------------------------------------------
echo "[4/6] Generando archivo de mapa genético aproximado..."
bcftools query -f '%CHROM\t%POS\n' "${VCF_PHASED}.vcf.gz" | \
awk 'BEGIN{OFS="\t"}{print $1, $1":"$2, $2/1000000, $2}' > "$MAP_FILE"

# 5. CÁLCULO DE iHS (SELSCAN)
# ------------------------------------------------------------------------------
echo "[5/6] Ejecutando selscan (--ihs)..."
# Nota: Se asume que selscan ya está instalado mediante conda/mamba
selscan \
    --ihs \
    --vcf "${VCF_PHASED}.vcf.gz" \
    --map "$MAP_FILE" \
    --out "$IHS_OUT"

# 6. NORMALIZACIÓN DE RESULTADOS
# ------------------------------------------------------------------------------
echo "[6/6] Normalizando puntuaciones iHS..."
norm \
    --ihs \
    --files "${IHS_OUT}.ihs.out"

# ==============================================================================
# REPORTE DE RESULTADOS EN CONSOLA
# ==============================================================================
echo -e "\n=== TOP 10 SNPs CON MAYOR MAGNITUD DE iHS ==="
awk 'NR>1 {x=$NF; if(x<0)x=-x; print x, $0}' "${IHS_OUT}.ihs.out.norm" | \
    sort -g -k1,1 | \
    tail -n 10 | \
    awk '{print $2, $3, $4, $5, $6}'

echo -e "\n=== VARIANTES CON SEÑALES FUERTES DE SELECCIÓN (|iHS| >= 2) ==="
echo "Chrom Position iHS unnorm_iHS"
awk 'NR>1 && ($(NF-1)>=2 || $(NF-1)<=-2) {print $1, $2, $(NF-1), $NF}' "${IHS_OUT}.ihs.out.norm"

echo -e "\n=== Análisis finalizado con éxito ==="
