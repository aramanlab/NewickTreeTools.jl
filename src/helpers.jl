
"""
    levelorder(v::CategoricalArray)

Get catagories from CategoricalArray as Vector{Int}
"""
levelorder(v::CategoricalArray) = Int.(v.refs)


"""
    getleafnames(t::NewickTree.Node)

Get names of all the leafs with `t` as ancester
"""
getleafnames(t::NewickTree.Node) = name.(getleaves(t))



function Base.delete!(n::NewickTree.Node)
    p = parent(n)
    cs = children(n)
    for c in cs; push!(p, c); end
    delete!(p, n)
end

