nextflow.enable.dsl = 2

// subworkflow definition
workflow  {
    // Channel with reference design file
    ch_notebook_multiomics = Channel.fromPath("./notebooks/*")

    // Run workflow
    SAMPLE_SELECTION (ch_notebook_multiomics.filter {it.name == 'sample_selection.qmd'})

    GENERATE_DESIGN_FILES(
        ch_notebook_multiomics.filter {it.name == 'generate_design_files.qmd'},
        SAMPLE_SELECTION.out.collect()
    )

    PREPROCESS_IMMUNE (ch_notebook_multiomics.filter {it.name == 'preprocess_immuneinfiltration.qmd'})

    DATA_NORMALIZATION(
        ch_notebook_multiomics.filter {it.name == 'preprocessing.qmd'},
        GENERATE_DESIGN_FILES.out.collect()
    )

    PROTEIN_ROLLUP(
        ch_notebook_multiomics.filter {it.name == 'protein_rollup.qmd'},
        DATA_NORMALIZATION.out.collect()
    )

    PTM_SEA(
        ch_notebook_multiomics.filter {it.name == 'phosphopeptide_aggregation_ptmsea.qmd'},
        PROTEIN_ROLLUP.out.collect()
    )

    BATCH_CORRECTION(
      ch_notebook_multiomics.filter {it.name == 'batchcorrection.qmd'},
      PROTEIN_ROLLUP.out.collect()
    )

    DIFFERENTIAL_EXPRESSION(
      ch_notebook_multiomics.filter {it.name == 'differentialexpression.qmd'},
      PROTEIN_ROLLUP.out.collect(),
      PTM_SEA.out.collect()
    )

    GSEA(
      ch_notebook_multiomics.filter {it.name == 'GSEA.qmd'},
      DIFFERENTIAL_EXPRESSION.out.collect()
    )

    CONSENSUS_CLUSTER(
      ch_notebook_multiomics.filter {it.name == 'consensus_clustering.qmd'},
      BATCH_CORRECTION.out.collect()
    )

    CLUSTERING(
      ch_notebook_multiomics.filter {it.name == 'clustering.qmd'},
      CONSENSUS_CLUSTER.out.collect()
    )

    MOFA(
      ch_notebook_multiomics.filter {it.name == 'MOFA.qmd'},
      BATCH_CORRECTION.out.collect(),
      PREPROCESS_IMMUNE.out.collect()
    )

    GSEA_MOFA(
      ch_notebook_multiomics.filter {it.name == 'GSEA_MOFA.qmd'},
      MOFA.out.collect()
    )

    SURVIVAL_MOFA(
      ch_notebook_multiomics.filter {it.name == 'survival_mofa.qmd'},
      MOFA.out.collect()
    )

    SURVIVAL_DE(
      ch_notebook_multiomics.filter {it.name == 'survival_DE_multiomics.qmd'},
      DIFFERENTIAL_EXPRESSION.out.collect()
    )

    SURVIVAL_CLUSTER(
      ch_notebook_multiomics.filter {it.name == 'survival_cluster.qmd'},
      CONSENSUS_CLUSTER.out.collect()
    )

    DIFFERENTIAL_EXPRESSION_CLUSTER(
      ch_notebook_multiomics.filter {it.name == 'differentialexpression_consensus_cluster.qmd'},
      CLUSTERING.out.collect()
    )

    GSEA_CONSENSUS_CLUSTER(
      ch_notebook_multiomics.filter {it.name == 'GSEA_consensus_cluster.qmd'},
      DIFFERENTIAL_EXPRESSION_CLUSTER.out.collect()
    )

    EXTERNAL_VALIDATION(
      ch_notebook_multiomics.filter {it.name == 'validation_analysis.qmd'},
      SURVIVAL_DE.out.collect(),
      SURVIVAL_MOFA.out.collect()
    )

    BOXPLOTS(
      ch_notebook_multiomics.filter {it.name == 'boxplots_validation_samples.qmd'},
      SURVIVAL_DE.out.collect(),
      SURVIVAL_MOFA.out.collect()
    )
    
    TABLE_1(
      ch_notebook_multiomics.filter {it.name == 'table1_data_completeness.qmd'},
      DIFFERENTIAL_EXPRESSION.out.collect()
    )
    
    IMMUNE_BOXPLOT(
      ch_notebook_multiomics.filter {it.name == 'immune_boxplot_LM22.qmd'}
    )
    
    VOLCANO_PLOTS(
      ch_notebook_multiomics.filter {it.name == 'volcano_plots_fig2.qmd'},
      DIFFERENTIAL_EXPRESSION.out.collect()
    )

    COHORT_CHARACTERISTICS(
        ch_notebook_multiomics.filter {it.name == 'table_patient_tumor_characteristics.qmd'},
        GENERATE_DESIGN_FILES.out.collect()
    )

    BOXPLOTS_SUPPLEMENTARY(
        ch_notebook_multiomics.filter {it.name == 'boxplots_supplementary.qmd'},
        SURVIVAL_DE.out.collect(),
        SURVIVAL_MOFA.out.collect()
    )

    PCA_SUPPLEMENTARY(
        ch_notebook_multiomics.filter {it.name == 'pca_plot_supplementary_figure.qmd'},
        PROTEIN_ROLLUP.out.collect()
    )

    

}

