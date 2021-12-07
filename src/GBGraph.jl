abstract type AbstractGBGraph{T} <: Graphs.AbstractGraph{UInt64} end

Base.eltype(::AbstractGBGraph) = UInt64

mutable struct GBWeightedGraph{T} <: AbstractGBGraph{T}
    A::GBMatrix{T} # The adjacency matrix of the graph
    nvertices::Int64
    function GBWeightedGraph{T}(adjmatrix::GBMatrix{T}, nvertices=size(adjmatrix, 1)) where {T}
        drows, dcols = size(adjmatrix)
        isequal(drows, dcols) || error("Adjacency matrix must be square.")
        issymmetric(adjmatrix) || error("Adjacency matrix must be symmetric.")
        gbset(adjmatrix, :format, :byrow) # we want graphs stored by row for the most part.
        return new{T}(adjmatrix, nvertices)
    end
end

weighttype(::GBWeightedGraph{T}) where T = T

Graphs.ne(g::GBWeightedGraph) = nnz(g.A)
Graphs.nv(g::GBWeightedGraph) = size(g.A, 1)

vertices(g::GBWeightedGraph) = one(UInt64):UInt64(nv(g))

Graphs.edgetype(::GBWeightedGraph{T}) where T = GBWeightedEdge{T}
Graphs.edges(g::GBWeightedGraph) = (GBWeightedEdge(x...) for x in zip(findnz(triu(g.A))...))

Graphs.weights(g::GBWeightedGraph) = g.A

Graphs.inneighbors(g::GBWeightedGraph, x...) = outneighbors(g, x...)

function Graphs.add_edge!(g::GBWeightedGraph, e::GBWeightedEdge)
    s, d, weight = Tuple(e)
    @inbounds g.A[s, d] = weight
    @inbounds g.A[d, s] = weight
    return true
end

function Graphs.rem_edge!(g::GBWeightedGraph, e::GBWeightedEdge)
    deleteat!(g.A, e.dst, e.src)
    deleteat!(g.A, e.src, e.dst)
    return true
end

Base.:(==)(g::GBWeightedGraph, h::GBWeightedGraph) = g.A == h.A

Graphs.is_directed(::Type{<:GBWeightedGraph}) = false


Graphs.has_edge(g::GBWeightedGraph, e::GBWeightedEdge) = g.A[dst(e), src(e)] !== nothing

# handles single-argument edge constructors such as pairs and tuples
Graphs.has_edge(g::GBWeightedGraph{T}, x) where T = has_edge(g, edgetype(g)(x))
Graphs.add_edge!(g::GBWeightedGraph{T}, x) where T = add_edge!(g, edgetype(g)(x))

# handles two-argument edge constructors like src,dst
Graphs.has_edge(g::GBWeightedGraph, x, y) = has_edge(g, edgetype(g)(x, y, 0))
Graphs.add_edge!(g::GBWeightedGraph, x, y) = add_edge!(g, edgetype(g)(x, y, 1))
Graphs.add_edge!(g::GBWeightedGraph, x, y, z) = add_edge!(g, edgetype(g)(x, y, z))
Graphs.has_vertex(g::GBWeightedGraph, v::Integer) = v in vertices(g)

function Graphs.rem_edge!(g::GBWeightedGraph{T}, u::Integer, v::Integer) where {T}
    rem_edge!(g, edgetype(g)(T(u), T(v), one(T)))
end

# IMPLEMENT WITH PACK/UNPACK.
function Graphs.outneighbors(g::GBWeightedGraph, v::Integer)
    row = findnz(g.A[v, :])[2]
