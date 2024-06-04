//
// This file holds several functions specific to the workflow/ensemblrepeatdownload.nf in the sanger-tol/ensemblrepeatdownload pipeline
//

import nextflow.Nextflow
import groovy.text.SimpleTemplateEngine

class WorkflowEnsemblrepeatdownload {

    //
    // Check and validate parameters
    //
    public static void initialise(params, log) {

        // Check input has been provided
        if (params.input) {
            def f = new File(params.input);
            if (!f.exists()) {
                Nextflow.error "'${params.input}' doesn't exist"
            }
        } else {
            if (!params.assembly_accession || !params.ensembl_species_name || !params.annotation_method) {
                Nextflow.error "Either --input, or --assembly_accession, --ensembl_species_name, and --annotation_method must be provided"
            }
        }
        if (!params.outdir) {
            Nextflow.error "--outdir is mandatory"
        }
    }

}
