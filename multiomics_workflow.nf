nextflow.enable.dsl = 2

// subworkflow definition
workflow  {
    // Channel with reference design file
    ch_notebook_multiomics = Channel.fromPath("./notebooks/*")

    // Run workflow
    GENERATE_DESIGN_FILES (ch_notebook_multiomics.filter {it.name == 'generate_design_files.qmd'})

    DATA_NORMALIZATION(
        ch_notebook_multiomics.filter {it.name == 'preprocessing.qmd'},
        GENERATE_DESIGN_FILES.out.collect()
    )

    PROTEIN_ROLLUP(
        ch_notebook_multiomics.filter {it.name == 'protein_rollup.qmd'},
        DATA_NORMALIZATION.out.collect()
    )

    BATCH_CORRECTION(
      ch_notebook_multiomics.filter {it.name == 'batchcorrection.qmd'},
      PROTEIN_ROLLUP.out.collect()
    )

    DIFFERENTIAL_EXPRESSION(
      ch_notebook_multiomics.filter {it.name == 'differentialexpression.qmd'},
      PROTEIN_ROLLUP.out.collect()
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
      BATCH_CORRECTION.out.collect()
    )

    GSEA_MOFA(
      ch_notebook_multiomics.filter {it.name == 'GSEA_MOFA.qmd'},
      MOFA.out.collect()
    )
}

// Process definition
process GENERATE_DESIGN_FILES{
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
