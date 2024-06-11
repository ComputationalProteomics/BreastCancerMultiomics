# Required packages

install.packages(pkgs = 'pak',clean = TRUE,quiet = TRUE,dependencies = TRUE)

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
  'tidymodels',
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
  'mixOmics')

# packages_bioconductor <- c('enrichplot',
#                            'AnnotationDbi',
#                            'NormalyzerDE',
#                            'clusterProfiler',
#                            'MOFA2',
#                            'org.Hs.eg.db',
#                            'ConsensusClusterPlus',
#                            'ComplexHeatmap',
#                            'mixOmics')

packageCheckInstall <- function(x){
  if(!require(x,quietly = FALSE,character.only = TRUE)){
    pak::pkg_install(pkg = x,ask = FALSE,dependencies = TRUE)
  }
}

# packageCheckBioconductor <- function(x){
#   if(!require(x,quietly = FALSE,character.only = TRUE)){
#     BiocManager::install(pkgs = x,update = TRUE,ask = FALSE,force = TRUE)
#   }
# }

lapply(X = packages,FUN = packageCheckInstall)
# lapply(X = packages_bioconductor,FUN = packageCheckBioconductor)
BiocManager::install("preprocessCore", configure.args = c(preprocessCore = "--disable-threading"), force= TRUE, update=TRUE, type = "source")

pak::pak_cleanup(package_cache = TRUE,metadata_cache = TRUE,force = TRUE)