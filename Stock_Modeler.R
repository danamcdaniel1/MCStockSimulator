###############################################################################
####### Monte Carlo Simulation of Stock Price Performance  ####################
#  Author:  Dana McDaniel
#  Date:  03/03/19
#  
#  This script accepts a stock ticker and some associated parameters as input
#  and uses a log-normal model to estimate ticker price after a specified 
#  holding perior.
#  
#  I was inspired by a recent HR policy change at my company  Employees are now
#  allowed to select from several mixes of SARs and RSUs.  Of course, the value 
#  of each bundle varies based on the future stock price.
#  
#  So I did what any reasonable code monkey who attempted a bachelors in math 
#  and economics does after learning how to program: spent my Sunday making R 
#  scripts to model stock prices using monte carlo simulations from recent price 
#  behavior.   Basically I created a log-normal MC model with parameters from 
#  ROG.VX price behavior between when I started at GNE (about 2014-06-01) and 
#  today.  Modeling was performed by simulating daily price movement over a 4 
#  year vesting period.   VOO is your "control stock" to give you a sense of how 
#  the S&P500 American Large Caps may perform in comparison.
#  
#  
###############################################################################

library(lubridate)
library(quantmod)
library(dplyr)
library(ggplot2)
library(knitr)


# Modeling details:
stock_ticker <- "ROG.VX"  # IMPORTANT:  which stock do you want to model?
begin_date   <- "2014-06-01"  # IMPORTANT:  capture historical data starting on this date
end_date     <- floor_date(today(), unit = "week") + days(1)  # end on most recent monday
n_days       <- 252 * 4  # IMPORTANT: how many days do you want to model?  252 market days per year; the longer you hold
j_prices     <- 500  # IMPORTANT: how many simulations to estimate returns? 
k_sim        <- 7  # how many simulations to visualize?



stock_dat <- getSymbols(stock_ticker, 
                        auto.assign = FALSE, 
                        src = "yahoo",
                        from = begin_date, to = end_date)
stock_log_returns <- stock_dat %>%   
    Ad() %>% 
    dailyReturn(type='log')

# start simulating prices from most recent date
# Simulation parameters

stock_avg    <- mean(stock_log_returns)
stock_stdev  <- sd(stock_log_returns) 
price      <- rep(NA,      n_days * k_sim)
simulation <- rep(1:k_sim, n_days) %>% 
    sort()
stock_init_price <- stock_dat %>% 
    Ad() %>% 
    as.data.frame() %>% 
    mutate(., date = rownames(.)) %>% 
    filter(date(date) == max(date)) %>%
    select(ends_with("Adjusted")) %>%
    as.numeric()

# Monte Carlo aka 0-order MM
#  for each simulation trial, calculate a random walk of stock prices
for(sim in 0:(k_sim - 1)) {
    for(i in 2:n_days) {
        if(i == 2)  { price[sim * n_days + i - 1]  <- stock_init_price }
        delta <- rnorm(1, stock_avg, stock_stdev)
        price[sim * n_days + i] <- price[sim * n_days + i - 1] * exp(delta)   
    }
}


simulate_closing_price <- function(n_days, price, avg, stdev){
    deltas        <- rnorm(n_days, avg, stdev)
    sample_path   <- cumprod(c(price, 1 + deltas))
    closing_price <- sample_path[1 + n_days]
    closing_price    
}

stock_closing_price <- replicate(j_prices, 
                                 simulate_closing_price(n_days = n_days, 
                                                        price = stock_init_price, 
                                                        avg = stock_avg, 
                                                        stdev = stock_stdev))

stock_closing_price_gains_pc    <- 100 * (stock_closing_price - stock_init_price) / stock_init_price
stock_closing_price_percentiles <- quantile(stock_closing_price_gains_pc, 
                                            c(0.1, .25, 0.33, 0.5, 0.66,  0.75, 0.9))

mc_stock_prices <- data.frame(day = 1:n_days, 
                              price = price, 
                              trial = simulation)


## Random walk graph
plot_random_walk <- mc_stock_prices %>% 
    ggplot(data=., 
           aes(x = day, 
               y = price, 
               color = factor(trial))) + 
    geom_line(alpha = 0.9) + 
    geom_hline(yintercept = stock_init_price, lty = 2, color = "gray") +
    theme_bw() +
    theme(plot.title = element_text(hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5)) + 
    guides(color = F) + 
    labs(title =paste0("$", stock_ticker, " price simulation"),
         subtitle =paste0("Monte carlo simulation using price activity between\n", 
                          begin_date, " and ", end_date),
         color = "Trial",
         x = "Holding length (days)",
         y = "Price ($)")



# Compare stock performance to S&P500
voo_dat <- getSymbols("VOO", 
                      auto.assign = FALSE, 
                      src = "yahoo",
                      from = begin_date, to = end_date)
voo_log_returns <- voo_dat %>%   
    Ad() %>% 
    dailyReturn(type='log')

# model parameters
voo_avg    <- mean(voo_log_returns)
voo_stdev  <- sd(voo_log_returns) 
voo_price      <- rep(NA,      n_days * k_sim)
voo_simulation <- rep(1:k_sim, n_days) %>% 
    sort()
voo_price[1] <- voo_dat %>% 
    Ad() %>% 
    as.data.frame() %>% 
    mutate(., date = rownames(.)) %>% 
    filter(date(date) == max(date)) %>%
    select(ends_with("Adjusted")) %>%
    as.numeric()

# modeling
voo_closing_price <- replicate(j_prices, 
                               simulate_closing_price(n_days = n_days, 
                                                      price = voo_price[1], 
                                                      avg = voo_avg, 
                                                      stdev = voo_stdev))
voo_closing_price_gains_pc <- 100 * (voo_closing_price - voo_price[1]) / voo_price[1]
voo_closing_price_percentiles <- quantile(voo_closing_price_gains_pc, 
                                          c(0.1, .25, 0.33, 0.5, 0.66,  0.75, 0.9))

# report out
price_results <- data.frame(percentile = names(stock_closing_price_percentiles),
                            stock_price = quantile(stock_closing_price,
                                                   c(0.1, .25, 0.33, 0.5, 0.66,  0.75, 0.9)),
                            stock_closing_price_percentiles,
                            voo_closing_price_percentiles) %>%
    mutate(stock_price = round(stock_price, 2),
           stock_closing_price_percentiles = round(stock_closing_price_percentiles, 1),
           voo_closing_price_percentiles = round(voo_closing_price_percentiles, 1)) 


price_results %>% kable(col.names = c("Percentile", 
                                      paste0(stock_ticker, " Final Price ($)"),
                                      paste0(stock_ticker, " Price change (%)"),
                                      paste0("VOO Price change (%)")))


## Visualize probability of price distribution
plot_price_dist <- stock_closing_price_gains_pc %>% data.frame(price = .) %>%
    ggplot(aes(x = price)) +
    geom_density() +
    geom_density(data = data.frame(price = voo_closing_price_gains_pc), 
                 aes(x = price), color = "gray") +
    geom_vline(xintercept = 0) +
    theme_bw() +
    theme(axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),
          plot.title = element_text(hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5)) +
    labs(title= paste0("Price distribution for $", stock_ticker, " (black)"), 
         subtitle = "Price distribution for $VOO (gray)",
         y = "Probability density",
         x = "Price performance (%)")