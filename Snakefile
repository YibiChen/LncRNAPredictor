configfile: "config.yaml"

rule all:
    input:
       "8_featureCounts/final_ncRNA_renamed.fasta"

rule trimming:
    input:
        read1=config["read1"],
        read2=config["read2"]
    output:
        "1_trimmed_reads/{sample}_1.trimmed.fastq.gz".format(sample=config["sample"]),
        "1_trimmed_reads/{sample}_2.trimmed.fastq.gz".format(sample=config["sample"])
    run:
        trimmed_read1_files =[]
        # paired end reads
        if len(input.read_2_files) >0:
            read_1_file =input.read1
            read_2_file =input.read2
            read_file_id = config["sample"]
            #trim reads
            shell("mkdir -p 1_trimmed_reads")
            shell("fastp -i {read_1_file} -o 1_trimmed_reads/{read_file_id}_1.trimmed.fastq -I {read_2_file} -O 1_trimmed_reads/{read_file_id}_2.trimmed.fastq -w {threads}")
            # remove spaces in the header
            shell("sed -i 's/ /_/g' 1_trimmed_reads/{read_file_id}_1.trimmed.fastq")
            shell("gzip  1_trimmed_reads/{read_file_id}_1.trimmed.fastq")
            shell("sed -i 's/ /_/g' 1_trimmed_reads/{read_file_id}_2.trimmed.fastq")
            shell("gzip  1_trimmed_reads/{read_file_id}_2.trimmed.fastq")

rule assemble:
    input:
        read1="1_trimmed_reads/{sample}_1.trimmed.fastq.gz".format(sample=config["sample"]),
        read2="1_trimmed_reads/{sample}_2.trimmed.fastq.gz".format(sample=config["sample"])
    output:
        "2_assemblies/trinity_{sample}.Trinity.fasta".format(sample=config["sample"])
    params:
        tmpdir=os.environ["TMPDIR"]
    threads: workflow.cores
    run:
        # assemble with Trinity
        shell("echo 'Trinity --max_memory 50G --seqType fq --SS_lib_type RF --left {read_1_paths} --right {read_2_paths} --output {tmpdir}/trinity_{sample}  --full_cleanup --CPU {threads}'".format(read_1_paths=input.read1,read_2_paths=input.read2,tmpdir=params.tmpdir,sample=config["sample"],threads=(threads-1)))
        shell("Trinity --max_memory 50G --seqType fq --SS_lib_type RF --left {read_1_paths} --right {read_2_paths} --output {tmpdir}/trinity_{sample}  --full_cleanup --CPU {threads}".format(read_1_paths=input.read1,read_2_paths=input.read2,tmpdir=params.tmpdir,sample=config["sample"],threads=(threads-1)))
        shell("mkdir -p 2_assemblies/")
        shell("cp  {tmpdir}/trinity_{sample}.Trinity.fasta {output}".format(tmpdir=params.tmpdir,sample=config["sample"],output=output))

            
rule clean_vector_sequences:
    input:
        "2_assemblies/trinity_{sample}.Trinity.fasta".format(sample=config["sample"])
    output:
        "3_SeqClean/transcripts.fa.clean"
    threads: workflow.cores
    run:
        shell("run_seqclean.sh {INPUT} {THREADS}".format(
            INPUT=input,
            THREADS=min(16,threads)))


rule map_to_genome:
    input:
        genome_file=config["genome_file"],
        transcripts_clean="3_SeqClean/transcripts.fa.clean"
    output:
        "4_PASA/{sample}_pasadb.sqlite.pasa_assemblies.bed".format(sample=config["sample"]),
        "4_PASA/{sample}_pasadb.sqlite.assemblies.fasta".format(sample=config["sample"]),
        "4_PASA/{sample}_pasadb.sqlite.assemblies.fasta.transdecoder.pep".format(sample=config["sample"])

    threads: workflow.cores
    params:
        tmpdir=os.environ["TMPDIR"]
    run:
        shell("run_PASA.sh  {TMPDIR} {GENOME_file} {MAX_INTRON_LENGTH} {NCPUS} {TRANSCRIPTS_CLEAN}  {TRANSCRIPTS} {GENOME}".format(
            TMPDIR=params.tmpdir,
            GENOME_file=input.genome_file,
            MAX_INTRON_LENGTH=config["max_intron_length"],
            NCPUS=threads,
            TRANSCRIPTS_CLEAN=input.transcripts_clean,
            TRANSCRIPTS="3_SeqClean/transcripts.fa",
            GENOME=config["sample"]
        ))


rule find_ncRNA_candidates:
    input:
        genes_gff=config["gene_annotation"],
        PASA_bed="4_PASA/{sample}_pasadb.sqlite.pasa_assemblies.bed".format(sample=config["sample"]),
        PASA_fasta="4_PASA/{sample}_pasadb.sqlite.assemblies.fasta".format(sample=config["sample"])
    output:
        bed_file="5_ncRNA_candidates/{sample}_lncRNA_raw_candidates.bed".format(sample=config["sample"]),
        fa_file="5_ncRNA_candidates/{sample}_lncRNA_raw_candidates.fa".format(sample=config["sample"])
        
    run:
        shell("find_ncRNA_candidates.sh  {sample} {gene_gff} {PASAassemb_bed} {PASAassemb_fa}".format(
            sample=config["sample"],
            gene_gff=input.genes_gff,
            PASAassemb_bed=input.PASA_bed,
            PASAassemb_fa=input.PASA_fasta
        ))