// Process definition
process SAMPLE_SELECTION{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)

    output:
        path('*.html'), emit: html

    script:
    """
    mkdir -p /multiomics/results/design_files/
    mkdir -p /multiomics/results/rendered_notebooks/
    quarto render ${notebook} --to html > .html
    """
}

process GENERATE_DESIGN_FILES{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)

    when:
        html.exists()

    output:
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} --to html > .html
    """
}

process PREPROCESS_IMMUNE{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)

    output:
        path('*.html'), emit: html

    script:
    """
    quarto render ${notebook} --to html > .html
    """
}

process DATA_NORMALIZATION{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)

    when:
        html.exists()

    output:
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} --to html > .html
    """
}

process PROTEIN_ROLLUP{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)

    when:
        html.exists()

    output:
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} --to html > .html
    """
}

process PTM_SEA{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)

    when:
        html.exists()

    output:
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} --to html > .html
    """
}

process BATCH_CORRECTION{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)

    when:
        html.exists()

    output:
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} --to html > .html
    """
}

process DIFFERENTIAL_EXPRESSION{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)

    when:
        html.exists()

    output:
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} --to html > .html
    """
}

process GSEA{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)

    when:
        html.exists()

    output:
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} --to html > .html
    """
}

process CLUSTERING{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)

    when:
        html.exists()

    output:
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} --to html > .html
    """
}

process MOFA{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)
        path(html)

    when:
        html.exists()

    output:
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} --to html > .html
    """
}

process GSEA_MOFA{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)

    when:
        html.exists()

    output:
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} --to html > .html
    """
}

process CONSENSUS_CLUSTER{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)

    when:
        html.exists()

    output:
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} --to html > .html
    """
}

process SURVIVAL_MOFA{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)
    output:
        path("*.html"),emit: html
    script:
    """
    quarto render ${notebook} -P model:'/multiomics/results/MOFA/AllSamples_noG2/model.RDS' -P outcome:'LN' -P time:'RFi_days' -P event:'RFi_event' > .html
    quarto render ${notebook} -P model:'/multiomics/results/MOFA/AllSamples_noG2/model.RDS' -P outcome:'LN' -P time:'OS_days' -P event:'OS_event' > .html

    quarto render ${notebook} -P model:'/multiomics/results/MOFA/Group1vsGroup2/model.RDS' -P outcome:'DRFi_event' -P time:'RFi_days' -P event:'RFi_event' > .html
    quarto render ${notebook} -P model:'/multiomics/results/MOFA/Group1vsGroup2/model.RDS' -P outcome:'DRFi_event' -P time:'DRFi_days' -P event:'DRFi_event' > .html
    quarto render ${notebook} -P model:'/multiomics/results/MOFA/Group1vsGroup2/model.RDS' -P outcome:'DRFi_event' -P time:'OS_days' -P event:'OS_event' > .html
    """
}

process SURVIVAL_DE{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html) 
    output:
        path("*.html"),emit: html
    script:
    """
    quarto render ${notebook} -P comparison:'AllSamples_noG2' -P time:'RFi_days' -P event:'RFi_event' -P outcome:'LN' > .html
    quarto render ${notebook} -P comparison:'AllSamples_noG2' -P time:'OS_days' -P event:'OS_event' -P outcome:'LN' > .html

    quarto render ${notebook} -P comparison:'Group1vsGroup2' -P time:'DRFi_days' -P event:'DRFi_event' -P outcome:'Group.Info' > .html
    quarto render ${notebook} -P comparison:'Group1vsGroup2' -P time:'RFi_days' -P event:'RFi_event' -P outcome:'Group.Info' > .html
    quarto render ${notebook} -P comparison:'Group1vsGroup2' -P time:'OS_days' -P event:'OS_event' -P outcome:'Group.Info' > .html
    """
}

process SURVIVAL_CLUSTER{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)
    output:
        path("*.html"),emit: html
    script:
    """
    quarto render ${notebook} -P dataPath:'/multiomics/results/consensus_clustering/DuctalvsLobular/proteome/proteome.k=6.consensusClass.csv' -P designPath:'/multiomics/results/design_files/design_Full_noPool.tsv' > .html
    quarto render ${notebook} -P dataPath:'/multiomics/results/consensus_clustering/DuctalvsLobular/proteome/proteome.k=6.consensusClass.csv' -P designPath:'/multiomics/results/design_files/design_Full_noPool.tsv' -P time:'OS_days' -P event:'OS_event' > .html

    quarto render ${notebook} -P dataPath:'/multiomics/results/consensus_clustering/DuctalvsLobular/phosphoproteome/phosphoproteome.k=5.consensusClass.csv' -P designPath:'/multiomics/results/design_files/design_phospho_noPool.tsv' > .html
    quarto render ${notebook} -P dataPath:'/multiomics/results/consensus_clustering/DuctalvsLobular/phosphoproteome/phosphoproteome.k=5.consensusClass.csv' -P designPath:'/multiomics/results/design_files/design_phospho_noPool.tsv' -P time:'OS_days' -P event:'OS_event' > .html

    quarto render ${notebook} -P dataPath:'/multiomics/results/consensus_clustering/DuctalvsLobular/transcriptome/transcriptome.k=5.consensusClass.csv' -P designPath:'/multiomics/results/design_files/design_RNA_noPool.tsv' > .html
    quarto render ${notebook} -P dataPath:'/multiomics/results/consensus_clustering/DuctalvsLobular/transcriptome/transcriptome.k=5.consensusClass.csv' -P designPath:'/multiomics/results/design_files/design_RNA_noPool.tsv' -P time:'OS_days' -P event:'OS_event' > .html

    """
}

process DIFFERENTIAL_EXPRESSION_CLUSTER{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)

    when:
        html.exists()

    output:
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} --to html > .html
    """
}

