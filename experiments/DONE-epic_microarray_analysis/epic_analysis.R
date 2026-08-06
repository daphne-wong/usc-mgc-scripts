# Install required packages
# FROM CRAN
# install.packages("tidyverse)

# BIOCMANAGER
#if (!require("BiocManager", quietly = TRUE))
#install.packages("BiocManager")
#BiocManager::install("minfi")
#BiocManager::install("IlluminaHumanMethylationEPICmanifest")
#BiocManager::install("IlluminaHumanMethylationEPICv2manifest")
#BiocManager::install("jokergoo/IlluminaHumanMethylationEPICv2anno.20a1.hg38")


# DEVTOOLS
# May have to remove lock for devtools: rm -rf /home1/daphnew/R/x86_64-pc-linux-gnu-library/4.4/00LOCK-sourcetools
#if(!require(devtools)) install.packages("devtools")
#devtools::install_github("achilleasNP/IlluminaHumanMethylationEPICanno.ilm10b5.hg38")
#devtools::install_github("chiaraherzog/IlluminaMouseMethylationmanifest")
#devtools::install_github("chiaraherzog/IlluminaMouseMethylationanno.12.v1.mm10")


# Specify lib paths -- project2 directory
.libPaths("/project2/weisenbe_1344/MGC/resources/microarray/EPIC_R_Library")


# Call libraries
library(minfi)
library(IlluminaHumanMethylationEPICmanifest)
library(IlluminaHumanMethylationEPICv2manifest)
library(IlluminaHumanMethylationEPICv2anno.20a1.hg38)
library(IlluminaMouseMethylationmanifest)
library(IlluminaMouseMethylationanno.12.v1.mm10)


# Set args from slurm script
args <- commandArgs(trailingOnly=TRUE)
if (length(args) < 2) stop("Must provide array and annotation as arguments")

# Set working directory project folder (scripts are in ./scripts, data in ./IDATS)
#getwd()
setwd("../")
run_dir <- getwd()
dir.create("./Processed_Data_Files/csv_with_SampleID")
dir.create("./Processed_Data_Files/csv_with_BarcodeID")

# Create targets csv for sample files
#targets <- unique(sub("(_Red\\.idat|_Grn\\.idat)$", "", list.files(path = "./IDATS", pattern = ".idat$")))
#targets <- paste0("./IDATS/", targets)
#write.csv(data.frame(Basename = targets), file = "./targets.csv", row.names = FALSE, quote = FALSE)


# The read.metharray.sheet function does not recognize "SentrixPosition_A" and "SentrixID_A", so we need to replace those colnames
# Read data and extract colnames
samplesheet <- read.metharray.sheet(base=".",pattern=".csv$", verbose=TRUE)
samplesheet_colnames <- colnames(samplesheet)

# Replace colnames 
samplesheet_colnames <- gsub("SentrixPosition.*", "Sentrix_Position", samplesheet_colnames)
samplesheet_colnames <- gsub("SentrixBarcode.*", "Sentrix_ID", samplesheet_colnames)

# Rename samplesheet colnames
colnames(samplesheet) <- samplesheet_colnames

# Create Basename for read.metharray.exp
samplesheet$Filename <- paste(samplesheet$Sentrix_ID, samplesheet$Sentrix_Position, sep="_")
samplesheet$Basename <- paste(run_dir, "/IDATS/", samplesheet$Filename, sep="")

# Read sample files into RGset object
RGset <- read.metharray.exp(targets = samplesheet, verbose = TRUE, force = TRUE)
RGset@annotation = c(array = args[1], annotation = args[2]) # Illumina Human Methylation 450k (20a1) array with the hg38 reference genome
#annotation(RGset) 


