

context("validate.subgroup")

test_that("test validate.subgroup for continuous outcomes with various options", {
    set.seed(123)
    n.obs  <- 100
    n.vars <- 5
    x <- matrix(rnorm(n.obs * n.vars, sd = 3), n.obs, n.vars)


    # simulate non-randomized treatment
    xbetat   <- 0.5 + 0.5 * x[,1] - 0.5 * x[,5]
    trt.prob <- exp(xbetat) / (1 + exp(xbetat))
    trt01    <- rbinom(n.obs, 1, prob = trt.prob)

    trt      <- 2 * trt01 - 1

    # simulate response
    delta <- 5 * (0.5 + x[,2] - x[,3]  )
    xbeta <- x[,1]
    xbeta <- xbeta + delta * trt

    # continuous outcomes
    y <- drop(xbeta) + rnorm(n.obs, sd = 2)

    # binary outcomes
    y.binary <- 1 * (xbeta + rnorm(n.obs, sd = 2) > 0 )

    # time-to-event outcomes
    surv.time <- exp(-20 - xbeta + rnorm(n.obs, sd = 1))
    cens.time <- exp(rnorm(n.obs, sd = 3))
    y.time.to.event  <- pmin(surv.time, cens.time)
    status           <- 1 * (surv.time <= cens.time)

    # create function for fitting propensity score model
    prop.func <- function(x, trt)
    {
        # fit propensity score model
        propens.model <- cv.glmnet(y = trt,
                                   x = x, family = "binomial")
        pi.x <- predict(propens.model, s = "lambda.min",
                        newx = x, type = "response")[,1]
        pi.x
    }

    subgrp.model <- fit.subgroup(x = x, y = y,
                                 trt = trt01,
                                 propensity.func = prop.func,
                                 loss   = "sq_loss_lasso",
                                 nfolds = 5)              # option for cv.glmnet

    expect_is(subgrp.model, "subgroup_fitted")

    invisible(capture.output(print(subgrp.model, digits = 2)))

    invisible(capture.output(summary(subgrp.model)))

    summ <- summarize.subgroups(subgrp.model)

    expect_is(summ, "data.frame")

    invisible(capture.output(print(summarize.subgroups(subgrp.model),
                                   digits = 2, p.value = 0.25)))

    subgrp.val <- validate.subgroup(subgrp.model, B = 10,
                                    method = "training")

    expect_is(subgrp.val, "subgroup_validated")

    invisible(capture.output(print(subgrp.val, digits = 2)))

    subgrp.val <- validate.subgroup(subgrp.model, B = 10,
                                    method = "boot")

    expect_is(subgrp.val, "subgroup_validated")

    invisible(capture.output(print(subgrp.val, digits = 2)))
})




test_that("test validate.subgroup for binary outcomes and various losses", {
    set.seed(123)
    n.obs  <- 100
    n.vars <- 5
    x <- matrix(rnorm(n.obs * n.vars, sd = 3), n.obs, n.vars)


    # simulate non-randomized treatment
    xbetat   <- 0.5 + 0.5 * x[,1] - 0.5 * x[,5]
    trt.prob <- exp(xbetat) / (1 + exp(xbetat))
    trt01    <- rbinom(n.obs, 1, prob = trt.prob)

    trt      <- 2 * trt01 - 1

    # simulate response
    delta <- 5 * (0.5 + x[,2] - x[,3]  )
    xbeta <- x[,1]
    xbeta <- xbeta + delta * trt

    # continuous outcomes
    y <- drop(xbeta) + rnorm(n.obs, sd = 2)

    # binary outcomes
    y.binary <- 1 * (xbeta + rnorm(n.obs, sd = 2) > 0 )

    # time-to-event outcomes
    surv.time <- exp(-20 - xbeta + rnorm(n.obs, sd = 1))
    cens.time <- exp(rnorm(n.obs, sd = 3))
    y.time.to.event  <- pmin(surv.time, cens.time)
    status           <- 1 * (surv.time <= cens.time)

    # create function for fitting propensity score model
    prop.func <- function(x, trt)
    {
        # fit propensity score model
        propens.model <- cv.glmnet(y = trt,
                                   x = x, family = "binomial")
        pi.x <- predict(propens.model, s = "lambda.min",
                        newx = x, type = "response")[,1]
        pi.x
    }

    subgrp.model <- fit.subgroup(x = x, y = y.binary,
                                 trt = trt01,
                                 propensity.func = prop.func,
                                 loss   = "logistic_loss_lasso",
                                 nfolds = 5)              # option for cv.glmnet

    expect_is(subgrp.model, "subgroup_fitted")

    invisible(capture.output(print(subgrp.model, digits = 2)))

    invisible(capture.output(summary(subgrp.model)))

    summ <- summarize.subgroups(subgrp.model)

    expect_is(summ, "data.frame")

    invisible(capture.output(print(summarize.subgroups(subgrp.model), digits = 2, p.value = 0.25)))

    subgrp.val <- validate.subgroup(subgrp.model, B = 10,
                                    method = "training")

    expect_error(validate.subgroup(subgrp.val, B = 10, method = "training"))

    expect_error(validate.subgroup(subgrp.model, B = 10, train.fraction = -1,
                                   method = "training"))

    expect_error(validate.subgroup(subgrp.model, B = 10, train.fraction = 2,
                                   method = "training"))


    subgrp.model2 <- fit.subgroup(x = x, y = y.binary,
                                 trt = trt01,
                                 propensity.func = prop.func,
                                 loss   = "logistic_loss_lasso",
                                 retcall = FALSE,
                                 nfolds = 5)

    # retcall must be true
    expect_error(validate.subgroup(subgrp.model2, B = 10,
                                   method = "training"))

    expect_is(subgrp.val, "subgroup_validated")

    invisible(capture.output(print(subgrp.val, digits = 2)))

    subgrp.val <- validate.subgroup(subgrp.model, B = 10,
                                    method = "boot")

    expect_is(subgrp.val, "subgroup_validated")

    invisible(capture.output(print(subgrp.val, digits = 2)))


})