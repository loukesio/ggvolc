# Turn a DE result object into a plain data frame

Converts the result objects returned by the three major differential
expression pipelines into a plain `data.frame` that
[`ggvolc`](https://loukesio.github.io/ggvolc/reference/ggvolc.md) and
[`genes_table`](https://loukesio.github.io/ggvolc/reference/genes_table.md)
understand. You rarely need to call this yourself: both functions call
it internally, so you can pass the objects straight in. It is exported
for when you want to inspect or filter the table first.

## Usage

``` r
de_table(x, coef = NULL)
```

## Arguments

- x:

  A DE result object or a data frame (see Details).

- coef:

  For a multi-coefficient limma fit, the coefficient (name or index) to
  extract. For a `DESeqDataSet`, passed as `name` to
  [`DESeq2::results()`](https://rdrr.io/pkg/DESeq2/man/results.html).
  Ignored otherwise.

## Value

A `data.frame` with one row per gene. Gene identifiers are kept in the
row names (or a `genes` column, if the input had one).

## Details

Supported inputs:

- DESeq2:

  A `DESeqResults` object from
  [`DESeq2::results()`](https://rdrr.io/pkg/DESeq2/man/results.html) or
  [`DESeq2::lfcShrink()`](https://rdrr.io/pkg/DESeq2/man/lfcShrink.html),
  or a `DESeqDataSet` after
  [`DESeq2::DESeq()`](https://rdrr.io/pkg/DESeq2/man/DESeq.html), in
  which case
  [`DESeq2::results()`](https://rdrr.io/pkg/DESeq2/man/results.html) is
  called for you (with `name = coef` when `coef` is given).

- edgeR:

  A `TopTags` object from
  [`edgeR::topTags()`](https://rdrr.io/pkg/edgeR/man/topTags.html), or a
  `DGELRT` / `DGEExact` object from
  [`edgeR::glmQLFTest()`](https://rdrr.io/pkg/edgeR/man/glmQLFTest.html),
  [`edgeR::glmLRT()`](https://rdrr.io/pkg/edgeR/man/glmLRT.html) or
  [`edgeR::exactTest()`](https://rdrr.io/pkg/edgeR/man/exactTest.html).
  All genes are kept (`edgeR::topTags(x, n = Inf)`).

- limma:

  An `MArrayLM` fit after
  [`limma::eBayes()`](https://rdrr.io/pkg/limma/man/ebayes.html).
  `limma::topTable(fit, coef = coef, number = Inf)` is called for you.
  If the fit has more than one coefficient, `coef` is required.

- data frame:

  Any `data.frame` (including tibbles) is returned unchanged.

## Examples

``` r
# A data frame passes straight through
head(de_table(all_genes))
#>       genes   baseMean log2FoldChange     lfcSE       stat       pvalue
#> 1      GCR1  7201.5782       2.244064 0.2004959  11.192564 4.434241e-29
#> 2     OPI10  1009.4171      -2.257454 0.2096469 -10.767889 4.880607e-27
#> 3      AGA2   249.1173       3.829474 0.3623263  10.569132 4.143136e-26
#> 4 FIM1_1376  5237.5035       2.550409 0.2560379   9.961059 2.256459e-23
#> 5      HMG1 10838.1037       2.214300 0.2229065   9.933763 2.968371e-23
#> 6 FIM1_3918  2456.8070       2.288243 0.2356228   9.711467 2.694309e-22
#>           padj
#> 1 2.153711e-25
#> 2 1.185255e-23
#> 3 6.707736e-23
#> 4 2.739905e-20
#> 5 2.883475e-20
#> 6 2.181043e-19

if (FALSE) { # \dontrun{
# DESeq2
dds <- DESeq2::DESeq(dds)
ggvolc(DESeq2::results(dds))       # results object
ggvolc(dds)                        # or the dataset itself

# edgeR
fit <- edgeR::glmQLFit(y, design)
ggvolc(edgeR::glmQLFTest(fit, coef = 2))

# limma
fit <- limma::eBayes(limma::lmFit(v, design))
ggvolc(fit, coef = "treatment")
} # }
```
