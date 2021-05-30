# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Ngon(p1, p2, ..., pN)

A N-gon is a polygon with `N` vertices `p1`, `p2`, ..., `pN`
oriented counter-clockwise (CCW). In this case the number of
vertices is fixed and known at compile time. Examples of N-gon
are `Triangle` (N=3), `Quadrangle` (N=4), `Pentagon` (N=5), etc.

### Notes

- Although the number of vertices `N` is known at compile time,
  we use abstract vectors to store the list of vertices. This
  design allows constructing N-gon from views of global vectors
  without expensive memory allocations.

- Type aliases are `Triangle`, `Quadrangle`, `Pentagon`, `Hexagon`,
  `Heptagon`, `Octagon`, `Nonagon`, `Decagon`.
"""
struct Ngon{N,Dim,T,V<:AbstractVector{Point{Dim,T}}} <: Polygon{Dim,T}
  vertices::V
end

Ngon{N}(vertices::AbstractVector{Point{Dim,T}}) where {N,Dim,T} =
  Ngon{N,Dim,T,typeof(vertices)}(vertices)

Ngon(vertices::AbstractVector{Point{Dim,T}}) where {Dim,T} =
  Ngon{length(vertices)}(vertices)

# type aliases for convenience
const Triangle   = Ngon{3}
const Quadrangle = Ngon{4}
const Pentagon   = Ngon{5}
const Hexagon    = Ngon{6}
const Heptagon   = Ngon{7}
const Octagon    = Ngon{8}
const Nonagon    = Ngon{9}
const Decagon    = Ngon{10}

isconvex(::Type{<:Triangle}) = true

issimplex(::Type{<:Triangle}) = true

nvertices(::Type{<:Ngon{N}}) where {N} = N
nvertices(ngon::Ngon) = nvertices(typeof(ngon))

# measure of N-gon embedded in 2D
function signarea(ngon::Ngon{N,2}) where {N}
  v = ngon.vertices
  sum(i -> signarea(v[1], v[i], v[i+1]), 2:N-1)
end
measure(ngon::Ngon{N,2}) where {N} = abs(signarea(ngon))

# measure of N-gon embedded in higher dimension
function measure(ngon::Ngon{N}) where {N}
  areaₜ(A, B, C) = norm((B - A) × (C - A)) / 2
  v = ngon.vertices
  sum(i -> areaₜ(v[1], v[i], v[i+1]), 2:N-1)
end

hasholes(::Ngon) = false

chains(ngon::Ngon) = [Chain(ngon.vertices)]

# N-gon already has unique vertices
Base.unique!(ngon::Ngon) = ngon

function Base.in(p::Point{2}, t::Triangle{2})
  a, b, c = t.vertices
  abp = signarea(a, b, p)
  bcp = signarea(b, c, p)
  cap = signarea(c, a, p)
  areas = (abp, bcp, cap)
  all(≥(0), areas) || all(≤(0), areas)
end

function Base.in(p::Point, q::Quadrangle)
  vs = q.vertices
  Δ₁ = Triangle(view(vs, [1,2,3]))
  Δ₂ = Triangle(view(vs, [3,4,1]))
  p ∈ Δ₁ || p ∈ Δ₂
end