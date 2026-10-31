# ---- de_table(): DE objects -> data frame ---------------------------------

test_that("de_table passes data frames through unchanged", {
  expect_identical(de_table(all_genes), all_genes)
})

test_that("de_table reads an edgeR TopTags-like object without edgeR", {
  df <- data.frame(logFC = c(2, -2), logCPM = 5, PValue = 1e-5, FDR = 1e-4,
                   row.names = c("a", "b"))
  tt <- structure(list(table = df), class = "TopTags")
  expect_s3_class(ggvolc(tt), "ggplot")
})

test_that("de_table errors clearly on unsupported input", {
  expect_error(de_table(1:10), "Don't know how to read")
  expect_error(ggvolc(matrix(1:4, 2)), "Don't know how to read")
})

make_counts <- function() {
  set.seed(1)
  n <- 200
  cnt <- matrix(rnbinom(n * 6, mu = 100, size = 10), n, 6,
                dimnames = list(paste0("g", seq_len(n)), paste0("s", 1:6)))
  cnt[1:20, 4:6] <- cnt[1:20, 4:6] * 5
  cnt
}

test_that("DESeq2 results and DESeqDataSet objects plot directly", {
  skip_if_not_installed("DESeq2")
  cnt <- make_counts()
  cd  <- data.frame(grp = factor(rep(c("ctrl", "trt"), each = 3)))
  dds <- suppressMessages(DESeq2::DESeq(
    DESeq2::DESeqDataSetFromMatrix(cnt, cd, ~grp), quiet = TRUE))

  res <- DESeq2::results(dds)
  expect_equal(nrow(de_table(res)), nrow(cnt))
  expect_s3_class(ggvolc(res), "ggplot")
  expect_s3_class(ggvolc(dds), "ggplot")
  expect_s3_class(genes_table(ggvolc(res), res, top_n = 5), "patchwork")
})

test_that("edgeR DGELRT / DGEExact objects plot directly", {
  skip_if_not_installed("edgeR")
  cnt <- make_counts()
  grp <- factor(rep(c("ctrl", "trt"), each = 3))
  design <- stats::model.matrix(~grp)
  y <- edgeR::estimateDisp(edgeR::calcNormFactors(edgeR::DGEList(cnt, group = grp)), design)
  qlf <- edgeR::glmQLFTest(edgeR::glmQLFit(y, design), coef = 2)

  expect_equal(nrow(de_table(qlf)), nrow(cnt))
  expect_s3_class(ggvolc(qlf), "ggplot")
  expect_s3_class(ggvolc(edgeR::exactTest(y)), "ggplot")
  expect_error(ggvolc(y), "DGEList holds counts")
})

test_that("limma MArrayLM fits need coef when there are several", {
  skip_if_not_installed("limma")
  set.seed(1)
  expr <- matrix(rnorm(600), 100, 6, dimnames = list(paste0("g", 1:100), NULL))
  design <- stats::model.matrix(~ factor(rep(1:2, each = 3)))
  colnames(design) <- c("Intercept", "trt")
  fit <- limma::eBayes(limma::lmFit(expr, design))

  expect_error(ggvolc(fit), "choose one with `coef`")
  expect_s3_class(ggvolc(fit, coef = "trt"), "ggplot")
  expect_equal(nrow(de_table(fit, coef = 2)), 100)
  expect_error(ggvolc(limma::lmFit(expr, design), coef = 2), "eBayes")
})

# ---- palettes ------------------------------------------------------------

test_that("ggvolc_palettes lists presets with a default", {
  pals <- ggvolc_palettes()
  expect_true(all(c("default", "okabe_ito") %in% pals$palette))
  expect_true(all(grepl("^#", c(pals$down, pals$up, pals$not_sig))))
})

test_that("default colors are unchanged from earlier versions", {
  cols <- attr(ggvolc(all_genes), "ggvolc_colors")
  expect_equal(unname(cols), c("#00798c", "#808080", "#d1495b"))
})

test_that("palette presets, named vectors and overrides combine", {
  cols <- attr(ggvolc(all_genes, palette = "okabe_ito"), "ggvolc_colors")
  expect_equal(cols[["up"]], "#D55E00")

  cols <- attr(ggvolc(all_genes, palette = c(up = "red")), "ggvolc_colors")
  expect_equal(cols[["up"]], "red")
  expect_equal(cols[["down"]], "#00798c")

  cols <- attr(ggvolc(all_genes, palette = "okabe_ito", up_reg_color = "pink"),
               "ggvolc_colors")
  expect_equal(cols[["up"]], "pink")
  expect_equal(cols[["down"]], "#0072B2")
})

