"""
Snakefile_inputfunc.smk — Standalone input function example

Demonstrates using a Python function to dynamically determine inputs
based on sample metadata (normal/tumour pairing from sample_ids.csv).

Input functions are useful when:
  - The input files for a rule depend on the wildcard values
  - You need to look up relationships between samples (e.g. normal/tumour pairs)
  - Input file paths need to be computed at runtime

Run with:
  $ snakemake --snakefile Snakefile_inputfunc.smk --dry-run
  $ snakemake --snakefile Snakefile_inputfunc.smk -j 1
"""

configfile: "config.yaml"

import pandas
from snakemake.utils import min_version
min_version("5.26")

# Read sample pairing information from CSV
samples_df = pandas.read_csv(config["SAMPLE_IDS"])
TUMOURS = samples_df.tumour
NORMALS = samples_df.normal
ALL_SAMPLES = set(list(TUMOURS) + list(NORMALS))

rule all:
    input:
        expand("output/paired/{normal}.txt", normal=set(NORMALS))


# --- Input function -----------------------------------------------------------
# This function is called by Snakemake at runtime for each value of {normal}.
# It receives the wildcards object and returns a list of file paths.
def get_tumours_for_normal(wildcards):
    """
    Given a normal sample name (via wildcards.normal), look up all the
    tumour samples paired with it in sample_ids.csv and return their
    BAM file paths.
    """
    tumours_for_normal = TUMOURS[NORMALS == wildcards.normal]
    return [f"data/bam/{tumour}.bam" for tumour in tumours_for_normal]
# ------------------------------------------------------------------------------


rule pair_normal_and_tumours:
    """
    For each normal sample, list its paired tumour samples.
    The input function get_tumours_for_normal dynamically determines
    which tumour BAM files to include based on sample_ids.csv.
    """
    input:
        normal="data/bam/{normal}.bam",
        tumours=get_tumours_for_normal
    output:
        "output/paired/{normal}.txt"
    shell:
        """
        echo "Normal: {wildcards.normal}" > {output}
        echo "Normal BAM: {input.normal}" >> {output}
        echo "Tumour BAMs: {input.tumours}" >> {output}
        """
