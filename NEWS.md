# ggvolc 0.2.0

## Multi-pipeline support & gt tables

* **DESeq2, edgeR, and limma auto-detection**: `ggvolc()` and `genes_table()`
  now accept output from all three major DE pipelines. Column names are
  automatically mapped internally — no manual renaming needed.
  - DESeq2: `log2FoldChange`, `pvalue`, `padj`, `baseMean`
  - edgeR: `logFC`, `PValue`, `FDR`, `logCPM`
  - limma: `logFC`, `P.Value`, `adj.P.Val`, `AveExpr`
* Gene identifiers stored as row names (common in edgeR/limma) are
  automatically promoted to a `genes` column.
* **`genes_table()` rewritten** with `gt` + `patchwork`:
  - Replaces `gridExtra::grid.arrange` with `patchwork::wrap_table()`
  - Gene table rendered as a `gt` table with formatted numerics,
    color-coded p-values, and directional log2FC coloring
  - Returns a proper `patchwork` object (composable, `ggsave()`-able)
* New internal helpers: `standardize_de_columns()`, `detect_de_source()`
* Added `testthat` test suite covering all three DE formats, column
  detection, attention genes, plot options, and the new gene table.
* Dependencies: replaced `gridExtra` with `gt` and `patchwork`.
* Version bump to 0.2.0.

# ggvolc 0.1.0

## Initial CRAN Release

* Initial release of ggvolc package
* Create customizable volcano plots for differential gene expression analysis
* Functions included:
  - `ggvolc()`: Main function to create volcano plots
  - `genes_table()`: Combine volcano plots with gene tables
* Features:
  - Highlight genes of interest
  - Adjustable significance thresholds (p-value and fold change)
  - Customizable colors for up/down regulated genes
  - Optional significance segment lines
  - Size scaling by log2FoldChange or p-value
  - Integration with ggplot2 for additional customization
* Example datasets included:
  - `all_genes`: Complete differential expression results
  - `attention_genes`: Subset of genes to highlight
