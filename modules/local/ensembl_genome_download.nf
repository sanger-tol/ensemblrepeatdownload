// Module that downloads all necessary genome files from Ensembl.
// The module checks that the MD5 checksums match before releasing the data.
// It also uncompresses the files, since we want bgzip compression.
process ENSEMBL_GENOME_DOWNLOAD {
    tag "${meta.id}"
    label 'process_single'

    conda "conda-forge::rsync=3.4.1"
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/db/dbfb90af7b92fb651e63ab29ef1919606f5fc536a8eaf13da74439bf200dd89e/data'
        : 'community.wave.seqera.io/library/rsync:3.4.1--a8163606c0035a88' }"

    input:
    tuple val(meta), val(ftp_path)

    output:
    tuple val(meta), path("*.fa.*"), emit: fasta
    tuple val("${task.process}"), val('rsync'), eval("rsync --version | sed '1!d;s/^rsync  version //; s/ .*//'"), topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    rsync -av \
      --exclude='*/' \
      --include='softmasked.fa.bgz*' \
      --include='md5sum.txt' \
      --exclude='*' \
      ${ftp_path}/ ./

    # Some files may be missing from md5sum.txt, let's not bother
    if grep -- "^softmasked\\.fa\\.bgz" md5sum.txt > md5checksums_restricted.txt
    then
        md5sum -c md5checksums_restricted.txt
    fi

    for i in softmasked.fa.*
    do
        mv \${i} ${prefix}.\${i/softmasked.fa.bgz/masked.fa.gz}
    done
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.masked.fa.gz
    touch ${prefix}.masked.fa.gz.fai
    touch ${prefix}.masked.fa.gz.gzi
    """
}
