# Snakefile_wildcards_solution.smk — Solution for the TODO exercises in Snakefile_wildcards.smk
#
# This file shows how to:
#   1. Add a sample number to each edited file
#   2. Concatenate all numbered files into a final results file
#
# Run with:
#   $ snakemake --snakefile Snakefile_wildcards_solution.smk --dry-run
#   $ snakemake --snakefile Snakefile_wildcards_solution.smk -j 1

configfile: "config.yaml"
workdir: config["WORKING_FOLDER"]

rule all:
    input:
        "output/final_results.txt"

rule edit_text:
    input: "data_wildcards/snakemake_input_{num}.txt"
    output: "output/edited_files/snakemake_output_{num}.txt"
    shell: "cat {input} | sed 's/no./number/' > {output}"

rule add_num_to_output_file:
    """Add the sample number to the end of the text in the edited files.
    So the new files have text such as "sample number 1", "sample number 2", etc.
    """
    input: "output/edited_files/snakemake_output_{num}.txt"
    output: "output/numbered_files/snakemake_numbered_{num}.txt"
    params: num="{num}"
    shell: "sed 's/$/ {params.num}/' {input} > {output}"

rule concatenate_all_files:
    """Concatenate all the numbered files into a single final_results.txt file."""
    input: expand("output/numbered_files/snakemake_numbered_{num}.txt", num=[0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    output: "output/final_results.txt"
    shell: "cat {input} > {output}"
