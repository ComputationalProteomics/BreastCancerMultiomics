gseaMsigDB <- function(data,genecol='Genes',qvaluecutoff,padjustmethod='fdr',species='Homo sapiens',category='H',FCcolname='1-0_log2FoldChange',...){
  data <- read_tsv(data)
  FCcol <- data %>% dplyr::pull(FCcolname)
  data <- data %>% filter(!is.na(FCcol))
  genelist <- data %>% pull(FCcolname)
  names(genelist) <- data %>% dplyr::pull(genecol)
  genelist <- na.omit(genelist)
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