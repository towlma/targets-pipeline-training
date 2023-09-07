# List of package names to check
packages_to_check <- c(
  "renv", 
  "targets",
  "tarchetypes",
  "assertr",
  "insuranceData",
  "dplyr",
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



# •	Contextualization of the problem
# •	Architecture design: Present the different components of the architecture and their interactions (MSSQL server, SAS server, R server)
# •	Solution design: 
#   o	Explanation of the target plot and these main components
#   o	Explanation of the code structure
#   o	Pipeline tool, focus sur le package target
#   o	Dataquality tools, focus on the R packages used
# •	Workflow : 
#   Detail the different steps with the use of GitHub :
#   o	Development
#   o	Test
#   o	Deployment
# •	Wrap-up: interactive phase where people are invited to transpose the solutions that have been presented to their own problems.


# Slides

# - Debuging development, vizualization
