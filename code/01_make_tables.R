here::i_am(
  "code/01_make_tables.R"
)

# load nessecary packages
library(tidyverse)
library(stringr)
library(gt)
library(knitr)
library(cowplot)
library(magick)

commodities <- readRDS(
  file = here::here("output/data_clean.rds")
)

# Compute basic summary stats
n_markets <- n_distinct(commodities$Market)
n_commodity <- n_distinct(commodities$Commodity)
min_year <- min(commodities$Item_Years)
max_year <- max(commodities$Item_Years)

# Combine Commodity and Variety to variable commodity_variety
commodities$commodity_variety <- str_trim(paste(commodities$Commodity,commodities$Variety))

#################### Create Tables #################### 

# 1) What markets have the most Items?
top_markets_by_item <- 
  commodities %>% 
  group_by(Market) %>%
  summarise(minYear = min(Item_Years), 
            maxYear = max(Item_Years), 
            Items = n_distinct(Commodity)) %>%
  mutate(rangeYears = maxYear-minYear) %>%
  arrange(desc(Items)) %>%
  slice(1:10)

# 2) What markets have the most Years?
top_markets_by_years <- 
  commodities %>% 
  group_by(Market) %>%
  summarise(minYear = min(Item_Years), 
            maxYear = max(Item_Years), 
            Items = n_distinct(Commodity)) %>%
  mutate(rangeYears = maxYear-minYear) %>%
  arrange(desc(rangeYears)) %>%
  slice(1:10)

# 3) What items are represented in the most markets?
common_items <-
  commodities %>%
  group_by(Commodity, Market) %>%
  group_by(Commodity) %>%
  summarise(MarketCount = n_distinct(Market)) %>%
  mutate(MarketPercent = MarketCount/n_markets) %>%
  arrange(desc(MarketCount)) %>%
  slice(1:10)

# 4) What market has the most commodity-years?
most_commodity_years <- 
  commodities %>%
  group_by(Market) %>%
  summarise(Count = n()) %>%
  arrange(desc(Count)) %>%
  slice(1:10)

#################### Format Tables #################### 
table_1 <- top_markets_by_years %>%
  gt() %>%
  tab_header(
    title = "Table 1: Markets with Largest Date Range"
  ) %>%
  cols_label(
    minYear = "Earlist Year",
    maxYear = "Latest Year",
    rangeYears = "Year Range"
  ) %>%
  tab_footnote(
    "Prices may not exist for every item across entire year range.",
    locations = cells_column_labels(
      columns = Items)
  ) %>%
  tab_footnote(
    "Price data may not exist for every year in year range.",
    locations = cells_column_labels(
      columns = rangeYears)
  )

table_2 <- top_markets_by_item %>%
  gt() %>%
  tab_header(
    title = "Table 2: Markets with Most Commodities"
  ) %>%
  cols_label(
    minYear = "Earlist Year",
    maxYear = "Latest Year",
    rangeYears = "Year Range"
  ) %>%
  tab_footnote(
    "Prices may not exist for every item across entire year range.",
    locations = cells_column_labels(
      columns = Items)
  ) %>%
  tab_footnote(
    "Price data may not exist for every year in year range.",
    locations = cells_column_labels(
      columns = rangeYears)
  )

table_3 <- common_items %>%
  gt() %>%
  tab_header(
    title = "Table 3: Commodities in the Most Markets"
  ) %>%
  cols_label(
    MarketCount = "Markets",
    MarketPercent = "% of Markets"
  ) %>%
  fmt_percent(
    columns = c(MarketPercent),
    decimals = 2
  )

table_4 <- most_commodity_years %>%
  gt() %>%
  tab_header(
    title = "Table 4: Markets with the Most Commodity-Years"
  ) %>%
  cols_label(
    Count = "Commodity-Years"
  ) %>%
  fmt_number(
    columns = c(Count),
    sep_mark = ",",
    decimals = 0
  )


saveRDS(
  table_1, 
  file = here::here("output/tab1.rds")
)
saveRDS(
  table_2, 
  file = here::here("output/tab2.rds")
)
saveRDS(
  table_3, 
  file = here::here("output/tab3.rds")
)
saveRDS(
  table_4, 
  file = here::here("output/tab4.rds")
)

