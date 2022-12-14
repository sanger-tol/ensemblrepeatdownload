# sanger-tol/ensemblrepeatdownload: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.0.0 - [date]

Initial release of sanger-tol/ensemblrepeatdownload, created with the [nf-core](https://nf-co.re/) template.

### `Added`

- Download from Ensembl
- `samtools faidx` and `samtools dict` indices for the masked genome
- BED file with the coordinates of the masked region
- `samtools faidx` and `samtools dict` indices for the annotation fastas
- tavix index for the GFF3 file

### `Dependencies`

All dependencies are automatically fetched by Singularity.

- bgzip
- samtools
- tabix
- python3
- wget
- awk
- gzip
