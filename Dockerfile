# Base image 
FROM rocker/r-ubuntu:latest

##install packagaes from CRAN
RUN apt-get update && apt-get install -y \
    libudunits2-dev \
    libgdal-dev \
 && rm -rf /var/lib/apt/lists/*

RUN R -e "options(warn=2); install.packages('spdep')"

RUN install2.r --error \
    Rmixmod \
    ggplot2 \
    reshape2 \
    zeallot \
    optparse \
    remotes 

##install additional package CELESTA from GitHub
RUN installGithub.r plevritis/CELESTA

##Make directories
RUN mkdir -p /app

# Set the working directory 
WORKDIR /app

# Copy the current directory contents to the container at /local
COPY . . 




