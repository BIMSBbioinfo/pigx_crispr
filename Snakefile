configfile: "config.yaml"

#print(config["samples"])
#print(expand("sample_data/raw_reads/{sample}.fastq.gz", sample = config["samples"]))
#print(config["genome"])
#rule all

nodeN = config["nodeN"]
adapters = config["adapters"]

rule all:
    input:
        expand("fastqc/{sample}_fastqc.html", sample = config["samples"]),
        "ref",
        expand("aln/{sample}.sam", sample = config["samples"])


rule fastqc:
    input:
        "sample_data/raw_reads/{sample}.fastq.gz"
    output:
        "fastqc/{sample}_fastqc.html"
    shell:
        "fastqc {input} -o fastqc"

rule trimmomatic:
    input:
        "sample_data/raw_reads/{sample}.fastq.gz"
    output:
        "sample_data/filtered_reads/{sample}.fastq.gz"
    shell:
       "trimmomatic SE -threads {nodeN} {input} {output} \
       ILLUMINACLIP:{adapters}:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36"

rule bbmap_indexgenome:
    input:
        fa=config["genome"]
    output:
        "ref"
    shell:
        "bbmap.sh ref={input.fa}"

rule bbmap_map:
    input:
        "sample_data/filtered_reads/{sample}.fastq.gz",
        "ref"
    output:
        "aln/{sample}.sam"
    shell:
        "bbmap.sh in={input} outm={output} t={nodeN} sam=1.3"


#rule samtools_sam2bam

#rule samtools_rmdup

#rule samtools_sort

#rule samtools_index

#rule samtools_mpileup

#rule parse_mpileup #find indels

#rule extractPerBaseDeletionScores

#rule getDeletions

#rule report
