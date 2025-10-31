# 0. Base Java Images (Minimal UBI tags for size/security)
FROM eclipse-temurin:21-jdk-ubi9-minimal AS temurin_jdk
FROM eclipse-temurin:21-jre-ubi9-minimal AS temurin_jre 

# Stage 1: builder 
FROM rocker/r-ver:4.4.0 AS builder

## Define user details
ARG USER_NAME=multiomics
ARG USER_UID=1000
ARG USER_GID=1000

## Set up non-root user and shell environment (required for permissions/clean setup)
SHELL ["/bin/bash", "-c"]

RUN groupadd -g ${USER_GID} ${USER_NAME} && \
    useradd -m -u ${USER_UID} -g ${USER_GID} ${USER_NAME} && \
    mkdir -p /home/${USER_NAME}/data && \
    chown -R ${USER_UID}:${USER_GID} /home/${USER_NAME}

## 1. Install ALL System Dependencies 
RUN apt-get update && \
    apt-get remove default-libmysqlclient-dev -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential cmake curl git gosu pandoc python3 python3-pip sudo \
    libgl1-mesa-dev libglu1-mesa-dev libbz2-dev libcairo2-dev \
    libcurl4-openssl-dev libfontconfig1-dev libfreetype6-dev libgdal-dev \
    libgeos-dev libharfbuzz-dev libjpeg-dev liblzma-dev \
    libpng-dev libproj-dev libssl-dev libtiff5-dev libudunits2-dev \
    libxml2-dev libxt-dev libzstd-dev zlib1g-dev libhdf5-dev \
    libgraphviz-dev libpq-dev libv8-dev libprotobuf-dev libglpk-dev libglpk40 \
    ca-certificates net-tools wget unzip less vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

## 2. Install Java (JDK) and Nextflow
ENV JAVA_HOME=/opt/java/openjdk
COPY --from=temurin_jdk $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV NEXTFLOW_HOME=/usr/local/bin
ENV NFCORE_ENABLE_CUSTOM_CONTENT=true
RUN curl -s https://get.nextflow.io | bash \
    && mv nextflow $NEXTFLOW_HOME/nextflow

## 3. Install Python and Quarto
RUN QUARTO_VERSION="1.8.25" \
    && curl -o quarto.deb -L "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" \
    && dpkg -i quarto.deb \
    && rm quarto.deb \
    && ln -sf /opt/quarto/bin/quarto /usr/local/bin/quarto

## 4. Prepare Work Directory and Copy R dependencies
WORKDIR /home/${USER_NAME}

### Set environment variables for the multiomics user
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/quarto/bin:${PATH}"

### Switch to non-root user for file operations
USER ${USER_NAME}

### Copy project files and ensure correct ownership
COPY --chown=${USER_UID}:${USER_GID} ./data/ ./data/
COPY --chown=${USER_UID}:${USER_GID} renv.lock renv.lock

## 5. Install R Packages (Prep for restore in final stage)
### We temporarily switch to root only to access the cache mount paths
USER root

### Install renv globally in the builder, but skip restore
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"

### Run RENV RESTORE and Finalize

### Define all necessary repositories (CRAN + Bioconductor 3.20 and 3.19)
ENV R_REPOS="https://p3m.dev/cran/latest,https://bioconductor.org/packages/3.20/bioc,https://bioconductor.org/packages/3.20/data/annotation,https://bioconductor.org/packages/3.19/bioc,https://bioconductor.org/packages/3.19/data/annotation"

### Restore packages using the new, clean lockfile
RUN Rscript -e "\
    # 1. SET OPTIONS for network stability \
    options(timeout = 180,renv.download.retry = 10 ); \
    # Properly parse and set the combined repository URLs \
    repo_urls <- strsplit(Sys.getenv('R_REPOS'), ',')[[1]]; \
    names(repo_urls) <- c('CRAN', 'BioC320', 'BioCData320', 'BioC319', 'BioCData319'); \
    options(repos = repo_urls);"

RUN R -s -e "options(configure.args = c(preprocessCore = '--disable-threading')); \
              renv::restore(rebuild = 'preprocessCore')"

