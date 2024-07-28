module BioS_ExtTools


# external libs
using DataFrames
using CSV
using Statistics


# my libs
using BioS_Gen
using BioS_ProjsWFs
import BioS_ProjsWFs.run_workflow
import BioS_ProjsWFs.build_cmd
import BioS_ProjsWFs.build_string_cmd
using BioS_SeqFuns

# external tools - julia wrapers
include("misc/BioS_ExtTools_cmd_Primer3.jl")
include("misc/BioS_ExtTools_cmd_Shrinksam.jl")
include("misc/BioS_ExtTools_cmd_CalcCov.jl")
include("misc/BioS_ExtTools_cmd_Samtools.jl")

# seq-aligners
include("seq-aligners/BioS_ExtTools_cmd_Blast.jl")
include("seq-aligners/BioS_ExtTools_cmd_MMseqs2.jl")
include("seq-aligners/BioS_ExtTools_Skani.jl")

# binners
include("Binners/BioS_ExtTools_cmd_MaxBin2.jl")
include("Binners/BioS_ExtTools_cmd_MetaBat2.jl")
#include("Binners/BioS_cmd_SemiBin.jl")
include("Binners/BioS_ExtTools_cmd_MetaDecoder.jl")
include("Binners/BioS_ExtTools_cmd_VAMB.jl")
include("Binners/BioS_ExtTools_cmd_DasTool.jl")

# read-mappers
include("ReadMappers/BioS_ExtTools_cmd_Bowtie2.jl")
include("ReadMappers/BioS_ExtTools_cmd_MiniMap2.jl")
include("ReadMappers/BioS_DoBowtie/DoBowtieCom.jl")

# virus-predictors
include("virus_predictors/BioS_ExtTools_cmd_VirSorter.jl")
include("virus_predictors/BioS_ExtTools_cmd_genomad.jl")
include("virus_predictors/BioS_ExtTools_cmd_VIBRANT.jl")
include("virus_predictors/BioS_ExtTools_cmd_checkV.jl")
include("virus_predictors/BioS_ExtTools_cmd_PhaTYP.jl")
include("virus_predictors/BioS_ExtTools_cmd_DeepVirusFinder.jl")
include("virus_predictors/Bios_ExtTools_cmd_CenoteTaker3.jl")
include("virus_predictors/BioS_ExtTools_cmd_viralVerify.jl")

# microdiversity
include("microdiversity/BioS_ExtTools_cmd_inStrain.jl")
end # module BioS_ExtTools
