FROM rocker/tidyverse

# Metadata
LABEL description = "Image for Multiomics Analysis under SCAN-B project"
MAINTAINER "Sergio Mosquim Junior" sergio.mosquim_junior@immun.lth.se

# Use bash as shell
SHELL ["/bin/bash", "--login", "-c"]

# Install python, pip3
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libglpk-dev \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python and quarto
RUN /rocker_scripts/install_python.sh
RUN /rocker_scripts/install_quarto.sh

# Set workdir
RUN mkdir -p /home/multiomics
WORKDIR /home/multiomics

# Install required R packages
COPY ./notebooks/required_packages.R ./notebooks/
RUN Rscript ./notebooks/required_packages.R
RUN R -e "installed.packages()"

# Default command
CMD /bin/bash
