//
// Download all files from Ensembl and prepare clean output channels for post-processing
//

include { ENSEMBL_GENOME_DOWNLOAD       } from '../../modules/local/ensembl_genome_download'


workflow DOWNLOAD {

    take:
    repeat_params  // tuple(analysis_dir, ensembl_species_name, assembly_accession)


    main:
    ch_versions = Channel.empty()

    ch_genome_fasta     = ENSEMBL_GENOME_DOWNLOAD ( repeat_params ).fasta
    ch_versions         = ch_versions.mix(ENSEMBL_GENOME_DOWNLOAD.out.versions)


    emit:
    genome   = ch_genome_fasta           // path: genome.fa
    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}
