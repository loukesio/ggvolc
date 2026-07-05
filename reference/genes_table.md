# Combine a Volcano Plot with a gt Table of Genes

Takes a ggplot object (typically from
[`ggvolc`](https://loukesio.github.io/ggvolc/reference/ggvolc.md)) and a
data frame of gene details and produces a combined layout using
patchwork. The gene table is rendered as a polished gt table with
color-coded significance and formatted numeric columns.

## Usage

``` r
genes_table(plot_obj, data2, p_value = 0.05, table_height = 1)
```

## Arguments

- plot_obj:

  A ggplot object, typically the output of
  [`ggvolc`](https://loukesio.github.io/ggvolc/reference/ggvolc.md).

- data2:

  A data frame containing gene details. Columns are auto-detected in the
  same way as
  [`ggvolc`](https://loukesio.github.io/ggvolc/reference/ggvolc.md)
  (DESeq2, edgeR, or limma conventions). Required columns after mapping:
  `genes`, `log2FoldChange`, `pvalue`. Optional: `baseMean`, `padj`.

- p_value:

  Significance threshold used for color-coding the p-value column.
  Default is 0.05.

- table_height:

  Relative height of the table panel (plot panel is always 3). Default
  is 1.

## Value

A `patchwork` object that can be further composed or saved with
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html).

## Examples

``` r
# Load example datasets
data(all_genes)
data(attention_genes)

# Create a volcano plot and combine it with a gt gene table
p <- ggvolc(all_genes, attention_genes, add_seg = TRUE)
genes_table(p, attention_genes)

```
