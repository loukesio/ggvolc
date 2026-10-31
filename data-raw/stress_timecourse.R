# Build `stress_timecourse`: three DESeq2 contrasts from a real RNA-seq time
# course of the fission yeast (S. pombe) response to osmotic stress
# (1 M sorbitol), from the Bioconductor data package 'fission'.
#
# Source: Leong HS, Dawson K, Wirth C, et al. (2014). A global non-coding RNA
# system modulates fission yeast protein levels in response to stress.
# Nature Communications 5:3947. doi:10.1038/ncomms4947 (GEO: GSE56761).
#
# Only the wild-type strain is used (3 replicates per time point). Each
# contrast compares a time point after stress against time 0.
#
# BiocManager::install(c("fission", "DESeq2"))

library(DESeq2)
library(SummarizedExperiment)

data(fission, package = "fission")
wt <- fission[, fission$strain == "wt"]
wt$minute <- droplevels(wt$minute)

# drop genes with almost no reads
wt <- wt[rowSums(assay(wt)) >= 10, ]

dds <- DESeqDataSetFromMatrix(assay(wt), colData(wt), design = ~ minute)
dds <- DESeq(dds)

# readable gene symbols where available, unique
sym <- rowData(wt)$symbol
sym[is.na(sym) | sym == ""] <- rownames(wt)[is.na(sym) | sym == ""]
sym <- make.unique(sym)

one_contrast <- function(t) {
  res <- results(dds, contrast = c("minute", t, "0"))
  data.frame(
    genes          = sym,
    baseMean       = signif(res$baseMean, 5),
    log2FoldChange = signif(res$log2FoldChange, 5),
    pvalue         = signif(res$pvalue, 5),
    padj           = signif(res$padj, 5),
    stringsAsFactors = FALSE
  )
}

stress_timecourse <- list(
  "30 min"  = one_contrast("30"),
  "60 min"  = one_contrast("60"),
  "180 min" = one_contrast("180")
)

usethis::use_data(stress_timecourse, overwrite = TRUE, compress = "xz")
