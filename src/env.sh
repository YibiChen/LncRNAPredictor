module load trinity
module load samtools
module load jellyfish
module load bowtie2
module load salmon
module load R/4.1.0 # requires ggplot2 and seqlogo 
module load bedtools


export src=/scratch/d85/yc1401/snakemake/src
export scripts=/scratch/d85/yc1401/snakemake/scripts
export PASA=/g/data/d85/Dino_gene_prediction_workflow/programs/PASApipeline.v2.4.1-modified
export BLASTALL=/g/data/d85/Dino_gene_prediction_workflow/programs/blast-2.2.26/bin
export UNIVEC=/g/data/d85/Dino_gene_prediction_workflow/databases/UNIVEC/BUILD_10.0/UniVec_Core
export MINIMAP2=/g/data/d85/Dino_gene_prediction_workflow/programs/minimap2-2.18_modified
export python=/home/564/yc1401/programs/miniconda3/bin/python3.11


export PATH=${src}:$PATH
export PATH=${scripts}:$PATH
export PATH=/home/564/yc1401/programs/fastp_v0.23.3:${PATH}
export PATH=${BLASTALL}:$PATH
export PATH=${MINIMAP2}:$PATH
export PATH=${PASA}/pasa-plugins/cdbtools/cdbfasta:$PATH
export PATH=${PASA}/pasa-plugins/seqclean/mdust:$PATH
export PATH=${PASA}/pasa-plugins/seqclean/psx:$PATH
export PATH=${PASA}/pasa-plugins/seqclean/trimpoly:$PATH
export PATH=$PATH:${PASA}/misc_utilities/
export PATH=~/programs/CPC2/bin/:$PATH
export PATH=~/programs/FEELnc/bin/:$PATH
export PATH=~/programs/hisat/bin/:$PATH
export PATH=~/programs/subread-2.0.3-Linux-x86_64/bin/:$PATH
export PATH=~/programs/gffread/bin/:$PATH

