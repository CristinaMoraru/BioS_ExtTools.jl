"""
    This file contains the commands for the Samtools tool. 
        For each Samtools tools I'm creating a different struct and build_cmd function. 
        The view and sort are quite similar, but I think the others are not.
"""

export RunSamtoolsViewCmd, RunSamtoolsSortCmd, RunSamtoolsCovCmd, build_cmd

#region SAMTOOLS
struct RunSamtoolsViewCmd <: BioinfCmd
    program::String
    more_opts::Vector{String}
    num_threads::Int64    
    in_f::Union{SamP, BamP, CramP}
    out_f::Union{SamP, BamP, CramP}
end

build_cmd(obj::RunSamtoolsViewCmd) = `$(obj.program) view --threads $(obj.num_threads) $(obj.more_opts) -o $(obj.out_f.p) $(obj.in_f.p)`
build_cmd(obj::RunSamtoolsViewCmd, parentD::String) = `$(obj.program) view --threads $(obj.num_threads) $(obj.more_opts) -o $parentD/$(obj.out_f.p) $parentD/$(obj.in_f.p)`

#endregion


#region SAMTOOLS SORT
struct RunSamtoolsSortCmd <: BioinfCmd
    program::String
    more_opts::Vector{String}
    num_threads::Int64    
    in_f::Union{SamP, BamP, CramP}
    out_f::Union{SamP, BamP, CramP}
end

build_cmd(obj::RunSamtoolsSortCmd) = `$(obj.program) sort --threads $(obj.num_threads) $(obj.more_opts) -o $(obj.out_f.p) $(obj.in_f.p)` 
build_cmd(obj::RunSamtoolsSortCmd, parentD::String) = `$(obj.program) sort --threads $(obj.num_threads) $(obj.more_opts) -o $parentD/$(obj.out_f.p) $parentD/$(obj.in_f.p)` 

#endregion

#region SAMTOOLS coverage

struct RunSamtoolsCovCmd <: BioinfCmd
    program::String
    more_opts::Vector{String} 
    in_f::Union{SamP, BamP, CramP}
    out_f::TableP
end

build_cmd(obj::RunSamtoolsCovCmd) = `$(obj.program) coverage $(obj.more_opts) -o $(obj.out_f.p) $(obj.in_f.p)`
build_cmd(obj::RunSamtoolsCovCmd, parentD::String) = `$(obj.program) coverage $(obj.more_opts) -o $parentD/$(obj.out_f.p) $parentD/$(obj.in_f.p)`
#endregion