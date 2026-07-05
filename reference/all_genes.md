# Gene Expression Analysis Dataset

A dataset containing gene expression analysis results. It has seven
columns capturing various statistics related to gene expression.

## Usage

``` r
all_genes
```

## Format

A data frame with the following columns:

- genes:

  Character. Gene name or identifier.

- baseMean:

  Numeric. The base mean value for the gene across samples.

- log2FoldChange:

  Numeric. The log2 fold change of gene expression. Positive values
  indicate upregulation and negative values indicate downregulation.

- lfcSE:

  Numeric. Standard error of the log2 fold change.

- stat:

  Numeric. The Wald statistic for the gene's expression change.

- pvalue:

  Numeric. Raw p-value for the test of the gene's expression change.

- padj:

  Numeric. Adjusted p-value for multiple testing corrections.
