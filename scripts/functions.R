# File: functions.R
# Date: 5/5/19
# Author: Adriano Schneider

library(ape)
library(castor)
library(hashmap)
library(plyr)
library(dplyr)
library(data.table)
library(magrittr)
library(leaflet)
library(geosphere)
library(phangorn)
library(seqinr)

# Neighbor Joining Tree Builder # 
## Function which creates distance matrix from alignment, builds NJ tree, performs bootstrap analysis, collapses weakly supported nodes - Requires ape, phangorn, and seqinr libraries ##
NJ_build_collapse <- function(filePath, accession, bootstrapValue) {
  dna <- read.dna(filePath, format="fasta")
  # Create data frame in phangorn format
  aln_phyDat <- phyDat(dna, type="DNA", levels = NULL)
  
  mt <- modelTest(aln_phyDat) # perform model test to build distance matrix
  reducedmt <- mt[c(1,5),c(1,3)] # extracts rows 1 and 5 from modeltest, columns 1 and 3 (models accepted to build distance matrix)
  maxmt <- reducedmt[which.max(reducedmt$logLik),] # selects model with highest likelihood
  dna_dist <- dist.ml(aln_phyDat, model=maxmt$Model)  # builds distance matrix
  
  # Build NJ tree from distance matrix
  aln_NJ <- bionj(dna_dist)
  
  BS <- boot.phylo(aln_NJ, dna, function(e) # Run bootstrap
    root(nj(dist.dna(e, model=maxmt$Model)),accession)) 
  BS
 
  # Collapse branches of poorly supported nodes into multifurcations with bootstrap values less than X%
  trans_NJ <- aln_NJ # Dont want to change chikv_NJ file itself, assign to new variable for safekeeping
  N <- length(aln_NJ$tip.label) # Get total number of taxa from tree
  toCollapse <- match(which(BS<bootstrapValue)+N, trans_NJ$edge[,2]) # Match bootstrap value at node to 'destination' edge in second column, returns node number with bs <x%, to be collapsed
  trans_NJ$edge.length [toCollapse] <- 0 # Assigns 0 to edge lengths of nodes with bs <x%, collapses
  # di2multi collapse or resolve multichotomies in phylogenetic trees
  collapsedTree <- di2multi(trans_NJ, tol=.00001) # For branch to be considered separate, must be at least this length
  
  finaltree <- root(collapsedTree, out = accession, resolve.root = TRUE) 
  rootedTree <<- ladderize(finaltree)
}

# Tree and metadata parser #
parse_metaandtree <- function(treePath, metadataPath){
 # rootedTree <<- read.tree(treePath) #imports file in newick format instead of nexus.
  rootedTree <- treePath
  #\
  #  rootedTree structure:
  #    list of 3 components:
  #      $edge - a numeric matrix with 2 columns. It is the table of edges that describes
  #        the phylogenetic tree that was read in by the read.tree() function;
  #      $Nnode - a numeric vector of length one whose value is the number of nodes on the 
  #        inner branches of the tree;
  #      $tip.label - a character vector whose elements are the character string that
  #        identifies a leaf node on the phylogenetic tree;
  #/
  dataoriginal = read.csv(metadataPath, header = TRUE) # Imports csv metadata file. It has to have header and ID column has to be the first and labeled "accession" in order for script to work.
  sortingtable <- as.data.frame(rootedTree$tip.label) # Takes Tip Label information from Newick tree and transforms into a table, add ID to it and basically reorders the CSV metadata frame to match the Newick file. 
  sortingtable <- tibble::rowid_to_column(sortingtable, "ID")
  names(sortingtable)[2] <- "Accession"
  sortingdata <- merge(dataoriginal, sortingtable, by = "Accession")
  data <- sortingdata[order(sortingdata$ID),]
  listofcolumns <- as.list(data)
  accessioncharacter <<- as.character(listofcolumns$Accession) # Transforms accession from Factor into character
  country <<- as.numeric(listofcolumns$Country) # Transforms metadata state country from Factor into numeric
  names(country) <- accessioncharacter # Assign accession ID reference to the variable country
  characterlabels1 <- unique(listofcolumns$Country) #extract unique labels from Country column
  characterlabels <<- sort(as.character(characterlabels1)) #sort and create list of characters from previous vector - has to sort to match the order from the $country as when it becomes numeric is transformed to numbers in alphabetical order.
}

