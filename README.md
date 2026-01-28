# BreastCancerMultiomics
[![DOI](https://img.shields.io/badge/DOI-10.1186%2Fs13058--025--02173--9-blue)](https://doi.org/10.1186/s13058-025-02173-9)
[![Journal](https://img.shields.io/badge/Journal-Breast%20Cancer%20Research-green)](https://link.springer.com/article/10.1186/s13058-025-02173-9)
[![PRIDE](https://img.shields.io/badge/PRIDE-PXD059920-orange)](https://www.ebi.ac.uk/pride/archive/projects/PXD059920)
[![Docker Image](https://img.shields.io/badge/Docker-GHCR-blue?logo=docker)](https://ghcr.io/computationalproteomics/breastcancermultiomics/multiomics_analysis)
[![R](https://img.shields.io/badge/R-%E2%89%A54.0-276DC3?logo=r)](https://www.r-project.org/)
[![renv](https://img.shields.io/badge/renv-enabled-2C7FB8)](https://rstudio.github.io/renv/)
[![License](https://img.shields.io/github/license/ComputationalProteomics/BreastCancerMultiomics)](LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/ComputationalProteomics/BreastCancerMultiomics)](https://github.com/ComputationalProteomics/BreastCancerMultiomics)

**Integrative multi-omics analysis of ER-positive, HER2-negative breast cancer**

This repository contains code, notebooks, and workflows supporting the study:

```text
Mosquim Junior, S., Zamore, M., Vallon-Christersson, J. et al. Multiomic profiling of ER-positive HER2-negative breast cancer reveals markers associated with metastatic spread. Breast Cancer Res 28, 12 (2026). https://doi.org/10.1186/s13058-025-02173-9
```

The project focuses on identifying molecular features associated with lymph-node and distant metastasis by adopting a multi-omics approach which integrates proteomics, phosphoproteomics, transcriptomics and clinical data.

---

## Overview

According to recent statistics, Breast Cancer is the most commonly diagnosed cancer and a leading cause of cancer-related mortality among women. In the past few decades, considerable advances were made in molecular characterization of the disease and early detection, contributing to improved patient stratification and reduced mortality.
However, despite these advances, metastatic disease continues to represent the main cause of cancer-related deaths.
In this work, a multi-omics approach was adopted for the molecular profiling of primary breast tumor tissues and identification of potential subtypes and markers associated with metastatic processes.

This repository enables:
- Reproducible analysis of the collected multi-omics data
- Exploration of consensus clustering and survival analyses
- Reproduction of key figures and results from the publication

---

## Repository Structure

```text
.
├── Dockerfile              # Container for reproducible execution
├── README.md
├── docker-compose.yaml    # Docker compose for running the pipeline
├── entrypoint.sh          # Entrypoint script
├── notebooks/              # R notebooks for analysis and visualization
├── renv/                   # R environment management files
├── renv.lock               # Locked package versions
└── .gitignore
```

## Reproducing the Analyses

Using the Docker container is recommended for full reproducibility

1. Clone the repository

```bash
git clone https://github.com/ComputationalProteomics/BreastCancerMultiomics.git
```

2. Download the data from PRIDE (PXD059920)

```text
diann_search_results_phosphoproteomics.zip
diann_search_results_proteomics.zip
```

3. 7zip might be required to extract only the required files for the analysis

    On macOS:

    ```bash
    brew install p7zip
    ```

    On Linux (Ubuntu/Debian):

    ```bash
    sudo apt install p7zip-full
    ```

4. Extract the data files

```bash
mkdir -p BreastCancerMultiomics/data/proteomics/{full,phospho}

7z e diann_search_results_phosphoproteomics.zip "230815_report.pr_matrix.tsv" -oBreastCancerMultiomics/data/proteomics/phospho/
7z e diann_search_results_proteomics.zip "230814_report.pg_matrix.tsv" "230814_report.pr_matrix.tsv" -oBreastCancerMultiomics/data/proteomics/full/
```

5. Pull the docker image

```bash
docker pull ghcr.io/computationalproteomics/breastcancermultiomics/multiomics_analysis:latest
```

6. Run the pipeline

```bash
PUID=$(id -u) PGID=$(id -g) docker compose -f BreastCancerMultiomics/docker-compose.yaml run --rm analysis_pipeline
```

---

## Citation

If you use this repository or its contents, please cite:

```bash
Mosquim Junior, S., Zamore, M., Vallon-Christersson, J. et al. Multiomic profiling of ER-positive HER2-negative breast cancer reveals markers associated with metastatic spread. Breast Cancer Res 28, 12 (2026). https://doi.org/10.1186/s13058-025-02173-9
```
