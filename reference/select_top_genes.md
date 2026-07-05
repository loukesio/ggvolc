# Select the top N most significant genes

Ranks a standardized DE data frame by `sig_col` (ascending) among genes
that pass the significance threshold and returns the strongest ones.
Mirrors the `label_top` / `label_dir` selection used by
[`ggvolc`](https://loukesio.github.io/ggvolc/reference/ggvolc.md) so the
gene table and the plot agree on which genes are "top".

## Usage

``` r
select_top_genes(
  df,
  top_n,
  sig_col = "padj",
  dir = c("both", "up", "down", "each"),
  p_value = 0.05
)
```

## Arguments

- df:

  A standardized DE data frame (see
  [`standardize_de_columns`](https://loukesio.github.io/ggvolc/reference/standardize_de_columns.md)),
  with at least `genes`, `log2FoldChange`, and `sig_col`.

- top_n:

  Number of genes to return. For `dir = "each"` this is per direction
  (up to `2 * top_n` rows).

- sig_col:

  Column used to rank significance, typically `"padj"` or `"pvalue"`.

- dir:

  One of `"both"` (top N over all significant genes), `"up"` (top N
  upregulated), `"down"` (top N downregulated), or `"each"` (top N up
  *and* top N down).

- p_value:

  Significance threshold; only genes with `sig_col < p_value` are
  eligible.

## Value

A data frame containing the selected rows, ordered by `sig_col`.
