/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters
WorkflowEnsemblrepeatdownload.initialise(params, log)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { SAMPLESHEET_CHECK             } from '../modules/local/samplesheet_check'

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { DOWNLOAD        } from '../subworkflows/local/download'
include { PREPARE_FASTA   } from '../subworkflows/sanger-tol/prepare_fasta'
include { PREPARE_REPEATS } from '../subworkflows/sanger-tol/prepare_repeats'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/modules/custom/dumpsoftwareversions/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow ENSEMBLREPEATDOWNLOAD {

    ch_versions = Channel.empty()

    ch_inputs = Channel.empty()
    if (params.input) {

        SAMPLESHEET_CHECK ( file(params.input, checkIfExists: true) )
            .csv
            // Provides species_dir, assembly_name, and ensembl_species_name
            .splitCsv ( header:true, sep:',' )
            // Add analysis_dir, and load the accession number, following the Tree of Life directory structure
            .map {
                it + [
                    assembly_accession: file("${it["species_dir"]}/assembly/release/${it["assembly_name"]}/insdc/ACCESSION", checkIfExists: true).text.trim(),
                    analysis_dir: "${it["species_dir"]}/analysis/${it["assembly_name"]}",
                    ]
            }
            .set { ch_inputs }

    } else {

        ch_inputs = Channel.from( [
            [
                analysis_dir: params.outdir,
                assembly_accession: params.assembly_accession,
                ensembl_species_name: params.ensembl_species_name,
            ]
        ] )

    }

    // Actual download
    DOWNLOAD (
        ch_inputs
    )
    ch_versions         = ch_versions.mix(DOWNLOAD.out.versions)

    // Preparation of repeat-masking files
    PREPARE_FASTA (
        DOWNLOAD.out.genome
    )
    ch_versions         = ch_versions.mix(PREPARE_FASTA.out.versions)
    PREPARE_REPEATS (
        DOWNLOAD.out.genome
    )
    ch_versions         = ch_versions.mix(PREPARE_REPEATS.out.versions)

    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log)
    }
    NfcoreTemplate.summary(workflow, params, log)
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
