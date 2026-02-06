# Session I — Practicals

This session introduces Snakemake fundamentals through 4 structured practicals. Work through them in order.

**Prerequisites:** Before starting, make sure you have Snakemake installed and have generated the input data files:
```
$ cd snakemake_tutorial/session1
$ snakemake -j 1 generate_data_files
```

---

## Practical 1 — Orientation

**Goal:** Understand how to read a Snakefile and use `--dry-run` and `--dag` to explore workflows.

### Exercises

1. Open `Snakefile` in a text editor. Identify:
   - How many rules are defined?
   - What is the input and output of `count_words`?
   - Which rule uses an R script?

2. Run a dry-run of the `count_words` rule and examine the output:
   ```
   $ snakemake -j 1 count_words --dry-run
   ```
   - How many jobs does Snakemake plan to execute?
   - What files will be created?

3. Now run it for real:
   ```
   $ snakemake -j 1 count_words
   ```
   - Look at the output file in `output/word_count.txt`. What does it contain?

4. Run it again. What happens? Why?

5. Open `Snakefile_3rules.smk`. This chains multiple rules together.
   ```
   $ snakemake --snakefile Snakefile_3rules.smk --dry-run
   ```
   - How many jobs will run?
   - In what order do the rules execute?
   - Which rule is the "target" rule?

6. Visualise the workflow DAG (requires Graphviz):
   ```
   $ snakemake --snakefile Snakefile_3rules.smk --dag | dot -Tpng > my_dag.png
   ```
   Compare your DAG with `rulegraph.png`.

### Checkpoint questions

<details>
<summary>Q: Why does Snakemake not re-run a rule when you run it a second time?</summary>
A: Snakemake checks whether the output files already exist and are newer than the input files. If they are, the rule is skipped.
</details>

<details>
<summary>Q: What does `rule all` do in Snakefile_3rules.smk?</summary>
A: It is a target rule — it defines the final output files that the workflow should produce. Snakemake works backwards from these targets to determine which rules need to run.
</details>

<details>
<summary>Q: What is the difference between `--dry-run` and actually running the workflow?</summary>
A: `--dry-run` (or `-n`) shows what Snakemake *would* do without actually executing any commands. It is useful for verifying your workflow before committing to a potentially long run.
</details>

---

## Practical 2 — Modify the Workflow

**Goal:** Learn to modify wildcards, outputs, threads, logs, and use `expand()` with config files.

Work with `Snakefile_wildcards.smk` for these exercises.

### Task A — Add a sample
The workflow currently processes files numbered 0-9. Add a new input file:
```
$ echo "sample no. 10" > data_wildcards/snakemake_input_10.txt
```
Modify `rule all` in `Snakefile_wildcards.smk` to also process this new file. Run `--dry-run` to verify.

### Task B — Change the output directory
Change the output directory from `output/edited_files/` to `output/processed/`. Remember to update both `rule all` and `rule edit_text`.

### Task C — Add threads
Add `threads: 2` to `rule edit_text`. Run with `--dry-run` and notice that Snakemake now reports thread usage. (This rule doesn't actually benefit from threads, but it demonstrates the syntax.)

### Task D — Add a log directive
Add a `log` directive to `rule edit_text`:
```python
log: "logs/edit_text_{num}.log"
```
Modify the shell command to redirect stderr to the log file:
```python
shell: "cat {input} | sed 's/no./number/' > {output} 2> {log}"
```

### Task E — Complete the TODO rules
Read the TODO section at the bottom of `Snakefile_wildcards.smk`. Write:
1. `rule add_num_to_output_file` — appends the sample number to each edited file
2. `rule concatenate_all_files` — concatenates all numbered files into `output/final_results.txt`

Update `rule all` to target `output/final_results.txt`.

Check your solution against `Snakefile_wildcards_solution.smk`.

### Task F — Use expand() with config
Open `config.yaml` — notice the `SAMPLES` list. Refactor `rule all` to use:
```python
expand("output/edited_files/snakemake_output_{num}.txt", num=config["SAMPLES"])
```
instead of listing numbers explicitly.

---

## Practical 3 — Break It on Purpose

**Goal:** Learn to read Snakemake error messages and use debugging flags.

Work with `Snakefile_debug.smk`. This file contains a working baseline rule and 4 commented-out buggy variants.

### Setup
First, confirm the baseline works:
```
$ snakemake --snakefile Snakefile_debug.smk --dry-run
```

### Exercise: Fix the bugs
For each bug (1-4), uncomment the buggy rule, comment out the working one, and run:
```
$ snakemake --snakefile Snakefile_debug.smk --dry-run
```

**Bug 1 — Wildcard name mismatch:** The input uses `{sample}` but the output uses `{num}`. What error does Snakemake give? Fix it so both use the same wildcard name.

**Bug 2 — Output filename typo:** The output filename has a typo (`snakemake_outpt_`). What happens when you run `--dry-run`? Why doesn't Snakemake find the right rule?

**Bug 3 — Wrong input directory:** The input points to `data_wrong_folder/` which doesn't exist. Run without `--dry-run` — what error do you get?

**Bug 4 — Shell command typo:** The shell uses `catt` instead of `cat`. Run without `--dry-run` — what happens?

### Useful debugging flags
Try running with these flags to get more information:
```
$ snakemake --snakefile Snakefile_debug.smk -j 1 --printshellcmds --reason
```
- `--printshellcmds` (`-p`): shows the exact shell commands being executed
- `--reason` (`-r`): explains why each rule is being run
- `--rerun-incomplete`: re-runs jobs that were left incomplete (e.g. after a crash)

---

## Practical 4 — Extend the Workflow (stretch)

**Goal:** Add new rules to an existing workflow and use config toggles.

Start from `Snakefile_wildcards_solution.smk` (or your own completed version from Practical 2E).

### Task A — Add a line count rule
Add a rule `count_lines` that runs `wc -l` on each numbered file and saves the result to `output/line_counts/snakemake_linecount_{num}.txt`.

### Task B — Add a summary rule
Add a rule `summarise` that concatenates all line count files into `output/summary.txt`.

### Task C — Config toggle
Look at `config.yaml` — it has an `UPPERCASE` parameter set to `false`. Add an `if/else` block in your `edit_text` rule that converts the text to uppercase when `UPPERCASE` is `true`:
```python
rule edit_text:
    input: "data_wildcards/snakemake_input_{num}.txt"
    output: "output/edited_files/snakemake_output_{num}.txt"
    run:
        with open(input[0]) as f:
            text = f.read().replace("no.", "number")
        if config["UPPERCASE"]:
            text = text.upper()
        with open(output[0], 'w') as f:
            f.write(text)
```

### Task D — Visualise the extended DAG
Generate a DAG for your extended workflow:
```
$ snakemake --snakefile <your_snakefile> --dag | dot -Tpng > extended_dag.png
```
How does it compare to the original?

---

## Reference: Snakefiles in this session

| Snakefile | Concepts demonstrated |
|---|---|
| `Snakefile` | Basic rules, input/output, shell commands, R scripts, `expand()`, `generate_data_files` |
| `Snakefile_3rules.smk` | Chaining rules, `configfile`, `workdir`, Python `run` blocks, `rules.` references |
| `Snakefile_wildcards.smk` | Wildcards `{num}`, `expand()`, TODO exercises for students |
| `Snakefile_wildcards_solution.smk` | Solution to the TODO exercises above |
| `Snakefile_debug.smk` | Debugging exercises with 4 common bug types |
| `Snakefile_parse_gffs.smk` | Processing GFF3 files with R, external scripts, `expand()` |
