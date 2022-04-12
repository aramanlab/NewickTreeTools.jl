""" 
    newick(hc::Hclust; justroot=true, names=string.(hc.labels))

convert Hclust to newick tree; returns root node 

Args:
* hc, `Hclust` object from Clustering package
* justroot, `Bool` return just the root or the vector of all nodes
* names, `Vector{String}` names in same order as distance matrix
"""
function newick(hc::Hclust; justroot=true, names=string.(hc.labels))
   nodes = [Node(i, n=n, d=0.) for (i,n) in zip(hc.order,names)]
   n = length(nodes)
   idfun(x) = x > 0 ? x + n : abs(x)
   for i=1:size(hc.merges, 1)
       nid = n + i
       j, k = idfun.(hc.merges[i,:])
       a = nodes[j]
       b = nodes[k]
       h = hc.heights[i]
       newnode = Node(nid, n="$nid", d=h)
       setdistance!(a, h-distance(a))
       setdistance!(b, h-distance(b))
       push!(newnode, a)
       push!(newnode, b)
       push!(nodes, newnode)
   end
   setdistance!(nodes[end], 0.)
   return justroot ? nodes[end] : nodes
end

"""
    Hclust(tree::Node)

convert ultrametric NewickTree.Node into Clustering.Hclust type
"""
function Hclust(tree::Node)
    lvheights = NewickTree.height.(getleaves(tree))
    all(lvheights[1] .== lvheights[2:end]) || throw(ArgumentError("tree non-ultrametric, cannot be converted to Hclust"))
    maxleafheight = lvheights[1]

    mrgs = zeros(Int, length(lvheights)-1, 2)
    hgts = zeros(length(lvheights)-1)
    ordr = parse.(Int,(name.(getleaves(tree)))) # || throw(ArgumentError("Names of leaves are not integers"))
    link = :single
    id = -1
    for n in postwalk(tree)
        if !isleaf(n)
            if name(n) == ""
                NewickTree.setname!(n, string(id))
            end

            mrg = tuple([name(c) for c in n.children]...)
            mrg = .-parse.(Int, mrg)
            mrgs[abs(id),:] .= mrg

            hgts[abs(id)] = abs(NewickTree.height(n) - maxleafheight)

            id -= 1
        end
    end
    return Hclust(mrgs, hgts, ordr, link)
end
