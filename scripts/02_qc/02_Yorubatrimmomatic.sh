#!/bin/bash
#SBATCH --job-name=trimmomatic
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 4
#SBATCH --mem=15G
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=ALL
#SBATCH --mail-user=first.last@uconn.edu
#SBATCH -o %x_%A_%a.out
#SBATCH -e %x_%A_%a.err
#SBATCH --array=0-79

hostname
date

module load Trimmomatic/0.39

# directories (your structure is in /scratch)
BASEDIR=/core/projects/GAP/GDA/final_project2/
INDIR=${BASEDIR}/Yoruba_fastq
TRIMDIR=${BASEDIR}/results/02_qc/Yoruba_trimmed_fastq
mkdir -p $TRIMDIR

# adapters
ADAPTERS=/isg/shared/apps/Trimmomatic/0.39/adapters/TruSeq3-PE-2.fa

# accession list
ACCESSION_FILE=${BASEDIR}/metadata/accessionlistYoruba.txt

# get sample
SAMPLE=$(sed -n "$((SLURM_ARRAY_TASK_ID+1))p" $ACCESSION_FILE)

echo "Processing $SAMPLE"

# run trimmomatic
java -jar /isg/shared/apps/Trimmomatic/0.39/trimmomatic-0.39.jar PE -threads 4 \
    ${INDIR}/${SAMPLE}_1.fastq.gz \
    ${INDIR}/${SAMPLE}_2.fastq.gz \
    ${TRIMDIR}/${SAMPLE}_trim_1.fastq.gz ${TRIMDIR}/${SAMPLE}_orphans_1.fastq.gz \
    ${TRIMDIR}/${SAMPLE}_trim_2.fastq.gz ${TRIMDIR}/${SAMPLE}_orphans_2.fastq.gz \
    ILLUMINACLIP:${ADAPTERS}:2:30:10 \
    SLIDINGWINDOW:4:15 MINLEN:45
