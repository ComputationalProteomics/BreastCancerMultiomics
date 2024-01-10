#!/usr/bin/env Rscript

library(tidyverse)

sortIds <- function(){
  argv <- parse_input_params()
  
  data <- readr::read_tsv(file = argv$data_path)
  proteinColumn <- argv$protein_col
  data <- pull(data,proteinColumn) %>% 
    str_split(string = .,pattern = ';') %>% 
    map(.x = .,.f = str_sort) %>% 
    map(.x = .,.f = function(x) paste0(x,collapse = ';')) %>% 
    unlist %>% 
    mutate(data,Protein.ID=.,.before=colnames(data[2])) %>% 
    dplyr::select(-proteinColumn)
  names(data)[names(data)=='Protein.ID'] <- 'Protein'
  
  readr::write_tsv(x = data,file = argv$out_path)
}


parse_input_params <- function() {
  
  parser <- argparser::arg_parser("Sorting IDs")
  parser <- argparser::add_argument(parser, "--data_path", help="Data matrix path", type="character", default=NA,nargs = 1)
  parser <- argparser::add_argument(parser, "--out_path", help="Output matrix path", type="character", nargs=1)
  parser <- argparser::add_argument(parser, "--protein_col", help="Protein column in main data frame", type="character", default='Protein.Ids')

  argv <- argparser::parse_args(parser)
  
  argv
}

if (!interactive()) {
  sortIds()
}