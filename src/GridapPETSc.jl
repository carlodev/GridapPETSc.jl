module GridapPETSc

using MPI
using Libdl
using Gridap.Algebra
using SparseArrays
using SparseMatricesCSR

let deps_jl = joinpath(@__DIR__,"..","deps","deps.jl")

  if !isfile(deps_jl)
    msg = """
    GridapPETSc needs to be configured before use. Type
  
    pkg> build
  
    and try again.
    """
    error(msg)
  end
  
  include(deps_jl)
end

if !libpetsc_found
  msg = """
  GridapPETSc was not configured correcnly. See the errors in file:
  
  $(joinpath(@__DIR__,"..","deps","build.log"))

  If you are using the environment variable JULIA_PETSC_LIBRARY, make sure
  that it points to a correct PETSc dynamic library object.

  Solve the issue and

  pkg> build

  again.
  """
end

@static if libpetsc_provider != "JULIA_PETSC_LIBRARY"
  using PETSc_jll
end

const libpetsc_handle = Ref{Ptr{Cvoid}}()

function __init__()
  if libpetsc_provider == "JULIA_PETSC_LIBRARY"
    flags = Libdl.RTLD_LAZY | Libdl.RTLD_DEEPBIND | Libdl.RTLD_GLOBAL
    libpetsc_handle[] = Libdl.dlopen(libpetsc_path, flags)
  else
    libpetsc_handle[] = PETSc_jll.libpetsc_handle
  end
end

include("PETSC.jl")

using GridapPETSc.PETSC: @check_error_code
using GridapPETSc.PETSC: PetscBool, PetscInt, PetscScalar, Vec, Mat, KSP, PC
#export PETSC
export @check_error_code
export PetscBool, PetscInt, PetscScalar, Vec, Mat, KSP, PC

include("Environment.jl")

export PETScVector
export PETScMatrix
export petsc_sparse
include("PETScArrays.jl")

export PETScSolver
include("PETScSolvers.jl")

end # module
