# Detect DE pipeline from column names

Detect DE pipeline from column names

## Usage

``` r
detect_de_source(cols)
```

## Arguments

- cols:

  Character vector of column names.

## Value

One of `"deseq2"`, `"edger"`, `"limma"`, or errors if unrecognized.
