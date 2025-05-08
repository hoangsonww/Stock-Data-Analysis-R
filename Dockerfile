# Dockerfile

FROM rocker/tidyverse:latest

# Install additional dependencies
RUN install2.r --error \
    quantmod \
    PerformanceAnalytics \
    zoo \
    rmarkdown

# Copy project files
WORKDIR /home/project
COPY . /home/project

# Expose port if you want to serve (optional)
# EXPOSE 8787

# Default: run the analysis and exit
CMD ["bash", "-lc", "Rscript -e \"rmarkdown::render('Stock_Market_Analysis.Rmd')\""]
