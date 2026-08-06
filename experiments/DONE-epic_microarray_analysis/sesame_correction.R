# Install sesame

if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("sesame")


library(sesame)
library(sesameData)
library(BiocParallel)
library(preprocessCore)
options(preprocessCore.use.cores = 1)

# Point to your IDAT directory and samplesheet
path <- file.path("/project2/weisenbe_1344/scripts/experiments/epic_microarray_analysis/sesame_test_dir")
#path <- file.path("/project2/tp_612_1653/Paulson_Thomas/Paulson_EPICv2_01262026/run1/")
idat_dir <- file.path(path, "IDATS/")
samplesheet <- read.csv(file.path("/project2/weisenbe_1344/scripts/experiments/epic_microarray_analysis/sesame_test_dir/Paulson_EPICv2_rerun_02272026_Sample_Sheet.csv"))



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

