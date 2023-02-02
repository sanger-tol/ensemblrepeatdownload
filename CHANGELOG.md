# sanger-tol/ensemblrepeatdownload: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.1.0 - [date]

### `Fixed`

- Support for the updated directory structure of the Ensembl FTP
- Relative paths in the sample-sheet are now evaluated from the `--outdir` parameter
- Memory usage rules for `samtools dict`
- Appropriate use of `tabix`'s TBI and CSI indexing, depending on the sequence lengths

### `Added`

- New command-line parameter (`--annotation_method`): required for accessing the files on the Ensembl FTP
- `--outdir` is a _mandatory_ parameter

## v1.0.0 - [2022-10-19]

Initial release of sanger-tol/ensemblrepeatdownload, created with the [nf-core](https://nf-co.re/) template.

### `Added`

- Download from Ensembl
- `samtools faidx` and `samtools dict` indices for the masked genome
- BED file with the coordinates of the masked region
- `samtools faidx` and `samtools dict` indices for the annotation fastas
- tabix index for the GFF3 file

### `Dependencies`

All dependencies are automatically fetched by Singularity.

- bgzip
- samtools
- tabix
- python3
- wget
- awk
- gzip
