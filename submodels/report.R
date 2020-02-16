## Prepare plots and tables for report

## Before:
## After:

library(icesTAF)
library(rmarkdown)

mkdir("report")

render("report.Rmd")

cp("report.md", "report", move = TRUE)
cp("report_files", "report", move = TRUE)
