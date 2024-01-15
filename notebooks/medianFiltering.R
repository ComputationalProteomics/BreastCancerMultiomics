medianFiltering <- function(data,design,sampleCol,annotation,...){
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
    filter(variance > quantile(variance,0.5,na.rm = T))
  
  return(lowVarData)
}