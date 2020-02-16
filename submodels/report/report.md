Working notes
================

``` r
library(icesTAF)
library(ggplot2)
library(mgcv)
```

    ## Loading required package: nlme

    ## This is mgcv 1.8-31. For overview type 'help("mgcv-package")'.

``` r
taf.library(FLCore)
taf.library(FLa4a)
cat("buit on", date())
```

    ## buit on Sun Feb 16 16:56:13 2020

## Model building and simulating

Define a model for survey catchability - choose a range first that only
has ages for demonstration purposes.

``` r
qmod <-
  submodel(
    name = "trawl",
    range = c(min = 1, max = 10, minyear = 2017, maxyear = 2017),
    formula = ~ s(age, k = 4)
  )
```

we can visualise the various shapes this can take by simulating from the
‘prior’ parameter space, which we are thinking of here as multivariate
normal with mean vector zero and identity matrix variance covariance
matrix. By setting the variance of the intercept term to zero we can
focus on the shape rather then the level of the curve. Note that the
variance covariance is a 3D array, with the 3rd dimension potentially
contianing simulated variance covariance matrices, or variance
covariance matrices arising from fits to multiple simulated datasets.

``` r
vcov(qmod)["(Intercept)", "(Intercept)", 1] <- 0
```

simuate from the object and visualise it

``` r
ggplot(
  as.data.frame(
    genFLQuant(qmod, nsim = 50, seed = 1323)
  ),
  aes(x = age, y = data, group = iter)
) +
  geom_line(colour = alpha("red", alpha = 0.3)) +
  labs(title = "Samples from the q model space (log scale with Intercept = 0)")
```

![](d:/projects/git/flr/FLa4a.tests.taf/submodels/report/report_files/figure-gfm/fitted-values-1.png)<!-- -->

### Constraining q above a fixed age

in this example we use a formula that replaces ages above 8 with 8, and
therefore constrains q above 8 to be equal to q at age 8.

``` r
qmod <-
  submodel(
    name = "trawl-trunc",
    range = c(min = 1, max = 10, minyear = 2017, maxyear = 2017),
    formula = ~ s(replace(age, age > 8, 8), k = 4)
  )
```

Again, by setting the variance of the intercept term to zero we can
focus on the shape rather then the level of the curve.

``` r
vcov(qmod)["(Intercept)", "(Intercept)", 1] <- 0
```

simuate from the object and visualise it

``` r
ggplot(
  as.data.frame(
    genFLQuant(qmod, nsim = 50, seed = 1323)
  ),
  aes(x = age, y = data, group = iter)
) +
  geom_line(colour = alpha("red", alpha = 0.3)) +
  labs(title = "Samples from the q model space (log scale with Intercept = 0)")
```

![](d:/projects/git/flr/FLa4a.tests.taf/submodels/report/report_files/figure-gfm/fitted-values2-1.png)<!-- -->

an alternative to fixing the age in the formula is to supply a truncated
age as a covariate. This is done by adding a data.frame of covariates to
the submodel, much in the same way that the `data` argument in `lm()`
provides covariate data.

To add covariates, in this case it is easier to create the data.frame
from the previous submodel, but it can be done in one

``` r
qmod2 <-
  submodel(
    name = "trawl-trunc",
    range = c(min = 1, max = 10, minyear = 2017, maxyear = 2017),
    formula = ~ s(age_trunc, k = 4)
  )

data <- as.data.frame(qmod2, drop = TRUE)
data$age_trunc <- replace(data$age, data$age > 8, 8)

qmod2 <-
  submodel(
    qmod2,
    covariates = data
  )
vcov(qmod2)["(Intercept)", "(Intercept)", 1] <- 0


ggplot(
  as.data.frame(
    genFLQuant(qmod2, nsim = 50, seed = 1323)
  ),
  aes(x = age, y = data, group = iter)
) +
  geom_line(colour = alpha("red", alpha = 0.3)) +
  labs(title = "Samples from the q model space (log scale with Intercept = 0)")
```

![](d:/projects/git/flr/FLa4a.tests.taf/submodels/report/report_files/figure-gfm/new-submodel-with-covars-1.png)<!-- -->

### filling out over years

In order to create a q model that operates over several years, it is
just a case of extending the range of the submodel
