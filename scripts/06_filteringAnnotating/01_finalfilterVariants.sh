#!/bin/bash 
#SBATCH --job-name=filterVariants
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 7
#SBATCH --mem=10G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

hostname
date

set -euo pipefail

module load vcftools/0.1.16

#####################################
# WHOLE GENOME INPUT (KEEP THIS)
#####################################

VCF_IN=../../results/05_variantCalling/freebayes_results_all/parallel.vcf.gz

OUTDIR=../../results/06_annotate/filtered_vcf
PREFIX=wg_filtered

mkdir -p "${OUTDIR}"

#####################################
# WHOLE-GENOME FILTERING ONLY
#####################################

vcftools --gzvcf "${VCF_IN}" \
  --min-alleles 2 \
  --max-alleles 2 \
  --remove-indels \
  --minQ 20 \
  --max-missing 0.75 \
  --maf 0.01 \
  --recode \
  --recode-INFO-all \
  --out "${OUTDIR}/${PREFIX}"

#####################################
# EXTRACT LACTASE REGION (SEPARATE STEP)
#####################################

bcftools view \
  -r chr2:135000000-136500000 \
  "${OUTDIR}/${PREFIX}.recode.vcf" \
  -Oz -o "${OUTDIR}/lct_region.vcf.gz"

tabix -p vcf "${OUTDIR}/lct_region.vcf.gz"
