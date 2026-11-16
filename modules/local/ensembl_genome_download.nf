// Module that downloads all necessary genome files from Ensembl.
// The module checks that the MD5 checksums match before releasing the data.
// It also uncompresses the files, since we want bgzip compression.
process ENSEMBL_GENOME_DOWNLOAD {
    tag "${meta.id}"
    label 'process_single'

    conda "bioconda::gnu-wget=1.18"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/gnu-wget:1.18--h7132678_6'
        : 'biocontainers/gnu-wget:1.18--h7132678_6'}"

    input:
    tuple val(meta), val(ftp_path)

    output:
    tuple val(meta), path("*.fa"), emit: fasta
    tuple val("${task.process}"), val('wget'), eval("wget --version | head -n 1 | cut -d' ' -f3"), topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    #export https_proxy=http://wwwcache.sanger.ac.uk:3128
    #export http_proxy=http://wwwcache.sanger.ac.uk:3128
    rm -f *.bgz md5sum.txt
    wget ${ftp_path}/softmasked.fa.bgz
    wget ${ftp_path}/md5sum.txt

    if grep -- "softmasked\\.fa\\.bgz\$" md5sum.txt > md5checksums_restricted.txt
    then
        md5sum -c md5checksums_restricted.txt
    fi
    # Temporary, until the sub-workflow downstream can accept compressed files
    zcat softmasked.fa.bgz > ${prefix}.fa
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.fa
    """
}
