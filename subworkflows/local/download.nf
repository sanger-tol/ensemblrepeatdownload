//
// Download all files from Ensembl and prepare clean output channels for post-processing
//

include { ENSEMBL_GENOME_DOWNLOAD       } from '../../modules/local/ensembl_genome_download'


workflow DOWNLOAD {

    take:
    repeat_params  // tuple(analysis_dir, ensembl_species_name, assembly_accession)


    main:
    ch_versions = Channel.empty()

    ch_genome_fasta     = ENSEMBL_GENOME_DOWNLOAD (
        repeat_params.map { [
            // meta
            [
                id: it[2] + ".masked.ensembl",
                outdir: it[0],
            ],
            // e.g. https://ftp.ensembl.org/pub/rapid-release/species/Agriopis_aurantiaria/GCA_914767915.1/genome/Agriopis_aurantiaria-GCA_914767915.1-softmasked.fa.gz
            // ftp_path
            params.ftp_root + "/" + it[1] + "/" + it[2] + "/genome",
            // remote_filename_stem
            it[1] + "-" + it[2],
        ] },
    ).fasta
    ch_versions         = ch_versions.mix(ENSEMBL_GENOME_DOWNLOAD.out.versions.first())


    emit:
    genome   = ch_genome_fasta           // path: genome.fa
    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}
