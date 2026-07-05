#' Combine a Volcano Plot with a gt Table of Genes
#'
#' Takes a ggplot object (typically from \code{\link{ggvolc}}) and a data frame
#' of gene details and produces a combined layout using \pkg{patchwork}.
#' The gene table is rendered as a polished \pkg{gt} table with color-coded
#' significance and formatted numeric columns.
#'
#' @param plot_obj A ggplot object, typically the output of \code{\link{ggvolc}}.
#' @param data2 A data frame containing gene details.
#'   Columns are auto-detected in the same way as \code{\link{ggvolc}} (DESeq2,
#'   edgeR, or limma conventions). Required columns after mapping:
#'   \code{genes}, \code{log2FoldChange}, \code{pvalue}.
#'   Optional: \code{baseMean}, \code{padj}.
#'   When \code{top_n} is supplied you can pass the full DE table here (e.g.
#'   \code{all_genes}) and the most significant genes are selected automatically.
#' @param top_n Optional integer. When supplied, the \code{top_n} most
#'   significant genes (smallest \code{sig_col}, among genes with
#'   \code{sig_col < p_value}) are selected from \code{data2} for the table.
#'   When \code{NULL} (default) every row of \code{data2} is shown, so passing a
#'   pre-filtered set such as \code{attention_genes} behaves as before.
#' @param sig_col Column used to rank significance when \code{top_n} is set.
#'   Either \code{"padj"} (adjusted p-value / FDR, the default) or
#'   \code{"pvalue"}. Falls back to \code{"pvalue"} when \code{"padj"} is the
#'   default but no adjusted-p column is present.
#' @param dir Direction to draw the \code{top_n} genes from. One of
#'   \code{"both"} (top N over all significant genes, the default),
#'   \code{"up"} (top N upregulated), \code{"down"} (top N downregulated), or
#'   \code{"each"} (top N up \emph{and} top N down, up to \code{2 * top_n} rows).
#'   Ignored when \code{top_n} is \code{NULL}.
#' @param p_value Significance threshold used for color-coding the p-value
#'   column, and for filtering eligible genes when \code{top_n} is set.
#'   Default is 0.05.
#' @param table_height Relative height of the table panel (plot panel is always 3).
#'   Default is 1.
#'
#' @return A \code{patchwork} object that can be further composed or saved with
#'   \code{ggplot2::ggsave()}.
#' @export
#'
#' @examples
#' # Load example datasets
#' data(all_genes)
#' data(attention_genes)
#'
#' # Create a volcano plot and combine it with a gt gene table
#' p <- ggvolc(all_genes, attention_genes, add_seg = TRUE)
#' genes_table(p, attention_genes)
#'
#' # Auto-select the 10 most significant genes from the full table
#' p2 <- ggvolc(all_genes, label_top = 10)
#' genes_table(p2, all_genes, top_n = 10)
#'
#' # Top 8 of each direction (up to 16 rows)
#' genes_table(p2, all_genes, top_n = 8, dir = "each")
#'
genes_table <- function(plot_obj, data2,
                        top_n        = NULL,
                        sig_col      = c("padj", "pvalue"),
                        dir          = c("both", "up", "down", "each"),
                        p_value      = 0.05,
                        table_height = 1) {

  sig_col_explicit <- !missing(sig_col)
  sig_col <- match.arg(sig_col)
  dir     <- match.arg(dir)

  # Check input
  if (!inherits(plot_obj, "gg")) stop("plot_obj must be a ggplot object", call. = FALSE)
  if (!is.data.frame(data2))    stop("data2 must be a data frame", call. = FALSE)
  if (!is.null(top_n) &&
      (!is.numeric(top_n) || length(top_n) != 1 || top_n < 1)) {
    stop("top_n must be a single positive number", call. = FALSE)
  }

  # Standardize columns (so edgeR / limma tables work too)
  data2 <- standardize_de_columns(data2)

  # Auto-select the most significant genes when top_n is requested
  if (!is.null(top_n)) {
    # Default is padj (FDR); fall back to the raw p-value when there is no
    # adjusted-p column and the user did not explicitly ask for padj.
    if (sig_col == "padj" && !"padj" %in% colnames(data2) && !sig_col_explicit) {
      message("genes_table: no adjusted p-value (padj) column found; ",
              "using sig_col = 'pvalue' instead.")
      sig_col <- "pvalue"
    }
    data2 <- select_top_genes(data2, top_n = top_n, sig_col = sig_col,
                              dir = dir, p_value = p_value)
    if (nrow(data2) == 0) {
      warning("genes_table: no genes passed the significance threshold; ",
              "returning the plot without a table.", call. = FALSE)
      return(plot_obj)
    }
  }

  # Select columns that exist
  show_cols <- c("genes", "baseMean", "log2FoldChange", "pvalue", "padj")
  show_cols <- intersect(show_cols, colnames(data2))
  selected_data <- data2[, show_cols, drop = FALSE]

  # Build gt table
  tbl <- gt::gt(selected_data) |>
    gt::cols_label(
      genes           = "Gene",
      log2FoldChange  = "log2FC",
      pvalue          = "p-value"
    ) |>
    gt::fmt_number(
      columns  = "log2FoldChange",
      decimals = 2
    ) |>
    gt::fmt_scientific(
      columns   = "pvalue",
      decimals  = 2,
      exp_style = "e"   # grid-safe: patchwork renders the table as a graphic,
                        # where gt's superscript x10^n markup is not interpreted
    ) |>
    gt::tab_style(
      style     = gt::cell_text(weight = "bold"),
      locations = gt::cells_column_labels()
    ) |>
    gt::tab_options(
      table.font.size   = "12px",
      data_row.padding   = gt::px(4),
      column_labels.padding = gt::px(6),
      table.border.top.style    = "solid",
      table.border.bottom.style = "solid"
    )

  # Conditional formatting for optional columns
  if ("baseMean" %in% show_cols) {
    tbl <- tbl |>
      gt::cols_label(baseMean = "baseMean") |>
      gt::fmt_number(columns = "baseMean", decimals = 1)
  }

  if ("padj" %in% show_cols) {
    tbl <- tbl |>
      gt::cols_label(padj = "p-adj") |>
      gt::fmt_scientific(columns = "padj", decimals = 2, exp_style = "e") |>
      gt::tab_style(
        style     = gt::cell_fill(color = "#fce4ec"),
        locations = gt::cells_body(
          columns = "padj",
          rows    = selected_data$padj < p_value
        )
      )
  }

  # Color-code p-value cells
  tbl <- tbl |>
    gt::tab_style(
      style     = gt::cell_fill(color = "#fce4ec"),
      locations = gt::cells_body(
        columns = "pvalue",
        rows    = selected_data$pvalue < p_value
      )
    )

  # Highlight direction via log2FC color
  if (nrow(selected_data) > 0) {
    up_rows   <- which(selected_data$log2FoldChange > 0)
    down_rows <- which(selected_data$log2FoldChange < 0)

    if (length(up_rows) > 0) {
      tbl <- tbl |>
        gt::tab_style(
          style     = gt::cell_text(color = "#d1495b"),
          locations = gt::cells_body(columns = "log2FoldChange", rows = up_rows)
        )
    }
    if (length(down_rows) > 0) {
      tbl <- tbl |>
        gt::tab_style(
          style     = gt::cell_text(color = "#00798c"),
          locations = gt::cells_body(columns = "log2FoldChange", rows = down_rows)
        )
    }
  }

  # Compose with patchwork
  combined <- plot_obj + patchwork::wrap_table(tbl) +
    patchwork::plot_layout(ncol = 1, heights = c(3, table_height))

  combined
}