test_that("bad palettes give helpful errors", {
  expect_error(ggvolc(all_genes, palette = "nope"), "Unknown palette")
  expect_error(ggvolc(all_genes, palette = c(left = "red")), "named")
})

test_that("ltc palette objects can be passed as colors", {
  # mimics ltc::ltc("maya"), a character vector with class "ltc"
  pal <- structure(c("#3d5a80", "#98c1d9", "#e0fbfc", "#ee6c4d", "#293241"),
                   class = "ltc", name = "maya")
  cols <- attr(ggvolc(all_genes, palette = c(down = pal[1], up = pal[4])),
               "ggvolc_colors")
  expect_equal(cols[["up"]], unclass(pal)[4])
})

# ---- readable table colors ----------------------------------------------

test_that("readable_on_white darkens light colors and keeps dark ones", {
  expect_lt(contrast_on_white("#FFB000"), 4.5)
  expect_gte(contrast_on_white(readable_on_white("#FFB000")), 4.5)
  expect_equal(readable_on_white("#00798c"), "#00798c")
})

# ---- show_counts ----------------------------------------------------------

test_that("show_counts adds up/down counts matching the data", {
  p <- ggvolc(all_genes, show_counts = TRUE)
  txt <- Filter(function(l) inherits(l$geom, "GeomText"), p$layers)
  expect_length(txt, 2)
  sig <- all_genes$padj < 0.05
  expect_equal(txt[[1]]$data$n_down, sum(sig & all_genes$log2FoldChange < -1, na.rm = TRUE))
  expect_equal(txt[[1]]$data$n_up,   sum(sig & all_genes$log2FoldChange >  1, na.rm = TRUE))
})

# ---- highlight gene sets ------------------------------------------------

test_that("highlight colors gene sets with their own legend entries", {
  sets <- list(A = all_genes$genes[1:10], B = all_genes$genes[50:60])
  p <- ggvolc(all_genes, highlight = sets, highlight_colors = c("red", "blue"))
  expect_s3_class(p, "ggplot")
  set_rows <- rbind(p$layers[[2]]$data, p$layers[[3]]$data)
  expect_setequal(unique(set_rows$.ggvolc_col), c("A", "B"))
  expect_equal(nrow(set_rows), 21)
})

test_that("highlight validates input and warns on empty sets", {
  expect_error(ggvolc(all_genes, highlight = c("a", "b")), "named list")
  expect_warning(ggvolc(all_genes, highlight = list(none = "not_a_gene")),
                 "no genes of highlight set")
  expect_error(ggvolc(all_genes, highlight = list(A = "x", B = "y"),
                      highlight_colors = "red"), "one color per")
})

test_that("data2 can be a character vector of gene names", {
  p <- ggvolc(all_genes, c("GCR1", "HMG1"))
  lab <- Filter(function(l) inherits(l$geom, "GeomTextRepel"), p$layers)[[1]]
  expect_setequal(lab$data$genes, c("GCR1", "HMG1"))
})

# ---- several contrasts ------------------------------------------------------

test_that("a named list of results gives one panel per contrast", {
  res <- list(first = all_genes, second = edger_genes)
  p <- ggvolc(res, label_top = 3, show_counts = TRUE)
  expect_s3_class(p$facet, "FacetWrap")
  lab <- Filter(function(l) inherits(l$geom, "GeomTextRepel"), p$layers)[[1]]
  expect_equal(as.vector(table(lab$data$.contrast)), c(3, 3))
  txt <- Filter(function(l) inherits(l$geom, "GeomText"), p$layers)[[1]]
  expect_equal(nrow(txt$data), 2)
})

test_that("contrast lists need unique names", {
  expect_error(ggvolc(list(all_genes, all_genes)), "unique name")
  expect_error(ggvolc(list(a = all_genes, a = all_genes)), "unique name")
})

# ---- stress_timecourse & NA handling ------------------------------------

