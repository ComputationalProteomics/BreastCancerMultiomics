# Proteome function
gseaMsigDBProt <- function(data,genecol='Genes',qvaluecutoff,padjustmethod='fdr',species='Homo sapiens',category='H',...){
  data <- read_tsv(data) 
  comparison <- data %>% dplyr::select(contains('FoldChange')) %>% colnames %>% str_split_i(pattern = '\\_',i = 1)
  FCCol <- paste0(comparison,'_log2FoldChange')
  PValCol <- paste0(comparison,'_PValue')
  
  data <- data %>% 
    dplyr::mutate(signedPVal = (-log10(.[[PValCol]])/(sign(.[[FCCol]])))) %>% 
    dplyr::select(genecol,signedPVal) %>% 
    dplyr::filter(!is.na(signedPVal)) %>% 
    dplyr::group_by(.[,genecol]) %>% 
    group_nest()
  genelist <- purrr::map(data$data,~median(.x$signedPVal,na.rm=T)) %>% unlist
  names(genelist) <- data %>% dplyr::pull(genecol)
  genelist <- sort(x = genelist,decreasing = TRUE)
  
  term2gene <- msigdbr(species = species,category = category) %>% dplyr::select(gs_name,human_gene_symbol)
  
  gseResults <- clusterProfiler::GSEA(geneList = genelist,
                                      pAdjustMethod = 'fdr',
                                      eps = 0,
                                      pvalueCutoff = qvaluecutoff,
                                      TERM2GENE = term2gene,
                                      by = 'fgsea')
  
  return(gseResults)
}

# Phosphopeptide function
gseaMsigDBPhospho <- function(data,genecol='Genes',sequenceCol = 'Stripped.Sequence',qvaluecutoff,padjustmethod='fdr',species='Homo sapiens',category='H',...){
  data <- read_tsv(data) 
  comparison <- data %>% dplyr::select(contains('FoldChange')) %>% colnames %>% str_split_i(pattern = '\\_',i = 1)
  FCCol <- paste0(comparison,'_log2FoldChange')
  PValCol <- paste0(comparison,'_PValue')
  
  data <- data %>% 
    dplyr::mutate(signedPVal = (-log10(.[[PValCol]])/(sign(.[[FCCol]])))) %>% 
    dplyr::select(genecol,sequenceCol,signedPVal) %>% 
    dplyr::filter(!is.na(signedPVal)) %>% 
    dplyr::group_by(.[,sequenceCol]) %>% 
    group_nest()
  geneNames <- purrr::map(data$data,~pluck(.x = .x,genecol)) %>%  purrr::map(.,unique) %>% purrr::map(.,~pluck(.x,1)) %>% list_simplify()
  genelist <-  purrr::map(data$data,~median(.x$signedPVal,na.rm=T)) %>% unlist
  names(genelist) <- geneNames
  genelist <- sort(x = genelist,decreasing = TRUE)
  
  term2gene <- msigdbr(species = species,category = category) %>% dplyr::select(gs_name,human_gene_symbol)
  
  gseResults <- clusterProfiler::GSEA(geneList = genelist,
                                      pAdjustMethod = 'fdr',
                                      eps = 0,
                                      pvalueCutoff = qvaluecutoff,
                                      TERM2GENE = term2gene,
                                      by = 'fgsea')
  
  return(gseResults)
}

