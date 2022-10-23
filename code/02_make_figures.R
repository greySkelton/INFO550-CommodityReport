here::i_am(
  "code/02_make_figures.R"
)

# load nessecary packages
library(tidyverse)
library(stringr)
library(gt)
library(knitr)
library(cowplot)
library(magick)

# 1) What is the trend over time of the 10 commodities in England with the most years of price data?
#     a) What are the 10 commodities in England with the most years of price data?
commodities <- readRDS(
  file = here::here("output/data_clean.rds")
)

england <- commodities %>% filter(Market=="England")

# get top 10 commodities in England, year of earlist record, and earlist price
top_commodities_in_england <- 
  england %>% 
  group_by(commodity_variety) %>%
  summarise(Count = n(), firstYear= min(Item_Years)) %>% 
  arrange(desc(Count)) %>%
  slice(1:10) %>%
  select(commodity_variety,firstYear) %>% 
  left_join(england, 
            by = c("commodity_variety"="commodity_variety", 
                   "firstYear"="Item_Years")) %>% 
  select(commodity_variety, firstYear, Item_Value_Standardized) %>%
  rename(first_price=Item_Value_Standardized)

# make table that has all info for top 10 commodities in England 
# and their price as percent of earlirst price
england_top10 <- 
  commodities %>% 
  filter(Market=="England", commodity_variety %in% top_commodities_in_england[[1]]) %>%
  left_join(top_commodities_in_england, by="commodity_variety") %>%
  mutate(item_value_as_percent = Item_Value_Standardized/first_price)

# line graph of item price as percent of earliest price over time
fig1 <- england_top10 %>%
  ggplot(aes(x=Item_Years, y=item_value_as_percent, color=commodity_variety)) +
  geom_smooth(method="gam") +
  xlab("Years") +
  ylab("Price as % of First Price") +
  scale_x_continuous(breaks = seq(1200,1950,by=50)) +
  scale_y_continuous(breaks = seq(0,36,by=10)) +
  geom_hline(yintercept = 1) +
  guides(color = guide_legend(title = "Commodity")) +
  ggtitle("Figure 1: Selected Commodity Prices in England over Time")


# same line graph but excluding wheat
fig2 <- england_top10 %>% filter(commodity_variety!="Salt") %>%
  ggplot(aes(x=Item_Years, y=item_value_as_percent, color=commodity_variety)) +
  geom_smooth(method="gam") +
  xlab("Years") +
  ylab("Price as % of First Price") +
  scale_x_continuous(breaks = seq(1200,1950,by=50)) +
  scale_y_continuous(breaks = seq(0,12,by=1)) +
  geom_hline(yintercept = 1) +
  guides(color = guide_legend(title = "Commodity")) +
  ggtitle("Figure 2: Selected Commodity Prices in England over Time", subtitle = "Excluding Salt")

saveRDS(
  fig1, 
  file = here::here("output/fig1.rds")
)

saveRDS(
  fig2, 
  file = here::here("output/fig2.rds")
)

