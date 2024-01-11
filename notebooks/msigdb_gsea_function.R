# Proteome function
gseaMsigDBProt <- function(data,genecol='Genes',qvaluecutoff,padjustmethod='fdr',species='Homo sapiens',category='H',FCcolname='1-0_log2FoldChange',...){
  data <- read_tsv(data) %>%
    as_tibble() %>% 
    dplyr::mutate(pick(genecol,FCcolname),.keep = 'none') %>% 
    dplyr::filter(!is.na(.[,FCcolname])) %>% 
    dplyr::group_by(.[,genecol]) %>% 
    group_nest()
  genelist <- purrr::map(data$data,~median(.x[[FCcolname]],na.rm=T)) %>% unlist
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
gseaMsigDBPhospho <- function(data,genecol='Genes',sequenceCol = 'Stripped.Sequence',qvaluecutoff,padjustmethod='fdr',species='Homo sapiens',category='H',FCcolname='1-0_log2FoldChange',...){
  data <- read_tsv(data) %>%
    as_tibble() %>% 
    dplyr::mutate(pick(genecol,sequenceCol,FCcolname),.keep = 'none') %>% 
    dplyr::filter(!is.na(.[,FCcolname])) %>% 
    dplyr::group_by(.[,sequenceCol]) %>% 
    group_nest()
  geneNames <- purrr::map(data$data,~pluck(.x = .x,genecol)) %>%  purrr::map(.,unique) %>% purrr::map(.,~pluck(.x,1)) %>% list_simplify()
  genelist <-  purrr::map(data$data,~median(.x[[FCcolname]],na.rm=T)) %>% unlist
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
gseaMsigDBRNA <- function(data,genecol='Gene',qvaluecutoff,padjustmethod='fdr',species='Homo sapiens',category='H',FCcolname='1-0_log2FoldChange',...){
  data <- read_tsv(data) %>% 
    dplyr::mutate(Gene=str_split_i(string = Gene,pattern = '\\.',i = 1))
  FCcol <- data %>% dplyr::pull(FCcolname)
  data <- data %>% dplyr::filter(!is.na(FCcol))
  genelist <- data %>% dplyr::pull(FCcolname)
  names(genelist) <- data %>% dplyr::pull(genecol)
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