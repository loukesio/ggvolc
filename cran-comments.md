## Submission

This is an update of ggvolc (0.1.0 -> 0.4.0). Main changes:

* DESeq2, edgeR and limma result objects are accepted directly (these
  Bioconductor packages are in Suggests and used conditionally).
* Colorblind-safe color presets, gene-set highlighting, gene counts on the
  plot, and side-by-side comparison of several contrasts.
* A new example dataset, `stress_timecourse` (derived from the Bioconductor
  data package 'fission'; source cited in its help page).

## Test environments

* local: macOS, R 4.5.1
* win-builder: R-devel and R-release
* GitHub Actions: macOS, Windows (R-release); Ubuntu (R-devel, R-release, R-oldrel-1)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

There are no reverse dependencies on CRAN.
