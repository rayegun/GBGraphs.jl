struct GBWeightedEdge{W} <: Graphs.AbstractEdge{UInt64}
    src::UInt64
    dst::UInt64
    weight::W
end

# Not sure about the default to Float64 here, but it's probably the least bad.
GBWeightedEdge(t::NTuple{2}) = GBWeightedEdge(t..., one(Float64))
GBWeightedEdge(t::NTuple{3}) = GBWeightedEdge(t...)
GBWeightedEdge(p::Pair) = GBWeightedEdge(p.first, p.second, one(Float64))
GBWeightedEdge{W}(p::Pair) where W = GBWeightedEdge(UInt64(p.first), UInt64(p.second), one(W))
GBWeightedEdge{W}(t::NTuple{3}) where W = GBWeightedEdge(UInt64(t[1]), UInt64(t[2]), W(t[3]))
GBWeightedEdge{W}(t::NTuple{2}) where W = GBWeightedEdge(UInt64(t[1]), UInt64(t[2]), one(W))
GBWeightedEdge(x, y) = GBWeightedEdge(x, y, one(Float64))

Graphs.src(e::GBWeightedEdge) = e.src
Graphs.dst(e::GBWeightedEdge) = e.dst
weight(e::GBWeightedEdge) = e.weight

#Printing
Base.show(io::IO, e::GBWeightedEdge) = print(io, "Edge $(e.src) => $(e.dst) with weight $(e.weight)")

Base.Tuple(e::GBWeightedEdge) = (src(e), dst(e), weight(e))

Graphs.reverse(e::GBWeightedEdge) = GBWeightedEdge(dst(e), src(e), weight(e))

==(e1::GBWeightedEdge, e2::GBWeightedEdge) = (src(e1) == src(e2) && dst(e1) == dst(e2))
==(e1::GBWeightedEdge, e2::AbstractEdge) = (src(e1) == src(e2) && dst(e1) == dst(e2))
==(e1::AbstractEdge, e2::GBWeightedEdge) = (src(e1) == src(e2) && dst(e1) == dst(e2))
