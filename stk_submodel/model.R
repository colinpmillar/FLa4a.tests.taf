## Run analysis, write model results

## Before:
## After:

library(icesTAF)
library(FLCore)
library(ggplotFL)

mkdir("model")

# load assessment data
load("data/ple4.rda")

if (FALSE) {
  pkg <- "d:\\projects\\git\\flr\\FLa4a"
  devtools::load_all(pkg)
}

# create F model
fmod <-
  submodel(
    name = "f-at-age",
    range = range(ple4),
    formula = ~ s(age, k = 4) + s(year, k = 10)
  )
plot(genFLQuant(fmod, nsim = 100)) + facet_wrap( ~ age)

# create Q models
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
plot(genFLQuant(qmod, nsim = 100)) +
  aes(x = age, y = data) +
  facet_wrap(~ qname)

# create initial population structure model
n1range <- range(ple4)[c("min", "max", "minyear", "maxyear")]
n1range["maxyear"] <- n1range["minyear"]
n1mod <-
  submodel(
    name = "initial-age-structure",
    range = n1range,
    formula = ~ s(age, k = 4)
  )
# plot and override default aes and facet_wrap
plot(genFLQuant(qmod, nsim = 100)) +
  aes(x = age, y = data) +
  facet_wrap( ~ "age")

# create recruitment model
rrange <- range(ple4)[c("min", "max", "minyear", "maxyear")]
rrange["max"] <- rrange["min"]
rmod <-
  submodel(
    name = "recruitment",
    range = rrange,
    formula = ~ factor(year) - 1
  )
# plot and override default aes and facet_wrap
plot(genFLQuant(rmod, nsim = 100))
