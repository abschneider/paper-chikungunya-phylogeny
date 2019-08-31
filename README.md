# Updated phylogeny of Chikungunya virus suggests lineage-specific RNA architecture

This repository contains software and datasets for the above paper, published at MDPI Viruses https://doi.org/10.3390/v11090798

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
@Article{BernardiSchneider-2019,
  author =       {de Bernardi Schneider, Adriano and Ochsenreiter,
                  Roman and Hostager, Reilly and Hofacker, Ivo L. and
                  Janies, Daniel and Wolfinger, Michael T.},
  title =        {Updated {P}hylogeny of {C}hikungunya {V}irus
                  {S}uggests {L}ineage-{S}pecific {RNA}
                  {A}rchitecture},
  journal =      {Viruses},
  volume =       11,
  issue =        9,
  pages =        798,
  doi =          {10.3390/v11090798},
  URL =          {https://doi.org/10.3390/v11090798},
  year =         2019
}

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
