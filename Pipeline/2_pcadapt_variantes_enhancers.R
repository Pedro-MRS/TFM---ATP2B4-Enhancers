#!/usr/bin/env Rscript

# ==============================================================================
# Análisis de Selección con PCADAPT (Sierra Leona vs. USA)
# ==============================================================================

# 1. GESTIÓN DE PAQUETES Y DEPENDENCIAS
# ------------------------------------------------------------------------------
required_packages <- c("pcadapt", "BiocManager")
missing_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]

if (length(missing_packages) > 0) {
  install.packages(missing_packages, repos = "https://cloud.r-project.org")
}

library(pcadapt)

# 2. CONFIGURACIÓN DE RUTAS RELATIVAS (Buenas prácticas para GitHub)
# ------------------------------------------------------------------------------
# Usamos rutas relativas basadas en la estructura del repositorio
input_bed  <- "archivos/ATP2B4_USA_MSL.bed"
input_bim  <- "archivos/ATP2B4_USA_MSL.bim"
output_tsv <- "archivos/ATP2B4_pcadapt_outliers_annotated.tsv"

# 3. ANÁLISIS CON PCADAPT
# ------------------------------------------------------------------------------
message("Cargando datos genómicos...")
x <- read.pcadapt(input_bed, type = "bed")

message("Ejecutando pcadapt (K = 2)...")
pc <- pcadapt(x, K = 2)

# Guardar el screeplot automáticamente en lugar de mostrarlo en ventana
pdf("archivos/screeplot_pcadapt.pdf")
plot(pc, option = "screeplot")
dev.off()

# 4. IDENTIFICACIÓN DE OUTLIERS
# ------------------------------------------------------------------------------
# Ajuste de p-valores por Benjamini-Hochberg
qvalues <- p.adjust(pc$pvalues, method = "BH")

results <- data.frame(
  SNP = seq_along(qvalues),
  pvalue = pc$pvalues,
  qvalue = qvalues
)

# Filtrar por FDR < 0.05
outliers <- subset(results, qvalue < 0.05)

message(paste("Número de SNPs outliers detectados:", nrow(outliers)))

# 5. ANOTACIÓN DE VARIANTES (Lectura del archivo .bim)
# ------------------------------------------------------------------------------
if (nrow(outliers) > 0) {
  message("Anotando variantes outliers con el archivo .bim...")
  
  bim <- read.table(
    input_bim,
    header = FALSE,
    stringsAsFactors = FALSE
  )
  
  colnames(bim) <- c("CHR", "SNP_ID", "CM", "POSITION", "ALLELE1", "ALLELE2")
  
  # Extraer la información de las variantes usando el índice del SNP
  outlier_variants <- bim[outliers$SNP, ]
  
  # Combinar los estadísticos con las posiciones genómicas
  outliers_full <- cbind(outliers, outlier_variants)
  
  # Mostrar top 6 en la consola/logs de GitHub si se corre en servidor
  print(head(outliers_full[order(outliers_full$qvalue), ]))
  
  # 6. EXPORTAR RESULTADOS
  # ------------------------------------------------------------------------------
  write.table(
    outliers_full,
    file = output_tsv,
    sep = "\t",
    quote = FALSE,
    row.names = FALSE
  )
  message(paste("Resultados guardados exitosamente en:", output_tsv))
  
} else {
  warning("No se detectaron SNPs bajo selección con el umbral establecido.")
}
