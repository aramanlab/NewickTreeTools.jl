

"""
    cuttree(distfun::Function, tree::NewickTree.Node, θ) 

returns all vector of Nodes where distance to root is
greater than theta `d > θ`.

distance function must take to NewickTree.Node objects and 
compute a scaler distance between them.
"""
function cuttree(distfun::Function, tree::NewickTree.Node, θ) 
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
    mapinternalnodes(fun::Function, tree::NewickTree.Node, args...; kwargs...)

maps function `fun()` across internal nodes of tree.

args and kwargs are passed to `fun()`
"""
function mapinternalnodes(fun::Function, tree::NewickTree.Node, args...; kwargs...)
    results = Vector()
    for (i,node) in enumerate(prewalk(tree))
        # only internal nodes
        isleaf(node) && continue
        # run function
        push!(results, fun(node, args...; kwargs...))
    end
    return results
end

"""
    maplocalnodes(fun::Function, tree::NewickTree.Node, args...; kwargs...)

maps function `fun()` across internal nodes of tree conditioned on having
    one direct child that is a leaf.

args and kwargs are passed to `fun()`
"""
function maplocalnodes(fun::Function, tree::NewickTree.Node, args...; kwargs...)
    results = Vector()
    for (i,node) in enumerate(prewalk(tree))
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
    collectiveLCA(nodes)

finds last common ancester of a collection of Nodes
"""
function collectiveLCA(nodes::AbstractArray{<:NewickTree.Node})
    lca = map(b->NewickTree.getlca(nodes[1], b), nodes[2:end])
    idx = argmin(NewickTree.height.(lca))
    lca[idx]
end

"""
    as_polytomy(fun::Function, tree::NewickTree.Node)
    as_polytomy!(fun::Function, tree::NewickTree.Node)

removes internal nodes from tree based on `fun()` 
which must return a true if node is to be removed

by default removes zero length branches 
(i.e. nodes where distance between child and parent == 0)
"""
function as_polytomy(fun::Function, tree::NewickTree.Node)
    tree_new = deepcopy(tree)
    as_polytomy!(fun, tree_new)
    tree_new
end

function as_polytomy!(fun::Function, tree::NewickTree.Node)
    for n in filter(fun, prewalk(tree))
        !isroot(n) && !isleaf(n) && delete!(n)
    end
end



# """
#     insertduplicatesamples!(tree, mapping, degencol; idcol=:ids)
# requires loading DataFrames...
# """
# function insertduplicatesamples!(tree::NewickTree.Node, mapping::DataFrame, degencol; idcol=:ids)
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
