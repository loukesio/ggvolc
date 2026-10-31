# Getting started with ggvolc

`ggvolc` turns the output of a differential-expression (DE) analysis
into a polished, publication-ready volcano plot. It accepts the output
of **DESeq2**, **edgeR**, and **limma** directly, highlights and labels
genes of interest, combines the plot with a `gt` table, and can render
an interactive version with `ggiraph`.

``` r

library(ggvolc)
```

## The example data

The package ships with two data frames. `all_genes` is a complete
DESeq2-style result table; `attention_genes` is a small subset of genes
you might want to highlight.

``` r

data(all_genes)
data(attention_genes)

head(all_genes)
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
```

## A basic volcano plot

Passing a single data frame colours every gene by significance. By
default a gene is called significant when its **adjusted** p-value (FDR)
is below `0.05` and its `|log2FoldChange|` exceeds `1`.

``` r

ggvolc(all_genes)
```

![](ggvolc_files/figure-html/unnamed-chunk-3-1.png)

## Highlighting genes of interest

Supply a second data frame and those genes are drawn with a black
outline and labelled.

``` r

ggvolc(all_genes, attention_genes, add_seg = TRUE)
```

![](ggvolc_files/figure-html/unnamed-chunk-4-1.png)

The `add_seg = TRUE` argument adds dashed guides at the fold-change and
significance thresholds.

## Labelling the top genes automatically

You usually do not want to build a separate data frame just to label a
handful of hits. `label_top` picks the most significant genes for you,
and `label_dir` controls the direction they are drawn from.

``` r

# the 10 most significant genes overall
ggvolc(all_genes, label_top = 10, add_seg = TRUE, title = "Top 10 hits")
```

![](ggvolc_files/figure-html/unnamed-chunk-5-1.png)

``` r

# the top 8 up- and top 8 down-regulated genes
ggvolc(all_genes, label_top = 8, label_dir = "each",
       add_seg = TRUE, title = "Top 8 up + 8 down")
```

![](ggvolc_files/figure-html/unnamed-chunk-6-1.png)

`label_dir` accepts `"both"` (the default), `"up"`, `"down"`, and
`"each"`.

## Calling significance on the FDR (or the raw p-value)

