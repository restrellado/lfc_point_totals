library(tidyverse)
library(lubridate)

# Thanks for the data fivethirtyeight!
# download.file(
#   "https://projects.fivethirtyeight.com/soccer-api/club/spi_matches.csv", 
#   destfile = "data/spi_matches.csv"
#   )

#------------------------------------------------------------------------------

# Read data
spi <- read_csv("data/spi_matches.csv")

#------------------------------------------------------------------------------

# Build Liverpool dataset 
lfc <- spi %>% 
  filter(league_id == 2411,
         team1 == "Liverpool" | team2 == "Liverpool", 
         # Filter for future games
         date > ymd(20190102))

#------------------------------------------------------------------------------

# Function to simulate match 
pred_result <- function(win, loss, draw) {
  sample(c(3, 0, 1), 1, replace=T, prob=c(win, loss, draw)) 
}

#------------------------------------------------------------------------------

# Function to predict all matches 
pred_season <- function(lfc_data) {
  
  # Predict home games
  pred_home <- lfc_data %>% 
    filter(team1 == "Liverpool") %>%
    mutate(result = pmap_dbl(list(prob1, prob2, probtie), pred_result)) %>% 
    select(date, team1, team2, prob1, prob2, probtie, result)
  
  # Predict away games
  pred_away <- lfc_data %>% 
    filter(team2 == "Liverpool") %>%
    mutate(result = pmap_dbl(list(prob2, prob1, probtie), pred_result)) %>% 
    select(date, team1, team2, prob1, prob2, probtie, result) 
  
  # Combine
  bind_rows(pred_home, pred_away) %>% 
    arrange(date) %>% 
    mutate(adj_points = ifelse(date == min(lfc_data$date), 54 + result, result), 
           total_points = cumsum(adj_points))
}

#------------------------------------------------------------------------------

# Simulate seasons
# Initialize list
sims <- vector("list", length = 1000)

# Function to simulate season and add to list
build_list <- function(i) {
  sims[[i]] <<- pred_season(lfc) 
}

# Simulate
c(1:1000) %>% walk(build_list) 

# Combine into one dataset
all_sims <- bind_rows(sims)

#------------------------------------------------------------------------------

# Split simultations by match
by_match <- all_sims %>% 
  split(.$date)