process GSEA_CONSENSUS_CLUSTER{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)

    when:
        html.exists()

    output:
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} --to html > .html
    """
}

process EXTERNAL_VALIDATION{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)
        path(html)

    when:
        html.exists()

    output:
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} -P comparison:'AllSamples_noG2' -P time:'OS_days' -P event:'OS_event' > .html
    quarto render ${notebook} -P comparison:'AllSamples_noG2' -P time:'RFi_days' -P event:'RFi_event' > .html
    quarto render ${notebook} -P comparison:'Group1vsGroup2' -P time:'DRFi_days' -P event:'DRFi_event' > .html
    quarto render ${notebook} -P comparison:'Group1vsGroup2' -P time:'OS_days' -P event:'OS_event' > .html
    quarto render ${notebook} -P comparison:'Group1vsGroup2' -P time:'RFi_days' -P event:'RFi_event' > .html
    """
}

process BOXPLOTS{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)
        path(html)

    when:
        html.exists()

    output:
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} -P comparison:'AllSamples_noG2' -P time:'OS_days' -P event:'OS_event' -P outcome:'LN' > .html
    quarto render ${notebook} -P comparison:'AllSamples_noG2' -P time:'RFi_days' -P event:'RFi_event' -P outcome:'LN' > .html
    quarto render ${notebook} -P comparison:'Group1vsGroup2' -P time:'DRFi_days' -P event:'DRFi_event' -P outcome:'DRFi_event' > .html
    quarto render ${notebook} -P comparison:'Group1vsGroup2' -P time:'OS_days' -P event:'OS_event' -P outcome:'DRFi_event' > .html
    quarto render ${notebook} -P comparison:'Group1vsGroup2' -P time:'RFi_days' -P event:'RFi_event' -P outcome:'DRFi_event' > .html
    """
}

process TABLE_1{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)

    when:
        html.exists()

    output:
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} > .html
    """
}

process IMMUNE_BOXPLOT{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)

    output:
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} > .html
    """
}

process VOLCANO_PLOTS{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)

    when:
        html.exists()

    output:
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} > .html
    """
}

process COHORT_CHARACTERISTICS{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)

    when:
        html.exists()

    output:
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} > .html
    """
}

process BOXPLOTS_SUPPLEMENTARY{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)

    when:
        html.exists()

    output:
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} > .html
    """
}

process PCA_SUPPLEMENTARY{
    publishDir "./results/rendered_notebooks",
        mode: "copy"

    input:
        path(notebook)
        path(html)

    when:
        html.exists()

    output:
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} > .html
    """
}
