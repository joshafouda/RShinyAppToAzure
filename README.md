# Partie 1 : Construire l'image Docker

```bash
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
```

Pour build l'image : sudo docker build -t myshinyappimg .

Pour exécuter le container : sudo docker run -d -p 6378:6378 --name myshinyapp myshinyappimg:latest

Pour voir l'application en local : http://127.0.0.1:6378

# Partie 2 : Pusher l'image Docker dans un Azure Container Registry 

```yaml
name: Azure Container Registry

on:
  push:
    branches:
      main
      
env:
  IMAGE_NAME: myshinyappimg
  
jobs:
  build:
    name: Build container image
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      - name: Log into registry
        uses: docker/login-action@v3
        with:
          registry: ${{ secrets.FST_ENDPOINT }}
          username: ${{ secrets.FST_USERNAME }}
          password: ${{ secrets.FST_PASSWORD }}
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          push: true
          tags: ${{ secrets.FST_ENDPOINT }}/${{ env.IMAGE_NAME }}
```

Il s'agit ici de créer un fichier yaml qui est une configuration de workflow GitHub Actions qui automatise le processus de création et de transfert d'une image Docker vers un Azure Container Registry à chaque fois qu'il y a un transfert vers la branche principale.


