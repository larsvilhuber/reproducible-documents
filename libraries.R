# Install the R packages used in this repository, in the versions recorded
# in renv.lock.
#
# Used in three places:
#   - on posit.cloud, by participants:   source("libraries.R")
#   - in the Dockerfile (local testing)
#   - in the GitHub Actions workflow
#
# Idempotent: only packages that are missing, or in a different version,
# are installed.
#
# To add a package: install it, use it in the code, then run renv::snapshot()

if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv")

# Into the first library: the project library on posit.cloud (renv is active
# there), the site library in the Docker image.
renv::restore(lockfile = "renv.lock", library = .libPaths()[1], prompt = FALSE)
