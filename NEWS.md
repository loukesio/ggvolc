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
