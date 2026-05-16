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
#' @param p_value Significance threshold used for color-coding the p-value
#'   column. Default is 0.05.
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
genes_table <- function(plot_obj, data2, p_value = 0.05, table_height = 1) {

  # Check input
  if (!inherits(plot_obj, "gg")) stop("plot_obj must be a ggplot object", call. = FALSE)
  if (!is.data.frame(data2))    stop("data2 must be a data frame", call. = FALSE)

  # Standardize columns (so edgeR / limma tables work too)
  data2 <- standardize_de_columns(data2)

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
      columns = "pvalue",
      decimals = 2
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
      gt::fmt_scientific(columns = "padj", decimals = 2) |>
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
