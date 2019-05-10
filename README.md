# Updated Phylogeny of Chikungunya Virus Reveals Lineage-specific Non-coding RNAs

"URL of submitted file here"

# Authors

* Adriano de Bernardi Schneider, Ph.D.
* Roman Ochseinreiter
* Reilly Hostager
* Ivo L. Hofacker, Ph.D.
* Daniel Janies, Ph.D.
* Michael T. Wolfinger, Ph.D.

---

Please cite using the following BibTex entry:

```

ENTRY HERE

```
---
How-to/Workflow:
User must hardcode the input file paths to execute functions

master.R is dependent on the functions.R file

Neighbor-Joining (NJ) tree-builder:
A function which creates a distance matrix from an alignment, builds a NJ tree, performs a bootstrap analysis, and collapses weakly supported nodes.
User input: filePath, accession for taxon used in rooting, bootstrapValue as threshold for collapsing branches
Of note: A model test is performed within the function, selects the highest likelihood of either JC69 or F81 (the accepted nucleotide models in the model test procedure).

Parse metadata and tree:
A function which utilizes the rooted tree made in the prior function.
User must input a csv format metadata file with a header and the first column labeled "accession."
Data is extracted and paired with the taxon labels. These are sorted jointly in subsequent functions.

Parsimony ancestral reconstruction:
A function which assigns most likely character state to tree nodes, using the pre-constructed phylogeny and paired metadata to build a heuristic ancestral reconstruction.

Plot a transmission network in a map using leaflet:
A function which creates a map of the inferred network, designating appropriate states as Origin or Destination in pinpointed tranmission events.
User must input a csv table with "Location","Latitude", and "Longitude" headers.


---

Contact: Adriano de Bernardi Schneider (@abschneider, <adeberna@ucsd.edu>) or Michael T. Wolfinger (@mtw, <michael.wolfinger@univie.ac.at>)
