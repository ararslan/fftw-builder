using Base.Test

if Sys.iswindows()
    builddir = joinpath(ENV["APPVEYOR_BUILD_FOLDER"], "build")
    suffix = "-3." * Libdl.dlext
else
    builddir = joinpath(ENV["TRAVIS_BUILD_DIR"], "build")
    suffix = "_threads." * Libdl.dlext
end

bindir = joinpath(builddir, "bin")
libdir = joinpath(builddir, "lib")

const libfftw = joinpath(libdir, "libfftw3$suffix")
const libfftwf = joinpath(libdir, "libfftw3f$suffix")

# For debugging
println("=====\nFull contents of build/lib:")
foreach(println, readdir(libdir))
println("=====\nFull contents of build/bin:")
foreach(println, readdir(bindir))
println("=====\nLooking for:\n", libfftw, "\n", libfftwf)

@testset "things exist" begin
    @test isfile(libfftw)
    @test isfile(libfftwf)
end

@testset "things work" begin
    stat = ccall((:fftw_init_threads, libfftw), Int32, ())
    @test stat > 0
    plan2 = ccall((:fftw_plan_with_nthreads, libfftw), Void, (Int32,), Int32(2))
    @test plan2 === nothing
end
