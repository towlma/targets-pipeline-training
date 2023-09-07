# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)
# library(dplyr)
# library(assertr)

# Set target options:
tar_option_set(
  packages = c("tibble", 
               "dplyr",
               "assertr",
               "log4r") # packages that your targets need to run
  # format = "qs", # Optionally set the default storage format. qs is fast.
  #
  # For distributed computing in tar_make(), supply a {crew} controller
  # as discussed at https://books.ropensci.org/targets/crew.html.
  # Choose a controller that suits your needs. For example, the following
  # sets a controller with 2 workers which will run as local R processes:
  #
  #   controller = crew::crew_controller_local(workers = 2)
  #
  # Alternatively, if you want workers to run on a high-performance computing
  # cluster, select a controller from the {crew.cluster} package. The following
  # example is a controller for Sun Grid Engine (SGE).
  # 
  #   controller = crew.cluster::crew_controller_sge(
  #     workers = 50,
  #     # Many clusters install R as an environment module, and you can load it
  #     # with the script_lines argument. To select a specific verison of R,
  #     # you may need to include a version string, e.g. "module load R/4.3.0".
  #     # Check with your system administrator if you are unsure.
  #     script_lines = "module load R"
  #   )
  #
  # Set other options as needed.
)

# tar_make_clustermq() is an older (pre-{crew}) way to do distributed computing
# in {targets}, and its configuration for your machine is below.
options(clustermq.scheduler = "multiprocess")

# tar_make_future() is an older (pre-{crew}) way to do distributed computing
# in {targets}, and its configuration for your machine is below.
# Install packages {{future}}, {{future.callr}}, and {{future.batchtools}} to allow use_targets() to configure tar_make_future() options.

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
list(
  
  # Track changes in the data file
  tar_target(
    name = data_file,
    command = "data/dataCar.rds",
    format = "file"
  ),
  
  # Load data
  tar_target(
    name = data_in,
    command = readRDS(data_file)
  ),
  
  # Track changes in data expectations file
  tar_target(
    name = expecations_file,
    command = "data/expectations.yaml",
    format = "file"
  ),
  
  # Load expectations
  tar_target(
    name = data_expectations,
    command = yaml::read_yaml(expecations_file)
  ),
  
  # Exploratory report
  tar_render(
    name = exploratory_report, 
    "Rmd/exploratory_report.Rmd",
    output_dir = "output",
    params = list(data = data_in)
  ),
  
  # Data quality checks
  # Write data quality checks in the log
  tar_target(
    name = data_quality,
    command = perform_data_quality(data_in, data_expectations)
  ),
  
  # Model severity
  tar_skip(
    name = train_sev,
    command = {
      
      df_sev <- data_in %>% 
        filter(numclaims > 0)
      
      glm(claimcst0 ~ agecat + area + veh_value, 
          data = df_sev, 
          family = Gamma(link = "log"), 
          offset = log(numclaims))
      
    },
    skip = data_quality
  ),
  
  # Model frequency
  tar_skip(
    name = train_freq,
    command = {
      
      glm(numclaims ~ agecat + area + veh_value,
          data = data_in,
          family = poisson(link = "log"), 
          offset = log(exposure))
      
    }, 
    skip = data_quality 
  )
  
  # Prevent the rest of the pipeline to run if dq are not passed
  
)
