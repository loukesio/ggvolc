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


#' Fission Yeast Stress Time Course (three contrasts)
#'
#' Real DESeq2 results from an RNA-seq time course of wild-type fission yeast
#' (\emph{Schizosaccharomyces pombe}) exposed to osmotic stress (1 M sorbitol).
#' Each element of the list compares one time point after stress with time 0,
#' so the list can be passed straight to \code{\link{ggvolc}} to compare the
#' contrasts side by side. The response is strongest at 30 minutes and fades
#' by 180 minutes.
#'
#' The counts come from the Bioconductor data package \pkg{fission}
#' (wild-type samples only, 3 replicates per time point; genes with fewer than
#' 10 reads in total removed). Results were computed with
#' \code{DESeq2::DESeq()} using \code{design = ~ minute}; see
#' \code{data-raw/stress_timecourse.R} in the package sources. As in any
#' DESeq2 output, \code{padj} is \code{NA} for genes removed by independent
#' filtering.
#'
#' @format A named list of three data frames, \code{"30 min vs 0 min"},
#'   \code{"60 min vs 0 min"}, and \code{"180 min vs 0 min"}, each with 6535
#'   rows and the columns:
#' \describe{
#'   \item{genes}{Character. Gene symbol, or the systematic ID when no symbol exists.}
#'   \item{baseMean}{Numeric. Mean of normalized counts across all samples.}
#'   \item{log2FoldChange}{Numeric. log2 fold change versus time 0.}
#'   \item{pvalue}{Numeric. Wald test p-value.}
#'   \item{padj}{Numeric. Benjamini-Hochberg adjusted p-value.}
#' }
#' @source Leong HS, Dawson K, Wirth C, et al. (2014). A global non-coding RNA
#'   system modulates fission yeast protein levels in response to stress.
#'   \emph{Nature Communications} 5:3947. \doi{10.1038/ncomms4947}.
#'   GEO accession GSE56761. Data via the Bioconductor package \pkg{fission}.
#' @examples
#' names(stress_timecourse)
#' ggvolc(stress_timecourse, label_top = 5, show_counts = TRUE)
"stress_timecourse"
