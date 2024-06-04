//
// Download all files from Ensembl and prepare clean output channels for post-processing
//

include { ENSEMBL_GENOME_DOWNLOAD       } from '../../modules/local/ensembl_genome_download'


workflow DOWNLOAD {

    take:
    repeat_params  // tuple(outdir, assembly_accession, ensembl_species_name, annotation_method)


    main:
    ch_versions = Channel.empty()

    ch_genome_fasta     = ENSEMBL_GENOME_DOWNLOAD (
        repeat_params.map {

            outdir,
            assembly_accession,
            ensembl_species_name,
            annotation_method

            -> [
                // meta
                [
                    id: assembly_accession + ".masked.ensembl",
                    method: annotation_method,
                    outdir: outdir,
                ],

                // e.g. https://ftp.ensembl.org/pub/rapid-release/species/Agriopis_aurantiaria/GCA_914767915.1/braker/genome/Agriopis_aurantiaria-GCA_914767915.1-softmasked.fa.gz
                // ftp_path
                [
                    params.ftp_root,
                    ensembl_species_name,
                    assembly_accession,
                    annotation_method,
                    "genome",
                ].join("/"),

                // remote_filename_stem
                [
                    ensembl_species_name,
                    assembly_accession,
                ].join("-"),
            ]
        },
    ).fasta
    ch_versions         = ch_versions.mix(ENSEMBL_GENOME_DOWNLOAD.out.versions.first())


    emit:
    genome   = ch_genome_fasta           // path: genome.fa
    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}
