#' Create a Volcano Plot
#'
#' This function creates a volcano plot using ggplot2 based on provided datasets.
#' It is particularly useful for visualizing differential gene expression data.
#'
#' Column names from DESeq2, edgeR, and limma are automatically detected and
#' mapped internally, so you can pass the output of any of the three pipelines
#' directly.
#'
#' @param data1 Data frame for the primary dataset. Accepts output from
#'   DESeq2 (\code{results()}), edgeR (\code{topTags()}), or limma
#'   (\code{topTable()}). Gene identifiers can live in a \code{genes} column
#'   or in the row names.
#' @param data2 Data frame for the secondary dataset (genes of interest).
#'   Uses the same auto-detection as \code{data1}. Default is NULL.
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
#' @param not_sig_color Color for non-significant genes. Default is "#808080".
#' @param down_reg_color Color for downregulated genes. Default is "#00798c".
#' @param up_reg_color Color for upregulated genes. Default is "#d1495b".
#' @param add_seg Logical. If TRUE, dashed lines will be added to the plot
#'   indicating the p-value and fold change thresholds. Default is FALSE.
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
#' \dontrun{
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
                   not_sig_color = "#808080",
                   down_reg_color = "#00798c",
                   up_reg_color = "#d1495b",
                   add_seg = FALSE){

  sig_col_explicit <- !missing(sig_col)
  sig_col   <- match.arg(sig_col)
  label_dir <- match.arg(label_dir)

  # ---- Validate input ---------------------------------------------------
  if (!is.data.frame(data1)) stop("data1 must be a data frame")
  if (!is.null(data2) && !is.data.frame(data2)) stop("data2 must be a data frame")
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
      "<b>%s</b><br/>log2FC: %.2f<br/>%s: %s",
      df$genes, df$log2FoldChange, sig_col,
      formatC(df[[sig_col]], format = "e", digits = 2))
    df
  }

  d1 <- prep(data1)

  # ---- Build the highlighted / labelled set -----------------------------
  att <- NULL
  if (!is.null(data2)) att <- prep(data2)
  if (!is.null(label_top)) {
    # most significant `n` rows of a candidate pool
    pick_top <- function(pool, n) {
      pool <- pool[order(pool[[sig_col]]), , drop = FALSE]
      pool[seq_len(min(n, nrow(pool))), , drop = FALSE]
    }
    up_pool   <- d1[d1$threshold == "s_upregulated",   , drop = FALSE]
    down_pool <- d1[d1$threshold == "s_downregulated", , drop = FALSE]
    all_pool  <- d1[d1$threshold != "not_significant",  , drop = FALSE]

    topn <- switch(label_dir,
      both = pick_top(all_pool,  label_top),
      up   = pick_top(up_pool,   label_top),
      down = pick_top(down_pool, label_top),
      each = dplyr::bind_rows(pick_top(up_pool,   label_top),
                              pick_top(down_pool, label_top))
    )
    att <- if (is.null(att)) topn else dplyr::bind_rows(att, topn)
  }
  if (!is.null(att) && nrow(att) > 0) {
    att <- att[!duplicated(att$genes), , drop = FALSE]
  } else {
    att <- NULL
  }

  # background points = everything not in the highlighted set
  bg <- if (is.null(att)) d1 else dplyr::anti_join(d1, att, by = "genes")

  color_mapping <- c("s_downregulated" = down_reg_color,
                     "not_significant" = not_sig_color,
                     "s_upregulated"   = up_reg_color)

  # ---- Point geom (interactive or static) -------------------------------
  geom_pt <- if (interactive) ggiraph::geom_point_interactive else ggplot2::geom_point

  if (interactive) {
    main_aes <- aes(x = log2FoldChange, y = .ggvolc_y, color = threshold,
                    size = size_aes, tooltip = .ggvolc_tip, data_id = genes)
  } else {
    main_aes <- aes(x = log2FoldChange, y = .ggvolc_y, color = threshold,
                    size = size_aes)
  }

  p <- ggplot2::ggplot(dplyr::arrange(bg, threshold)) +
    geom_pt(mapping = main_aes, shape = 16, alpha = 0.5) +
    ggplot2::theme_bw() +
    ggplot2::labs(title = title,
                  x = "log2FoldChange",
                  y = paste0("-log10(", sig_col, ")")) +
    ggplot2::scale_color_manual(
      values = color_mapping,
      name = "Genes",
      breaks = c("s_downregulated", "not_significant", "s_upregulated"),
      labels = c("Downregulated", "non-significant", "Upregulated")
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
    y_top <- 0.85 * max(d1$.ggvolc_y, na.rm = TRUE)
    expression_limits <- data.frame(
      x.start = c(-fc, fc, min(d1$log2FoldChange, na.rm = TRUE)),
      x.end   = c(-fc, fc, max(d1$log2FoldChange, na.rm = TRUE)),
      y.start = c(0, 0, -log10(p_value)),
      y.end   = c(y_top, y_top, -log10(p_value))
    )

    p <- p + ggplot2::geom_segment(data = expression_limits,
                                   aes(x = x.start, xend = x.end,
                                       y = y.start, yend = y.end),
                                   linetype = "dashed")
  }

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
