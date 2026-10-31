# Create a Volcano Plot

This function creates a volcano plot using ggplot2 based on provided
datasets. It is particularly useful for visualizing differential gene
expression data.

## Usage

``` r
ggvolc(
  data1,
  data2 = NULL,
  size_var = NULL,
  p_value = 0.05,
  fc = 1,
  sig_col = c("padj", "pvalue"),
  label_top = NULL,
  label_dir = c("both", "up", "down", "each"),
  title = NULL,
  interactive = FALSE,
  palette = "default",
  not_sig_color = NULL,
  down_reg_color = NULL,
  up_reg_color = NULL,
  add_seg = FALSE,
  show_counts = FALSE,
  highlight = NULL,
  highlight_colors = NULL,
  facet_scales = c("fixed", "free_y", "free_x", "free"),
  coef = NULL
)
```

## Arguments

- data1:

  The DE results to plot: a data frame, or a DESeq2 (`DESeqResults`,
  `DESeqDataSet`), edgeR (`TopTags`, `DGELRT`, `DGEExact`) or limma
  (`MArrayLM`) object. Gene identifiers can live in a `genes` column or
  in the row names. To compare contrasts, pass a *named list* of
  results, e.g. `list("Day 1" = res1, "Day 7" = res7)`: each becomes a
  panel on shared axes, and `label_top` and `show_counts` work per
  panel.

- data2:

  Genes to highlight and label: a data frame or DE object (same
  auto-detection as `data1`), or simply a character vector of gene
  names. With a list in `data1`, the genes are highlighted in every
  panel. Default is NULL.

- size_var:

  Variable for determining the size of points. Options are
  `"log2FoldChange"` and `"pvalue"`. Default is NULL (fixed size).

- p_value:

  Threshold for statistical significance. Default is 0.05.

- fc:

  Fold change threshold for determining upregulated or downregulated
  genes. Default is 1.

- sig_col:

  Column used to call significance and to build the y-axis. Either
  `"padj"` (the adjusted p-value / FDR, the default and the recommended
  cutoff for calling hits in most DE workflows) or `"pvalue"` (the raw
  p-value). The y-axis and the significance segment follow this choice,
  so the plot stays internally consistent. When the default `"padj"` is
  used but the data has no adjusted-p column, ggvolc falls back to the
  raw p-value.

- label_top:

  Optional integer. When supplied, the `label_top` most significant
  genes (smallest `sig_col`, among significant genes) are highlighted
  and labelled automatically, without building a separate `data2`.
  Combined with `data2` if both are given. Default NULL.

- label_dir:

  Direction to draw the `label_top` genes from. One of `"both"` (top N
  over all significant genes, the default), `"up"` (top N upregulated),
  `"down"` (top N downregulated), or `"each"` (top N upregulated *and*
  top N downregulated, i.e. up to 2N labels). Ignored when `label_top`
  is NULL.

- title:

  Plot title. Default NULL (no title).

- interactive:

  Logical. If TRUE, returns an interactive ggiraph `girafe` widget where
  hovering a point reveals the gene name and its statistics. Requires
  the optional ggiraph package. Default FALSE.

