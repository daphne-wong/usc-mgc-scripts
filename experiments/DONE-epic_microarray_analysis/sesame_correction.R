# Install sesame

#if (!require("BiocManager", quietly = TRUE))
#  install.packages("BiocManager", lib = "/project2/tp_612_1653/resources/microarray/EPIC_R_Library")
#BiocManager::install("sesame", lib = "/project2/tp_612_1653/resources/microarray/EPIC_R_Library")

# Specify libpaths
.libPaths("/project2/tp_612_1653/resources/microarray/EPIC_R_Library")

BiocManager::install("BiocParallel", lib = "/project2/tp_612_1653/resources/microarray/EPIC_R_Library")
BiocManager::install("preprocessCore", lib = "/project2/tp_612_1653/resources/microarray/EPIC_R_Library")


library(sesame)
library(sesameData)
library(BiocParallel)
library(preprocessCore)
options(preprocessCore.use.cores = 1)

# Set working directory project folder (SLURM script is in ./scripts, data in ./IDATS)
#getwd()
setwd("../")

# Point to your IDAT directory and samplesheet
path <- file.path(getwd())

#path <- file.path("/project2/tp_612_1653/Paulson_Thomas/Paulson_EPICv2_01262026/run1/")
idat_dir <- file.path(path, "IDATS/")

args <- commandArgs(trailingOnly=TRUE)
if (length(args) < 3) stop("Must provide samplesheet, array and annotation as arguments")
samplesheet <- args[3]


# Option 2: Step-by-step with FFPE-relevant additions
betas.sesame2 <- do.call(cbind, lapply(
  searchIDATprefixes(idat_dir), function(pfx) {
    pfx %>%
      readIDATpair() %>%
      qualityMask() %>%           # 1. mask multi/unknown probes first
      #inferSpecies() %>%          # 2. species inference before background
      inferInfiniumIChannel() %>%     # 3. channel inference before dye bias
      dyeBiasCorr() %>%           # 4. linear dye bias correction early
      pOOBAH() %>%                # 5. detection calling before noob
      noob() %>%                  # 6. noob last (modifies oob)
      getBetas()
  }))


# COMPARE sesame to minfi


# Find common probes
common_probes2 <- intersect(rownames(betas.sesame2), rownames(noob_correct))

# Correlation per sample
cor_per_sample <- sapply(colnames(betas.sesame), function(s) {
  cor(betas.sesame[common_probes, s], 
      noob_correct[common_probes, s], 
      use = "complete.obs")
})
summary(cor_per_sample)

# Plot beta distributions side by side
par(mfrow = c(1,2))
plot(density(betas.sesame2[,1], na.rm=TRUE), main="SeSAMe")
plot(density(noob_correct[,1], na.rm=TRUE), main="minfi noob")

