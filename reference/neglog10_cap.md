# Compute -log10(p) with infinite values capped

`-log10()` of a p-value of exactly 0 (which DESeq2 and edgeR can emit
through floating-point underflow for the strongest genes) is `Inf`, and
ggplot2 silently drops non-finite values. That would make the most
significant genes disappear from the plot. This helper replaces the
infinite values with a finite ceiling so those genes stay on the plot,
near the top.

## Usage

``` r
neglog10_cap(p, ceiling = NULL)
```

## Arguments

- p:

  Numeric vector of p-values.

- ceiling:

  Optional finite value used for capping. When `NULL` it is set to 1.05
  times the largest finite `-log10(p)`. Pass an explicit value to keep
  two datasets (e.g. background and highlighted genes) on the same
  scale.

## Value

A list with `value` (the capped `-log10(p)` vector), `ceiling` (the cap
used), and `n_capped` (how many values were replaced).