[`ggvolc()`](https://loukesio.github.io/ggvolc/reference/ggvolc.md)
calls significance on the adjusted p-value (`padj`) by default, which is
the right cutoff for most DE workflows. The y-axis and the significance
line follow the choice, so the plot stays internally consistent. Switch
to the raw p-value with `sig_col = "pvalue"`.

``` r

ggvolc(all_genes, sig_col = "pvalue", add_seg = TRUE,
       title = "Significance on the raw p-value")
```

![](ggvolc_files/figure-html/unnamed-chunk-7-1.png)

[`ggvolc()`](https://loukesio.github.io/ggvolc/reference/ggvolc.md) is
also robust to p-values of exactly `0` (which DESeq2 and edgeR can emit
for the strongest genes): rather than dropping those points, their
`-log10` value is capped so they stay near the top of the plot.

## Scaling point size

Point size can encode either the fold change or the significance.

``` r

ggvolc(all_genes, attention_genes, size_var = "log2FoldChange", add_seg = TRUE)
```

![](ggvolc_files/figure-html/unnamed-chunk-8-1.png)

## Adding a gene table

[`genes_table()`](https://loukesio.github.io/ggvolc/reference/genes_table.md)
composes the volcano plot with a `gt` table of the highlighted genes
using `patchwork`. The result is a single object you can save with
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html).

``` r

p <- ggvolc(all_genes, attention_genes, add_seg = TRUE)
genes_table(p, attention_genes)
```

![](ggvolc_files/figure-html/unnamed-chunk-9-1.png)

To tabulate the most significant genes without curating them yourself,
pass the full DE table and a `top_n`. Genes are ranked by `sig_col`
(`padj` by default, falling back to `pvalue`); `dir = "each"` takes the
top N up- and down-regulated genes.

``` r

p_top <- ggvolc(all_genes, label_top = 10, add_seg = TRUE)
genes_table(p_top, all_genes, top_n = 10)
```

![](ggvolc_files/figure-html/unnamed-chunk-10-1.png)

## Works with DESeq2, edgeR, and limma

Column names from all three pipelines are detected and mapped
automatically, so you can pass their output straight in. Gene
identifiers held in the row names (as edgeR and limma often do) are
promoted to a `genes` column for you.

The package ships `edger_genes`, an example `topTags()`-style table with
the gene identifiers in the row names, so you can try this right away:

``` r

data(edger_genes)
head(edger_genes, 3)
#>           logFC  logCPM       PValue          FDR
#> GCR1   2.244064 12.8143 4.434241e-29 2.153711e-25
#> OPI10 -2.257454  9.9807 4.880607e-27 1.185255e-23
#> AGA2   3.829474  7.9665 4.143136e-26 6.707736e-23

ggvolc(edger_genes, label_top = 8, add_seg = TRUE, title = "edgeR input")
```

![](ggvolc_files/figure-html/unnamed-chunk-11-1.png)

| Pipeline             | Fold change      | p-value   | adjusted p  | expression |
|----------------------|------------------|-----------|-------------|------------|
| DESeq2 (`results()`) | `log2FoldChange` | `pvalue`  | `padj`      | `baseMean` |
| edgeR (`topTags()`)  | `logFC`          | `PValue`  | `FDR`       | `logCPM`   |
| limma (`topTable()`) | `logFC`          | `P.Value` | `adj.P.Val` | `AveExpr`  |

You can also skip the conversion and pass the result objects directly:
`DESeqResults` or `DESeqDataSet` (DESeq2), `TopTags`, `DGELRT` or
`DGEExact` (edgeR), and `MArrayLM` (limma, choose the coefficient with
`coef`).

``` r

ggvolc(DESeq2::results(dds))
ggvolc(edgeR::glmQLFTest(fit, coef = 2))
ggvolc(limma::eBayes(fit), coef = "treatment")
```

[`de_table()`](https://loukesio.github.io/ggvolc/reference/de_table.md)
performs the same conversion if you want the data frame itself.

## Colors and colorblind-safe palettes

`palette` selects a color preset.
[`ggvolc_palettes()`](https://loukesio.github.io/ggvolc/reference/ggvolc_palettes.md)
lists them, including colorblind-safe options and presets from the ltc
palettes.

``` r

ggvolc_palettes()
#>     palette    down not_sig      up colorblind_safe             source
#> 1   default #00798c #808080 #d1495b           FALSE         ltc: minou
#> 2 okabe_ito #0072B2 #999999 #D55E00            TRUE Okabe & Ito (2008)
#> 3      rdbu #0571b0 #999999 #ca0020            TRUE   ColorBrewer RdBu
#> 4 pantone23 #1F2C43 #B8B8B8 #FFB000            TRUE     ltc: pantone23
#> 5  seafarer #013D5A #BDBDBD #E4A25B            TRUE      ltc: seafarer
#> 6  midnight #075056 #B0B0B0 #FF5B04           FALSE      ltc: midnight
#> 7      maya #3d5a80 #A9A9A9 #ee6c4d           FALSE          ltc: maya
#> 8     trio1 #0E7175 #B0B0B0 #FD7901           FALSE         ltc: trio1

ggvolc(all_genes, label_top = 8, label_dir = "each", palette = "okabe_ito")
```

![](ggvolc_files/figure-html/unnamed-chunk-12-1.png)

[`genes_table()`](https://loukesio.github.io/ggvolc/reference/genes_table.md)
reuses the plot’s colors, darkening light ones so the table text stays
readable.

## Counts, gene sets, and several contrasts

``` r

# number of up- and downregulated genes in the corners
ggvolc(all_genes, show_counts = TRUE)
```

![](ggvolc_files/figure-html/unnamed-chunk-13-1.png)

``` r


# color named gene sets
ggvolc(all_genes, highlight = list(Set_A = all_genes$genes[1:15],
                                   Set_B = all_genes$genes[200:260]))
```

![](ggvolc_files/figure-html/unnamed-chunk-13-2.png)

To compare contrasts, pass a named list of results. `stress_timecourse`
holds real DESeq2 results from a fission yeast stress time course (Leong
et al. 2014):

``` r

ggvolc(stress_timecourse, label_top = 5, show_counts = TRUE)
```

![](ggvolc_files/figure-html/unnamed-chunk-14-1.png)

Each panel compares one time point with 0 minutes. The x-axis (fold
change) is shared; each panel uses its own y-axis height, and
`facet_scales = "fixed"` shares that too.

A named vector sets the colors directly, and `up_reg_color`,
`down_reg_color` and `not_sig_color` still override single colors:

``` r

ggvolc(all_genes, palette = c(down = "navy", up = "firebrick"))
```

![](ggvolc_files/figure-html/unnamed-chunk-15-1.png)

## An interactive volcano

With the optional [`ggiraph`](https://davidgohel.github.io/ggiraph/)
package installed, `interactive = TRUE` returns a widget where hovering
a point reveals the gene name and its statistics.

``` r

ggvolc(all_genes, attention_genes, interactive = TRUE)
```
