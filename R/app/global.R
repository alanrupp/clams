library(readxl)
library(tidyverse)

# - Parameter choices ---------------------------------------------------------
param_choices <- c("VO2" = "VO2-mouse ", "VCO2" = "VCO2-mouse", "RER" = "RER",
                   "EE" = "EE-mouse", "Activity-X" = "Activity-X total",
                   "Activity-Z" = "Activity-Z total",
                   "Ambulatory" = "Activity-X Ambulatory",
                   "Fat Oxidation" = "Fat Oxidation-LBM",
                   "Glucose Oxidation" = "Glucose Oxidation-LBM",
                   "Food Intake" = "Food Intake")

# - Read data -----------------------------------------------------------------
read_data <- function(filepath, sheet_name) {
  df <- read_xlsx(filepath, sheet = sheet_name, skip = 59)
  df <- filter(df, !Computer %in% c("Date/Clock", "Time"))
  df <- select(df, -starts_with(".."), -`Hourly Average`)
  df <- rename(df, "Day" = Computer, "Time" = `ID#:`)
  df <- mutate(df, Day = as.Date(as.numeric(Day), 
                                 origin = "1900-01-01") - 2)
  df <- mutate(df, Time = as.numeric(Time))
  df <- mutate(df, Time = ifelse(Time >= 1, Time - as.integer(Time), Time))
  df <- gather(df, -Day, -Time, key = "Mouse", value = "value")
  return(df)
}

# - Plot continuous -----------------------------------------------------------
plot_continuous <- function(df, parameters = NULL, 
                            group = NULL, color = NULL, fill = NULL) {
  if (!is.null(parameters)) {
    df <- df[parameters]
  }
  
  plot_fn <- function(parameter) {
    df[[parameter]] %>%
      group_by(Time, Mouse) %>%
      summarize(value = mean(value, na.rm = TRUE)) %>%
      group_by(Time) %>%
      summarize(avg = mean(value, na.rm = TRUE), 
                sem = sd(value, na.rm = TRUE) / sqrt(n())) %>%
      ggplot(aes(x = Time, y = avg)) +
      geom_line() +
      geom_ribbon(aes(ymin = avg - sem, ymax = avg + sem),
                  alpha = 0.3, color = 0) +
      theme_classic() +
      ggtitle(parameter) +
      ylab(NULL) + xlab("Time of day") +
      scale_x_continuous(expand = c(0, 0)) +
      ggtitle(parameter)
  }
  return(cowplot::plot_grid(plotlist = map(df, plot_fn), ncol = 1))
}
