

"""    
    network_distance(n::Node, m::Node)

shortest traversal distance between two nodes

sibling nodes would have network distance = 2
"""
function network_distance(n::Node, m::Node)
    p1, p2 = getpath(n, m)
    (length(p1)-1) + (length(p2)-1)
end

"""    
    network_distances(t::Node)

shortest traversal distance between all leafs with `t` as ancester
sibling nodes would have network distance = 2
"""
function network_distances(tree::Node)
    leaves = getleaves(tree) |> x->sort(x; by=name)
    dists = zeros(binomial(length(leaves), 2))
    for (i, (n1, n2)) in enumerate(combinations(1:length(leaves), 2))
        dists[i] = network_distance(leaves[n1], leaves[n2])
    end
    return dists
end


"""
    patristic_distance(n::Node, m::Node)

shortest branch length path between two nodes.

sibling nodes `i`, and `j` of parent `p` would have patristic `distance(i, p) + distance(j, p)`
"""
function patristic_distance(n::Node, m::Node)
    NewickTree.getdistance(n,m)
end

"""    
    patristic_distances(t::Node)

shortest branch length path between all leafs with `t` as ancester

sibling nodes `i`, and `j` of parent `p` would have patristic `distance(i, p) + distance(j, p)`
"""
function patristic_distances(tree::Node)
    leaves = getleaves(tree) |> x->sort(x; by=name)
    dists = zeros(binomial(length(leaves), 2))
    for (i, (n1, n2)) in enumerate(combinations(1:length(leaves), 2))
        dists[i] = NewickTree.getdistance(leaves[n1], leaves[n2])
    end
    return dists
end

function fscore_precision_recall(reftree::Node, predtree::Node; β=1.0)
    truesplits = keys(tally_tree_bifurcations(reftree))
    predsplits = keys(tally_tree_bifurcations(predtree))
    compsplits = [k for k in truesplits] .== permutedims([k for k in predsplits])
    precision = mean(sum(compsplits;dims=1))
    recall = mean(sum(compsplits;dims=2))
    fscore = (1 + β) * (precision * recall) / (β * precision + recall)
    return fscore, precision, recall
end