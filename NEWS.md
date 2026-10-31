# ggvolc 0.4.0

## DE objects in, colorblind-safe palettes

* **Pass DE result objects directly.** `ggvolc()` and `genes_table()` now accept
  the objects themselves, not only data frames:
  - DESeq2: `DESeqResults` (from `results()` / `lfcShrink()`) and a
    `DESeqDataSet` after `DESeq()` (`results()` is called for you).
  - edgeR: `TopTags`, and `DGELRT` / `DGEExact` from `glmQLFTest()`,
    `glmLRT()` and `exactTest()` (all genes are kept).
  - limma: `MArrayLM` fits after `eBayes()`; choose the coefficient with the
    new `coef` argument when the fit has several.
* New exported `de_table()` does the conversion, for when you want the data
  frame yourself.
* **`palette` argument** with built-in presets, listed by the new
  `ggvolc_palettes()`: colorblind-safe `"okabe_ito"` and `"rdbu"`, and presets
  from the ltc palettes (`"pantone23"`, `"seafarer"`, `"midnight"`, `"maya"`,
  `"trio1"`). `palette` also takes a named vector such as
  `c(down = "navy", up = "firebrick")`. The default colors are unchanged.
* `up_reg_color`, `down_reg_color` and `not_sig_color` now default to `NULL`
  and, when given, override the matching palette color.
* `genes_table()` colors the log2FC column to match the plot's palette, and
  gains `palette` and `coef` arguments. The table now spans the full width of
  the plot panel with larger text, and takes only the height its rows need
  (`table_height` now defaults to `NULL`; set it to fix the ratio as before).
* `top_n` in `genes_table()` selects the most significant genes automatically.
* **Compare contrasts.** Pass a named list of results, e.g.
  `ggvolc(list("Day 1" = res1, "Day 7" = res7))`, to get one panel per
  contrast on shared axes. `label_top` and `show_counts` work per panel, and
  `data2` genes are highlighted in every panel. Panels are titled with clean bold
  labels (restyle with `+ theme(strip.background = ...)`).
* **`highlight`** colors named gene sets (pathways, GO terms) with their own
  legend entries, in colors matching the default palette; choose colors with
  `highlight_colors` and per-set transparency with `highlight_alpha`.
* **`show_counts = TRUE`** prints the number of down- and upregulated genes in
  the top corners.
* **`flip = TRUE`** swaps the axes: log2 fold change on the y-axis,
  significance on the x-axis. When comparing contrasts side by side this lines
  the fold-change axis up across panels.
* `facet_scales` controls which axes compared panels share. By default only the
  significance axis is free (`"free_y"`, or `"free_x"` with `flip = TRUE`), so
  the fold-change axis stays comparable while a weak contrast is not squashed
  by a strong one; `"fixed"` shares both.
* New dataset **`stress_timecourse`**: real DESeq2 results (30, 60 and 180 min
  vs 0) from a fission yeast osmotic stress time course (Leong et al. 2014,
  via the Bioconductor package *fission*), for trying out contrast comparison.
* Genes with an `NA` p-value or fold change (e.g. those DESeq2 removes by
  independent filtering) are left out with a message, instead of triggering
  ggplot2's "Removed rows" warning.
* `data2` can now be a plain character vector of gene names.
* Text colors in the `genes_table()` table and the counts are darkened when
  needed to reach a WCAG contrast ratio of 4.5:1 on white, so light palette
  colors (e.g. `pantone23`'s gold) stay readable.
* DESeq2, edgeR and limma are optional (`Suggests`) dependencies.

# ggvolc 0.3.0

## Better significance handling, auto-labels & interactivity

* **Significance on the adjusted p-value (FDR) by default.** `ggvolc()` gains a
  `sig_col` argument (`"padj"` or `"pvalue"`) and now defaults to `"padj"`, so
  hits are called on the FDR — the recommended cutoff in most DE workflows —
  with the y-axis and the significance segment following the choice so the plot
  stays internally consistent. Set `sig_col = "pvalue"` for the raw p-value.
  When the default `"padj"` is used but the data has no adjusted-p column,
  ggvolc falls back to the raw p-value automatically.
* **Robust to `p == 0`.** DESeq2 and edgeR can report a p-value of exactly 0
  (floating-point underflow) for the strongest genes; `-log10(0)` is `Inf`,
  which ggplot2 silently drops — so the *most* significant genes used to vanish
  from the plot. Those values are now capped to a finite ceiling (just above the
  most significant real gene) and a message reports how many were adjusted.
* **`label_top = N`.** Automatically highlight and label the `N` most
  significant genes without building a separate `data2`. Combines with an
  explicit `data2` when both are supplied.
* **`label_dir`.** Choose the direction the labelled genes are drawn from:
  `"both"` (default), `"up"`, `"down"`, or `"each"` (top N upregulated *and*
  top N downregulated). Pairs with `label_top`, e.g. `label_top = 10,
  label_dir = "each"`.
* **`title` argument.** The plot title is now configurable and defaults to
  `NULL` (no title), replacing the previous hardcoded placeholder title.
* **Interactive volcano plots.** `ggvolc(..., interactive = TRUE)` returns a
  `ggiraph` `girafe` widget where hovering a point reveals the gene name and its
  statistics. `ggiraph` is an optional (`Suggests`) dependency, so the core
  package still installs without it.
* New internal helper: `neglog10_cap()`.
* The README is now generated from `README.Rmd` (via `devtools::build_readme()`)
  so every example plot is rendered from live code and kept in sync with the
  package.
* `DESCRIPTION` now declares `R (>= 4.1.0)`, matching the native pipe (`|>`)
  used internally (previously mis-declared as `>= 3.5.0`).

# ggvolc 0.2.0

## Multi-pipeline support & gt tables

* **DESeq2, edgeR, and limma auto-detection**: `ggvolc()` and `genes_table()`
  now accept output from all three major DE pipelines. Column names are
  automatically mapped internally — no manual renaming needed.
  - DESeq2: `log2FoldChange`, `pvalue`, `padj`, `baseMean`
  - edgeR: `logFC`, `PValue`, `FDR`, `logCPM`
  - limma: `logFC`, `P.Value`, `adj.P.Val`, `AveExpr`
* Gene identifiers stored as row names (common in edgeR/limma) are
  automatically promoted to a `genes` column.
* **`genes_table()` rewritten** with `gt` + `patchwork`:
  - Replaces `gridExtra::grid.arrange` with `patchwork::wrap_table()`
  - Gene table rendered as a `gt` table with formatted numerics,
    color-coded p-values, and directional log2FC coloring
  - p-value / adjusted-p columns use grid-safe scientific notation
    (`1.0e-08`) so exponents render correctly once the table is composed
    into the plot graphic by `patchwork`
  - Returns a proper `patchwork` object (composable, `ggsave()`-able)
* New internal helpers: `standardize_de_columns()`, `detect_de_source()`
* Added `testthat` test suite covering all three DE formats, column
  detection, attention genes, plot options, and the new gene table.
* Dependencies: replaced `gridExtra` with `gt` and `patchwork`.
* Version bump to 0.2.0.

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
