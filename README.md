# NewickTreeTools

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://aramanlab.github.io/NewickTreeTools.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://aramanlab.github.io/NewickTreeTools.jl/dev)
[![Build Status](https://github.com/aramanlab/NewickTreeTools.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/aramanlab/NewickTreeTools.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/aramanlab/NewickTreeTools.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/aramanlab/NewickTreeTools.jl)

## Install

type:

```julia-repl
]dev git@github.com:aramanlab/NewickTreeTools.jl.git
```

into the julia command line

## Examples

```julia
using NewickTreeTools

# read in file
tree = readnw(read("filename.nw", String))

leafnames = getleafnames(tree)

# pairwise traversal distances between all leaves
full_Dn = network_distances(tree)
# pairwise patristic distances between all leaves
full_Dp = patristic_distances(tree)
```

What is the average patristic distance between tips within every sub-clade?

```julia
result = mapinternalnodes(tree) do node
    mean(patristic_distances(node))
end

# equivalent to...
result = mapinternalnodes(n->mean(patristic_distances(n)), tree)
```
What is the average patristic distance between every sub-clade that is also connected to a leaf node?

```julia
result = maplocalnodes(tree) do node
    mean(patristic_distance(node))
end
```
map leaves to external data.

```julia
using CSV, DataFrames
leafmetadf = CSV.read("leafmeta.csv", DataFrame)
result = maplocalnodes(tree) do node
    idx = indexin(getleafnames(node), leafmetadf.ID)
    somevals = leafmetadf[idx, :somecolumn]
    return sum(somevals)
end
```

Get vector of cluster ids from cutting the tree at a particular hight
```julia
θ = 10
clusts = cuttree(network_distance, tree, θ)
clustmapping = getleafnames.(clusts)
clusterids = Int.(vcat([zeros(length(c)) .+ j for (j, c) in enumerate(clustmapping)]...));
```

Write out tree from hierarchical clustering.

```julia
hc = hclust(distance_matrix, linkage=:single, branchorder=:optimal)
open("out.nw", "w") do io
    write(io, nwstr(newick(hc)) * "\n")
end
```

If you need tip labels that are not in the tree, use a vector of strings in the same order as the distance matrix.

```julia

open("out_1.nw", "w") do io
    tree = newick(hc, tiplabels)
    write(io, nwstr(tree) * "\n")
end
```

### Plotting

plotting for trees in julia is not great at the moment.

For small trees [`NewickTree.jl`](https://github.com/arzwa/NewickTree.jl) has a plot recipe

```julia
using NewickTree # not needed if already set `using NewickTreeTools` as NewickTrees is reexported from this package
using StatsPlots
tree = readnw(read("filename.nw", String))
plot(tree)
```

For larger trees if you want to stick with julia try using [`Phylo.jl`](https://docs.ecojulia.org/Phylo.jl/stable/)
Phylo and NewickTrees do not play well together and have some conflicting functions, 
so it is best to do this in a new file or notebook

```julia
using StatsPlots
using Phylo
tree = open(parsenewick(), "filename.nw")
sort!(tree)
plot(tree)
```

The most featureful library for plotting trees is R's [`ggtree`](https://bioconductor.org/packages/release/bioc/html/ggtree.html) library. 
Which can read in newick format trees with the [`ape`](https://www.rdocumentation.org/packages/ape/versions/5.6-2) and [`treeio`](https://bioconductor.org/packages/release/bioc/html/treeio.html) libraries.

useful links:

https://guangchuangyu.github.io/ggtree-book/chapter-ggtree.html

```R
supressMessages({
    # library(tidyverse)
    library(ape)
    library(treeio)
    library(ggplot2)
    library(ggtree)
})
treefile <- "tree.newick"
tree <- read.tree(treefile)
p <- ggtree(tree,
    size = 2,
    ladderize = TRUE,
    # layout = "fan",
    layout = "rectangular",
    # layout = "slanted",
    ) +
    geom_tiplab(linesize = .2, size = 4)
    # geom_text(aes(label=node))
p
```


## Citing

See [`CITATION.bib`](CITATION.bib) for the relevant reference(s).