RUN chown -R ${USER_UID}:${USER_GID} /usr/local/lib/R/site-library

USER ${USER_NAME}
## 6. Download Data
### Add transcriptomics data from https://data.mendeley.com/datasets/yzxtxn4nmd 
### Vallon-Christersson, Johan (2025), “RNA Sequencing-Based Single Sample Predictors of Molecular Subtype and Risk of Recurrence for Clinical Assessment of Early-Stage Breast Cancer”, Mendeley Data, V4, doi: 10.17632/yzxtxn4nmd.4
### CC BY 4.0 licence https://creativecommons.org/licenses/by/4.0/
RUN mkdir -p ./data/transcriptomics/ \
    && curl -L -o ./data/transcriptomics/SCANB.9206.genematrix_noNeg.Rdata \
        https://data.mendeley.com/public-files/datasets/yzxtxn4nmd/files/c066599b-666d-4e02-8f5d-845c2dc03c50/file_downloaded \
    && curl -L -o ./data/transcriptomics/Gene.ID.ann.Rdata \
        https://data.mendeley.com/public-files/datasets/yzxtxn4nmd/files/55160846-1966-46dd-a62a-fda51a9a4659/file_downloaded

# Stage 2: final
FROM rocker/r-ver:4.4.0 AS final

USER root

## Open Container Initiative (OCI) Standard Metadata
LABEL org.opencontainers.image.title="multiomics_analysis" \
    org.opencontainers.image.version="2.0.0" \
    org.opencontainers.image.description="Image for Multiomic profiling of ER-positive HER2-negative breast cancer reveals markers associated with metastatic spread" \
    org.opencontainers.image.authors="Sergio Mosquim Junior <sergio.mosquim_junior@med.lu.se>" \
    org.opencontainers.image.source="https://github.com/ComputationalProteomics/BreastCancerMultiomics"\
    org.opencontainers.image.licenses="MIT"

## Define user details
ARG USER_NAME=multiomics
ARG USER_UID=1000
ARG USER_GID=1000
ENV PUID=1000
ENV PGID=1000

## 1. Install only essential RUNTIME libraries
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl git pandoc libcurl4 libxml2 libssl3 libgl1-mesa-glx libglu1-mesa \
    libhdf5-103 graphviz libpq5 libgdal30 libgeos-c1v5 libproj22 \
    libglpk40 libc6 libstdc++6 libaio1 \
    ca-certificates net-tools wget unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

## 2. Set up User, Work Directory, and Environment
RUN groupadd -g ${USER_GID} ${USER_NAME} && \
    useradd -m -u ${USER_UID} -g ${USER_GID} ${USER_NAME} && \
    mkdir -p /home/${USER_NAME}/data && \
    chown -R ${USER_UID}:${USER_GID} /home/${USER_NAME}
WORKDIR /home/${USER_NAME}

ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/quarto/bin:${PATH}"

## 3. Copy Java (JRE)
COPY --from=temurin_jre $JAVA_HOME $JAVA_HOME

## 4. Copy essential files from the builder stage
### Copy Nextflow and Quarto binaries
COPY --from=builder /usr/local/bin/nextflow /usr/local/bin/nextflow
COPY --from=builder /opt/quarto/ /opt/quarto/
COPY --from=builder /usr/sbin/gosu /usr/local/bin/gosu

### Copy R library and project files
COPY --from=builder /usr/local/lib/R/site-library/ /usr/local/lib/R/site-library/
COPY --chown=${USER_UID}:${USER_GID} --from=builder /home/${USER_NAME}/ ./

## 5. Permission fix and entrypoint
RUN chmod 755 /usr/local/bin/nextflow && \
    chmod -R a+x ${JAVA_HOME}/bin && \
    mkdir -p /home/${USER_NAME}/.nextflow && \
    chown -R ${USER_UID}:${USER_GID} /home/${USER_NAME}/.nextflow && \
    chown -R ${USER_UID}:${USER_GID} /home/${USER_NAME} 

## Entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

## Final command:
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"] 