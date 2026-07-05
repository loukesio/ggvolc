# Attention Genes Dataset

A dataset containing specific genes of interest referred to as
"attention genes".

## Usage

``` r
attention_genes
```

## Format

A data frame with 10 rows and 7 variables:

- genes:

  Character. Gene name or identifier.

- baseMean:

  Numeric vector: Base mean expression level of genes

- log2FoldChange:

  Numeric vector: Log2 Fold Change of gene expression

- lfcSE:

  Numeric vector: Standard error for log2 fold change

- stat:

  Numeric vector: Wald statistic for the gene's expression change

- pvalue:

  Numeric vector: Raw p-value from Wald test

- padj:

  Numeric vector: Adjusted p-value for multiple testing using the
  Benjamini-Hochberg procedure
