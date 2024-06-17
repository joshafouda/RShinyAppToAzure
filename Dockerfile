# Use the rocker/r-ver base image for R 4.1.2
FROM rocker/r-ver:4.1.2

# Install system dependencies for R packages
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libv8-dev \
    libfontconfig1-dev \
    libxt-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libpng-dev \
    libtiff-dev \
    libjpeg-dev \
    build-essential

# Install remotes package and specific version of renv
RUN R -e "install.packages('remotes')"
RUN R -e "remotes::install_version('renv', version = '1.0.7', repos = 'https://cran.rstudio.com/')"
RUN R -e "options(renv.config.repos.override = 'https://packagemanager.posit.co/cran/latest')"

# Copy the entire app directory to /app in the container
COPY . /app

# Set the working directory to /app
WORKDIR /app

# Restore R package environment based on renv.lock
RUN R -e "renv::restore()"

# Expose port 6378 for the Shiny app
EXPOSE 6378

# Run the Shiny app on port 6378
CMD ["R", "-e", "shiny::runApp('./app.R', host = '0.0.0.0', port = 6378)"]
