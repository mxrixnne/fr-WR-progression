# Scrape freestyle WR progression since 1976

library(rvest)
library(tidyverse)
library(stringr)
library(jsonlite)

url <- "https://en.wikipedia.org/wiki/50_metres_freestyle"
page <- read_html(url)

nodes <- page |> html_elements("h2, h3, table.wikitable")

heading <- NA_character_
men_table <- NULL
women_table <- NULL

for(i in seq_along(nodes)){
  node <- nodes[[i]]
  if (html_name(node) %in% c("h2", "h3")){
    heading <- html_text(node, trim = TRUE)
  } else if (is.null(men_table) && str_detect(heading, "Men")){
    men_table <- node
  } else if (is.null(women_table) && str_detect(heading, "Women")){
    women_table <- node
  }
}




