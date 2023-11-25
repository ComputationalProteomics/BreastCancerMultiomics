nextflow.enable.dsl = 2

// subworkflow definition
workflow  GENERATE_DESIGN_FILES {
    // Channel with reference design file
    ch_notebook_design = Channel
        .fromPath ( "./notebooks/generate_design_files.qmd" ) }

    // Run workflow
    GENERATE_DESIGN_FILES(ch_notebook_design)

}

// Process definition
process GENERATE_DESIGN_FILES{
    publishDir "./notebooks",
        mode: "copy"

    input:
        path(notebook)

    output:
        path("*.qmd"), emit: qmd
        path("*.html"), emit: html

    script:
    """
    quarto render ${notebook} --to html
    """
}
