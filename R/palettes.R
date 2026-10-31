# Built-in color presets. Each gives the colors for downregulated,
# not significant, and upregulated genes. Several pairs are taken from the
# ltc palettes (https://github.com/loukesio/ltc); they are stored here as hex
# codes so ggvolc does not need ltc installed.
.ggvolc_palettes <- list(
  #             down        not sig.    up          colorblind-safe  source
  default   = list(c("#00798c", "#808080", "#d1495b"), FALSE, "ltc: minou"),
  okabe_ito = list(c("#0072B2", "#999999", "#D55E00"), TRUE,  "Okabe & Ito (2008)"),
  rdbu      = list(c("#0571b0", "#999999", "#ca0020"), TRUE,  "ColorBrewer RdBu"),
  pantone23 = list(c("#1F2C43", "#B8B8B8", "#FFB000"), TRUE,  "ltc: pantone23"),
  seafarer  = list(c("#013D5A", "#BDBDBD", "#E4A25B"), TRUE,  "ltc: seafarer"),
  midnight  = list(c("#075056", "#B0B0B0", "#FF5B04"), FALSE, "ltc: midnight"),
  maya      = list(c("#3d5a80", "#A9A9A9", "#ee6c4d"), FALSE, "ltc: maya"),
  trio1     = list(c("#0E7175", "#B0B0B0", "#FD7901"), FALSE, "ltc: trio1")
)


#' Color presets for volcano plots
#'
#' Lists the color presets available through the \code{palette} argument of
#' \code{\link{ggvolc}} and \code{\link{genes_table}}. Each preset sets the
#' color of downregulated, non-significant, and upregulated genes.
#'
#' Presets marked \code{colorblind_safe} keep the up and down colors clearly
#' apart under simulated deuteranopia, protanopia, and tritanopia (checked
#' with \pkg{colorspace}). Several presets come from the
#' \href{https://github.com/loukesio/ltc}{ltc} palettes; ltc does not need to be
#' installed to use them.
#'
#' You are not limited to these presets: \code{palette} also accepts a named
#' color vector such as \code{c(down = "navy", up = "firebrick")}. That makes
#' any palette usable, for example one from ltc:
#' \code{pal <- ltc::ltc("maya"); ggvolc(all_genes, palette = c(down = pal[1], up = pal[4]))}.
#'
#' @return A data frame with one row per preset and columns \code{palette},
#'   \code{down}, \code{not_sig}, \code{up}, \code{colorblind_safe}, and
#'   \code{source}.
#' @export
#' @examples
#' ggvolc_palettes()
#'
#' ggvolc(all_genes, palette = "okabe_ito")
#' ggvolc(all_genes, palette = c(down = "navy", up = "firebrick"))
ggvolc_palettes <- function() {
  data.frame(
    palette         = names(.ggvolc_palettes),
    down            = vapply(.ggvolc_palettes, function(p) p[[1]][1], ""),
    not_sig         = vapply(.ggvolc_palettes, function(p) p[[1]][2], ""),
    up              = vapply(.ggvolc_palettes, function(p) p[[1]][3], ""),
    colorblind_safe = vapply(.ggvolc_palettes, function(p) p[[2]], NA),
    source          = vapply(.ggvolc_palettes, function(p) p[[3]], ""),
    row.names = NULL, stringsAsFactors = FALSE
  )
}


#' Resolve a palette argument to down / not_sig / up colors
#'
#' @param palette A preset name, or a named character vector with any of
#'   \code{down}, \code{not_sig}, \code{up}. Missing entries fall back to the
#'   default preset.
#' @return A named character vector \code{c(down, not_sig, up)}.
#' @keywords internal
#' @noRd
resolve_palette <- function(palette = "default") {
  base <- stats::setNames(.ggvolc_palettes$default[[1]], c("down", "not_sig", "up"))
  if (is.null(palette)) return(base)

  if (is.character(palette) && length(palette) == 1 && is.null(names(palette))) {
    if (!palette %in% names(.ggvolc_palettes)) {
      stop("Unknown palette '", palette, "'. Available presets: ",
           paste(names(.ggvolc_palettes), collapse = ", "),
           ".\nOr pass colors directly, e.g. palette = c(down = \"navy\", up = \"firebrick\").",
           call. = FALSE)
    }
    return(stats::setNames(.ggvolc_palettes[[palette]][[1]], c("down", "not_sig", "up")))
  }

  palette <- unclass(palette)
  nm <- names(palette)
  if (!is.character(palette) || is.null(nm) ||
      any(nm == "") || !all(nm %in% names(base))) {
    stop("palette must be a preset name (see ggvolc_palettes()) or a named ",
         "color vector using the names 'down', 'not_sig', 'up'.", call. = FALSE)
  }
  base[nm] <- palette
  base
}


#' WCAG contrast ratio of a color against white
#' @keywords internal
#' @noRd
contrast_on_white <- function(col) {
  rgb <- grDevices::col2rgb(col)[, 1] / 255
  lin <- ifelse(rgb <= 0.03928, rgb / 12.92, ((rgb + 0.055) / 1.055)^2.4)
  lum <- sum(c(0.2126, 0.7152, 0.0722) * lin)
  1.05 / (lum + 0.05)
}


#' Darken a color until text in it is readable on white
#'
#' Keeps the hue and darkens towards black in small steps until the WCAG
#' contrast ratio against white reaches \code{min_ratio} (4.5 = WCAG AA for
#' normal text). Colors that already pass are returned unchanged.
#' @keywords internal
#' @noRd
readable_on_white <- function(col, min_ratio = 4.5) {
  vapply(col, function(cl) {
    if (contrast_on_white(cl) >= min_ratio) return(cl)
    rgb <- grDevices::col2rgb(cl)[, 1] / 255
    for (k in seq(0.05, 1, by = 0.05)) {
      out <- grDevices::rgb(rgb[1] * (1 - k), rgb[2] * (1 - k), rgb[3] * (1 - k))
      if (contrast_on_white(out) >= min_ratio) return(out)
    }
    "#000000"
  }, character(1), USE.NAMES = FALSE)
}


#' Colors for highlight gene sets
#' @keywords internal
#' @noRd
highlight_set_colors <- function(set_names, highlight_colors = NULL) {
  # Okabe-Ito hues not used by the up/down presets
  default <- c("#E69F00", "#56B4E9", "#009E73", "#CC79A7", "#F0E442",
               "#000000", "#882255", "#44AA99")
  if (is.null(highlight_colors)) {
    if (length(set_names) > length(default)) {
      stop("More than ", length(default), " highlight sets: please supply ",
           "highlight_colors.", call. = FALSE)
    }
    return(stats::setNames(default[seq_along(set_names)], set_names))
  }
  if (!is.null(names(highlight_colors))) {
    miss <- setdiff(set_names, names(highlight_colors))
    if (length(miss)) stop("highlight_colors is missing: ",
                           paste(miss, collapse = ", "), call. = FALSE)
    return(highlight_colors[set_names])
  }
  if (length(highlight_colors) < length(set_names)) {
    stop("highlight_colors needs one color per highlight set.", call. = FALSE)
  }
  stats::setNames(highlight_colors[seq_along(set_names)], set_names)
}