# Write raw files
MSet.raw <-preprocessRaw(RGset) # convert R/G channels to M signal (no normalization)
Meth.raw <- getMeth(MSet.raw) # stores Methylated data
write.table(Meth.raw,"./Processed_Data_Files/csv_with_BarcodeID/Methylated_intensities-raw.csv", row.names=T, sep=",")
Unmeth.raw <- getUnmeth(MSet.raw) # stores Unmethylated data
write.table(Unmeth.raw,"./Processed_Data_Files/csv_with_BarcodeID/Unmethylated_intensities-raw.csv", row.names=T, sep=",")
ratioSet <- ratioConvert(MSet.raw, what = "both", keepCN = TRUE) # what = which ratios to compute, keepCN = include copy number values
beta <- getBeta(ratioSet) # get beta values
write.table(beta,"./Processed_Data_Files/csv_with_BarcodeID/beta_values-raw.csv", row.names=T, sep=",")

## qcReport
if (length(unique(pData(RGset)$Sample_Group)) >= 2) {
  qcReport(RGset, sampNames=pData(RGset)$Sample_Name, sampGroups = pData(RGset)$Sample_Group, pdf= "./QC_Reports/qcReport.pdf")
  
} else {
  qcReport(RGset, sampNames=pData(RGset)$Sample_Name, sampGroups = NULL, pdf= "./QC_Reports/qcReport.pdf")
}



## Individual raw density plot (also found in qcReport)
if (length(unique(pData(RGset)$Sample_Group)) >= 2) {
  png(filename="./QC_Reports/density_plot_raw.png",
      width = 1200, height = 1200, res = 150)
  densityPlot(RGset, sampGroups = pData(RGset)$Sample_Group, main = "", xlab = "Beta")
  dev.off()
} else {
  png(filename="./QC_Reports/density_plot_raw.png",
      width = 1200, height = 1200, res = 150)
  densityPlot(RGset, sampGroups = NULL, main = "", xlab = "Beta")
  dev.off()
}

## Individual density bean plot (also found in qcReport)
# shape = density, vertical bar = median
if (length(unique(pData(RGset)$Sample_Group)) >= 2) {
  png(filename="./QC_Reports/density_bean_plot_raw.png",
      width = 1500, height = 2000, res = 150)
  densityBeanPlot(RGset, sampNames=pData(RGset)$Sample_Name, sampGroups = pData(RGset)$Sample_Group)
  dev.off()
} else {
  png(filename="./QC_Reports/density_bean_plot_raw.png",
      width = 1500, height = 2000, res = 150)
  densityBeanPlot(RGset, sampNames=pData(RGset)$Sample_Name, sampGroups = NULL)
  dev.off()
}


## Detect P-values
# remotes::install_version("matrixStats", version="1.1.0")
# rows = probes, columns = samples
# p-values -- probe hybridized well = bound to target = low p-value
pvalue <- detectionP(RGset, type = "m+u")
write.table(pvalue,"./Processed_Data_Files/csv_with_BarcodeID/P_values.csv", row.names=T, sep=",")


## Create pvalue correction matrix
pvalue_mat <- pvalue
pvalue_mat[pvalue_mat >= 0.05] <- NA # mask low quality probes p >= 0.05
pvalue_mat[pvalue_mat < 0.05] <- 0 # mark high quality probes p < 0.05


## Preprocess Noob
MSet.noob <- preprocessNoob(RGset, offset = 15, dyeCorr = TRUE, verbose = TRUE) # dye bias normalization


## Generate beta values from preprocess noob
ratioSet.noob <- ratioConvert(MSet.noob, what =  "both", keepCN = TRUE) # corrected ratios of M+U
beta.noob <- getBeta(ratioSet.noob) # beta values of corrected values
write.table(beta.noob,"./Processed_Data_Files/csv_with_BarcodeID/beta_values-noob_no_p_value_masking.csv", row.names=T, sep=",")


## Write methylation and unmethylation values after preprocess noob
Meth.noob <- getMeth(MSet.noob)
Unmeth.noob <- getUnmeth(MSet.noob)
write.table(Meth.noob,"./Processed_Data_Files/csv_with_BarcodeID/Methylated_intensities-noob.csv", row.names=T, sep=",")
write.table(Unmeth.noob,"./Processed_Data_Files/csv_with_BarcodeID/Unmethylated_intensities-noob.csv", row.names=T, sep=",")


