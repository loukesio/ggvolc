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


# ===========================================================================
# neglog10_cap — infinite value handling
# ===========================================================================

test_that("neglog10_cap replaces -log10(0) = Inf with a finite ceiling", {
  res <- neglog10_cap(c(1e-4, 1e-8, 0))
  expect_true(all(is.finite(res$value)))
  expect_equal(res$n_capped, 1)
  expect_true(res$value[3] >= max(res$value[1:2]))  # capped value sits at the top
})

test_that("neglog10_cap is a no-op when no zeros are present", {
  res <- neglog10_cap(c(1e-4, 1e-8, 1e-2))
  expect_equal(res$n_capped, 0)
  expect_equal(res$value, -log10(c(1e-4, 1e-8, 1e-2)))
})

test_that("neglog10_cap leaves NA values untouched", {
  res <- neglog10_cap(c(1e-4, NA, 0))
  expect_true(is.na(res$value[2]))
  expect_equal(res$n_capped, 1)
})


# ===========================================================================
# ggvolc — significance column (sig_col)
# ===========================================================================

test_that("ggvolc defaults to sig_col = 'padj'", {
  p <- ggvolc(make_deseq2_df())
  expect_s3_class(p, "gg")
  expect_equal(p$labels$y, "-log10(padj)")
})

test_that("ggvolc accepts sig_col = 'pvalue'", {
  p <- ggvolc(make_deseq2_df(), sig_col = "pvalue")
  expect_equal(p$labels$y, "-log10(pvalue)")
})

test_that("ggvolc falls back to pvalue when padj is absent and not requested", {
  df <- make_edger_df()
  df$FDR <- NULL                       # no column maps to padj
  expect_message(p <- ggvolc(df), "pvalue")
  expect_equal(p$labels$y, "-log10(pvalue)")
})

test_that("ggvolc errors when sig_col = 'padj' is requested but unavailable", {
  df <- make_edger_df()
  df$FDR <- NULL
  expect_error(ggvolc(df, sig_col = "padj"), "sig_col")
})


# ===========================================================================
# ggvolc — infinite p-value robustness
# ===========================================================================

test_that("ggvolc handles p == 0 (Inf) without dropping genes", {
  df <- make_deseq2_df()
  df$pvalue[1:3] <- 0
  df$padj[1:3]   <- 0
  expect_message(p <- ggvolc(df), "capped")              # default sig_col = padj
  expect_s3_class(p, "gg")
  expect_message(ggvolc(df, sig_col = "pvalue"), "capped")
})


# ===========================================================================
# ggvolc — label_top
# ===========================================================================

test_that("ggvolc label_top adds a labelled layer", {
  df <- make_deseq2_df(200)
  p_plain <- ggvolc(df)
  p_top   <- ggvolc(df, label_top = 10)
  expect_s3_class(p_top, "gg")
  # label_top adds highlight + text layers on top of the base plot
  expect_gt(length(p_top$layers), length(p_plain$layers))
})

test_that("ggvolc label_top unions with an explicit data2", {
  df  <- make_deseq2_df(200)
  att <- df[1:3, ]
  p   <- ggvolc(df, att, label_top = 5)
  expect_s3_class(p, "gg")
})

test_that("ggvolc rejects an invalid label_top", {
  df <- make_deseq2_df()
  expect_error(ggvolc(df, label_top = -1), "label_top")
  expect_error(ggvolc(df, label_top = "ten"), "label_top")
})

test_that("ggvolc label_dir directions all return a ggplot", {
  df <- make_deseq2_df(200)
  for (dir in c("both", "up", "down", "each")) {
    p <- ggvolc(df, label_top = 6, label_dir = dir)
    expect_s3_class(p, "gg")
  }
})

test_that("ggvolc label_dir = 'up' labels only upregulated genes", {
  # build data where direction is unambiguous
  set.seed(1)
  df <- data.frame(
    genes = paste0("gene", 1:40),
    baseMean = 100,
    log2FoldChange = c(rep(3, 20), rep(-3, 20)),   # first 20 up, last 20 down
    pvalue = 1e-6,
    padj   = 1e-5
  )
  p <- ggvolc(df, label_top = 5, label_dir = "up")
  # the ggrepel label layer is the last layer; its data holds the labelled genes
  lab_data <- p$layers[[length(p$layers)]]$data
  expect_true(all(lab_data$log2FoldChange > 0))
  expect_equal(nrow(lab_data), 5)
})

test_that("ggvolc label_dir = 'each' draws from both directions", {
  set.seed(1)
  df <- data.frame(
    genes = paste0("gene", 1:40),
    baseMean = 100,
    log2FoldChange = c(rep(3, 20), rep(-3, 20)),
    pvalue = 1e-6,
    padj   = 1e-5
  )
  p <- ggvolc(df, label_top = 5, label_dir = "each")
  lab_data <- p$layers[[length(p$layers)]]$data
  expect_true(any(lab_data$log2FoldChange > 0))
  expect_true(any(lab_data$log2FoldChange < 0))
  expect_equal(nrow(lab_data), 10)          # 5 up + 5 down
})

test_that("ggvolc rejects an invalid label_dir", {
  expect_error(ggvolc(make_deseq2_df(), label_top = 5, label_dir = "sideways"))
})


# ===========================================================================
# ggvolc — title
# ===========================================================================

test_that("ggvolc has no title by default and honours a supplied title", {
  expect_null(ggvolc(make_deseq2_df())$labels$title)
  expect_equal(ggvolc(make_deseq2_df(), title = "Hello")$labels$title, "Hello")
})


# ===========================================================================
# ggvolc — interactive (ggiraph)
# ===========================================================================

test_that("ggvolc interactive = TRUE returns a girafe widget", {
  skip_if_not_installed("ggiraph")
  df <- make_deseq2_df(80)
  att <- df[1:4, ]
  g <- ggvolc(df, att, interactive = TRUE)
  expect_s3_class(g, "girafe")
})


# ===========================================================================
# bundled datasets
# ===========================================================================

test_that("edger_genes ships in edgeR format and plots directly", {
  data(edger_genes, package = "ggvolc", envir = environment())
  expect_true(is.data.frame(edger_genes))
  # genes live in the row names, edgeR-style columns present
  expect_false("genes" %in% colnames(edger_genes))
  expect_true(all(c("logFC", "logCPM", "PValue", "FDR") %in% colnames(edger_genes)))
  p <- ggvolc(edger_genes, label_top = 5, add_seg = TRUE)
  expect_s3_class(p, "gg")
})