- palette:

  Colors for the plot: a preset name (see
  [`ggvolc_palettes`](https://loukesio.github.io/ggvolc/reference/ggvolc_palettes.md)),
  such as `"default"`, `"okabe_ito"` (colorblind-safe), or one of the
  ltc-derived presets, or a named vector such as
  `c(down = "navy", up = "firebrick")`.

- not_sig_color, down_reg_color, up_reg_color:

  Colors for non-significant, downregulated, and upregulated genes. When
  given, they override the matching color from `palette`. Default NULL.

- add_seg:

  Logical. If TRUE, dashed lines will be added to the plot indicating
  the p-value and fold change thresholds. Default is FALSE.

- show_counts:

  Logical. If TRUE, the number of significantly down- and upregulated
  genes is printed in the top corners of the plot (of each panel when
  comparing contrasts). Default FALSE.

- highlight:

  Optional named list of gene sets to color, e.g.
  `list(Ribosome = c("RPL3", "RPS2"), Glycolysis = c("PFK1", "PYK1"))`.
  Genes in a set are drawn in the set's color, whatever their
  significance, and each set gets a legend entry. A gene in several sets
  takes the first.

- highlight_colors:

  Optional colors for the `highlight` sets, in order or named by set.
  Defaults to colorblind-friendly Okabe-Ito hues.

- facet_scales:

  When comparing contrasts, whether the panels share their axes:
  `"fixed"` (default, best for comparing panels), `"free_y"`,
  `"free_x"`, or `"free"`.

- coef:

  For a multi-coefficient limma fit, the coefficient to plot; for a
  `DESeqDataSet`, the result `name`. See
  [`de_table`](https://loukesio.github.io/ggvolc/reference/de_table.md).

## Value

A ggplot2 object displaying the volcano plot, or, when
`interactive = TRUE`, a ggiraph `girafe` widget.

## Details

You can pass the result objects of DESeq2, edgeR, and limma directly
(see
[`de_table`](https://loukesio.github.io/ggvolc/reference/de_table.md)),
or a data frame. Column names from all three pipelines are detected and
mapped automatically.

## Examples

``` r
# Load example datasets included in the package
data(all_genes)
data(attention_genes)

# Create a basic volcano plot with default settings
# Points are colored by significance (p < 0.05, |log2FC| > 1)
ggvolc(all_genes)


# Highlight specific genes of interest with labels
# These genes are shown with black borders and gene names
ggvolc(all_genes, attention_genes)


# \donttest{
# Add dashed lines to indicate significance thresholds
ggvolc(all_genes, attention_genes, add_seg = TRUE)


# Significance is called on the adjusted p-value (FDR) by default;
# use the raw p-value instead with:
ggvolc(all_genes, sig_col = "pvalue")


# Automatically label the 10 most significant genes
ggvolc(all_genes, label_top = 10)


# Label the top 10 upregulated genes only
ggvolc(all_genes, label_top = 10, label_dir = "up")


# Label the top 8 of each direction (up to 16 labels)
ggvolc(all_genes, label_top = 8, label_dir = "each")


# Give the plot a title
ggvolc(all_genes, title = "Treated vs. control")


# Show how many genes go up and down
ggvolc(all_genes, show_counts = TRUE)


# Color gene sets, e.g. a pathway
ggvolc(all_genes, highlight = list(Set_A = all_genes$genes[1:15],
                                   Set_B = all_genes$genes[100:130]))


# Compare contrasts side by side: a real stress time course
ggvolc(stress_timecourse, label_top = 5, show_counts = TRUE)
#> ggvolc: left out 384 gene(s) with NA padj or log2FoldChange (e.g. genes DESeq2 filtered as low-count or outliers).


# Let each panel use its own y-axis
ggvolc(stress_timecourse, label_top = 5, facet_scales = "free_y")
#> ggvolc: left out 384 gene(s) with NA padj or log2FoldChange (e.g. genes DESeq2 filtered as low-count or outliers).


# Colorblind-safe colors, or any preset from ggvolc_palettes()
ggvolc(all_genes, label_top = 10, palette = "okabe_ito")


# Customize colors for up- and down-regulated genes
ggvolc(all_genes, attention_genes,
       up_reg_color = "#E63946",
       down_reg_color = "#457B9D")


# Scale point size by p-value instead of default
ggvolc(all_genes, attention_genes, size_var = "pvalue")


# Adjust significance thresholds (p-value and fold change)
ggvolc(all_genes, p_value = 0.01, fc = 2)


# edgeR-style input works directly
edger_df <- data.frame(
  genes = paste0("gene", 1:50),
  logFC = rnorm(50, 0, 2),
  logCPM = runif(50, 5, 15),
  PValue = 10^-runif(50, 0, 6),
  FDR = 10^-runif(50, 0, 5)
)
ggvolc(edger_df)


# limma-style input works too
limma_df <- data.frame(
  genes = paste0("gene", 1:50),
  logFC = rnorm(50, 0, 2),
  AveExpr = runif(50, 5, 15),
  t = rnorm(50),
  P.Value = 10^-runif(50, 0, 6),
  adj.P.Val = 10^-runif(50, 0, 5)
)
ggvolc(limma_df)


# }

if (FALSE) { # \dontrun{
# DE objects work directly, no conversion needed
ggvolc(DESeq2::results(dds))
ggvolc(edgeR::glmQLFTest(qlf_fit, coef = 2))
ggvolc(limma::eBayes(limma_fit), coef = "treatment")

# Interactive volcano (requires the ggiraph package): hover a point to
# see the gene name and its statistics
ggvolc(all_genes, attention_genes, interactive = TRUE)
} # }
```
