FROM rocker/tidyverse

# Open Container Initiative (OCI) Standard Metadata
LABEL org.opencontainers.image.title="multiomics_analysis" \
    org.opencontainers.image.version="1.2.0" \
    org.opencontainers.image.description="Image for Multiomic profiling of ER-positive HER2-negative breast cancer reveals markers associated with metastatic spread" \
    org.opencontainers.image.authors="Sergio Mosquim Junior <sergio.mosquim_junior@med.lu.se>" \
    org.opencontainers.image.source="https://github.com/ComputationalProteomics/BreastCancerMultiomics" \
    org.opencontainers.image.licenses="MIT" 

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

# Copy additional files
COPY ./data/ ./data/

# Add transcriptomics data from https://data.mendeley.com/datasets/yzxtxn4nmd 
# Vallon-Christersson, Johan (2025), “RNA Sequencing-Based Single Sample Predictors of Molecular Subtype and Risk of Recurrence for Clinical Assessment of Early-Stage Breast Cancer”, Mendeley Data, V4, doi: 10.17632/yzxtxn4nmd.4
# CC BY 4.0 licence https://creativecommons.org/licenses/by/4.0/
RUN mkdir -p ./data/transcriptomics/
RUN curl -L -o ./data/transcriptomics/SCANB.9206.genematrix_noNeg.Rdata \
    https://data.mendeley.com/public-files/datasets/yzxtxn4nmd/files/c066599b-666d-4e02-8f5d-845c2dc03c50/file_downloaded
RUN curl -L -o ./data/transcriptomics/Gene.ID.ann.Rdata \
    https://data.mendeley.com/public-files/datasets/yzxtxn4nmd/files/55160846-1966-46dd-a62a-fda51a9a4659/file_downloaded

# Install required R packages
COPY ./notebooks/required_packages.R ./notebooks/
RUN Rscript ./notebooks/required_packages.R
RUN R -e "installed.packages()"

# Default command
CMD /bin/bash
