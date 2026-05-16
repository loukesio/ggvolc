# ---- helpers: synthetic DE data frames ----

make_deseq2_df <- function(n = 100) {

  set.seed(42)
  data.frame(
    genes            = paste0("gene", seq_len(n)),
    baseMean         = runif(n, 10, 1000),
    log2FoldChange   = rnorm(n, 0, 2),
    lfcSE            = runif(n, 0.1, 0.5),
    stat             = rnorm(n),
    pvalue           = 10^-runif(n, 0, 8),
    padj             = 10^-runif(n, 0, 6),
    stringsAsFactors = FALSE
  )
}

make_edger_df <- function(n = 100) {
  set.seed(42)
  data.frame(
    genes  = paste0("gene", seq_len(n)),
    logFC  = rnorm(n, 0, 2),
    logCPM = runif(n, 5, 15),
    PValue = 10^-runif(n, 0, 8),
    FDR    = 10^-runif(n, 0, 6),
    stringsAsFactors = FALSE
  )
}

make_edger_rownames_df <- function(n = 100) {
  df <- make_edger_df(n)
  rownames(df) <- df$genes
  df$genes <- NULL
  df
}

make_limma_df <- function(n = 100) {
  set.seed(42)
  data.frame(
    genes     = paste0("gene", seq_len(n)),
    logFC     = rnorm(n, 0, 2),
    AveExpr   = runif(n, 5, 15),
    t         = rnorm(n),
    P.Value   = 10^-runif(n, 0, 8),
    adj.P.Val = 10^-runif(n, 0, 6),
    stringsAsFactors = FALSE
  )
}


# ===========================================================================
# detect_de_source
# ===========================================================================

test_that("detect_de_source correctly identifies DESeq2 columns", {
  df <- make_deseq2_df()
  expect_equal(detect_de_source(colnames(df)), "deseq2")
})

test_that("detect_de_source correctly identifies edgeR columns", {
  df <- make_edger_df()
  expect_equal(detect_de_source(colnames(df)), "edger")
})

test_that("detect_de_source correctly identifies limma columns", {
  df <- make_limma_df()
  expect_equal(detect_de_source(colnames(df)), "limma")
})

test_that("detect_de_source errors on unrecognized columns", {
  expect_error(detect_de_source(c("x", "y", "z")), "don't match")
})


# ===========================================================================
# standardize_de_columns
# ===========================================================================

test_that("standardize_de_columns is a no-op for DESeq2 input", {
  df <- make_deseq2_df()
  out <- standardize_de_columns(df)
  expect_identical(colnames(out), colnames(df))
})

test_that("standardize_de_columns maps edgeR columns correctly", {
  df <- make_edger_df()
  out <- standardize_de_columns(df)
  expect_true(all(c("genes", "log2FoldChange", "pvalue", "padj", "baseMean") %in% colnames(out)))
  expect_false("logFC" %in% colnames(out))
})

test_that("standardize_de_columns maps limma columns correctly", {
  df <- make_limma_df()
  out <- standardize_de_columns(df)
  expect_true(all(c("genes", "log2FoldChange", "pvalue", "padj", "baseMean") %in% colnames(out)))
  expect_false("P.Value" %in% colnames(out))
})

test_that("standardize_de_columns promotes rownames when genes column is absent", {
  df <- make_edger_rownames_df()
  expect_false("genes" %in% colnames(df))
  out <- standardize_de_columns(df)
  expect_true("genes" %in% colnames(out))
  expect_equal(out$genes[1], "gene1")
})

test_that("standardize_de_columns errors when no genes and no informative rownames", {
  df <- data.frame(logFC = 1, PValue = 0.01, FDR = 0.05)
  expect_error(standardize_de_columns(df), "genes")
})


# ===========================================================================
# ggvolc — basic plot generation
# ===========================================================================

test_that("ggvolc returns a ggplot for DESeq2 input", {
  df <- make_deseq2_df()
  p <- ggvolc(df)
  expect_s3_class(p, "gg")
})

test_that("ggvolc returns a ggplot for edgeR input", {
  df <- make_edger_df()
  p <- ggvolc(df)
  expect_s3_class(p, "gg")
})

test_that("ggvolc returns a ggplot for limma input", {
  df <- make_limma_df()
  p <- ggvolc(df)
  expect_s3_class(p, "gg")
})

test_that("ggvolc returns a ggplot for edgeR with rowname genes", {
  df <- make_edger_rownames_df()
  p <- ggvolc(df)
  expect_s3_class(p, "gg")
})


# ===========================================================================
# ggvolc — attention genes
# ===========================================================================

test_that("ggvolc works with attention genes (DESeq2)", {
  all <- make_deseq2_df(200)
  att <- all[sample(200, 5), ]
  p <- ggvolc(all, att)
  expect_s3_class(p, "gg")
})

test_that("ggvolc works with attention genes (edgeR)", {
  all <- make_edger_df(200)
  att <- all[sample(200, 5), ]
  p <- ggvolc(all, att)
  expect_s3_class(p, "gg")
})


# ===========================================================================
# ggvolc — options
# ===========================================================================

test_that("ggvolc add_seg works", {
  df <- make_deseq2_df()
  p <- ggvolc(df, add_seg = TRUE)
  expect_s3_class(p, "gg")
})

test_that("ggvolc size_var = 'pvalue' works", {
  df <- make_deseq2_df()
  p <- ggvolc(df, size_var = "pvalue")
  expect_s3_class(p, "gg")
})

test_that("ggvolc size_var = 'log2FoldChange' works", {
  df <- make_deseq2_df()
  p <- ggvolc(df, size_var = "log2FoldChange")
  expect_s3_class(p, "gg")
})

test_that("ggvolc custom colors work", {
  df <- make_deseq2_df()
  p <- ggvolc(df, up_reg_color = "red", down_reg_color = "blue")
  expect_s3_class(p, "gg")
})

test_that("ggvolc custom thresholds work", {
  df <- make_deseq2_df()
  p <- ggvolc(df, p_value = 0.01, fc = 2)
  expect_s3_class(p, "gg")
})


# ===========================================================================
# ggvolc — input validation
# ===========================================================================

test_that("ggvolc rejects non-dataframe input", {
  expect_error(ggvolc("not a df"), "data frame")
})

test_that("ggvolc rejects non-dataframe data2", {
  df <- make_deseq2_df()
  expect_error(ggvolc(df, data2 = "not a df"), "data frame")
})


# ===========================================================================
# genes_table — gt + patchwork
# ===========================================================================

test_that("genes_table returns a patchwork object for DESeq2 input", {
  all <- make_deseq2_df(200)
  att <- all[sample(200, 5), ]
  p <- ggvolc(all, att)
  combined <- genes_table(p, att)
  expect_s3_class(combined, "patchwork")
})

test_that("genes_table returns a patchwork object for edgeR input", {
  all <- make_edger_df(200)
  att <- all[sample(200, 5), ]
  p <- ggvolc(all, att)
  combined <- genes_table(p, att)
  expect_s3_class(combined, "patchwork")
})

test_that("genes_table returns a patchwork object for limma input", {
  all <- make_limma_df(200)
  att <- all[sample(200, 5), ]
  p <- ggvolc(all, att)
  combined <- genes_table(p, att)
  expect_s3_class(combined, "patchwork")
})

test_that("genes_table rejects non-ggplot input", {
  expect_error(genes_table("not a plot", make_deseq2_df(5)), "ggplot")
})

test_that("genes_table rejects non-dataframe data2", {
  p <- ggvolc(make_deseq2_df())
  expect_error(genes_table(p, "not a df"), "data frame")
})
