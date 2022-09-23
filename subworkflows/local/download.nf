//
// Download all files from Ensembl and prepare clean output channels for post-processing
//

include { ENSEMBL_GENOME_DOWNLOAD       } from '../../modules/local/ensembl_genome_download'


workflow DOWNLOAD {

    take:
    inputs  // maps that indicate what to download (straight from the samplesheet)


    main:
    ch_versions = Channel.empty()

    ch_genome_fasta     = ENSEMBL_GENOME_DOWNLOAD (
        inputs.map {
            [it["analysis_dir"], it["ensembl_species_name"], it["assembly_accession"]]
        }
    ).fasta
    ch_versions         = ch_versions.mix(ENSEMBL_GENOME_DOWNLOAD.out.versions)


    emit:
    genome   = ch_genome_fasta           // path: genome.fa
    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}
