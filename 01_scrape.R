# Scrape freestyle WR progression since 1976

library(rvest)
library(dplyr)
library(purrr)
library(lubridate)

urls <- c(
  "50m" = "https://en.wikipedia.org/wiki/50_metres_freestyle",
  "100m" = "https://en.wikipedia.org/wiki/World_record_progression_100_metres_freestyle",
  "200m" = "https://en.wikipedia.org/wiki/200_metres_freestyle",
  "400m" = "https://en.wikipedia.org/wiki/400_metres_freestyle",
  "800m" = "https://en.wikipedia.org/wiki/800_metres_freestyle",
  "1500m" = "https://en.wikipedia.org/wiki/1500_metres_freestyle"
)

scrape_event <- function(url){
  page <- read_html(url)
  xpath_base <- "(//h3[contains(translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'long course')])"

  list(
    Men = page |> html_element(xpath = paste0(xpath_base, "[1]/following::table[1]")) |> html_table(),
    Women = page |> html_element(xpath = paste0(xpath_base, "[2]/following::table[1]")) |> html_table()
  )
}

clean_table <- function(tbl){
  # Take care of empty or NA column names
  col_names <- names(tbl)
  bad_cols <- is.na(col_names) | col_names == ""
  if(any(bad_cols)){
    col_names[bad_cols] <- paste0("col_", which(bad_cols))
  }
  names(tbl) <- make.unique(col_names)
  
  tbl |> 
    mutate(across(everything(), as.character)) |> 
    mutate(across(everything(), ~ gsub("[\u00a0\u200b]", " ", .x))) |> 
    mutate(across(everything(), ~ gsub("\\[.*?\\]", "", .x))) |> 
    mutate(across(everything(), trimws))
}


# Create combined df
combined_records <- imap_dfr(urls, function(url, event){
  data <- scrape_event(url)
  
  bind_rows(
    clean_table(data$Men) |> mutate(Event = event, Gender = "Men"),
    clean_table(data$Women) |> mutate(Event = event, Gender = "Women")
  )
}) |> 
  # Parse dates
  mutate(Date = as.Date(parse_date_time(Date, orders = c("dmY", "mdY"), locale = "C"))) |> 
  relocate(Event, Gender) |> 
  select(-col_3, -Ref)

dir.create("data", showWarnings = FALSE, recursive = TRUE)
write_csv(combined_records, "data/combined_records.csv")

