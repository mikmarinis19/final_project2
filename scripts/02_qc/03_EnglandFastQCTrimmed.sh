#!/bin/bash 
#SBATCH --job-name=fastqc_trimmed
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 6
#SBATCH --mem=10G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

hostname
date

module load fastqc/0.11.7

INDIR=../../results/02_qc/England_trimmed_fastq
OUTDIR=../../results/02_qc/England_fastqc_trimmed
mkdir -p $OUTDIR

# paired-end
fastqc -t 6 -o $OUTDIR ${INDIR}/*_trim_1.fastq.gz
fastqc -t 6 -o $OUTDIR ${INDIR}/*_trim_2.fastq.gz

# MultiQC
module load MultiQC/1.9

multiqc -f -o $OUTDIR/multiqc $OUTDIR
