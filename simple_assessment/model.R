## Run analysis, write model results

## Before:
## After:

library(icesTAF)
library(mgcv)
taf.library(FLCore)
#taf.library(FLa4a)
library(ggplot2)
library(ggplotFL)

mkdir("model")

# load assessment data
load("data/ple4.rda")

#summary(ple4)
#summary(ple4_indices)
names(ple4_indices)

devtools::load_all("d:\\projects\\git\\flr\\FLa4a")

# create some models
fmod <-
  submodel(
    name = "f-at-age",
    range = range(ple4),
    formula = ~ s(age, k = 4) + s(year, k = 10)
  )
plot(genFLQuant(fmod, nsim = 100)) + facet_wrap( ~ age)

qmod <-
  submodels(
    lapply(ple4_indices,
      function(x) {
        submodel(
          name = name(x),
          range = range(x),
          formula = ~ s(age, k = 4)
        )
    })
  )
plot(genFLQuant(qmod, nsim = 100))

# now use these in sca function
fit <-
  sca(
    ple4, ple4_indices,
    fmodel = formula(fmod),
    qmodel = formula(qmod))

# inspect fit and covariate relationships
