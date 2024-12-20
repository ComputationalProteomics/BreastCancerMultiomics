library(tidyverse)

# The following 2 files make Supplementary table 2 in latest manuscript
# Supplementary table 2 is 'multiomics/results/figures/survival_analysis/MOFA/AllSamples_noG2/AllSamples_noG2_LN_RFi_event/cox_analysis_res.tsv'
data1 <- read_tsv("~/Library/Mobile Documents/com~apple~CloudDocs/thesis/manuscript_figures/supplementary_table_2.tsv")
# Supplementary table 3 is 'multiomics/results/figures/survival_analysis/MOFA/AllSamples_noG2/AllSamples_noG2_LN_OS_event/cox_analysis_res.tsv'
data2 <- read_tsv("~/Library/Mobile Documents/com~apple~CloudDocs/thesis/manuscript_figures/supplementary_table_3.tsv")

# teste <- inner_join(data1,data2,by = "variable",suffix = c(x=".RFS",y=".OS"))
# teste <- teste %>% filter(p.value_univariable.RFS<0.05 & p.value_univariable.OS<0.05)
# teste <- teste %>% select(variable,15:27,41:53)
# write_tsv(x = teste,file = "~/Library/Mobile Documents/com~apple~CloudDocs/thesis/manuscript_figures/supplementary_table_2_3_joined.tsv")
#Updated on 2024.12.20
table_s2 <- full_join(data1,data2,by = "variable",suffix = c(x=".RFS",y=".OS")) %>% 
  select(variable,Phosphosite.RFS,Residue.RFS, 15:27,Phosphosite.OS,Residue.OS,41:53)
write_tsv(x = table_s2,file = "~/Library/Mobile Documents/com~apple~CloudDocs/thesis/manuscript_figures/final_supplementary/supplementary_table2.tsv")


# These files concern Supplementary Table 3 in the latest manuscript
# Supplementary table 4 here is 'multiomics/results/figures/survival_analysis/DE/Group1vsGroup2/Group1vsGroup2_DRFi_event/cox_analysis_res.tsv'
data1 <- read_tsv("~/Library/Mobile Documents/com~apple~CloudDocs/thesis/manuscript_figures/supplementary_table_4.tsv")
# Supplementary Table 5 here is 'multiomics/results/figures/survival_analysis/DE/Group1vsGroup2/Group1vsGroup2_OS_event/cox_analysis_res.tsv'
data2 <- read_tsv("~/Library/Mobile Documents/com~apple~CloudDocs/thesis/manuscript_figures/supplementary_table_5.tsv")
# teste <- inner_join(data1,data2,by = "variable",suffix = c(x=".DRFS",y=".OS"))
# teste <- teste %>% select(variable,14,18,24,39,43,49)
# write_tsv(x = teste,file = "~/Library/Mobile Documents/com~apple~CloudDocs/thesis/manuscript_figures/supplementary_table_4_5_joined.tsv")
# Updated on 2024.12.20
table_s3 <- full_join(data1,data2,by = "variable",suffix = c(x=".DRFS",y=".OS")) %>% 
  select(variable,Phosphosite.DRFS,Residue.DRFS,14:26,Phosphosite.OS,Residue.OS,39:51)
write_tsv(x = table_s3,file = "~/Library/Mobile Documents/com~apple~CloudDocs/thesis/manuscript_figures/final_supplementary/supplementary_table3.tsv")

# These files correct to Supplementary Table 4 in the latest manuscript
# Supplementary table 6 here is 'multiomics/results/figures/survival_analysis/MOFA/Group1vsGroup2/Group1vsGroup2_DRFi_event_DRFi_event/cox_analysis_res.tsv'
data1 <- read_tsv("~/Library/Mobile Documents/com~apple~CloudDocs/thesis/manuscript_figures/supplementary_table_6.tsv")
# Supplementary table 7 here is 'multiomics/results/figures/survival_analysis/MOFA/Group1vsGroup2/Group1vsGroup2_DRFi_event_OS_event/cox_analysis_res.tsv'
data2 <- read_tsv("~/Library/Mobile Documents/com~apple~CloudDocs/thesis/manuscript_figures/supplementary_table_7.tsv")
# teste <- inner_join(data1,data2,by = "variable",suffix = c(x=".DRFS",y=".OS"))
# teste <- teste %>% filter(p.value_univariable.DRFS<0.05 | p.value_univariable.OS<0.05)
# teste <- teste %>% select(variable,15,19,25,41,45,51)
# write_tsv(x = teste,file = "~/Library/Mobile Documents/com~apple~CloudDocs/thesis/manuscript_figures/supplementary_table_6_7_joined.tsv")
#Updated on 2024.12.20
table_s4 <- full_join(data1,data2,by = "variable",suffix = c(x=".DRFS",y=".OS")) %>% 
  select(variable,Phosphosite.DRFS,Residue.DRFS,15:27,Phosphosite.OS,Residue.OS,41:53)
write_tsv(x = table_s4,file = "~/Library/Mobile Documents/com~apple~CloudDocs/thesis/manuscript_figures/final_supplementary/supplementary_table4.tsv")
