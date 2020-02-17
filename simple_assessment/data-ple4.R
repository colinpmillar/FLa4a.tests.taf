## Preprocess data, write TAF data tables

## Before:
## After:

library(icesTAF)

mkdir("data")

# load from bootstrap
load("bootstrap//data//ple4//ple4.rda")

# modify
ple4_indices <- ple4.indices[c("IBTS_Q1", "IBTS_Q3", "BTS-Combined (all)")]

# save
save(ple4, ple4_indices, file = "data/ple4.rda")

# done
