#!/bin/bash
#SBATCH --job-name=freebayes_parallel
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 60
#SBATCH --mem=480G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err


hostname
date

# load required software
module load freebayes/1.3.10
module load htslib/1.21-gcc-11.4.0-m4swynp
module load bcftools/1.19
module load parallel/20240322
module load vcflib/1.0.13

# in and out directories 

INDIR=../../results/03_Alignment/bwa_align/

OUTDIR=../../results/05_variantCalling/freebayes_results_all
mkdir -p ${OUTDIR} 

# make a list of bam files
find ${INDIR} -name "*.bam" > ${INDIR}/bam_list.txt

# set a variable for the reference genome location  
GENOME=../../genome/GRCh38_GIABv3_no_alt_analysis_set_maskedGRC_decoys_MAP2K3_KMT2C_KCNJ18.fasta

# Targents, 100kb windows 
TARGETS=../../results/04_alignQC/coverage/GRCh38_100kb.bed

# Call variants in parallel using freebayes 
(cat "$TARGETS" | sed 's/\t/:/ ; s/\t/-/' | parallel -k -j 56 \
"freebayes -f ${GENOME} --bam-list ${INDIR}/bam_list.txt -r {} --skip-coverage 1000 -k" \
) |
vcffirstheader |
vcfstreamsort -w 1000 |
vcfuniq |
bgzip >${OUTDIR}/parallel.vcf.gz

#Index vcf
tabix -p vcf ${OUTDIR}/parallel.vcf.gz


hostname
date
