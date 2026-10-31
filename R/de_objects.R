#' Turn a DE result object into a plain data frame
#'
#' Converts the result objects returned by the three major differential
#' expression pipelines into a plain \code{data.frame} that \code{\link{ggvolc}}
#' and \code{\link{genes_table}} understand. You rarely need to call this
#' yourself: both functions call it internally, so you can pass the objects
#' straight in. It is exported for when you want to inspect or filter the
#' table first.
#'
#' Supported inputs:
#' \describe{
#'   \item{DESeq2}{A \code{DESeqResults} object from \code{DESeq2::results()}
#'     or \code{DESeq2::lfcShrink()}, or a \code{DESeqDataSet} after
#'     \code{DESeq2::DESeq()}, in which case \code{DESeq2::results()} is called
#'     for you (with \code{name = coef} when \code{coef} is given).}
#'   \item{edgeR}{A \code{TopTags} object from \code{edgeR::topTags()}, or a
#'     \code{DGELRT} / \code{DGEExact} object from \code{edgeR::glmQLFTest()},
#'     \code{edgeR::glmLRT()} or \code{edgeR::exactTest()}. All genes are kept
#'     (\code{edgeR::topTags(x, n = Inf)}).}
#'   \item{limma}{An \code{MArrayLM} fit after \code{limma::eBayes()}.
#'     \code{limma::topTable(fit, coef = coef, number = Inf)} is called for
#'     you. If the fit has more than one coefficient, \code{coef} is
#'     required.}
#'   \item{data frame}{Any \code{data.frame} (including tibbles) is returned
#'     unchanged.}
#' }
#'
#' @param x A DE result object or a data frame (see Details).
#' @param coef For a multi-coefficient limma fit, the coefficient (name or
#'   index) to extract. For a \code{DESeqDataSet}, passed as \code{name} to
#'   \code{DESeq2::results()}. Ignored otherwise.
#' @return A \code{data.frame} with one row per gene. Gene identifiers are kept
#'   in the row names (or a \code{genes} column, if the input had one).
#' @export
#' @examples
#' # A data frame passes straight through
#' head(de_table(all_genes))
#'
#' \dontrun{
#' # DESeq2
#' dds <- DESeq2::DESeq(dds)
#' ggvolc(DESeq2::results(dds))       # results object
#' ggvolc(dds)                        # or the dataset itself
#'
#' # edgeR
#' fit <- edgeR::glmQLFit(y, design)
#' ggvolc(edgeR::glmQLFTest(fit, coef = 2))
#'
#' # limma
#' fit <- limma::eBayes(limma::lmFit(v, design))
#' ggvolc(fit, coef = "treatment")
#' }
de_table <- function(x, coef = NULL) {

  if (is.data.frame(x)) return(x)

  # ---- DESeq2 -----------------------------------------------------------
  if (methods::is(x, "DESeqDataSet")) {
    need_pkg("DESeq2", "a DESeqDataSet")
    res <- if (is.null(coef)) DESeq2::results(x) else DESeq2::results(x, name = coef)
    return(as.data.frame(res))
  }
  # DESeqResults extends S4Vectors::DataFrame
  if (methods::is(x, "DataFrame")) {
    return(as.data.frame(x))
  }

  # ---- edgeR ------------------------------------------------------------
  if (methods::is(x, "TopTags")) {
    return(as.data.frame(x$table))
  }
  if (methods::is(x, "DGELRT") || methods::is(x, "DGEExact")) {
    need_pkg("edgeR", paste0("a ", class(x)[1], " object"))
    return(as.data.frame(edgeR::topTags(x, n = Inf, sort.by = "none")$table))
  }
  if (methods::is(x, "DGEList")) {
    stop("A DGEList holds counts, not test results.\n",
         "Run a test first, e.g. edgeR::glmQLFTest(edgeR::glmQLFit(y, design), coef = 2), ",
         "and pass that to ggvolc().", call. = FALSE)
  }

  # ---- limma ------------------------------------------------------------
  if (methods::is(x, "MArrayLM")) {
    need_pkg("limma", "an MArrayLM fit")
    if (is.null(x$p.value)) {
      stop("This limma fit has no p-values. Run limma::eBayes(fit) first.",
           call. = FALSE)
    }
    coefs <- colnames(x$coefficients)
    if (is.null(coef)) {
      if (length(coefs) > 1) {
        stop("This limma fit has ", length(coefs), " coefficients; ",
             "choose one with `coef`.\n",
             "Available: ", paste(coefs, collapse = ", "), call. = FALSE)
      }
      coef <- 1
    }
    return(limma::topTable(x, coef = coef, number = Inf, sort.by = "none"))
  }

  stop("Don't know how to read an object of class '", class(x)[1], "'.\n",
       "ggvolc accepts a data frame, or DESeqResults / DESeqDataSet (DESeq2), ",
       "TopTags / DGELRT / DGEExact (edgeR), or MArrayLM (limma).",
       call. = FALSE)
}


#' Stop with an install hint if a suggested package is missing
#' @keywords internal
#' @noRd
need_pkg <- function(pkg, what) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop("Reading ", what, " requires the '", pkg, "' package.\n",
         "Install it with BiocManager::install(\"", pkg, "\").", call. = FALSE)
  }
}
