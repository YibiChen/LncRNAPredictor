SRC_PATH=$1
TMPDIR=$2
GENOME_file=$3
MAX_INTRON_LENGTH=$4
NCPUS=$5
TRANSCRIPTS_CLEAN=$6
TRANSCRIPTS=$7
GENOME=$8

export PATH=${MINIMAP}:$PATH
#export PATH=/g/data/d85/Dino_gene_prediction_workflow/programs/blat_v36x2:$PATH

mkdir -p 4_PASA
cd 4_PASA
cp ${SRC_PATH}/PASA_alignAssembly.config alignAssembly.config
# Set SQLite database path to $TMPDIR (need to fully resolve path)
sed -i -e "s@DATABASE=.*@DATABASE=${TMPDIR}/${GENOME}_pasadb.sqlite@" alignAssembly.config

${PASA}/Launch_PASA_pipeline.pl --transcribed_is_aligned_orient \
--ALIGNERS minimap2 -c alignAssembly.config -C -R -g ${GENOME_file} \
--MAX_INTRON_LENGTH ${MAX_INTRON_LENGTH} --CPU ${NCPUS} -T -t ../${TRANSCRIPTS_CLEAN} -u ../${TRANSCRIPTS} \
> pasa.log 2>&1
${PASA}/pasa-plugins/transdecoder/TransDecoder.LongOrfs -t ${GENOME}_pasadb.sqlite.assemblies.fasta
${PASA}/pasa-plugins/transdecoder/TransDecoder.Predict -t ${GENOME}_pasadb.sqlite.assemblies.fasta
${PASA}/scripts/pasa_asmbls_to_training_set.dbi --pasa_transcripts_fasta ${GENOME}_pasadb.sqlite.assemblies.fasta --pasa_transcripts_gff3 ${GENOME}_pasadb.sqlite.pasa_assemblies.gff3
cd ..