# Detect DE source and standardize column names

Inspects column names of a data frame and maps them to the internal
ggvolc convention: `genes`, `log2FoldChange`, `pvalue`, `padj`,
`baseMean`.

## Usage

``` r
standardize_de_columns(df)
```

## Arguments

- df:

  A data frame from a DE analysis pipeline.

## Value

A data frame with standardized column names.

## Details

Recognized formats:

- DESeq2:

  `log2FoldChange`, `pvalue`, `padj`, `baseMean`

- edgeR:

  `logFC`, `PValue`, `FDR`, `logCPM`

- limma:

  `logFC`, `P.Value`, `adj.P.Val`, `AveExpr`
