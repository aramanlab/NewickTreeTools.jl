module NewickTreeTools

using Reexport
# using AbstractTrees
using NewickTree
using NewickTree: Node
using NewickTree: prewalk, height, getpath
using NewickTree: setdistance!, setsupport!, support, getpath

using Statistics
using CategoricalArrays
using DataStructures: Accumulator, counter, inc!
using Combinatorics: combinations
using Clustering: Hclust

@reexport using NewickTree

export newick, Hclust
include("conversions.jl")

export network_distance, network_distances,
    patristic_distance, patristic_distances,
    fscore_precision_recall
include("distancesandmetrics.jl")

export tally_tree_bifurcations,
    # majorityruletree,
    bitstringtoboolvec, 
    getnodenamesfromstarbarkey,
    countsubset,
    stringhamming
include("consensustree.jl")

export cuttree, mapinternalnodes, 
    maplocalnodes, collectiveLCA,
    as_polytomy, as_polytomy!
include("treefunctions.jl")

export levelorder, getleafnames
include("helpers.jl")

end # module
