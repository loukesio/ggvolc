## Build `edger_genes`: an edgeR topTags()-style example table.
##
## Derived from the DESeq2-style `all_genes` so it reflects the same experiment,
## re-expressed with edgeR's column conventions (logFC / logCPM / PValue / FDR)
## and with the gene identifiers stored in the row names, exactly as
## edgeR::topTags() returns them. This lets the examples show that ggvolc reads
## edgeR output directly and promotes rowname gene IDs automatically.

load("data/all_genes.RData")

edger_genes <- data.frame(
  logFC     = all_genes$log2FoldChange,
  logCPM    = round(log2(all_genes$baseMean + 1), 4),
  PValue    = all_genes$pvalue,
  FDR       = all_genes$padj,
  row.names = all_genes$genes,
  stringsAsFactors = FALSE
)

# match the package's existing .RData datasets (all_genes.RData, ...)
save(edger_genes, file = "data/edger_genes.RData", compress = "xz")
