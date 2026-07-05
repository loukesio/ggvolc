# edgeR-style Differential Expression Dataset

The same experiment as
[`all_genes`](https://loukesio.github.io/ggvolc/reference/all_genes.md),
re-expressed with the column conventions of edgeR's `topTags()` output.
The gene identifiers are stored in the row names (as `topTags()` returns
them), which lets it demonstrate that
[`ggvolc`](https://loukesio.github.io/ggvolc/reference/ggvolc.md)
accepts edgeR results directly and promotes rowname gene IDs to a
`genes` column automatically.

## Usage

``` r
edger_genes
```

## Format

A data frame with gene identifiers in the row names and the following
columns:

- logFC:

  Numeric. Log2 fold change of gene expression.

- logCPM:

  Numeric. Average log2 counts per million.

- PValue:

  Numeric. Raw p-value from the differential expression test.

- FDR:

  Numeric. Benjamini-Hochberg adjusted p-value (false discovery rate).
