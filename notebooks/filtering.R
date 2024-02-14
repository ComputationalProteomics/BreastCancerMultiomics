varianceFiltering <- function(data,design,sampleCol,cutoff=0.5,...){
  varianceNA <- function(data) var(data,na.rm=TRUE)
  
  varianceData <- data %>%
    dplyr::select(design[[sampleCol]]) %>% 
    apply(MARGIN = 1,FUN = varianceNA,simplify = TRUE) %>% 
    mutate(data,variance=.)

  lowVarData <- varianceData %>% 
    filter(variance > quantile(variance,cutoff,na.rm = TRUE))
  
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
    apply(MARGIN = 1,FUN = countNA,simplify = TRUE) %>% 
    mutate(data,number.NA=.)
  
  filteredData <- NAData %>% 
    filter(number.NA <= cutoff) %>% 
    dplyr::select(-c('number.NA'))
  
  return(filteredData)
}
