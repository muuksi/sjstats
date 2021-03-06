stopifnot(require("testthat"),
          require("sjstats"))

context("sjstats, anova_stats")


# fit linear model
data(efc)
m <- aov(
  c12hour ~ as.factor(e42dep) + as.factor(c172code) + c160age,
  data = efc
)

test_that("eta_sq", {
  eta_sq(m, partial = FALSE)
  eta_sq(m, partial = TRUE)
  eta_sq(m, partial = FALSE, ci.lvl = .5, n = 50)
  eta_sq(m, partial = TRUE, ci.lvl = .6, n = 50)
})

test_that("omega_sq", {
  omega_sq(m, partial = FALSE)
  omega_sq(m, partial = TRUE)
  omega_sq(m, partial = FALSE, ci.lvl = .5, n = 50)
  omega_sq(m, partial = TRUE, ci.lvl = .6, n = 50)
})

test_that("cohens_f", {
  cohens_f(m)
})

test_that("anova_stats", {
  anova_stats(m, digits = 3)
  anova_stats(m, digits = 5)
  anova_stats(car::Anova(m, type = 2))
  anova_stats(car::Anova(m, type = 3))
})
