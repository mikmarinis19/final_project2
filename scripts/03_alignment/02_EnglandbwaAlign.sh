#!/bin/bash 
#SBATCH --job-name=align_pipe
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 8
#SBATCH --mem=30G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#SBATCH -o %x_%A_%a.out
#SBATCH -e %x_%A_%a.err
#SBATCH --array=[0-79]

hostname
date

# load required software
module load bwa-mem2/2.1
module load samblaster/0.1.24
module load samtools/1.21-gcc-11.4.0-mcohq7c
module load openssl   # ✅ FIX: resolves libcrypto.so.10 error

# base directory
BASEDIR=/scratch/mmarinis/final_project2

# directories
SAMPDIR=${BASEDIR}/results/02_qc/England_trimmed_fastq
OUTDIR=${BASEDIR}/results/03_Alignment/bwa_align/England
mkdir -p $OUTDIR

INDEX=${BASEDIR}/results/03_Alignment/bwa_index/GRCh38

# accession list
ACCESSION_FILE=${BASEDIR}/metadata/accessionlistEngland.txt

# get sample
SAMPLE=$(sed -n "$((SLURM_ARRAY_TASK_ID+1))p" $ACCESSION_FILE)

echo "Processing $SAMPLE"

# read group
RG="@RG\tID:${SAMPLE}\tSM:${SAMPLE}"

# alignment pipeline
bwa-mem2 mem -t 7 -R "$RG" $INDEX \
    ${SAMPDIR}/${SAMPLE}_trim_1.fastq.gz \
    ${SAMPDIR}/${SAMPLE}_trim_2.fastq.gz | \
    samblaster | \
    samtools view -h -u - | \
    samtools sort -T ${OUTDIR}/${SAMPLE}.temp -O BAM -o ${OUTDIR}/${SAMPLE}.bam

# index BAM
samtools index ${OUTDIR}/${SAMPLE}.bam
