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
