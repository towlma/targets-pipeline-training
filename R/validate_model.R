
validate_model <- function(data, mod_freq, mod_sev){
  
  data_temp <- data
  data_temp["numclaims"] <- 1
  data$pred_freq <- predict(mod_freq, type = "response")
  data$pred_sev <- predict(mod_sev, newdata = data_temp, type = "response")
  
  df <- data
  df <- df %>%
    mutate(pred_freq_ann = pred_freq/exposure)
  df <- df %>% 
    mutate(qt = cut(df$pred_freq_ann, quantile(df$pred_freq_ann, 0:10/10), include.lowest = TRUE)) %>%
    group_by(qt) %>%
    summarise(pred = sum(pred_freq)/sum(exposure),
              obs = sum(numclaims)/sum(exposure))  %>% 
    tidyr::gather("type", "value", pred, obs)
  
  lift_curve <- ggplot(data = df, aes(x = qt, y = value, color = type)) +
    geom_point(size = 2)
  
  ggsave(filename = "output/lift_curve.png", lift_curve)
  
}


