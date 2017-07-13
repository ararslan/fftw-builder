# fftw-builder

This is a small wrapper over the [FFTW](http://www.fftw.org) library meant to utilize
continuous integration infrastructure to compile FFTW as a shared library and store the
resulting binaries in releases.
These binaries are intended to be used by [FFTW.jl](https://github.com/JuliaMath/FFTW.jl)
and are thus built in a Julia-centric manner.

At this point, this repository should _not_ be considered production-ready.
If a tag containing binaries exists, DO NOT USE THEM as they may be literal garbage.
