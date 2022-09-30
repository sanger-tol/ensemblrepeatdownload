//
// Check and parse the input parameters
//

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'

workflow PARAMS_CHECK {

    take:
    inputs          // tuple, see below


    main:

    def (samplesheet, assembly_accession, ensembl_species_name, outdir) = inputs

    ch_versions = Channel.empty()

    ch_inputs = Channel.empty()
    if (samplesheet) {

        SAMPLESHEET_CHECK ( file(samplesheet, checkIfExists: true) )
            .csv
            // Provides species_dir, assembly_name, assembly_accession (optional), and ensembl_species_name
            .splitCsv ( header:true, sep:',' )
            .map {
                // If assembly_accession is missing, load the accession number from file, following the Tree of Life directory structure
                it["assembly_accession"] ? it : it + [
                    assembly_accession: file("${it["species_dir"]}/assembly/release/${it["assembly_name"]}/insdc/ACCESSION", checkIfExists: true).text.trim(),
                ]
            }
            // Convert to tuple, as required by the download subworkflow
            .map { [
                "${it["species_dir"]}/analysis/${it["assembly_name"]}",
                it["ensembl_species_name"],
                it["assembly_accession"],
            ] }
            .set { ch_inputs }

        ch_versions = ch_versions.mix(SAMPLESHEET_CHECK.out.versions.first())

    } else {

        ch_inputs = Channel.of(
            [
                params.outdir,
                params.ensembl_species_name,
                params.assembly_accession,
            ]
        )

    }


    emit:
    ensembl_params  = ch_inputs        // tuple(analysis_dir, ensembl_species_name, assembly_accession)
    versions        = ch_versions      // channel: versions.yml
}