parsimony_ancestral_reconstruction <- function(accessioncharacter, country, characterlabels, rootedTree) {
  
  #builds a hashmap using the leaf node strings as keys and the character states as values
  H <- hashmap(accessioncharacter, country)
  
  # The asr_max_parsimony() function requires a numeric vector that lists the character states
  #   of the leaf nodes in sequence as one of its parameter arguments. The following for loop
  #   walks through the character vector $tip.label in the rootedTree list, starting at the 
  #   index [1], and stores the value of $tip.label[i] in the character vector accession.
  #   This character string is then passed into the find function of the hashmap and its
  #   character state is returned. Thus when the loop is complete, it has populated 
  #   the metadataStates numeric vector with the character states associated with the 
  #   leaf nodes in the order that they appeal in $tip.label;
  # Get character state for each node that isn't a leaf node (i.e. all the inner nodes)
  #asr_max_parsimony accepts 3 parameters:
  # - the list object returned by the read.tree() function
  # - the character states of the leaf nodes listed in the $tip.label character vector found in
  #     the list object
  # - the number of possible character states of the trait
  # 
  # it returns a list object with the following components:
  #
  #   $ancestral_likelihoods - a numeric matrix object with nrows = the number of inner nodes 
  #     in the phylogenetic tree, and ncolumns = to the number of possible character states
  #     of the character trait being studied. The value at $ancestral_likelihoods[n,m] is 
  #     the probability of interior node n being character state m
  #   $success - a logical vector of length one that says whether the process was a success
  #               or not
  #/
  numCharStates <- length(characterlabels) ##### change to the number above
  ancestralStates = asr_max_parsimony(rootedTree, country, numCharStates)
  
  # Deletes all keys and values from the hashmap
  H$clear()
  
  # Rebuilds hashmap using sequential numbers 1 through the number of leaf nodes as the key/index 
  #and using the integer values found in metadataStates as values. It essentially builds a hashmap 
  #of the leaf nodes of the tree: their index and their value.
  for(i in 1:length(country)) {
    H$insert(i, country[i])
  }
  
  # Loop through the inner nodes of the phylogenetic tree and assign the most likely character state
  # to that tree node;
  numLeaves <- length(country)
  numInnerNodes <- rootedTree$Nnode
  totalTreeNodes <- numLeaves + numInnerNodes
  innerNodeIndices <- (numLeaves+1):totalTreeNodes
  numCharacterStates <- length(ancestralStates$ancestral_likelihoods[1,])
  counter <- c() #initializes counter vector
  for (i in innerNodeIndices) # 474:945  # 473 leaf nodes + 472 inner nodes = 945 total;
  {                                                                         
    counter <- ancestralStates$ancestral_likelihoods[i - numLeaves,] #numeric vector of character state 
    # probabilities for inner node of index i
    H$insert(i, match(max(counter), counter)) #enters a new key-value pair 
    #(inner node i -> most likely character state)
  }
  
  #after the previous for loop executes, we now have an ASR of the phylogenetic tree given in the beginning.
  sourceList <- c()
  targetList <- c()
  
  #walk through each edge in the phylogenetic tree. if there's a state change between the two nodes, 
  #add the character states to their respective vector 
  #(diedge tail == sourceList, diedge head == targetList)
  rootedTree <- rootedTree
  
  for(row in 1:nrow(rootedTree$edge)) 
  {
    nextEdge <- rootedTree$edge[row,]
    edgeStates <- c(H$find(nextEdge[1]), H$find(nextEdge[2]))
    if (edgeStates[1] != edgeStates[2]) 
    {
      sourceList <- c(sourceList, edgeStates[1])
      targetList <- c(targetList, edgeStates[2])
    }
  }
  
  # This creates a table (in the form of a data frame) of the state changes that occur 
  #in the phylogenetic tree;
  dat <- data.frame(from = sourceList, to = targetList)
  #counts the frequency of a specific state change occurring
  edges_file <<- plyr::count(dat)
  names(edges_file)[names(edges_file) == "freq"] <- "value"
  
  # Extract the selected metadata state label from the data
  metastates <<- characterlabels
  
  # Create table for map from edge list 
  
  dat2 = as_tibble(dat) #transforms transition state data to tibble
  metastates2 = tibble::enframe(metastates) #transforms metastates in a tibble 
  
  Edge_tib = left_join(dat2, metastates2, by = c("from" = "name")) %>% 
    left_join(metastates2, by = c("to" = "name"), suffix = c("_org", "_dst")) %>% 
    select(value_org, value_dst)
  
  colnames(Edge_tib) <-c("State_org","State_dst")
  
  Edge_list <<- Edge_tib # Edge list
}

## Plot transmission network in map using Leaflet - requires leaflet and geosphere libraries ##
make_map <- function(filePath, transmissionpath){
  org_dst <- transmissionpath # transmissionpath = probability user filtered table for beast output, org dst table for parsimony ancestry reconstruction 
  latlong <- read.csv(filePath) #User have to input csv table with "Location","Latitude","Longitude" headers.
  lat_long = as_tibble(latlong)
  map_coord = left_join(org_dst, lat_long, by = c("State_org" = "Location")) %>% #Join lat_long and org_dst tables.
    left_join(lat_long, by = c("State_dst" = "Location"), suffix = c("_org", "_dst"))
  mydf <- data.frame(InitialLoc = map_coord$State_org, #Rename and reorganize table to be input ready 
                     InitialLat = map_coord$Latitude_org, 
                     InitialLong = map_coord$Longitude_org,
                     NewLat = map_coord$Latitude_dst,
                     NewLong = map_coord$Longitude_dst,
                     EndLoc = map_coord$State_dst
  )
  p1 <- as.matrix(mydf[,c(3,2)]) # it's important to list lng before lat here
  p2 <- as.matrix(mydf[,c(5,4)]) # and here
  map = gcIntermediate(p1, p2,  #This enforces the pairs of Origin and Destination for the polylines (otherwise it will enforce all locations to be connected)
                       breakAtDateLine = TRUE,
                       n=100,
                       addStartEnd=TRUE,
                       sp=TRUE) %>% 
    leaflet() %>% 
    addTiles() %>%   # addProviderTiles(providers$CartoDB.Positron) %>% #Alternative to regular tiles
    addCircleMarkers(lng = mydf$InitialLong, lat = mydf$InitialLat, popup= mydf$InitialLoc)%>% #Origin is circle marker, transparency is related to number of transmissions to/from place. 
    addMarkers(lng = mydf$NewLong, lat = mydf$NewLat, popup= mydf$EndLoc)%>% #Events of transmission to place are pinpointed, transparency is related to number of transmissions to/from place.
    addPolylines() #The darker the line the more traffic there is between the nodes.
  
  return(map)
}
