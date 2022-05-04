
"""
    tally_tree_bifurcations(rootnode::AbstractTree, [cntr::Accumulator])

returns tally of leaf groups based on splitting tree at each internal node

assumes nodenames are strings parsible to integers, and returns Accumulator with key
as a string: `1110000` where 1 = belonging to smaller group & 0 = belonging to the larger.
values are the number of times this split is observed. cntr is modified in place so using
the same counter in multiple calls will keep a tally across multiple trees
"""
function tally_tree_bifurcations(tree::Node, cntr=counter(String))
    leafnames = getleafnames(tree)
    nleaves = length(leafnames)
    for node in prewalk(tree)
        # only internal nodes
        (isleaf(node) || isroot(node)) && continue
        # get leaves
        key = zeros(Bool, nleaves)
        subsetleaves = indexin(getleafnames(node), leafnames)
        key[subsetleaves] .= true
        # convert to bitstring true := smaller cluster
        keystr = sum(key) <= nleaves/2 ? join(Int.(key)) : join(Int.(.!key))
        inc!(cntr, keystr)
    end
    cntr
end

""" Construct majority rule tree from tallylist (not well tested)"""
function majorityruletree(tallylist; nboot=1000)
    tallylist = sort([(k,v) for (k,v) in tallylist], by=x-> -last(x))
    N = length(tallylist)
    nleaves = length(tallylist[1][1])
    nodes = [Node(i, n=string(i), d=1.) for i in 1:nleaves]
    root = Node(0, n="lca", d=1.)
    map(node->push!(root, node), nodes)
    nextid = nleaves+1
    for (k, t) in tallylist
        t ≥ nboot/2 || break
        subset = nodes[getnodenamesfromstarbarkey(k)]
        ancestor = collectiveLCA(root, id.(subset))
        newnode = Node(nextid, n=string(nextid), d=1.)
        setsupport!(newnode.data, t/nboot)
        push!(ancestor, newnode)
        map(n->push!(newnode, n), subset)
        map(n->delete!(ancestor, n), subset)
        nextid += 1
    end
    return root
end

bitstringtoboolvec(str) = parse.(Bool,collect(str))
getnodenamesfromstarbarkey(k) = findall(bitstringtoboolvec(k).==1)
countsubset(k) = sum(bitstringtoboolvec(k))
stringhamming(sa, sb) = sum(collect(sa) .!= collect(sb))