# Updated phylogeny of Chikungunya virus reveals lineage-specific RNA architecture

This repository contains software and datasets for the above publication. A preprint is available from BioRxiv at https://doi.org/10.1101/698522

# Authors

* Adriano de Bernardi Schneider
* Roman Ochseinreiter
* Reilly Hostager
* Ivo L. Hofacker
* Daniel Janies
* Michael T. Wolfinger [[@mtw](https://github.com/mtw)]

---

Please cite using the following BibTex entry:

```
@article {deBernardiSchneider-2019,
	author = {de Bernardi Schneider, Adriano and Ochsenreiter, Roman and Hostager, Reilly and Hofacker, Ivo L and Janies, Daniel and Wolfinger, Michael T},
	title = {Updated phylogeny of {C}hikungunya virus reveals lineage-specific {RNA} architecture},
	elocation-id = {698522},
	year = {2019},
	doi = {10.1101/698522},
	publisher = {Cold Spring Harbor Laboratory},
	abstract = {Chikungunya virus (CHIKV), a mosquito-borne alphavirus of the family Togaviridae, has recently emerged in the Americas from lineages from two continents, Asia and Africa. Historically, CHIKV circulated as at least four lineages worldwide with both enzootic and epidemic transmission cycles. To understand the recent patterns of emergence and the current status of the CHIKV spread, updated analyses of the viral genetic data and metadata are needed. Here, we performed phylogenetic and comparative genomics screens of CHIKV genomes, taking advantage of the public availability of many recently sequenced isolates. Based on these new data and analyses, we derive a revised phylogeny from nucleotide sequences in coding regions. Using this phylogeny, we uncover the presence of several distinct lineages in Africa that were previously considered a single one. In parallel, we performed thermodynamic modeling of CHIKV untranslated regions (UTRs), which revealed evolutionarily conserved structured and unstructured RNA elements in the 3{\textquoteright}UTR. We provide evidence for duplication events in recently emerged American isolates of the Asian CHIKV lineage and propose the existence of a flexible 3{\textquoteright}UTR architecture among different CHIKV lineages.},
	URL = {https://www.biorxiv.org/content/early/2019/07/11/698522},
	eprint = {https://www.biorxiv.org/content/early/2019/07/11/698522.full.pdf},
	journal = {bioRxiv}
}
```
---
# How-to/Workflow:

User must hardcode the input file paths to execute functions on master.R.

The master.R script is dependent on the following functions(available at functions.R):

*NJ_build_collapse(filePath, accession, bootstrapValue)* - Neighbor-Joining (NJ) tree-builder:

User input: filePath, accession for taxon used in rooting, bootstrapValue as threshold for collapsing branches.
A function which creates a distance matrix from an alignment, builds a NJ tree, performs a bootstrap analysis, and collapses weakly supported nodes.

*Note: A model test is performed within the function, selects the highest likelihood of either JC69 or F81 (the accepted nucleotide models in the model test procedure)*.

*parse_metaandtree(treePath, metadataPath)* - Parse metadata and tree:

User input: csv format metadata file with header and the first column labeled "Accession".
A function which utilizes the rooted tree made in the prior function.
Data is extracted and paired with the taxon labels. These are sorted jointly in subsequent functions.

*parsimony_ancestral_reconstruction(accessioncharacter, country, characterlabels, rootedTree)* - Parsimony ancestral reconstruction:

User input: None, function is dependent of parse_metaandtree and NJ_build_collapse.
A function which assigns the most likely metadata character state to tree nodes based on parsimony ancestral reconstruction using the phylogenetic tree and paired metadata and outputs an edge list for "origin" and "destination" metadata.

*make_map(filePath, transmissionpath, linecolor, circlecolor)* - Plot a transmission network in a map using leaflet:

User input: csv table with "Location","Latitude", and "Longitude" headers.
A function which creates a map of the inferred network, designating appropriate states as Origin or Destination in pinpointed tranmission events.


---

Contact: Adriano de Bernardi Schneider ([@abschneider](https://github.com/abschneider), <adeberna@ucsd.edu>) or Michael T. Wolfinger ([@mtw](https://github.com/mtw), <michael.wolfinger@univie.ac.at>)