rule get_coding_potential_CPC:
    input:
        "5_ncRNA_candidates/{sample}_lncRNA_raw_candidates.fa".format(sample=config["sample"])
    output:
        "6_coding_potential/CPC2/all_candidate.results.txt"
    run:
        shell("run_CPC2.sh {raw_candidates} ".format(raw_candidates=input))


rule get_coding_potential_FEELnc_intergenic:
    input:
        genome_file=config["genome_file"],
        genes_gff=config["gene_annotation"],
        ncRNA_candidates="5_ncRNA_candidates/{sample}_lncRNA_raw_candidates.fa".format(sample=config["sample"])
    output:
        "6_coding_potential/FEELnc_intergenic/{sample}_lncRNA_raw_candidates.fa.lncRNA.fa".format(sample=config["sample"])
    run:
        shell("run_FEELnc_intergenic.sh {gene_gff} {sample} {raw_candidates} {genome_file}".format(
            gene_gff=input.genes_gff,
            sample=config["sample"],
            raw_candidates=input.ncRNA_candidates,
            genome_file=input.genome_file
            ))

rule get_coding_potential_FEELnc_shuffle:
    input:
        genome_file=config["genome_file"],
        genes_gff=config["gene_annotation"],
        ncRNA_candidates="5_ncRNA_candidates/{sample}_lncRNA_raw_candidates.fa".format(sample=config["sample"])
    output:
        "6_coding_potential/FEELnc_shuffle/{sample}_lncRNA_raw_candidates.fa.lncRNA.fa".format(sample=config["sample"])
    run:
        shell("run_FEELnc_shuffle.sh {gene_gff} {sample} {raw_candidates} {genome_file}".format(
            gene_gff=input.genes_gff,
            sample=config["sample"],
            raw_candidates=input.ncRNA_candidates,
            genome_file=input.genome_file
            ))

rule combine_coding_potential:
    input:
        CPC_result="6_coding_potential/CPC2/all_candidate.results.txt",
        FEELnc_intergenic="6_coding_potential/FEELnc_intergenic/{sample}_lncRNA_raw_candidates.fa.lncRNA.fa".format(sample=config["sample"]),
        FEELnc_shuffle="6_coding_potential/FEELnc_shuffle/{sample}_lncRNA_raw_candidates.fa.lncRNA.fa".format(sample=config["sample"]),
        PASA_transcripts="4_PASA/{sample}_pasadb.sqlite.assemblies.fasta".format(sample=config["sample"])
    output:
        "6_coding_potential/consensus.lst"
    run:
        shell("combine_coding_potential.sh {PASA_transcripts}}".format(PASA_transcripts=input.PASA_transcripts))

rule check_pfam_protein_domains:
    input:
        ncRNA_pep="4_PASA/{sample}_pasadb.sqlite.assemblies.fasta.transdecoder.pep".format(sample=config["sample"]),
        ncRNA_list="6_coding_potential/consensus.lst",
        ncRNA_bed="4_PASA/{sample}_pasadb.sqlite.pasa_assemblies.bed".format(sample=config["sample"]),
        genes_gff=config["gene_annotation"]
    output:
        "7_Pfam/annotation.gtf",
        "7_Pfam/represent_ncRNA.bed",
        "7_Pfam/represent_ncRNA.gff3"
    run:
        shell("run_pfam.sh {ncRNA_pep_fa} {combined_ncRNA_list} {ncRNA_bed} {gene_gff}".format(
            ncRNA_pep_fa=input.ncRNA_pep,
            combined_ncRNA_list=input.ncRNA_list,
            ncRNA_bed=input.ncRNA_bed,
            gene_gff=input.genes_gff
            ))

rule feature_counts:
    input:
        genome=config["genome_file"],
        read1="1_trimmed_reads/{sample}_1.trimmed.fastq.gz".format(sample=config["sample"]),
        read2="1_trimmed_reads/{sample}_2.trimmed.fastq.gz".format(sample=config["sample"]),
        annotation_gtf="7_Pfam/annotation.gtf",
        represent_ncRNA_bed="7_Pfam/represent_ncRNA.bed",
        represent_ncRNA_gff="7_Pfam/represent_ncRNA.gff3",
        ncRNA_fasta="4_PASA/{sample}_pasadb.sqlite.assemblies.fasta".format(sample=config["sample"])
    output:
        "8_featureCounts/featureCounts_pair.txt",
        "8_featureCounts/final_ncRNA_renamed.fasta"
    threads: workflow.cores
    run:
        shell("feature_counts.sh {genome} {trimmed_read_1} {trimmed_read_2} {annotation_gtf} {threads}".format(
            genome=input.genome,
            trimmed_read_1=input.read1,
            trimmed_read_2=input.read2,
            annotation_gtf=input.annotation_gtf,
            threads=threads
            ))
        shell("get_final_lncRNAs.sh {ncRNA_bed} {ncRNA_fasta} {prefix} {ncRNA_gff3}".format(
            ncRNA_bed=input.represent_ncRNA_bed,
            ncRNA_fasta=input.ncRNA_fasta,
            prefix=config["sample"],
            ncRNA_gff3=input.represent_ncRNA_gff
        ))