test_that("stress_timecourse plots as three panels", {
  expect_named(stress_timecourse, c("30 min vs 0 min", "60 min vs 0 min", "180 min vs 0 min"))
  p <- suppressMessages(ggvolc(stress_timecourse, label_top = 3, facet_scales = "free_y"))
  expect_s3_class(p$facet, "FacetWrap")
  lab <- Filter(function(l) inherits(l$geom, "GeomTextRepel"), p$layers)[[1]]
  expect_equal(as.vector(table(lab$data$.contrast)), c(3, 3, 3))
})

test_that("genes with NA padj are left out with a message, not a warning", {
  d <- stress_timecourse[["30 min vs 0 min"]]
  n_na <- sum(is.na(d$padj))
  expect_gt(n_na, 0)
  expect_message(p <- ggvolc(d), paste("left out", n_na))
  expect_no_warning(ggplot2::ggplot_build(p))
})

# ---- table layout -------------------------------------------------------

test_that("the gene table stretches to the plot panel and fits its rows", {
  gtab <- stretch_gtable(gt::as_gtable(gt::gt(head(all_genes[, 1:3]))))
  n <- length(gtab$widths)
  expect_true(all(grid::unitType(gtab$widths[2:(n - 1)]) == "null"))
  expect_true(all(grid::convertWidth(gtab$widths[c(1, n)], "pt", valueOnly = TRUE) == 0))

  g <- genes_table(ggvolc(all_genes), all_genes, top_n = 5)
  expect_equal(grid::unitType(g$patches$layout$heights), c("null", "cm"))
  expect_s3_class(genes_table(ggvolc(all_genes), all_genes, top_n = 5,
                              table_height = 1), "patchwork")
})

test_that("threshold lines follow each panel with a free y-axis", {
  p <- suppressMessages(ggvolc(stress_timecourse, add_seg = TRUE))
  seg <- Filter(function(l) inherits(l$geom, "GeomSegment"), p$layers)[[1]]$data
  expect_equal(nlevels(droplevels(seg$.contrast)), 3)
  tops <- tapply(seg$y.end, seg$.contrast, max)
  expect_gt(tops[[1]], tops[[3]])
})

# ---- flip ---------------------------------------------------------------

test_that("flip puts log2FC on the y-axis and significance on the x-axis", {
  p <- ggvolc(all_genes, label_top = 3, add_seg = TRUE, show_counts = TRUE, flip = TRUE)
  b <- ggplot2::ggplot_build(p)
  expect_equal(p$labels$y, "log2FoldChange")
  expect_equal(p$labels$x, "-log10(padj)")
  pts <- b$data[[1]]
  expect_true(all(pts$x >= 0))
  expect_true(any(pts$y < 0))
  seg <- Filter(function(l) inherits(l$geom, "GeomSegment"), p$layers)[[1]]$data
  expect_equal(seg$y.start[1:2], c(-1, 1))      # fold-change thresholds now horizontal
  expect_error(ggvolc(all_genes, flip = "yes"), "TRUE or FALSE")
})

test_that("flipped contrast panels free the significance (x) axis by default", {
  p <- suppressMessages(ggvolc(stress_timecourse, flip = TRUE))
  expect_true(p$facet$params$free$x)
  expect_false(p$facet$params$free$y)
  p2 <- suppressMessages(ggvolc(stress_timecourse))
  expect_true(p2$facet$params$free$y)
  p3 <- suppressMessages(ggvolc(stress_timecourse, flip = TRUE, facet_scales = "fixed"))
  expect_false(p3$facet$params$free$x)
})


test_that("highlight_alpha sets the transparency per gene set", {
  sets <- list(A = all_genes$genes[1:10], B = all_genes$genes[50:60])
  alpha_of <- function(p) unname(vapply(p$layers[2:3], function(l) l$aes_params$alpha, 1))
  expect_equal(alpha_of(ggvolc(all_genes, highlight = sets)), c(0.5, 0.5))
  expect_equal(alpha_of(ggvolc(all_genes, highlight = sets,
                               highlight_alpha = c(B = 0.2, A = 1))), c(1, 0.2))
  expect_equal(alpha_of(ggvolc(all_genes, highlight = sets,
                               highlight_alpha = 0.8)), c(0.8, 0.8))
  expect_error(ggvolc(all_genes, highlight = sets, highlight_alpha = 2), "between 0 and 1")
  expect_error(ggvolc(all_genes, highlight = sets, highlight_alpha = c(0.1, 0.2, 0.3)),
               "one per highlight set")
})
