#' Combine a ggplot Object with a Table of Genes
#'
#' This function takes a ggplot object and a data frame of gene details and
#' produces a combined plot where the ggplot object is stacked above a table of
#' gene details.
#'
#' @param plot_obj A ggplot object, typically the output of a plotting function.
#' @param data2 A data frame containing gene details. It should have columns named
#'   "genes", "baseMean", "log2FoldChange", "pvalue", and "padj".
#'
#' @return A gtable object showing the ggplot stacked above a table of gene details.
#' @export
#'
#' @examples
#' # Load example datasets
#' data(all_genes)
#' data(attention_genes)
#'
#' # Create a volcano plot highlighting genes of interest
#' plot <- ggvolc(all_genes, attention_genes, add_seg = TRUE)
#'
#' # Combine the plot with a table showing gene statistics
#' # The table includes: gene names, baseMean, log2FoldChange, pvalue, and padj
#' genes_table(plot, attention_genes)
#'
genes_table <- function(plot_obj, data2) {
  # Check if the provided object is a ggplot
  if (!inherits(plot_obj, "gg")) stop("Input must be a ggplot object")

  # Select specific columns
  selected_data <- data2[, c("genes", "baseMean", "log2FoldChange", "pvalue", "padj"), drop = FALSE]

  # Define a custom theme for the table
  custom_theme <- gridExtra::ttheme_default(
    core = list(bg_params = list(fill = "white")),
    colhead = list(
      fg_params = list(col = "black"),
      bg_params = list(fill = "white", col = "#333333", lwd = 1)
    )
  )

  # Create the tableGrob with the custom theme
  attention.genes.tbl <- gridExtra::tableGrob(selected_data, rows = NULL, theme = custom_theme)

  # Combine plot and table using grid.arrange
  combined_plot <- gridExtra::grid.arrange(plot_obj, attention.genes.tbl,
                                           ncol = 1,
                                           heights = c(3, 1))
  return(combined_plot)
}
