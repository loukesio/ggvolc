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
