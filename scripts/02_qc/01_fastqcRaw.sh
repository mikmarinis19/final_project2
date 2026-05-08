#!/bin/bash 
#SBATCH --job-name=fastqc_raw
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

# load software
module load fastqc/0.11.7

# create output directory
OUTDIR1=../../results/02_qc/fastqc_raw/Yoruba_fastqc
mkdir -p "$OUTDIR1"

# input directories
DIR1="/core/projects/GAP/GDA/final_project2/Yoruba_fastq"

# run FastQC 
fastqc -t 6 -o "$OUTDIR1" \
    "$DIR1"/*fastq.gz

# load MultiQC
module load MultiQC/1.33

# run MultiQC on FastQC output
multiqc -f -o "$OUTDIR/multiqc" "$OUTDIR1"

# create output directory
OUTDIR2=../../results/02_qc/fastqc_raw/England_fastqc
mkdir -p "$OUTDIR2"

# input directories
DIR2="/core/projects/GAP/GDA/final_project2/England_fastq"

# run FastQC 
fastqc -t 6 -o "$OUTDIR2" \
    "$DIR2"/*fastq.gz

# run MultiQC on FastQC output
multiqc -f -o "$OUTDIR2/multiqc" "$OUTDIR2"
