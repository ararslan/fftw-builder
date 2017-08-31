# fftw-builder

This is a small wrapper over the [FFTW](http://www.fftw.org) library meant to utilize
continuous integration infrastructure to compile FFTW as a shared library and store the
resulting binaries in releases.
These binaries are intended to be used by [FFTW.jl](https://github.com/JuliaMath/FFTW.jl)
and are thus built in a Julia-centric manner.

| OS  | Arch | Status |
| :-- | :--: | :----: |
| Linux, macOS | x86-64 | [![Travis](https://travis-ci.org/ararslan/fftw-builder.svg?branch=master)](https://travis-ci.org/ararslan/fftw-builder) |
| Linux | i686 | [![CircleCI](https://circleci.com/gh/ararslan/fftw-builder/tree/master.svg?style=svg)](https://circleci.com/gh/ararslan/fftw-builder/tree/master) |
| Windows | i686, x86-64 | [![AppVeyor](https://ci.appveyor.com/api/projects/status/6fbcccap8rnwxn6d/branch/master?svg=true)](https://ci.appveyor.com/project/ararslan/fftw-builder/branch/master) |
