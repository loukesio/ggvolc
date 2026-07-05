#' Detect DE source and standardize column names
#'
#' Inspects column names of a data frame and maps them to the internal
#' ggvolc convention: \code{genes}, \code{log2FoldChange}, \code{pvalue},
#' \code{padj}, \code{baseMean}.
#'
#' Recognized formats:
#' \describe{
#'   \item{DESeq2}{\code{log2FoldChange}, \code{pvalue}, \code{padj}, \code{baseMean}}
#'   \item{edgeR}{\code{logFC}, \code{PValue}, \code{FDR}, \code{logCPM}}
#'   \item{limma}{\code{logFC}, \code{P.Value}, \code{adj.P.Val}, \code{AveExpr}}
#' }
#'
#' @param df A data frame from a DE analysis pipeline.
#' @return A data frame with standardized column names.
#' @keywords internal
standardize_de_columns <- function(df) {

  cols <- colnames(df)

  # ---- gene identifier --------------------------------------------------

  # If genes are stored as rownames (common in edgeR/limma), promote them
  if (!"genes" %in% cols) {
    if (!is.null(rownames(df)) && !all(rownames(df) == seq_len(nrow(df)))) {
      df$genes <- rownames(df)
      rownames(df) <- NULL
    } else {
      stop(
        "Cannot find a 'genes' column and rownames are not informative.\n",
        "Please add a 'genes' column with gene identifiers.",
        call. = FALSE
      )
    }
  }

  cols <- colnames(df)

  # ---- detect source ----------------------------------------------------
  source <- detect_de_source(cols)

  if (source == "deseq2") {
    return(df)
  }


  # Column maps: from → to (internal name)
  edger_map <- c(
    logFC         = "log2FoldChange",
    PValue        = "pvalue",
    FDR           = "padj",
    logCPM        = "baseMean"
  )

  limma_map <- c(
    logFC         = "log2FoldChange",
    P.Value       = "pvalue",
    adj.P.Val     = "padj",
    AveExpr       = "baseMean"
  )

  col_map <- if (source == "edger") edger_map else limma_map

  for (from in names(col_map)) {
    to <- col_map[[from]]
    if (from %in% cols) {
      colnames(df)[colnames(df) == from] <- to
    }
  }

  # Verify we have all required columns after mapping
  required <- c("genes", "log2FoldChange", "pvalue")
  missing <- setdiff(required, colnames(df))
  if (length(missing) > 0) {
    stop(
      "After column mapping (source: ", source, "), still missing: ",
      paste(missing, collapse = ", "), ".\n",
      "Columns present: ", paste(colnames(df), collapse = ", "),
      call. = FALSE
    )
  }

  df
}


#' Detect DE pipeline from column names
#'
#' @param cols Character vector of column names.
#' @return One of \code{"deseq2"}, \code{"edger"}, \code{"limma"}, or
#'   errors if unrecognized.
#' @keywords internal
detect_de_source <- function(cols) {

  # DESeq2 signature
  if (all(c("log2FoldChange", "pvalue") %in% cols)) {
    return("deseq2")
  }

  # edgeR signature: logFC + PValue
  if (all(c("logFC", "PValue") %in% cols)) {
    return("edger")
  }

  # limma signature: logFC + P.Value
  if (all(c("logFC", "P.Value") %in% cols)) {
    return("limma")
  }

  stop(
    "Column names don't match DESeq2, edgeR, or limma output.\n",
    "Expected one of:\n",
    "  DESeq2: log2FoldChange, pvalue, padj, baseMean\n",
    "  edgeR:  logFC, PValue, FDR, logCPM\n",
    "  limma:  logFC, P.Value, adj.P.Val, AveExpr\n",
    "Found: ", paste(cols, collapse = ", "),
    call. = FALSE
  )
}


#' Compute -log10(p) with infinite values capped
#'
#' \code{-log10()} of a p-value of exactly 0 (which DESeq2 and edgeR can emit
#' through floating-point underflow for the strongest genes) is \code{Inf}, and
#' ggplot2 silently drops non-finite values. That would make the most
#' significant genes disappear from the plot. This helper replaces the infinite
#' values with a finite ceiling so those genes stay on the plot, near the top.
#'
#' @param p Numeric vector of p-values.
#' @param ceiling Optional finite value used for capping. When \code{NULL} it is
#'   set to 1.05 times the largest finite \code{-log10(p)}. Pass an explicit
#'   value to keep two datasets (e.g. background and highlighted genes) on the
#'   same scale.
#' @return A list with \code{value} (the capped \code{-log10(p)} vector),
#'   \code{ceiling} (the cap used), and \code{n_capped} (how many values were
#'   replaced).
#' @keywords internal
neglog10_cap <- function(p, ceiling = NULL) {
  nl <- -log10(p)
  inf_idx <- is.infinite(nl)

  if (is.null(ceiling)) {
    finite_max <- suppressWarnings(max(nl[is.finite(nl)], na.rm = TRUE))
    ceiling <- if (is.finite(finite_max) && finite_max > 0) finite_max * 1.05 else 1
  }

  nl[inf_idx] <- ceiling
  list(value = nl, ceiling = ceiling, n_capped = sum(inf_idx, na.rm = TRUE))
}
