
context("subgroup effect calculations")

test_that("test that subgroup effect calculations are correct", {

    set.seed(123)
    bene.score <- rnorm(10)
    y <- rnorm(10)
    trt <- c(rep(1, 5), rep(0, 5))

    sub.eff <- subgroup.effects(benefit.scores = bene.score,
                                y = y, trt = trt)

    recom <- 1 * (bene.score > 0)

    mean11 <- mean(y[trt == 1 & recom == 1])
    mean01 <- mean(y[trt == 0 & recom == 1])
    mean10 <- mean(y[trt == 1 & recom == 0])
    mean00 <- mean(y[trt == 0 & recom == 0])

    overall <- mean(y[(trt == 1 & recom == 1) |
                          (trt == 0 & recom == 0)  ]) -
                mean(y[(trt == 0 & recom == 1) |
                           (trt == 1 & recom == 0)  ])

    expect_equal(overall, sub.eff$overall.subgroup.effect)

})