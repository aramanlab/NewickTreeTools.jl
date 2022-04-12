

"""
    cuttree(distfun::Function, tree::Node, θ) 

returns all vector of Nodes where distance to root is
greater than theta `d > θ`.

distance function must take to NewickTree.Node objects and 
compute a scaler distance between them.
"""
function cuttree(distfun::Function, tree::Node, θ) 
    θ ≤ distfun(tree, tree) && return [tree]
    ns = typeof(tree)[]
    # define tree traversal
    function walk!(n, t)
        distn = distfun(n, t)
        distp = distfun(parent(n), t)
        # if edge crosses θ then add current node
        if distp ≤ θ < distn
            push!(ns, n)
            return
        # if node is leaf an within θ add as singlet cluster
        elseif isleaf(n) && distn ≤ θ
            push!(ns, n)
            return
        # otherwise continue taversing tree
        else
            !isleaf(n) && for c in n.children walk!(c, t) end
            return
        end
    end
    # actually taverse the tree
    for c in tree.children 
        walk!(c, tree)
    end
    return ns
end

"""
    mapinternalnodes(fun::Function, tree::Node, args...; kwargs...)

maps function `fun()` across internal nodes of tree.

args and kwargs are passed to `fun()`
"""
function mapinternalnodes(fun::Function, tree::Node, args...; kwargs...)
    results = Vector()
    for (i,node) in enumerate(PreOrderDFS(tree))
        # only internal nodes
        isleaf(node) && continue
        # run function
        push!(results, fun(node, args...; kwargs...))
    end
    return results
end

"""
    maplocalnodes(fun::Function, tree::Node, args...; kwargs...)

maps function `fun()` across internal nodes of tree conditioned on having
    one direct child that is a leaf.

args and kwargs are passed to `fun()`
"""
function maplocalnodes(fun::Function, tree::Node, args...; kwargs...)
    results = Vector()
    for (i,node) in enumerate(PreOrderDFS(tree))
        # only internal nodes
        isleaf(node) && continue
        # only nodes that have a leaf as child
        all(.!isleaf.(children(node))) && continue
        # run function
        push!(results, fun(node, args...; kwargs...))
    end
    return results
end


"""
    collectiveLCA(tree, nodes)

finds last common ancester of a collection of Nodes
"""
function collectiveLCA(tree::Node, nodes::Vector{Node})
    lca = map(b->getlca(tree, string(nodes[1]), string(b)), nodes[2:end])
    idx = argmin(NewickTree.height.(lca))
    lca[idx]
end

"""
    as_polytomy!(tree::Node; fun::Function=n->distance(n)≈0)

removes internal nodes from tree based on `fun()` which must return a Bool

by default removes zero length branches 
(i.e. nodes where distance between child and parent == 0)
"""
function as_polytomy!(tree::Node; fun::Function=n->distance(n)≈0)
    for n in filter(fun, PreOrderDFS(tree))
        !isroot(n) && !isleaf(n) && delete!(n)
    end
end

# """
#     insertduplicatesamples!(tree, mapping, degencol; idcol=:ids)
# requires loading DataFrames...
# """
# function insertduplicatesamples!(tree::Node, mapping::DataFrame, degencol; idcol=:ids)
#     nv = [NewickTree.nv(tree)]
#     leaves = getleaves(tree)
#     leafnames = getleafnames(tree)
#     df = transform(mapping, idcol => ((c)-> map(∈(leafnames), c)) => :intree);
#     df |>
#         (df)-> groupby(df, degencol) |>
#         (df)-> filter(idcol => (x)->length(x)>1, df) |>
#         # map across groups and insert non-included duplicate rows
#         (df)-> combine(df, [idcol, degencol, :intree] => (ids, grp, mask) -> begin
#             l = leaves[indexin(ids[mask], leafnames)][1]
#             NewickTree.insertnode!(l; dist=0.0, name="grp$(string(grp[1]))")
#             p = parent(l)
#             for id ∈ ids[.!mask]
#                 push!(p, Node(UInt16(nv[1]); n=id, d=0.))
#                 nv[1] += 1
#             end
#             length(children(p))
#         end)
#     nothing
# end
