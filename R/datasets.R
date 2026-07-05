#' Gene Expression Analysis Dataset
#'
#' A dataset containing gene expression analysis results.
#' It has seven columns capturing various statistics related to gene expression.
#'
#' @format A data frame with the following columns:
#' \describe{
#'   \item{genes}{Character. Gene name or identifier.}
#'   \item{baseMean}{Numeric. The base mean value for the gene across samples.}
#'   \item{log2FoldChange}{Numeric. The log2 fold change of gene expression. Positive values indicate upregulation and negative values indicate downregulation.}
#'   \item{lfcSE}{Numeric. Standard error of the log2 fold change.}
#'   \item{stat}{Numeric. The Wald statistic for the gene's expression change.}
#'   \item{pvalue}{Numeric. Raw p-value for the test of the gene's expression change.}
#'   \item{padj}{Numeric. Adjusted p-value for multiple testing corrections.}
#' }
"all_genes"


#' Attention Genes Dataset
#'
#' A dataset containing specific genes of interest referred to as "attention genes".
#'
#' @format A data frame with 10 rows and 7 variables:
#' \describe{
#'   \item{genes}{Character. Gene name or identifier.}
#'   \item{baseMean}{Numeric vector: Base mean expression level of genes}
#'   \item{log2FoldChange}{Numeric vector: Log2 Fold Change of gene expression}
#'   \item{lfcSE}{Numeric vector: Standard error for log2 fold change}
#'   \item{stat}{Numeric vector: Wald statistic for the gene's expression change}
#'   \item{pvalue}{Numeric vector: Raw p-value from Wald test}
#'   \item{padj}{Numeric vector: Adjusted p-value for multiple testing using the Benjamini-Hochberg procedure}
#' }
"attention_genes"


#' edgeR-style Differential Expression Dataset
#'
#' The same experiment as \code{\link{all_genes}}, re-expressed with the column
#' conventions of \pkg{edgeR}'s \code{topTags()} output. The gene identifiers are
#' stored in the row names (as \code{topTags()} returns them), which lets it
#' demonstrate that \code{\link{ggvolc}} accepts edgeR results directly and
#' promotes rowname gene IDs to a \code{genes} column automatically.
#'
#' @format A data frame with gene identifiers in the row names and the following
#'   columns:
#' \describe{
#'   \item{logFC}{Numeric. Log2 fold change of gene expression.}
#'   \item{logCPM}{Numeric. Average log2 counts per million.}
#'   \item{PValue}{Numeric. Raw p-value from the differential expression test.}
#'   \item{FDR}{Numeric. Benjamini-Hochberg adjusted p-value (false discovery rate).}
#' }
"edger_genes"
