medianFiltering <- function(data,design,sampleCol,annotation,cutoff=0.5,...){
  varianceNA <- function(data) var(data,na.rm=TRUE)
  
  rowName <- pull(data,annotation)
  varianceData <- data %>% 
    dplyr::select(.,pull(design,sampleCol)) %>% 
    t %>% 
    as_tibble %>% 
    map_dfc(.,varianceNA) %>% 
    t
  
  dataVar <- data %>% 
    mutate(.,variance=varianceData,Protein=rowName)
  
  lowVarData <- dataVar %>% 
    filter(variance > quantile(variance,cutoff,na.rm = T))
  
  return(lowVarData)
}