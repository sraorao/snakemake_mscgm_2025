# Snakefile_debug.smk — Debugging exercises for Practical 3
#
# This Snakefile contains a WORKING baseline rule, followed by 4 buggy variants.
# Instructions:
#   1. First, run the baseline rule to confirm it works:
#      $ snakemake --snakefile Snakefile_debug.smk --dry-run
#      $ snakemake --snakefile Snakefile_debug.smk -j 1
#
#   2. Then uncomment ONE buggy rule at a time (and comment out the baseline),
#      run snakemake, read the error message, and try to fix the bug.
#
#   Useful flags for debugging:
#      --dry-run (-n)        Preview what will run without executing
#      --printshellcmds (-p) Show the exact shell commands being run
#      --reason (-r)         Show why each rule is being executed
#      --rerun-incomplete    Re-run jobs that were left incomplete

# =====================================================================
# BASELINE (working) — edit files using sed
# =====================================================================
rule all:
    input:
        expand("output/debug/snakemake_output_{num}.txt", num=[0, 1, 2, 3, 4])

rule edit_text:
    input: "data_wildcards/snakemake_input_{num}.txt"
    output: "output/debug/snakemake_output_{num}.txt"
    shell: "cat {input} | sed 's/no./number/' > {output}"


# =====================================================================
# BUG 1 — Wildcard name mismatch
# Uncomment the rule below and comment out the working edit_text above.
# Can you spot and fix the error?
# =====================================================================
# rule edit_text:
#     input: "data_wildcards/snakemake_input_{sample}.txt"
#     output: "output/debug/snakemake_output_{num}.txt"
#     shell: "cat {input} | sed 's/no./number/' > {output}"


# =====================================================================
# BUG 2 — Output filename typo
# Uncomment the rule below and comment out the working edit_text above.
# Can you spot and fix the error?
# =====================================================================
# rule edit_text:
#     input: "data_wildcards/snakemake_input_{num}.txt"
#     output: "output/debug/snakemake_outpt_{num}.txt"
#     shell: "cat {input} | sed 's/no./number/' > {output}"


# =====================================================================
# BUG 3 — Wrong input directory
# Uncomment the rule below and comment out the working edit_text above.
# Can you spot and fix the error?
# =====================================================================
# rule edit_text:
#     input: "data_wrong_folder/snakemake_input_{num}.txt"
#     output: "output/debug/snakemake_output_{num}.txt"
#     shell: "cat {input} | sed 's/no./number/' > {output}"


# =====================================================================
# BUG 4 — Shell command typo
# Uncomment the rule below and comment out the working edit_text above.
# Can you spot and fix the error?
# =====================================================================
# rule edit_text:
#     input: "data_wildcards/snakemake_input_{num}.txt"
#     output: "output/debug/snakemake_output_{num}.txt"
#     shell: "catt {input} | sed 's/no./number/' > {output}"
