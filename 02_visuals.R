# Animated bar charts

library(tidyverse)

combined_records <- read.csv("data/combined_records.csv", header = TRUE)

# Clean and filter for records since 1976
records_clean <- combined_records |> 
  select(-Meet, -Location) |> 
  rename("Order" = "X.") |> 
  separate_wider_delim(
    cols = Name,
    delim = " ",
    names = c("First_Name", "Last_Name"),
    too_many = "merge"
  ) |> 
  arrange(Event, Gender, Date) |> 
  group_by(Event, Gender) |> 
  slice({
    pre_1976 <- which(Date < as.Date("1976-01-01"))
    post_1976 <- which(Date >= as.Date("1976-01-01"))
    
    # Keep the last pre-1976 record (if one exists) and all post-1976 records
    c(tail(pre_1976, 1), post_1976)
  }) |> 
  ungroup()


  
