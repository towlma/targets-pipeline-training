perform_data_quality <- function(data, expectations){
  
  dq <- check_expectations(data, expectations)
  
  if(isTRUE(dq)){
    return(TRUE)
  } else {
    # print log
    log_file <- paste0("output/", gsub(":", "-", Sys.time()), ".log")
    file.create(log_file)
    logger <- logger("INFO", appenders = file_appender(log_file))
    error(logger, "Data quality issues ! \n")
    options(width = 10000)
    sink(log_file, append = TRUE)
    print(dq)
    sink()
    # write.table(dq, file = log_file)
    return(FALSE)
  }
  
}

check_expectations <- function(data, expectations){
    
    res <- data %>%
      chain_start()
    
    for(var in names(expectations)){
      
      ex <- expectations[[var]]
      
      # Check value in bounds
      if(!is.null(ex$bounds)){
        upperb <- ex$bounds$upperb
        lowerb <- ex$bounds$lowerb
        includelow <- ifelse(is.null(ex$bounds$includelow), F, ex$bounds$includelow)
        includeup <- ifelse(is.null(ex$bounds$includeup), F, ex$bounds$includeup)
        res <- res %>%
          assert(within_bounds(lowerb, upperb, includelow, includeup), 
                 starts_with(var))
      }
      
      # Check value in set
      if(!is.null(ex$value_set)){
        value_set <- ex$value_set
        res <- res %>%
          assert(in_set(value_set), starts_with(var))
      }
      
      # Check number of NAs
      if(!is.null(ex$na_max)){
        na_max <- quantile(1:nrow(data), probs = ex$na_max, type = 1)
        res <- res %>%
          assert_rows(function(x) sum(num_row_NAs(x)),
                      within_bounds(0, na_max), starts_with(var))
      }
      
    }
    
    res <- res %>% 
      chain_end(error_fun = error_df_return, 
                success_fun = success_logical)
    
    # Return TRUE if all good
    
    return(res)
}

# expectations <- list(
#   gender = list(
#     value_set = c("M")
#   )
# )
# library(assertr)
# expectations <- yaml::read_yaml("data/expectations.yaml")
# a <- perform_data_quality(df, expectations)
  
