#' @importFrom utils packageDescription
.onAttach <- function(libname, pkgname) {
  welcome_msg <- paste("Welcome to", packageDescription("ggvolc")$Package, "version", packageDescription("ggvolc")$Version, "!")
  ascii_art <- "
                                888
                                888
                                888
 .d88b.   .d88b.  888  888  .d88b.  888  .d8888b
d88P\"88b d88P\"88b 888  888 d88\"\"88b 888 d88P\"
888  888 888  888 Y88  88P 888  888 888 888
Y88b 888 Y88b 888  Y8bd8P  Y88..88P 888 Y88b.
 \"Y88888  \"Y88888   Y88P    \"Y88P\"  888  \"Y8888P
     888      888
Y8b d88P Y8b d88P
 \"Y88P\"   \"Y88P\"
  "

  # Use packageStartupMessage to display the messages
  packageStartupMessage(welcome_msg)
  packageStartupMessage(ascii_art)

}

#' Print Welcome Message and ASCII Art upon Loading `ggvolc`
#'
#' This function is executed when the `ggvolc` package is attached to the R session.
#' It prints a welcome message and an ASCII representation related to the package.
#'
#' @name ggvolc-onAttach
#' @keywords internal
#' @seealso \code{\link[base]{library}}
#' @examples
#' # The function is automatically called when you use:
#' # library(ggvolc)


# This code is to inform R that the listed names are intentionally global variables
# to prevent 'no visible binding for global variable' warnings during R CMD check
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c("log2FoldChange", "pvalue", "threshold","size_aes","genes" ,"x.start","x.end","y.start","y.end")) # Add other variables as needed
}