# Transcriptome function
gseaMsigDBRNA <- function(data,genecol='Gene',qvaluecutoff,padjustmethod='fdr',species='Homo sapiens',category='H',...){
  data <- read_tsv(data) %>% 
    dplyr::mutate(Gene=str_split_i(string = Gene.ID,pattern = '\\.',i = 1))
  comparison <- data %>% dplyr::select(contains('FoldChange')) %>% colnames %>% str_split_i(pattern = '\\_',i = 1)
  FCCol <- paste0(comparison,'_log2FoldChange')
  PValCol <- paste0(comparison,'_PValue')
  
  data <- data %>% 
    dplyr::mutate(signedPVal = (-log10(.[[PValCol]])/(sign(.[[FCCol]])))) %>% 
    dplyr::filter(!is.na(signedPVal))
  genelist <- data$signedPVal
  names(genelist) <- data$Gene
  genelist <- na.omit(genelist)
  genelist <- sort(x = genelist,decreasing = TRUE)
  
  term2gene <- msigdbr(species = species,category = category) %>% dplyr::select(gs_name,human_ensembl_gene)
  
  gseResults <- clusterProfiler::GSEA(geneList = genelist,
                                      pAdjustMethod = 'fdr',
                                      eps = 0,
                                      pvalueCutoff = qvaluecutoff,
                                      TERM2GENE = term2gene,
                                      by = 'fgsea')
  
  return(gseResults)
}

# Function using the weights from MOFA model
gseaMsigMOFA <- function(model, factor=1, qvaluecutoff, padjustmethod='fdr', species='Homo sapiens', category='H',...){
  weights <- get_weights(object = model,views = 'all',factors = 'all',as.data.frame = TRUE)
  factor <- paste0('Factor',factor)
  prot_weights <- weights %>% filter(view=='proteomics',factor==factor) %>% 
    dplyr::mutate(pick(feature,value),.keep = 'none') %>%
    dplyr::group_by(feature) %>%
    group_nest()
  phospho_weights <- weights %>% filter(view=='phosphoproteomics',factor==factor) %>% 
    dplyr::mutate(pick(feature,value),.keep = 'none') %>%
    dplyr::group_by(feature) %>%
    group_nest()
  rna_weights <- weights %>% filter(view=='transcriptomics',factor==factor) %>% 
    dplyr::mutate(pick(feature,value),.keep = 'none') %>%
    dplyr::group_by(feature) %>%
    group_nest()
  
  genelistProteome <- purrr::map(prot_weights$data,~median(.x[['value']],na.rm=T)) %>% unlist
  names(genelistProteome) <- prot_weights %>% dplyr::pull(feature)
  genelistProteome <- sort(x = genelistProteome,decreasing = TRUE)
  
  genelistPhospho <- purrr::map(phospho_weights$data,~median(.x[['value']],na.rm=T)) %>% unlist
  names(genelistPhospho) <- phospho_weights %>% dplyr::pull(feature)
  genelistPhospho <- sort(x = genelistPhospho,decreasing = TRUE)
  
  genelistRNA <- purrr::map(rna_weights$data,~median(.x[['value']],na.rm=T)) %>% unlist
  names(genelistRNA) <- rna_weights %>% dplyr::pull(feature)
  genelistRNA <- sort(x = genelistRNA,decreasing = TRUE)
  
  term2gene <- msigdbr::msigdbr(species = 'Homo sapiens',category = 'H') %>% dplyr::select(gs_name,human_gene_symbol)
  term2geneRNA <- msigdbr::msigdbr(species = 'Homo sapiens',category = 'H') %>% dplyr::select(gs_name,human_ensembl_gene)
  
  gseResultsProteome <- clusterProfiler::GSEA(geneList = genelistProteome,
                                              pAdjustMethod = 'fdr',
                                              eps = 0,
                                              pvalueCutoff = qvaluecutoff,
                                              TERM2GENE = term2gene,
                                              by = 'fgsea')
  
  gseResultsPhospho <- clusterProfiler::GSEA(geneList = genelistPhospho,
                                             pAdjustMethod = 'fdr',
                                             eps = 0,
                                             pvalueCutoff = qvaluecutoff,
                                             TERM2GENE = term2gene,
                                             by = 'fgsea')
  
  gseResultsRNA <- clusterProfiler::GSEA(geneList = genelistRNA,
                                         pAdjustMethod = 'fdr',
                                         eps = 0,
                                         pvalueCutoff = qvaluecutoff,
                                         TERM2GENE = term2geneRNA,
                                         by = 'fgsea')
  
  results <- list(proteome=gseResultsProteome,phosphoproteome=gseResultsPhospho,transcriptomics=gseResultsRNA)
  return(results)
}