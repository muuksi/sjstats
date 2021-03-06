#' @rdname hdi
#' @export
mcse <- function(x, ...) {
  UseMethod("mcse")
}


#' @rdname hdi
#' @export
mcse.brmsfit <- function(x, type = c("fixed", "random", "all"), ...) {
  # check arguments
  type <- match.arg(type)
  mcse_helper(x, type)
}


#' @export
mcse.stanmvreg <- function(x, type = c("fixed", "random", "all"), ...) {
  # check arguments
  type <- match.arg(type)

  s <- summary(x)
  dat <- data_frame(
    term = rownames(s),
    mcse = s[, "mcse"]
  )

  # check if we need to remove random or fixed effects
  remove_effects_from_stan(dat, type, is.brms = FALSE)
}


#' @rdname hdi
#' @export
mcse.stanreg <- function(x, type = c("fixed", "random", "all"), ...) {
  # check arguments
  type <- match.arg(type)

  if (inherits(x, "stanmvreg"))
    return(mcse.stanmvreg(x = x, type = type, ...))

  mcse_helper(x, type)
}


#' @importFrom purrr map_dbl
#' @importFrom dplyr pull
mcse_helper <- function(x, type) {
  dat <- as.data.frame(x)
  if (inherits(x, "brmsfit")) dat <- brms_clean(dat)

  # get standard deviations from posterior samples
  stddev <- purrr::map_dbl(dat, sd)

  # remove certain terms
  keep <- seq_len(length(names(stddev)))

  for (.x in c("^(?!lp__)", "^(?!log-posterior)", "^(?!mean_PPD)")) {
    keep <- intersect(keep, grep(.x, names(stddev), perl = TRUE))
  }

  stddev <- stddev[keep]


  # get effective sample sizes
  ess <- dplyr::pull(n_eff(x, type = "all"), "n_eff")

  # compute mcse
  dat <- data_frame(
    term = colnames(dat),
    mcse = stddev / sqrt(ess)
  )

  # check if we need to remove random or fixed effects
  remove_effects_from_stan(dat, type, is.brms = inherits(x, "brmsfit"))
}
