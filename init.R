# List of package names to check
packages_to_check <- c(
  "renv", 
  "targets",
  "tarchetypes",
  "assertr",
  "insuranceData",
  "dplyr",
  "ggplot2",
  "yaml",
  "log4r"
)

# Loop through the list of packages
for (package in packages_to_check) {
  if (!require(package, character.only = TRUE)) {
    install.packages(package)  
  }
}

renv::init()
targets::use_targets()

library(insuranceData)
data(dataCar)
saveRDS(dataCar, "data/dataCar.rds")

# https://docs.ropensci.org/gittargets/
