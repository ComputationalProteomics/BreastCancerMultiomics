FROM rocker/tidyverse

# Metadata
LABEL description = "Image for Multiomics Analysis under SCAN-B project"
MAINTAINER "Sergio Mosquim Junior" sergio.mosquim_junior@immun.lth.se

# Use bash as shell
SHELL ["/bin/bash", "--login", "-c"]

# Install Python, quarto and nextflow
RUN /rocker_scripts/install_python.sh
RUN /rocker_scripts/install_quarto.sh
RUN curl -s https://get.nextflow.io | bash
