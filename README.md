# Análisis de Variantes Genómicas en enhacers y Selección Natural en el Gen ATP2B4

## 📝 Descripción
Este repositorio contiene el pipeline bioinformático desarrollado para el **Trabajo Fin de Máster (TFM)** titulado *"Detección de variantes adaptativas en enhancers eritroides que modulan la expresión de la Basigina, 
ATP2B4 y PIEZO1 en poblaciones expuestas a la malaria."*. 

El objetivo principal de este proyecto es identificar variantes genómicas en las regiones *enhancers* de los genes **Basigina**,**ATP2B4**, **PIEZO1**, analizar el impacto biológico de las variantes identificadas, y 
evaluar las señales de selección natural entre varias poblaciones con mayor y menor exposición a la malaria.
En este repositorio se propone un ejemplo para la identificación de variantes en el gen **ATP2B4** en dos poblaciones específicas: **Sierra Leona (MSL)** y **Estados Unidos (USA)**, utilizando datos de alta cobertura 
del *1000 Genomes Project*.

---

## 🛠️ Requisitos del Sistema y Dependencias

Para poder ejecutar los scripts de este repositorio de manera local, es necesario contar con las siguientes herramientas instaladas:

### Herramientas de Consola (Bash/Linux)
* **bcftools** (v1.15 o superior) -> Para la manipulación y filtrado de archivos VCF.
* **vcftools** (v0.1.16 o superior) -> Para el control de calidad de variantes.
* **Beagle** (v5.4) -> Para el faseo de genotipos.
* **selscan** (v2.0) y **norm** -> Para el cálculo y normalización de puntuaciones iHS.

### Entorno de R
* **R** (v4.0 o superior)
* Librerías requeridas: `pcadapt`, `BiocManager`.

---

## 📂 Estructura del Repositorio

El proyecto está organizado de la siguiente manera:
* `pipeline/`: Carpeta destinada a almacenar los diferentes scripts para el procesamiento de los datos.
  * `filtrado_variantes_enhancers_ATP2B4.sh`: Descarga de datos, control de calidad con `vcftools` y separación por poblaciones.
  * `analisis_iHS_sierra_leona.sh`: Faseo con Beagle y análisis de selección con `selscan` y `norm` de la población de Sierra Leona.
  * `pcadapt_variantes_enhancers.R`: Análisis de componentes principales (PCA) y outliers.
* `archivos/`: Carpeta destinada a almacenar los datos de entrada locales (ej. archivos `.bed`, `.samples`).
* `resultados/`: Carpeta autogenerada donde se guardarán los reportes, tablas de *outliers* y gráficos resultantes.

---

## 🚀 Guía de Uso (Instrucciones de Ejecución)

Sigue estos pasos en tu terminal para replicar el análisis completo del TFM:

### 1. Clonar el repositorio y preparar el entorno
```bash
git clone [https://github.com/Pedro-MRS/TFM---ATP2B4-Enhancers](https://github.com/Pedro-MRS/TFM---ATP2B4-Enhancers)
cd TFM-ATP2B4-Enhancers
mkdir -p archivos resultados
git clone [https://github.com/tu_usuario/TFM-ATP2B4-Genomics.git](https://github.com/tu_usuario/TFM-ATP2B4-Genomics.git)


cd TFM-ATP2B4-Genomics
mkdir -p archivos resultados
