configfile: "config.yaml"
workdir: config["WORKING_FOLDER"]

reference_file = config["REF"]
print(reference_file)
# shell.executable("/bin/bash")
# shell.prefix("source ~/.bashrc; ")

rule all:
    input:
        # use expand() to do this concisely in one line
        expand("output/edited_files/snakemake_output_{filenum}.txt", filenum=['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) 

rule edit_text:
    input: "data_wildcards/snakemake_input_{num}.txt"
    output: "output/edited_files/snakemake_output_{num}.txt"
    shell: "cat {input} | sed 's/no./number/' > {output}"

# TODO
# rule add_num_to_output_file:
#     """Create a rule to add the sample number {num} to the end of the text in the edited files.
#     So the new files should have text such as "sample number 1", "sample number 2", etc
#     The new files should be in a folder named output/numbered_files/"""
#     input:
#     output:
#     params:
#     shell:

# rule concatenate_all_files:
#     """Create a rule to concatenate all the numbered files to create a new file called final_results.txt
#     within the folder output/
#     Don't forget to change rule 'all' so that all the rules are executed!
#     """
#     input:
#     output:
#     params:
#     shell:

# Additional resources
# https://slides.com/johanneskoester/snakemake-tutorial
