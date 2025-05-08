# =================================================================================
# Stock_Market_Analysis.R
#
# A comprehensive R script to fetch, analyze, and visualize stock price data
# for multiple tickers using quantmod & PerformanceAnalytics.
#
# Features:
#   1. Downloads daily adjusted closing prices for a set of tickers from Yahoo Finance.
#   2. Calculates 20-day & 50-day SMAs.
#   3. Computes daily log returns & 20-day rolling volatility.
#   4. Generates for each ticker:
#        • Price chart with SMAs
#        • Daily returns time series
#        • Histogram of returns
#        • Rolling volatility chart
#        • Cumulative returns chart
#        • Boxplot of monthly returns
#   5. Comparative normalized performance chart.
#   6. Saves each plot as plot-1.png through plot-43.png
#
# Dependencies:
#   - quantmod
#   - PerformanceAnalytics
#   - zoo
#
# Usage:
#   1. Ensure R ≥ 4.0 is installed.
#   2. source("Stock_Market_Analysis.R")
# =================================================================================

# 0. Install & load required packages
pkgs <- c("quantmod", "PerformanceAnalytics", "zoo")
for(pkg in pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
  library(pkg, character.only = TRUE)
}

# 1. Define tickers and date range
tickers    <- c("AAPL","MSFT","GOOG","AMZN","TSLA","NFLX","NVDA")
start_date <- as.Date("2020-01-01")
end_date   <- Sys.Date()

# 2. Fetch data
getSymbols(tickers, src = "yahoo",
           from = start_date, to = end_date,
           auto.assign = TRUE)

# 3. Processing function
process_symbol <- function(sym) {
  adj    <- Ad(get(sym))                           # Adjusted close price
  sma20  <- SMA(adj, n = 20)                       # 20-day SMA
  sma50  <- SMA(adj, n = 50)                       # 50-day SMA
  ret    <- dailyReturn(adj, type = "log")         # Daily log returns
  vol20  <- runSD(ret, n = 20) * sqrt(252)         # 20-day rolling volatility (annualized)
  mo_ret <- monthlyReturn(adj, type = "log")       # Monthly log returns
  
  list(
    adj    = adj,
    sma20  = sma20,
    sma50  = sma50,
    ret    = ret,
    vol20  = vol20,
    mo_ret = mo_ret
  )
}

# 4. Process all tickers
stock_data <- setNames(lapply(tickers, process_symbol), tickers)

# 5. Per‐ticker analyses (6 plots per ticker)
plot_counter <- 1

for(sym in tickers) {
  data <- stock_data[[sym]]
  
  # 5.1 Price chart with SMAs
  png(sprintf("plot-%d.png", plot_counter), width=800, height=600)
  par(bg="white")
  chartSeries(get(sym),
              name  = paste(sym, "Price + SMAs"),
              TA    = NULL,
              theme = chartTheme("white"))
  addTA(data$sma20, on = 1, col = "blue", lwd = 1.5)
  addTA(data$sma50, on = 1, col = "red",  lwd = 1.5)
  dev.off()
  plot_counter <- plot_counter + 1
  
  # 5.2 Daily returns time series
  png(sprintf("plot-%d.png", plot_counter), width=800, height=600)
  par(bg="white")
  chartSeries(data$ret,
              name  = paste(sym, "Daily Log Returns"),
              TA    = NULL,
              theme = chartTheme("white"))
  dev.off()
  plot_counter <- plot_counter + 1
  
  # 5.3 Histogram of daily returns
  png(sprintf("plot-%d.png", plot_counter), width=800, height=600)
  par(bg="white")
  hist(as.numeric(data$ret),
       breaks = 50,
       main   = paste(sym, "Histogram of Daily Returns"),
       xlab   = "Daily Log Return",
       col    = "lightgray",
       border = "white")
  dev.off()
  plot_counter <- plot_counter + 1
  
  # 5.4 Rolling volatility
  png(sprintf("plot-%d.png", plot_counter), width=800, height=600)
  par(bg="white")
  chartSeries(data$vol20,
              name  = paste(sym, "20-Day Rolling Volatility"),
              TA    = NULL,
              theme = chartTheme("white"))
  dev.off()
  plot_counter <- plot_counter + 1
  
  # 5.5 Cumulative returns
  cum_ret <- cumprod(1 + data$ret) - 1
  png(sprintf("plot-%d.png", plot_counter), width=800, height=600)
  par(bg="white")
  chartSeries(cum_ret,
              name  = paste(sym, "Cumulative Returns"),
              TA    = NULL,
              theme = chartTheme("white"))
  dev.off()
  plot_counter <- plot_counter + 1
  
  # 5.6 Monthly return boxplot
  png(sprintf("plot-%d.png", plot_counter), width=800, height=600)
  par(bg="white")
  boxplot(as.numeric(data$mo_ret),
          main   = paste(sym, "Monthly Log Returns"),
          ylab   = "Log Return",
          col    = "skyblue",
          border = "darkblue")
  dev.off()
  plot_counter <- plot_counter + 1
}

# 6. Comparative normalized performance (1 plot)
# Merge all adjusted series into one xts object
adj_all <- do.call(merge, lapply(stock_data, `[[`, "adj"))
colnames(adj_all) <- tickers

# Normalize so each series starts at 100
norm_prices <- sweep(adj_all, 2,
                     as.numeric(adj_all[1, , drop = TRUE]),
                     FUN = "/") * 100

png(sprintf("plot-%d.png", plot_counter), width=800, height=600)
par(bg="white")
plot.zoo(norm_prices,
         screens = 1,
         col     = rainbow(length(tickers)),
         lwd     = 2,
         main    = "Normalized Price Performance (Base = 100)",
         xlab    = "Date",
         ylab    = "Normalized Price")
legend("topleft",
       legend = tickers,
       col    = rainbow(length(tickers)),
       lwd    = 2,
       bty    = "n")
dev.off()
plot_counter <- plot_counter + 1

# 7. Print summary statistics for each ticker’s returns
for(sym in tickers) {
  cat("\n=== Summary stats for", sym, "===\n")
  print(table.Stats(stock_data[[sym]]$ret))
}

# =================================================================================
# End of Stock_Market_Analysis.R
# =================================================================================
# Note: Ensure to run this script in a directory where you have write permissions
