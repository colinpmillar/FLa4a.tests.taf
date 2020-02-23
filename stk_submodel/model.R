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

# create F model
fmod <-
  submodel(
    name = "f",
    range = range(ple4),
    formula = ~ s(age, k = 4) + s(year, k = 10)
  )
plot(genFLQuant(fmod, nsim = 100)) + facet_wrap( ~ age)

# create initial population structure model
n1range <- range(ple4)[c("min", "max", "minyear", "maxyear")]
n1range["maxyear"] <- n1range["minyear"]
n1mod <-
  submodel(
    name = "n1",
    range = n1range,
    formula = ~ s(age, k = 4)
  )
# plot and override default aes and facet_wrap
plot(genFLQuant(n1mod, nsim = 100)) +
  aes(x = age, y = data) +
  facet_wrap( ~ "age")

# create stock recruitment model
srrange <- range(ple4)[c("min", "max", "minyear", "maxyear")]
srrange["max"] <- srrange["min"]
srrange["minyear"] <- srrange["minyear"] + 1
srmod <-
  sr_submodel(
    name = "my sr model",
    range = srrange,
    formula = ~ bevholt(a = ~ s(year, k = 3), CV=0.2)
  )
# plot and override default aes and facet_wrap
plot(genFLQuant(srmod, nsim = 100))

devtools::load_all(pkg)
# now build a stk_model
stkmod <-
  stk_submodel(
    name = "my stock model",
    range = range(ple4),
    fmod = fmod,
    n1mod = n1mod,
    srmod = srmod,
    m = m(ple4),
    mat = mat(ple4),
    stock.wt = stock.wt(ple4),
    catch.wt = catch.wt(ple4),
    harvest.spwn = harvest.spwn(ple4),
    m.spwn = m.spwn(ple4)
  )

#
stk_sim <- genFLQuant(stkmod, nsim = 100)
names(stk_sim)

devtools::load_all(pkg)
stk_sim <- genFLStock(stkmod, nsim = 100)
plot(stk_sim)

stk_sim <-
  genFLStock(
    stkmod,
    nsim = 100,
    simulate.recruitment = TRUE
  )
plot(stk_sim)