## Overlay correction matrix on the beta values derived from noob
noob_correct <- beta.noob
noob_correct[is.na(pvalue_mat)] <- NA
write.table(noob_correct,"./Processed_Data_Files/csv_with_BarcodeID/beta_values-noob.csv", row.names=T, sep=",")

## Calculate per-probe missingness
missingness <- colMeans(is.na(noob_correct)) * 100
missingness <- as.data.frame(missingness)
missingness$filename <- rownames(missingness)
rownames(missingness) <- NULL
missingness
missingness$sample <- samplesheet$Sample_Name[
  match(missingness$filename, samplesheet$Filename)
]
new_order <- c("filename","sample","missingness")
missingness <- missingness[, new_order]
write.table(missingness, 
            "./QC_Reports/per_sample_probe_missingness.csv", 
            row.names = FALSE, sep = ",") 

missingness_sorted <- missingness[order(missingness$missingness), ] # Sort by missingness value for plotting

png("./QC_Reports/per_sample_probe_missingness_barplot.png", width = 1200, height = 600, res = 300)
barplot(missingness_sorted$missingness,
        names.arg = missingness_sorted$sample,
        las = 2, cex.names = 0.75,
        ylab = "% probes failed",
        main = "Per-sample probe missingness",
        col = ifelse(missingness_sorted$missingness > 40, "red",
                     ifelse(missingness_sorted$missingness > 20, "orange", "green")))
abline(h = 40, lty = 2, col = "red") # strict cutoff
abline(h = 20, lty = 2, col = "orange") # lenient cutoff

dev.off()



## Extract SNP-related probes (sample tracking) and write table
rgset_snp <- getSnpBeta(RGset)
write.table(rgset_snp,"./Processed_Data_Files/csv_with_BarcodeID/beta_values-rgset_snp.csv", row.names=T, sep=",")


## Density Plot after correction and normalization
if (length(unique(pData(MSet.noob)$Sample_Group)) >= 2) {
  png(filename="./QC_Reports/density_plot_noob.png",
      width = 1200, height = 1200, res = 150)
  densityPlot(getBeta(MSet.noob), 
              sampGroups = pData(MSet.noob)$Sample_Group, 
              main = "Density plot using Noob", xlab = "Beta", legend = FALSE)
  dev.off()
} else {
  png(filename="./QC_Reports/density_plot_noob.png",
      width = 1200, height = 1200, res = 150)
  densityPlot(getBeta(MSet.noob),
              sampGroups = NULL, 
              main = "Density plot using Noob", xlab = "Beta", legend = FALSE)
  dev.off()
}



## Density Bean Plot after correction and normalization
if (length(unique(pData(MSet.noob)$Sample_Group)) >= 2) {
  png(filename="./QC_Reports/density_bean_plot_noob.png",
      width = 1500, height = 2000, res = 150)
  densityBeanPlot(MSet.noob, 
                  sampGroups = pData(MSet.noob)$Sample_Group, 
                  sampNames=pData(RGset)$Sample_Name) 
  dev.off()
} else {
  png(filename="./QC_Reports/density_bean_plot_noob.png",
      width = 1500, height = 2000, res = 150)
  densityBeanPlot(MSet.noob, 
                  sampGroups = NULL, 
                  sampNames=pData(RGset)$Sample_Name) 
  dev.off()
}





### Convert Filename to Sample ID in the Processed_Data_Files csv
files_to_convert <- list.files("./Processed_Data_Files/csv_with_BarcodeID", full.names = F)
new_name_map <- setNames(samplesheet$Sample_ID, samplesheet$Filename)


for (file_path in files_to_convert) {
  new_file_path <- paste0("./Processed_Data_Files/csv_with_SampleID/",file_path)
  df <- read.csv(paste0("./Processed_Data_Files/csv_with_BarcodeID/",file_path), check.names=F, row.names = 1)
  old_names <- colnames(df)
  colnames(df) <- new_name_map[old_names]
  write.csv(df, file=new_file_path, row.names=T)
}
