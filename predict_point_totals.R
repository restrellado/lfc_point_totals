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
  filter(team1 == "Liverpool" | team2 == "Liverpool", 
         # Filter for future games
         date > ymd(20190102))

#------------------------------------------------------------------------------

# Function to simulate match 
pred_result <- function(n, win, loss, draw) {
  sample(c(3, 0, 1), n, replace=T, prob=c(win, loss, draw)) 
}

#------------------------------------------------------------------------------

# Simulate matches

test <- sample(c(3, 0, 1), 10000, replace=T, prob=c(.316, .440, 0.244))