// Module that downloads all necessary genome files from Ensembl.
// The module checks that the MD5 checksums match before releasing the data.
// It also uncompresses the files, since we want bgzip compression.
process ENSEMBL_GENOME_DOWNLOAD {
    tag "${meta.id}"
    label 'process_single'

    conda "bioconda::gnu-wget=1.18"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gnu-wget:1.18--h7132678_6' :
        'biocontainers/gnu-wget:1.18--h7132678_6' }"

    input:
    tuple val(meta), val(ftp_path), val(remote_filename_stem)

    output:
    tuple val(meta), path("*.fa") , emit: fasta
    path  "versions.yml"          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    #export https_proxy=http://wwwcache.sanger.ac.uk:3128
    #export http_proxy=http://wwwcache.sanger.ac.uk:3128
    rm -f *.gz md5sum.txt
    wget ${ftp_path}/${remote_filename_stem}-softmasked.fa.gz
    wget ${ftp_path}/md5sum.txt

    if grep -- "-softmasked\\.fa\\.gz\$" md5sum.txt > md5checksums_restricted.txt
    then
        md5sum -c md5checksums_restricted.txt
    fi
    zcat ${remote_filename_stem}-softmasked.fa.gz > ${prefix}.fa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        wget: \$(wget --version | head -n 1 | cut -d' ' -f3)
        BusyBox: \$(busybox | head -1 | cut -d' ' -f2)
    END_VERSIONS
    """
}
