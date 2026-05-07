#!/bin/bash 
#SBATCH --job-name=vcf_filter_NR_MONDAYNIGHT
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 1
#SBATCH --mem=8G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err


set -euo pipefail

hostname
date

# Load modules

module load vcftools/0.1.16
# Define variables

VCF_IN=../../results/05_variantCalling/freebayes_results_all/parallel.vcf.gz

OUTDIR=../../results/06_annotate/filtered_vcf/MondayNIGHT

PREFIX=NR_MONDAYNIGHT

echo "VCF: ${VCF_IN}"
# echo "BED: ${TARGETS}"
echo "OUT: ${OUTDIR}/${PREFIX}"

# Create directory

mkdir -p "${OUTDIR}"

# filter for only biallelic SNPs

vcftools --gzvcf "${VCF_IN}" \
  --min-alleles 2 \
  --max-alleles 2 \
  --minQ 50 \
  --recode \
  --recode-INFO-all \
  --out "${OUTDIR}/${PREFIX}"

hostname
date
