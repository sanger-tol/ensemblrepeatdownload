//
// This file holds several functions specific to the workflow/ensemblrepeatdownload.nf in the sanger-tol/ensemblrepeatdownload pipeline
//

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
                log.error "'${params.input}' doesn't exist"
                System.exit(1)
            }
        } else {
            if (!params.assembly_accession || !params.ensembl_species_name || !params.annotation_method) {
                log.error "Either --input, or --assembly_accession, --ensembl_species_name, and --annotation_method must be provided"
                System.exit(1)
            }
        }
        if (!params.outdir) {
            log.error "--outdir is mandatory"
            System.exit(1)
        }
    }

}
