# Fission Yeast Stress Time Course (three contrasts)

Real DESeq2 results from an RNA-seq time course of wild-type fission
yeast (*Schizosaccharomyces pombe*) exposed to osmotic stress (1 M
sorbitol). Each element of the list compares one time point after stress
with time 0, so the list can be passed straight to
[`ggvolc`](https://loukesio.github.io/ggvolc/reference/ggvolc.md) to
compare the contrasts side by side. The response is strongest at 30
minutes and fades by 180 minutes.

## Usage

``` r
stress_timecourse
```

## Format

A named list of three data frames, `"30 min"`, `"60 min"`, and
`"180 min"`, each with 6535 rows and the columns:

- genes:

  Character. Gene symbol, or the systematic ID when no symbol exists.

- baseMean:

  Numeric. Mean of normalized counts across all samples.

- log2FoldChange:

  Numeric. log2 fold change versus time 0.

- pvalue:

  Numeric. Wald test p-value.

- padj:

  Numeric. Benjamini-Hochberg adjusted p-value.

## Source

Leong HS, Dawson K, Wirth C, et al. (2014). A global non-coding RNA
system modulates fission yeast protein levels in response to stress.
*Nature Communications* 5:3947.
[doi:10.1038/ncomms4947](https://doi.org/10.1038/ncomms4947) . GEO
accession GSE56761. Data via the Bioconductor package fission.

## Details

The counts come from the Bioconductor data package fission (wild-type
samples only, 3 replicates per time point; genes with fewer than 10
reads in total removed). Results were computed with
[`DESeq2::DESeq()`](https://rdrr.io/pkg/DESeq2/man/DESeq.html) using
`design = ~ minute`; see `data-raw/stress_timecourse.R` in the package
sources. As in any DESeq2 output, `padj` is `NA` for genes removed by
independent filtering.

## Examples

``` r
names(stress_timecourse)
#> [1] "30 min"  "60 min"  "180 min"
ggvolc(stress_timecourse, label_top = 5, show_counts = TRUE)
#> ggvolc: left out 384 gene(s) with NA padj or log2FoldChange (e.g. genes DESeq2 filtered as low-count or outliers).
```
