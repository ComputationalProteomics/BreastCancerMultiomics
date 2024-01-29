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


# Function to filter rows after a threshold of NA values
NAFiltering <- function(data,design,sampleCol,cutoff=0.3,...){
  countNA <- function(x) {
    naCount <- is.na(x) %>% sum()
    cutoff <- naCount/length(x)
    return(cutoff)
  }
  
  NAData <- data %>% 
    dplyr::select(design[[sampleCol]]) %>% 
    t %>% 
    as_tibble %>% 
    map_dfc(.,countNA) %>% 
    t
  
  dataNA <- data %>% 
    mutate(number.NA=NAData)
  
  filteredData <- dataNA %>% 
    filter(number.NA <= cutoff) %>% 
    dplyr::select(-c('number.NA'))
  
  return(filteredData)
}
