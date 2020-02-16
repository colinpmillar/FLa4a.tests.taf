## Prepare plots and tables for report

## Before:
## After:

library(icesTAF)
library(rmarkdown)

mkdir("report")

rmarkdown::render("report.Rmd", output_dir = "report")
