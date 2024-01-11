sortIds <- function(data,proteinColumn = 'Protein.Ids',...){
  data <- pull(data,proteinColumn) %>% 
    str_split(string = .,pattern = ';') %>% 
    map(.x = .,.f = str_sort) %>% 
    map(.x = .,.f = function(x) paste0(x,collapse = ';')) %>% 
    unlist %>% 
    mutate(data,Protein.ID=.,.before=colnames(data[2])) %>% 
    dplyr::select(-proteinColumn)
  names(data)[names(data)=='Protein.ID'] <- 'Protein'
  return(data)
}