#' Create a Volcano Plot
#'
#' This function creates a volcano plot using ggplot2 based on provided datasets.
#' It is particularly useful for visualizing differential gene expression data.
#'
#' You can pass the result objects of DESeq2, edgeR, and limma directly
#' (see \code{\link{de_table}}), or a data frame. Column names from all three
#' pipelines are detected and mapped automatically.
#'
#' @param data1 The DE results to plot: a data frame, or a DESeq2
#'   (\code{DESeqResults}, \code{DESeqDataSet}), edgeR (\code{TopTags},
#'   \code{DGELRT}, \code{DGEExact}) or limma (\code{MArrayLM}) object.
#'   Gene identifiers can live in a \code{genes} column or in the row names.
#'   To compare contrasts, pass a \emph{named list} of results, e.g.
#'   \code{list("Day 1" = res1, "Day 7" = res7)}: each becomes a panel on
#'   shared axes, and \code{label_top} and \code{show_counts} work per panel.
#' @param data2 Genes to highlight and label: a data frame or DE object (same
#'   auto-detection as \code{data1}), or simply a character vector of gene
#'   names. With a list in \code{data1}, the genes are highlighted in every
#'   panel. Default is NULL.
#' @param size_var Variable for determining the size of points. Options are
#'   \code{"log2FoldChange"} and \code{"pvalue"}. Default is NULL (fixed size).
#' @param p_value Threshold for statistical significance. Default is 0.05.
#' @param fc Fold change threshold for determining upregulated or downregulated
#'   genes. Default is 1.
#' @param sig_col Column used to call significance and to build the y-axis.
#'   Either \code{"padj"} (the adjusted p-value / FDR, the default and the
#'   recommended cutoff for calling hits in most DE workflows) or
#'   \code{"pvalue"} (the raw p-value). The y-axis and the significance segment
#'   follow this choice, so the plot stays internally consistent. When the
#'   default \code{"padj"} is used but the data has no adjusted-p column, ggvolc
#'   falls back to the raw p-value.
#' @param label_top Optional integer. When supplied, the \code{label_top} most
#'   significant genes (smallest \code{sig_col}, among significant genes) are
#'   highlighted and labelled automatically, without building a separate
#'   \code{data2}. Combined with \code{data2} if both are given. Default NULL.
#' @param label_dir Direction to draw the \code{label_top} genes from. One of
#'   \code{"both"} (top N over all significant genes, the default),
#'   \code{"up"} (top N upregulated), \code{"down"} (top N downregulated), or
#'   \code{"each"} (top N upregulated \emph{and} top N downregulated, i.e. up to
#'   2N labels). Ignored when \code{label_top} is NULL.
#' @param title Plot title. Default NULL (no title).
#' @param interactive Logical. If TRUE, returns an interactive \pkg{ggiraph}
#'   \code{girafe} widget where hovering a point reveals the gene name and its
#'   statistics. Requires the optional \pkg{ggiraph} package. Default FALSE.
#' @param palette Colors for the plot: a preset name (see
#'   \code{\link{ggvolc_palettes}}), such as \code{"default"},
#'   \code{"okabe_ito"} (colorblind-safe), or one of the ltc-derived presets,
#'   or a named vector such as \code{c(down = "navy", up = "firebrick")}.
#' @param not_sig_color,down_reg_color,up_reg_color Colors for
#'   non-significant, downregulated, and upregulated genes. When given, they
#'   override the matching color from \code{palette}. Default NULL.
#' @param add_seg Logical. If TRUE, dashed lines will be added to the plot
#'   indicating the p-value and fold change thresholds. Default is FALSE.
#' @param show_counts Logical. If TRUE, the number of significantly down- and
#'   upregulated genes is printed in the top corners of the plot (of each panel
#'   when comparing contrasts). Default FALSE.
#' @param highlight Optional named list of gene sets to color, e.g.
#'   \code{list(Ribosome = c("RPL3", "RPS2"), Glycolysis = c("PFK1", "PYK1"))}.
#'   Genes in a set are drawn in the set's color, whatever their significance,
#'   and each set gets a legend entry. A gene in several sets takes the first.
#' @param highlight_colors Optional colors for the \code{highlight} sets, in
#'   order or named by set. Defaults to colorblind-friendly Okabe-Ito hues.
#' @param facet_scales When comparing contrasts, which axes each panel may set
#'   for itself. The default \code{"free_y"} keeps the fold-change (x) axis
#'   shared, so effect sizes stay comparable, while each panel uses its full
#'   height for significance, so a weaker contrast is not squashed by a
#'   stronger one. Use \code{"fixed"} to share both axes, or \code{"free_x"}
#'   / \code{"free"}.
#' @param coef For a multi-coefficient limma fit, the coefficient to plot; for
#'   a \code{DESeqDataSet}, the result \code{name}. See \code{\link{de_table}}.
#'
#' @importFrom dplyr %>%
#' @importFrom ggplot2 aes
#' @importFrom dplyr case_when
#' @importFrom ggplot2 scale_size_continuous
#' @importFrom ggplot2 guides
#' @importFrom ggplot2 guide_legend
#' @importFrom ggplot2 theme_minimal
#' @importFrom ggplot2 margin
#'
#' @return A ggplot2 object displaying the volcano plot, or, when
#'   \code{interactive = TRUE}, a \pkg{ggiraph} \code{girafe} widget.
#' @export
#' @examples
#' # Load example datasets included in the package
#' data(all_genes)
#' data(attention_genes)
#'
#' # Create a basic volcano plot with default settings
#' # Points are colored by significance (p < 0.05, |log2FC| > 1)
#' ggvolc(all_genes)
#'
#' # Highlight specific genes of interest with labels
#' # These genes are shown with black borders and gene names
#' ggvolc(all_genes, attention_genes)
#'
#' \donttest{
#' # Add dashed lines to indicate significance thresholds
#' ggvolc(all_genes, attention_genes, add_seg = TRUE)
#'
#' # Significance is called on the adjusted p-value (FDR) by default;
#' # use the raw p-value instead with:
#' ggvolc(all_genes, sig_col = "pvalue")
#'
#' # Automatically label the 10 most significant genes
#' ggvolc(all_genes, label_top = 10)
#'
#' # Label the top 10 upregulated genes only
#' ggvolc(all_genes, label_top = 10, label_dir = "up")
#'
#' # Label the top 8 of each direction (up to 16 labels)
#' ggvolc(all_genes, label_top = 8, label_dir = "each")
#'
#' # Give the plot a title
#' ggvolc(all_genes, title = "Treated vs. control")
#'
#' # Show how many genes go up and down
#' ggvolc(all_genes, show_counts = TRUE)
#'
#' # Color gene sets, e.g. a pathway
#' ggvolc(all_genes, highlight = list(Set_A = all_genes$genes[1:15],
#'                                    Set_B = all_genes$genes[100:130]))
#'
#' # Compare contrasts side by side: a real stress time course
#' ggvolc(stress_timecourse, label_top = 5, show_counts = TRUE)
#'
#' # Share the y-axis too, to compare significance between panels
#' ggvolc(stress_timecourse, label_top = 5, facet_scales = "fixed")
#'
#' # Colorblind-safe colors, or any preset from ggvolc_palettes()
#' ggvolc(all_genes, label_top = 10, palette = "okabe_ito")
#'
#' # Customize colors for up- and down-regulated genes
#' ggvolc(all_genes, attention_genes,
#'        up_reg_color = "#E63946",
#'        down_reg_color = "#457B9D")
#'
#' # Scale point size by p-value instead of default
#' ggvolc(all_genes, attention_genes, size_var = "pvalue")
#'
#' # Adjust significance thresholds (p-value and fold change)
#' ggvolc(all_genes, p_value = 0.01, fc = 2)
#'
#' # edgeR-style input works directly
#' edger_df <- data.frame(
#'   genes = paste0("gene", 1:50),
#'   logFC = rnorm(50, 0, 2),
#'   logCPM = runif(50, 5, 15),
#'   PValue = 10^-runif(50, 0, 6),
#'   FDR = 10^-runif(50, 0, 5)
#' )
#' ggvolc(edger_df)
#'
#' # limma-style input works too
#' limma_df <- data.frame(
#'   genes = paste0("gene", 1:50),
#'   logFC = rnorm(50, 0, 2),
#'   AveExpr = runif(50, 5, 15),
#'   t = rnorm(50),
#'   P.Value = 10^-runif(50, 0, 6),
#'   adj.P.Val = 10^-runif(50, 0, 5)
#' )
#' ggvolc(limma_df)
#'
#' }
#'
#' \dontrun{
#' # DE objects work directly, no conversion needed
#' ggvolc(DESeq2::results(dds))
#' ggvolc(edgeR::glmQLFTest(qlf_fit, coef = 2))
#' ggvolc(limma::eBayes(limma_fit), coef = "treatment")
#'
#' # Interactive volcano (requires the ggiraph package): hover a point to
#' # see the gene name and its statistics
#' ggvolc(all_genes, attention_genes, interactive = TRUE)
#' }
#'
ggvolc <- function(data1,
                   data2 = NULL,
                   size_var = NULL,  # Default value set to NULL
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
                   facet_scales = c("free_y", "fixed", "free_x", "free"),
                   coef = NULL){

  sig_col_explicit <- !missing(sig_col)
  sig_col   <- match.arg(sig_col)
  label_dir <- match.arg(label_dir)
  facet_scales <- match.arg(facet_scales)

  # ---- Colors: palette preset, then explicit overrides ------------------
  cols <- resolve_palette(palette)
  if (!is.null(down_reg_color)) cols[["down"]]    <- down_reg_color
  if (!is.null(not_sig_color))  cols[["not_sig"]] <- not_sig_color
  if (!is.null(up_reg_color))   cols[["up"]]      <- up_reg_color

  # ---- Accept DE objects (DESeq2 / edgeR / limma) or data frames --------
  # A plain named list = several contrasts, one panel each
  multi <- identical(class(data1), "list")
  if (multi) {
    nms <- names(data1)
    if (is.null(nms) || any(nms == "") || anyDuplicated(nms)) {
      stop("To compare contrasts, data1 must be a list with a unique name per ",
           "element, e.g. list(\"Day 1\" = res1, \"Day 7\" = res7).", call. = FALSE)
    }
    data1 <- dplyr::bind_rows(lapply(nms, function(n) {
      d <- standardize_de_columns(de_table(data1[[n]], coef = coef))
      d$.contrast <- n
      d
    }))
    data1$.contrast <- factor(data1$.contrast, levels = nms)
  } else {
    data1 <- de_table(data1, coef = coef)
  }
  data2_genes <- NULL
  if (is.character(data2)) {
    data2_genes <- unique(data2)
    data2 <- NULL
  } else if (!is.null(data2)) {
    data2 <- de_table(data2, coef = coef)
  }

  # ---- Validate input ---------------------------------------------------
  if (!is.null(label_top) &&
      (!is.numeric(label_top) || length(label_top) != 1 || label_top < 1)) {
    stop("label_top must be a single positive number", call. = FALSE)
  }
  if (isTRUE(interactive) && !requireNamespace("ggiraph", quietly = TRUE)) {
    stop("interactive = TRUE requires the 'ggiraph' package.\n",
         "Install it with install.packages(\"ggiraph\").", call. = FALSE)
  }

  # ---- Standardize column names (DESeq2 / edgeR / limma) ----------------
  data1 <- standardize_de_columns(data1)
  if (!is.null(data2)) data2 <- standardize_de_columns(data2)
  # with several contrasts, highlight data2's genes in every panel
  if (multi && !is.null(data2)) {
    data2_genes <- unique(data2$genes)
    data2 <- NULL
  }
  if (!is.null(highlight)) {
    if (!is.list(highlight) || is.null(names(highlight)) ||
        any(names(highlight) == "") ||
        !all(vapply(highlight, is.character, NA))) {
      stop("highlight must be a named list of character vectors of gene names, ",
           "e.g. list(Ribosome = c(\"RPL3\", \"RPS2\")).", call. = FALSE)
    }
  }

  # Default is padj (FDR); fall back to the raw p-value when there is no
  # adjusted-p column and the user did not explicitly ask for padj.
  if (sig_col == "padj" && !"padj" %in% colnames(data1) && !sig_col_explicit) {
    message("ggvolc: no adjusted p-value (padj) column found; ",
            "using sig_col = 'pvalue' instead.")
    sig_col <- "pvalue"
  }

  if (!sig_col %in% colnames(data1)) {
    stop("sig_col = '", sig_col, "' is not available after column detection.\n",
         "Columns present: ", paste(colnames(data1), collapse = ", "),
         call. = FALSE)
  }
  if (!is.null(size_var) && !size_var %in% colnames(data1)) {
    stop("size_var = '", size_var, "' is not a column in the data.", call. = FALSE)
  }

  # ---- Drop genes without a test result --------------------------------
  # DESeq2 sets padj (and sometimes pvalue) to NA for low-count genes
  # (independent filtering) and count outliers; they cannot be placed.
  keep <- !is.na(data1[[sig_col]]) & !is.na(data1$log2FoldChange)
  if (!all(keep)) {
    message(sprintf(
      "ggvolc: left out %d gene(s) with NA %s or log2FoldChange (e.g. genes DESeq2 filtered as low-count or outliers).",
      sum(!keep), sig_col))
    data1 <- data1[keep, , drop = FALSE]
  }
  if (!is.null(data2) && sig_col %in% colnames(data2)) {
    data2 <- data2[!is.na(data2[[sig_col]]) & !is.na(data2$log2FoldChange), , drop = FALSE]
  }

  # ---- y-axis: -log10(sig_col) with p == 0 (Inf) capped -----------------
  y1 <- neglog10_cap(data1[[sig_col]])
  ceiling <- y1$ceiling
  if (y1$n_capped > 0) {
    message(sprintf(
      "ggvolc: %d gene(s) had %s == 0; -log10 was capped at %.1f so they stay on the plot.",
      y1$n_capped, sig_col, ceiling))
  }

  # size legend range
  if (is.null(size_var)) {
    size_aes_range <- c(3, 3)
  } else if (size_var == "pvalue") {
    size_aes_range <- c(0, 6)
  } else {
    size_aes_range <- c(min(abs(data1[[size_var]]), na.rm = TRUE),
                        max(abs(data1[[size_var]]), na.rm = TRUE))
  }

  # closure that adds all derived columns to a standardized data frame
  prep <- function(df) {
    df$.ggvolc_y <- neglog10_cap(df[[sig_col]], ceiling = ceiling)$value
    df$threshold <- factor(case_when(
      df[[sig_col]] < p_value & df$log2FoldChange >  fc ~ "s_upregulated",
      df[[sig_col]] < p_value & df$log2FoldChange < -fc ~ "s_downregulated",
      TRUE ~ "not_significant"
    ), levels = c("not_significant", "s_downregulated", "s_upregulated"))

    if (is.null(size_var)) {
      df$size_aes <- 3
    } else if (size_var == "pvalue") {
      sp <- -log10(df$pvalue)
      if (any(is.infinite(sp))) sp[is.infinite(sp)] <- ceiling
      df$size_aes <- abs(sp)
    } else {
      df$size_aes <- abs(df[[size_var]])
    }

    df$.ggvolc_tip <- sprintf(
      "<b>%s</b>%s<br/>log2FC: %.2f<br/>%s: %s",
      df$genes,
      if (multi) paste0(" (", df$.contrast, ")") else "",
      df$log2FoldChange, sig_col,
      formatC(df[[sig_col]], format = "e", digits = 2))
    df
  }

  d1 <- prep(data1)
  key_cols <- if (multi) c("genes", ".contrast") else "genes"

  # ---- Build the highlighted / labelled set -----------------------------
  att <- NULL
  if (!is.null(data2)) att <- prep(data2)
  if (!is.null(data2_genes)) {
    att <- d1[d1$genes %in% data2_genes, , drop = FALSE]
    if (nrow(att) == 0) warning("ggvolc: none of the genes in data2 were found.",
                                call. = FALSE)
  }
  if (!is.null(label_top)) {
    # most significant `n` rows of a candidate pool
    pick_top <- function(pool, n) {
      pool <- pool[order(pool[[sig_col]]), , drop = FALSE]
      pool[seq_len(min(n, nrow(pool))), , drop = FALSE]
    }
    top_of <- function(g) {
      up_pool   <- g[g$threshold == "s_upregulated",   , drop = FALSE]
      down_pool <- g[g$threshold == "s_downregulated", , drop = FALSE]
      all_pool  <- g[g$threshold != "not_significant",  , drop = FALSE]
      switch(label_dir,
        both = pick_top(all_pool,  label_top),
        up   = pick_top(up_pool,   label_top),
        down = pick_top(down_pool, label_top),
        each = dplyr::bind_rows(pick_top(up_pool,   label_top),
                                pick_top(down_pool, label_top))
      )
    }
    # with several contrasts, the top genes are picked in each panel
    topn <- if (multi) dplyr::bind_rows(lapply(split(d1, d1$.contrast), top_of))
            else top_of(d1)
    att <- if (is.null(att)) topn else dplyr::bind_rows(att, topn)
  }
  if (!is.null(att) && nrow(att) > 0) {
    att <- att[!duplicated(att[, key_cols, drop = FALSE]), , drop = FALSE]
  } else {
    att <- NULL
  }

  # background points = everything not in the highlighted set
  bg <- if (is.null(att)) d1 else dplyr::anti_join(d1, att, by = key_cols)

  color_mapping <- c("s_downregulated" = cols[["down"]],
                     "not_significant" = cols[["not_sig"]],
                     "s_upregulated"   = cols[["up"]])
  color_breaks <- c("s_downregulated", "not_significant", "s_upregulated")
  color_labels <- c("Downregulated", "non-significant", "Upregulated")

  # ---- Gene sets: their own color and legend entry ----------------------
  bg$.ggvolc_col <- as.character(bg$threshold)
  set_pts <- NULL
  if (!is.null(highlight)) {
    set_names <- names(highlight)
    set_cols  <- highlight_set_colors(set_names, highlight_colors)
    member <- rep(NA_character_, nrow(bg))
    for (s in set_names) {
      hit <- is.na(member) & bg$genes %in% highlight[[s]]
      member[hit] <- s
      if (!any(d1$genes %in% highlight[[s]])) {
        warning("ggvolc: no genes of highlight set '", s, "' were found.",
                call. = FALSE)
      }
    }
    set_pts <- bg[!is.na(member), , drop = FALSE]
    set_pts$.ggvolc_col <- member[!is.na(member)]
    bg <- bg[is.na(member), , drop = FALSE]
    color_mapping <- c(color_mapping, set_cols)
    color_breaks  <- c(color_breaks, set_names)
    color_labels  <- c(color_labels, set_names)
  }

  # ---- Point geom (interactive or static) -------------------------------
  geom_pt <- if (interactive) ggiraph::geom_point_interactive else ggplot2::geom_point

  if (interactive) {
    main_aes <- aes(x = log2FoldChange, y = .ggvolc_y, color = .ggvolc_col,
                    size = size_aes, tooltip = .ggvolc_tip, data_id = genes)
  } else {
    main_aes <- aes(x = log2FoldChange, y = .ggvolc_y, color = .ggvolc_col,
                    size = size_aes)
  }

  p <- ggplot2::ggplot(dplyr::arrange(bg, threshold)) +
    geom_pt(mapping = main_aes, shape = 16, alpha = 0.5) +
    (if (!is.null(set_pts))
      geom_pt(data = set_pts, mapping = main_aes, shape = 16, alpha = 0.9)) +
    ggplot2::theme_bw() +
    ggplot2::labs(title = title,
                  x = "log2FoldChange",
                  y = paste0("-log10(", sig_col, ")")) +
    ggplot2::scale_color_manual(
      values = color_mapping,
      name = "Genes",
      breaks = color_breaks,
      labels = color_labels
    )  +
    ggplot2::guides(color = ggplot2::guide_legend(override.aes = list(size = 5, alpha = 1)))

  if (!is.null(att)) {
    if (interactive) {
      att_aes <- aes(x = log2FoldChange, y = .ggvolc_y, fill = threshold,
                     size = size_aes, tooltip = .ggvolc_tip, data_id = genes)
    } else {
      att_aes <- aes(x = log2FoldChange, y = .ggvolc_y, fill = threshold,
                     size = size_aes)
    }

    p <- p + geom_pt(data = att, mapping = att_aes, shape = 21, color = "black") +
      ggplot2::scale_fill_manual(
        values = color_mapping,
        name = "Genes",
        breaks = c("s_downregulated", "not_significant", "s_upregulated"),
        labels = c("Downregulated", "non-significant", "Upregulated"),
        guide = "none"
      )

    p <- p + ggrepel::geom_text_repel(data = att,
                                      aes(x = log2FoldChange, y = .ggvolc_y,
                                          label = genes), color = "#333333", fontface = "bold",
                                      segment.curvature = -0.4,
                                      segment.alpha = 0.5)
  }

  if (is.null(size_var)) {
    p <- p + scale_size_continuous(guide = "none")  # No legend for size when size_var is NULL
  } else {
    size_legend_name <- ifelse(size_var == "log2FoldChange", "log2FoldChange", "-log10(pvalue)")
    p <- p + scale_size_continuous(name = size_legend_name,
                                   range = size_aes_range) +
      guides(size = guide_legend(override.aes = list(shape = 21, fill = NA)))
  }

  p <- p +
    ggplot2::theme_bw() +
    ggplot2::theme(
      axis.text = ggplot2::element_text(size=14),
      axis.text.x = ggplot2::element_text(margin = margin(t = 2.5, r =0, b = 0, l = 0)),
      axis.text.y = ggplot2::element_text(margin = margin(t = 0, r =2.5, b = 0, l = 0)),
      axis.ticks.length.x = grid::unit(0.25,"cm"),
      axis.ticks.length.y = grid::unit(0.25,"cm"),
      axis.ticks = ggplot2::element_line(color = "#333333", linewidth= .5),
      axis.title = ggplot2::element_text(size=15),
      panel.grid.major = ggplot2::element_line(color="grey93"),
      panel.grid.minor =ggplot2::element_line(color=NA),
      panel.border = ggplot2::element_rect(linewidth = 1, color="#333333"),
      legend.title = ggplot2::element_text(hjust=0.5, size=12),
      legend.text = ggplot2::element_text(size=10),
      plot.title = ggtext::element_markdown(color = "#333333", size = 18, face = "bold", margin = margin(0,0,0.5,0, unit = "cm"), hjust=0.5),
      plot.subtitle = ggtext::element_markdown(color = "grey30", size = 12, lineheight = 1.35, hjust=0.5),
      plot.caption = ggtext::element_markdown(color = "grey30", size = 10, lineheight = 1.35, hjust=0.5)
    )

  if (add_seg) {
    seg_of <- function(g) {
      y_top <- 0.85 * max(g$.ggvolc_y, na.rm = TRUE)
      data.frame(
        x.start = c(-fc, fc, min(g$log2FoldChange, na.rm = TRUE)),
        x.end   = c(-fc, fc, max(g$log2FoldChange, na.rm = TRUE)),
        y.start = c(0, 0, -log10(p_value)),
        y.end   = c(y_top, y_top, -log10(p_value))
      )
    }
    # with a free y-axis the lines follow each panel's own height
    if (multi && facet_scales %in% c("free_y", "free")) {
      parts <- split(d1, d1$.contrast)
      expression_limits <- do.call(rbind, lapply(names(parts), function(n) {
        s <- seg_of(parts[[n]])
        s$.contrast <- factor(n, levels = levels(d1$.contrast))
        s
      }))
    } else {
      expression_limits <- seg_of(d1)
    }

    p <- p + ggplot2::geom_segment(data = expression_limits,
                                   aes(x = x.start, xend = x.end,
                                       y = y.start, yend = y.end),
                                   linetype = "dashed")
  }

  if (isTRUE(show_counts)) {
    count_of <- function(g) data.frame(
      n_down = sum(g$threshold == "s_downregulated"),
      n_up   = sum(g$threshold == "s_upregulated"))
    counts <- if (multi) {
      cl <- lapply(split(d1, d1$.contrast), count_of)
      out <- do.call(rbind, cl)
      out$.contrast <- factor(names(cl), levels = levels(d1$.contrast))
      out
    } else count_of(d1)
    counts$down_lab <- paste(counts$n_down, "down")
    counts$up_lab   <- paste(counts$n_up, "up")

    p <- p +
      ggplot2::geom_text(data = counts, aes(x = -Inf, y = Inf, label = down_lab),
                         hjust = -0.15, vjust = 1.6, size = 4.2, fontface = "bold",
                         color = readable_on_white(cols[["down"]]),
                         inherit.aes = FALSE) +
      ggplot2::geom_text(data = counts, aes(x = Inf, y = Inf, label = up_lab),
                         hjust = 1.15, vjust = 1.6, size = 4.2, fontface = "bold",
                         color = readable_on_white(cols[["up"]]),
                         inherit.aes = FALSE) +
      ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0.05, 0.12)))
  }

  if (multi) {
    p <- p +
      ggplot2::facet_wrap(ggplot2::vars(.contrast), scales = facet_scales) +
      ggplot2::theme(
        strip.background = ggplot2::element_blank(),
        strip.text = ggplot2::element_text(size = 14, face = "bold", color = "#333333",
                                           margin = margin(t = 0, r = 0, b = 6, l = 0)))
  }

  # remembered so genes_table() can color the table to match
  attr(p, "ggvolc_colors") <- cols

  if (interactive) {
    return(ggiraph::girafe(
      ggobj = p,
      options = list(
        ggiraph::opts_hover(css = "stroke:#333333;stroke-width:1.5px;"),
        ggiraph::opts_tooltip(
          css = paste0("background:#333333;color:#ffffff;padding:6px 8px;",
                       "border-radius:4px;font-size:12px;"))
      )
    ))
  }

  return(p)
}
