#!/bin/bash
#SBATCH --job-name=fasterq_dump_xanadu
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 12
#SBATCH --mem=15G
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mim18007@uconn.edu
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

hostname
date

# load software
module load parallel/20180122
module load sratoolkit/3.0.1

# Yoruba
OUTDIR1=../Yoruba_fastq
mkdir -p ${OUTDIR1}
ACCLIST1=../../metadata/accessionlistYoruba.txt

cat $ACCLIST1 | parallel -j 2 "fasterq-dump {} -O ${OUTDIR1} && gzip ${OUTDIR1}/{}*.fastq"

# England
OUTDIR2=../England_fastq
mkdir -p ${OUTDIR2}
ACCLIST2=../../metadata/accessionlistEngland.txt

cat $ACCLIST2 | parallel -j 2 "fasterq-dump {} -O ${OUTDIR2} && gzip ${OUTDIR2}/{}*.fastq"
