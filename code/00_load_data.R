# load data
here::i_am("code/00_load_data.R")
absolute_path_to_data <- here::here("raw_data", "commodities.csv")
commodities <- read.csv(absolute_path_to_data, header = TRUE)

library(tidyverse)

# Remove whitespace from character columns
commodities <- commodities %>% 
  mutate(across(where(is.character), str_trim))

# Combine Commodity and Variety to variable commodity_variety
commodities$commodity_variety <- str_trim(paste(commodities$Commodity,commodities$Variety))

saveRDS(
  commodities, 
  file = here::here("output/data_clean.rds")
)
