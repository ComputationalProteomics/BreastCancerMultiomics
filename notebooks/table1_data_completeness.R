prot <- read_tsv(file = "~/multiomics/results/rollup/fullproteome/cycloess_Rollup.tsv")
design_prot <- read_tsv(file = "~/multiomics/results/design_files/design_Full_noPool.tsv")
teste_prot <- prot %>% rowwise() %>% mutate(na_percent=sum(is.na(c_across(starts_with("S"))))/177)
teste_prot_filter <- teste_prot %>% filter(na_percent<=0.3)

design_phospho <- read_tsv("~/multiomics/results/design_files/design_phospho_noPool.tsv")
phospho <- read_tsv("~/multiomics/results/normalization/phosphoproteome/peptide_normalization/CycLoess-normalized.txt")
teste_phospho <- phospho %>% rowwise() %>% mutate(na_percent=sum(is.na(c_across(starts_with("S0"))))/162)
phospho_filter <- teste_phospho %>% filter(na_percent<=0.3)

design_gene <- read_tsv("~/multiomics/results/design_files/design_RNA_noPool.tsv")
gene <- read_tsv("~/multiomics/data/transcriptomics/genematrix_adjusted_cycloess.tsv")
teste_gene <- gene %>% rowwise() %>% mutate(na_percent=sum(is.na(c_across(starts_with("S0"))))/182)
gene_filter <- teste_gene %>% filter(na_percent<=0.3)

