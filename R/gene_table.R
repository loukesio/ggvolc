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
#' @return A gridExtra object showing the ggplot stacked above a table of gene details.
#' @export
#'
#' @examples
#' \dontrun{
#' plot <- ggplot2::qplot(1:10, 1:10) # replace this with your ggvolc function call
#' data_example <- data.frame(genes = letters[1:10],
#'                            baseMean = rnorm(10),
#'                            log2FoldChange = rnorm(10),
#'                            pvalue = runif(10),
#'                            padj = runif(10))
#' plot %>%
#'   genes_table(data2 = data_example)
#' }
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

  combined_plot <- plot_obj / attention.genes.tbl
  return(combined_plot)
}
