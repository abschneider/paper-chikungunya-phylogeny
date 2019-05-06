# File: master.R
# Date: 5/5/19
# Author: Adriano Schneider
# Purpose: Plot NJ spread map.

source("/Users/schneider/GitHub/paper-chikungunya-phylogeny/scripts/functions.R")

#### Available from functions.R ####

# NJ_build_collapse <- function(filePath, accession) # filePath = alignment in fasta format / accession = accession ID
# parse_metaandtree <- function(treePath, metadataPath, metacolumn) # treePath = rootedTree (from NJ_build_collapse) / metadataPath = csv spreadsheet with ID + metadata / metacolumn = column name
# parsimony_ancestral_reconstruction(accessioncharacter, country, characterlabels, rootedTree) # all variables come from parse_metaandtree
# make_map <- function(filePath, transmissionpath) # filePath = geographic coordinates csv file / transmissionpath = variable with path from parsimony_ancestral_reconstruction.

##### MAIN CODE #####

#Set working directory

wd <- ("/Users/schneider/GitHub/paper-chikungunya-phylogeny/datasets/AUL")
# wd1 <- ("/Users/schneider/GitHub/paper-chikungunya-phylogeny/datasets/ECSA_IOL")
# wd2 <- ("/Users/schneider/GitHub/paper-chikungunya-phylogeny/datasets/ECSA_MASA")

setwd(wd)
# setwd(wd1)
# setwd(wd2)

## STEP 1 - Build Neighbor-Joining tree and collapse branches with low bootstrap value ##

NJ_build_collapse(filePath = 'AUL_CHIKV.aln.fasta', accession = "HM045788.1_India", bootstrapValue = 80)
# NJ_build_collapse(filePath = 'ECSA_IOL_CHIKV.aln.fasta', accession = "KF283986.1_Comoros", bootstrapValue = 80)
# NJ_build_collapse(filePath = 'ECSA_MASA_CHIKV.aln.fasta', accession = "KX262996.1_Cameroon", bootstrapValue = 80)

## STEP 2 - Parse phylogenetic tree and metadata file ##

parse_metaandtree(treePath = rootedTree,metadataPath = "AUL_metadata.csv")
# parse_metaandtree(treePath = rootedTree,metadataPath = "ECSA_IOL_metadata.csv")
# parse_metaandtree(treePath = rootedTree,metadataPath = "ECSA_MASA_metadata.csv")

## STEP 3 - Perform ancestry reconstruction step ##

parsimony_ancestral_reconstruction(accessioncharacter, country, characterlabels, rootedTree)

## STEP 4 - Map changes of character states ##

make_map(filePath = "geodata.csv", transmissionpath = Edge_list)
