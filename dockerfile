FROM rocker/tidyverse

# Metadata
LABEL description="Image for Multiomic profiling of ER-positive HER2-negative breast cancer reveals markers associated with metastatic spread" \
    maintainer="Sergio Mosquim Junior <sergio.mosquim_junior@med.lu.se>" \
    version="1.1.0" 

# Use bash as shell
SHELL ["/bin/bash", "--login", "-c"]

# Install python, pip3
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libglpk-dev \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Java and nextflow
ENV JAVA_HOME=/opt/java/openjdk
COPY --from=eclipse-temurin:21 $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"
RUN curl -s https://get.nextflow.io | bash
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

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
