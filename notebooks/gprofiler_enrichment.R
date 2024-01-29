library(gprofiler2)
gprofilerEnrichment <- function(data,clusterCol,idCol,sep){
  results <- data %>% 
    group_by(.[[clusterCol]]) %>% 
    group_map(~gost(query = str_split_i(string=.[[idCol]],
                                        pattern=paste0('\\',sep),
                                        i=1),
                    organism = 'hsapiens',
                    multi_query = FALSE,
                    significant = TRUE,
                    ordered_query = FALSE,
                    exclude_iea = TRUE,
                    measure_underrepresentation = FALSE,
                    evcodes = TRUE,
                    user_threshold = 0.05,
                    correction_method = 'gSCS',
                    custom_bg = NULL,
                    numeric_ns = "",
                    domain_scope = 'annotated',
                    sources = NULL))
}
