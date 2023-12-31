% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gene_table.R
\name{genes_table}
\alias{genes_table}
\title{Combine a ggplot Object with a Table of Genes}
\usage{
genes_table(plot_obj, data2)
}
\arguments{
\item{plot_obj}{A ggplot object, typically the output of a plotting function.}

\item{data2}{A data frame containing gene details. It should have columns named
"genes", "baseMean", "log2FoldChange", "pvalue", and "padj".}
}
\value{
A gridExtra object showing the ggplot stacked above a table of gene details.
}
\description{
This function takes a ggplot object and a data frame of gene details and
produces a combined plot where the ggplot object is stacked above a table of
gene details.
}
\examples{
\dontrun{
plot <- ggplot2::qplot(1:10, 1:10) # replace this with your ggvolc function call
data_example <- data.frame(genes = letters[1:10],
                           baseMean = rnorm(10),
                           log2FoldChange = rnorm(10),
                           pvalue = runif(10),
                           padj = runif(10))
plot \%>\%
  genes_table(data2 = data_example)
}

}
