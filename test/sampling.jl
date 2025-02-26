using Base: need_full_hex
@testset "Sampling" begin
  @testset "UniformSampling" begin
    Random.seed!(2021)
    d = CartesianGrid{T}(100,100)
    s = sample(d, UniformSampling(100))
    μ = mean(coordinates.([centroid(s, i) for i in 1:nelements(s)]))
    @test nelements(s) == 100
    @test isapprox(μ, T[50.,50.], atol=T(10))
  end

  @testset "WeightedSampling" begin
    # uniform weights => uniform sampler
    Random.seed!(2020)
    d = CartesianGrid{T}(100,100)
    s = sample(d, WeightedSampling(100))
    μ = mean(coordinates.([centroid(s, i) for i in 1:nelements(s)]))
    @test nelements(s) == 100
    @test isapprox(μ, T[50.,50.], atol=T(10))
  end

  @testset "BallSampling" begin
    d = CartesianGrid{T}(100,100)
    s = sample(d, BallSampling(T(10)))
    n = nelements(s)
    x = coordinates(centroid(s, 1))
    y = coordinates(centroid(s, 17))
    @test n < 100
    @test sqrt(sum((x - y).^2)) ≥ T(10)

    d = CartesianGrid{T}(100,100)
    s = sample(d, BallSampling(T(20)))
    n = nelements(s)
    x = coordinates(centroid(s, 1))
    y = coordinates(centroid(s, 17))
    @test n < 50
    @test sqrt(sum((x - y).^2)) ≥ T(20)
  end

  @testset "RegularSampling" begin
    s = Segment(P2(0, 0), P2(1, 1))
    ps = sample(s, RegularSampling(2))
    @test collect(ps) == P2[(0,0), (1,1)]
    ps = sample(s, RegularSampling(3))
    @test collect(ps) == P2[(0,0), (0.5,0.5), (1,1)]

    b = Box(P2(0, 0), P2(2, 2))
    ps = sample(b, RegularSampling(3))
    @test collect(ps) == P2[(0,0),(1,0),(2,0),(0,1),(1,1),(2,1),(0,2),(1,2),(2,2)]
    ps = sample(b, RegularSampling(2, 3))
    @test collect(ps) == P2[(0,0),(2,0),(0,1),(2,1),(0,2),(2,2)]

    s = Sphere(P2(0, 0), T(2))
    ps = sample(s, RegularSampling(4))
    ts = P2[(2,0),(0,2),(-2,0),(0,-2)]
    for (p, t) in zip(ps, ts)
      @test p ≈ t
    end

    s = Sphere(P3(0, 0, 0), T(2))
    ps = sample(s, RegularSampling(2,2))
    ts = P3[(1.7320508075688772, 0.0, 1.0),
            (1.7320508075688772, 0.0, -1.0),
            (-1.7320508075688772, 0.0, 1.0),
            (-1.7320508075688772, 0.0, -1.0)]
    for (p, t) in zip(ps, ts)
      @test p ≈ t
    end

    b = Ball(P2(0, 0), T(2))
    ps = sample(b, RegularSampling(4,3))
    ts = P2[(1.0, 0.0), (0.0, 1.0), (-1.0, 0.0), (0.0, -1.0),
            (1.5, 0.0), (0.0, 1.5), (-1.5, 0.0), (0.0, -1.5),
            (2.0, 0.0), (0.0, 2.0), (-2.0, 0.0), (0.0, -2.0)]
    for (p, t) in zip(ps, ts)
      @test p ≈ t
    end

    b = Ball(P3(0, 0, 0), T(2))
    ps = sample(b, RegularSampling(3,2,3))
    ts = P3[(0.7071067811865475, 0.0, 0.7071067811865476),
            (1.0, 0.0, 6.123233995736766e-17),
            (0.7071067811865476, 0.0, -0.7071067811865475),
            (-0.7071067811865475, 8.659560562354932e-17, 0.7071067811865476),
            (-1.0, 1.2246467991473532e-16, 6.123233995736766e-17),
            (-0.7071067811865476, 8.659560562354934e-17, -0.7071067811865475),
            (1.0606601717798212, 0.0, 1.0606601717798214),
            (1.5, 0.0, 9.184850993605148e-17),
            (1.0606601717798214, 0.0, -1.0606601717798212),
            (-1.0606601717798212, 1.2989340843532398e-16, 1.0606601717798214),
            (-1.5, 1.8369701987210297e-16, 9.184850993605148e-17),
            (-1.0606601717798214, 1.29893408435324e-16, -1.0606601717798212),
            (1.414213562373095, 0.0, 1.4142135623730951),
            (2.0, 0.0, 1.2246467991473532e-16),
            (1.4142135623730951, 0.0, -1.414213562373095),
            (-1.414213562373095, 1.7319121124709863e-16, 1.4142135623730951),
            (-2.0, 2.4492935982947064e-16, 1.2246467991473532e-16),
            (-1.4142135623730951, 1.7319121124709868e-16, -1.414213562373095)]
    for (p, t) in zip(ps, ts)
      @test p ≈ t
    end
  end

  @testset "HomogeneousSampling" begin
    t = Triangle(P2(0,0), P2(1,0), P2(0,1))
    ps = sample(t, HomogeneousSampling(100))
    @test first(ps) isa P2
    @test all(∈(t), ps)

    q = Quadrangle(P2(0,0), P2(1,0), P2(1,1), P2(0,1))
    ps = sample(q, HomogeneousSampling(100))
    @test first(ps) isa P2
    @test all(∈(q), ps)

    poly1 = PolyArea(P2[(0,0),(1,0),(1,1),(0,1),(0,0)])
    poly2 = PolyArea(P2[(1,1),(2,1),(2,2),(1,2),(1,1)])
    multi = Multi([poly1, poly2])
    ps = sample(multi, HomogeneousSampling(100))
    @test all(p -> (P2(0,0) ⪯ p ⪯ P2(1,1)) || (P2(1,1) ⪯ p ⪯ P2(2,2)), ps)

    points = P2[(0,0), (1,0), (0,1), (1,1), (0.25,0.5), (0.75,0.5)]
    connec = connect.([(3,1,5),(4,6,2),(1,2,6,5),(5,6,4,3)])
    mesh = SimpleMesh(points, connec)
    ps = sample(mesh, HomogeneousSampling(400))
    @test first(ps) isa P2
    @test all(∈(mesh), ps)
  end

  @testset "MinDistanceSampling" begin
    poly1 = PolyArea(P2[(0,0),(1,0),(1,1),(0,1),(0,0)])
    poly2 = PolyArea(P2[(1,1),(2,1),(2,2),(1,2),(1,1)])
    multi = Multi([poly1, poly2])
    ps = sample(multi, MinDistanceSampling(0.1))
    @test all(p -> (P2(0,0) ⪯ p ⪯ P2(1,1)) || (P2(1,1) ⪯ p ⪯ P2(2,2)), ps)

    points = P2[(0,0), (1,0), (0,1), (1,1), (0.25,0.5), (0.75,0.5)]
    connec = connect.([(3,1,5),(4,6,2),(1,2,6,5),(5,6,4,3)])
    mesh = SimpleMesh(points, connec)
    ps = sample(mesh, MinDistanceSampling(0.2))
    n = length(ps)
    @test first(ps) isa P2
    @test all(∈(mesh), ps)
    @test all(norm(ps[i] - ps[j]) ≥ 0.2 for i in 1:n for j in i+1:n)
  end

  @testset "Utilities" begin
    # uniform sampling
    d = CartesianGrid{T}(10,10)
    s = sample(d, 50)
    @test nelements(s) == 50
    @test s[1] isa Quadrangle

    # weighted sampling
    d = CartesianGrid{T}(10,10,10)
    s = sample(d, 100, rand([1,2], 1000))
    @test nelements(s) == 100
    @test s[1] isa Hexahedron
  end
end
