# Ensure 'renv' and 'pak' are installed
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv", repos = getOption("repos"), dependencies = TRUE)
}
if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak", repos = getOption("repos"), dependencies = TRUE)
}

# Restore packages from renv lockfile
renv::restore(
  lockfile = '/home/multiomics/data/renv/renv.lock',
  prompt = FALSE,
  # EXCLUDE the BiocStyle package from the renv restore process:
  exclude = c('BiocStyle', 'DOSE', 'GOSemSim')
)

renv::install(packages = c('bioc::BiocStyle@2.32.0', 'bioc::DOSE@3.30.1', 'GOSemSim@2.30.0'))

packages <- c(
  'quarto',
  'igraph',
  'tidyverse',
  'argparser',
  'devtools',
  'ggplotify',
  'msigdbr',
  'psych',
  'future',
  'future.callr',
  'furrr',
  'tidymodels',
  'cluster',
  'factoextra',
  'gprofiler2',
  'BiocManager',
  'censored',
  'glmnet',
  'survival',
  'survminer',
  'forestmodel',
  'gridExtra',
  'grDevices',
  'enrichplot',
  'AnnotationDbi',
  'NormalyzerDE',
  'clusterProfiler',
  'MOFA2',
  'org.Hs.eg.db',
  'ConsensusClusterPlus',
  'ComplexHeatmap',
  'patchwork', 
  'cowplot',
  'ggpubr',
  'ggrepel',
  'gt',
  'gtsummary',
  'webshot2',
  'Biostrings',
  'cmapR',
  'nicolerg/ssGSEA2',
  'openxlsx',
  'outliers',
  'matrixStats')


missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if(length(missing)) {
  message("Installing missing packages with pak: ", paste(missing, collapse = ", "))

  pak::pkg_install(missing, upgrade = FALSE, ask = FALSE)

  if (length(missing) > 0) {
      message("Updating renv.lock with newly installed packages.")
      renv::snapshot(prompt = FALSE)
  }
}

pak::pak_cleanup(package_cache = TRUE,metadata_cache = TRUE,force = TRUE)