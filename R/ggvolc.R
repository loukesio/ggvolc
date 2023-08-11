#' Create a Volcano Plot
#'
#' This function creates a volcano plot using ggplot2 based on provided datasets.
#' It is particularly useful for visualizing differential gene expression data.
#'
#' @param data1 Data frame for the primary dataset.
#' @param data2 Data frame for the secondary dataset. Default is NULL.
#' @param size_var Variable for determining the size of points. Options are "log2FoldChange" and "pvalue". Default is "log2FoldChange".
#' @param p_value Threshold for statistical significance. Default is 0.05.
#' @param fc Fold change threshold for determining upregulated or downregulated genes. Default is 1.
#' @param not_sig_color Color for non-significant genes. Default is "grey82".
#' @param down_reg_color Color for downregulated genes. Default is "#00798c".
#' @param up_reg_color Color for upregulated genes. Default is "#d1495b".
#' @param add_seg Logical. If TRUE, dashed lines will be added to the plot indicating the p-value and fold change thresholds. Default is FALSE.
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
#' @return A ggplot2 object displaying the volcano plot.
#' @export
#' @examples
#' \dontrun{
#' # Assuming df1 and df2 are your data frames:
#' library(ggvolc)
#' ggvolc(df1, df2)
#' }
#'

ggvolc <- function(data1,
                   data2 = NULL,
                   size_var = NULL,  # Default value set to NULL
                   p_value = 0.05,
                   fc = 1,
                   not_sig_color = "grey82",
                   down_reg_color = "#00798c",
                   up_reg_color = "#d1495b",
                   add_seg = FALSE) {

  # Validate input
  if(!is.data.frame(data1)) stop("data1 must be a data frame")
  if(!is.null(data2) && !is.data.frame(data2)) stop("data2 must be a data frame")

  # Calculate the size aesthetic outside ggplot
  if(is.null(size_var)) {
    data1$size_aes <- 3  # Default size if size_var is NULL
    if(!is.null(data2)) data2$size_aes <- 3
    size_aes_range <- c(3, 3)
  } else if (size_var == "pvalue") {
    data1$size_aes <- abs(-log10(data1$pvalue))
    if(!is.null(data2)) data2$size_aes <- abs(-log10(data2$pvalue))
    size_aes_range <- c(0, 6)
  } else {
    data1$size_aes <- abs(data1[[size_var]])
    if(!is.null(data2)) data2$size_aes <- abs(data2[[size_var]])
    size_aes_range <- c(min(abs(data1[[size_var]])), max(abs(data1[[size_var]])))
  }

  dat1 <- data1 %>%
    dplyr::mutate(threshold = factor(case_when(
      pvalue < p_value & log2FoldChange > fc ~ "s_upregulated",
      pvalue < p_value & log2FoldChange < -fc ~ "s_downregulated",
      TRUE ~ "not_significant"
    ), levels = c("not_significant", "s_downregulated", "s_upregulated")))


  if (is.null(data2)) {
    dat1.2 <- dat1
  } else {
    dat1.2 <- dplyr::anti_join(dat1, data2, by="genes")
  }

  color_mapping <- c("s_downregulated" = down_reg_color,
                     "not_significant" = not_sig_color,
                     "s_upregulated" = up_reg_color)

  p <- ggplot2::ggplot(dplyr::arrange(dat1.2, threshold)) +
    ggplot2::geom_point(aes(x = log2FoldChange, y = -log10(pvalue), color = threshold, size = size_aes),
                        shape = 16, alpha = 0.5) +
    ggplot2::theme_bw() +
    ggplot2::labs(title = "Exploring data with ggvolc",
                  x = "log2FoldChange",
                  y = "-log10(pvalue)") +
    ggplot2::scale_color_manual(
      values = color_mapping,
      name = "Genes",
      breaks = c("s_downregulated", "not_significant", "s_upregulated"),
      labels = c("Downregulated", "non-significant", "Upregulated")
    )  +
    ggplot2::guides(color = ggplot2::guide_legend(override.aes = list(size = 5, alpha=1)))

  if (!is.null(data2)) {
    data2 <- data2 %>%
      dplyr::mutate(threshold = factor(case_when(
        pvalue < p_value & log2FoldChange > fc ~ "s_upregulated",
        pvalue < p_value & log2FoldChange < -fc ~ "s_downregulated",
        TRUE ~ "not_significant"
      ),levels = c("not_significant", "s_downregulated", "s_upregulated")))

    p <- p + ggplot2::geom_point(data = data2, aes(x = log2FoldChange, y = -log10(pvalue),
                                                   fill = threshold, size = size_aes),
                                 shape = 21, color = "black") +
      ggplot2::scale_fill_manual(
        values = color_mapping,
        name = "Genes",
        breaks = c("s_downregulated", "not_significant", "s_upregulated"),
        labels = c("Downregulated", "non-significant", "Upregulated"),
        guide = "none"
      )

    p <- p + ggrepel::geom_text_repel(data = data2,
                                      aes(x = log2FoldChange, y = -log10(pvalue),
                                          label = genes), color = "#333333", fontface="bold",
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
      panel.grid.major = ggplot2::element_line(color=NA),
      panel.border = ggplot2::element_rect(linewidth = 1, color="#333333"),
      legend.title = ggplot2::element_text(hjust=0.5, size=12),
      legend.text = ggplot2::element_text(size=10),
      plot.title = ggtext::element_markdown(color = "#333333", size = 18, face = "bold", margin = margin(0,0,0.5,0, unit = "cm"), hjust=0.5),
      plot.subtitle = ggtext::element_markdown(color = "grey30", size = 12, lineheight = 1.35, hjust=0.5),
      plot.caption = ggtext::element_markdown(color = "grey30", size = 10, lineheight = 1.35, hjust=0.5)
    )

  if (add_seg) {
    expression_limits <- data.frame(
      x.start = c(-fc, fc, min(data1$log2FoldChange, na.rm = TRUE)),
      x.end = c(-fc, fc, max(data1$log2FoldChange, na.rm = TRUE)),
      y.start = c(0, 0, -log10(p_value)),
      y.end = c(0.85 * max(-log10(data1$pvalue), na.rm = TRUE),
                0.85 * max(-log10(data1$pvalue), na.rm = TRUE),
                -log10(p_value))
    )

    p <- p + ggplot2::geom_segment(data = expression_limits,
                                   aes(x = x.start, xend = x.end,
                                       y = y.start, yend = y.end),
                                   linetype = "dashed")
  }

  return(p)
}

