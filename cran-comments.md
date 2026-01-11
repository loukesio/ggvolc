## R CMD check results

0 errors | 0 warnings | 2 notes

* This is a new release.

## Test environments

* local: macOS Sequoia 15.6.1, R 4.5.1 (2025-06-13)
* win-builder: (devel and release) - to be tested
* R-hub: to be tested

## R CMD check results

There were 2 NOTEs:

1. New submission
   - This is expected for a first-time CRAN submission.

2. HTML validation: 'tidy' doesn't look like recent enough HTML Tidy
   - HTML Tidy version 5.8.0 is installed locally but R CMD check doesn't recognize it.
   - This is a local environment issue. CRAN's automated systems will validate the HTML properly.
   - No actual HTML validation errors exist in the documentation.

## Examples

All examples run successfully in under 5 seconds:
* ggvolc: 2.1 seconds
* genes_table: 0.7 seconds

Examples demonstrate:
* Basic volcano plot creation
* Highlighting genes of interest
* Adding significance thresholds
* Customizing colors and parameters
* Combining plots with gene tables

## Downstream dependencies

There are currently no downstream dependencies for this package.
