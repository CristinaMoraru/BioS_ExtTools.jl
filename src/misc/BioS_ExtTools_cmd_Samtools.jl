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

function build_cmd(obj::RunSamtoolsViewCmd)
    cmd = `$(obj.program) view --threads $(obj.num_threads) $(obj.more_opts) -o $(obj.out_f.p) $(obj.in_f.p)`
    
    return cmd
end

#endregion


#region SAMTOOLS SORT
struct RunSamtoolsSortCmd <: BioinfCmd
    program::String
    more_opts::Vector{String}
    num_threads::Int64    
    in_f::Union{SamP, BamP, CramP}
    out_f::Union{SamP, BamP, CramP}
end

function build_cmd(obj::RunSamtoolsSortCmd)
    cmd = `$(obj.program) sort --threads $(obj.num_threads) $(obj.more_opts) -o $(obj.out_f.p) $(obj.in_f.p)` 
    
    return cmd
end

#endregion

#region SAMTOOLS coverage

struct RunSamtoolsCovCmd <: BioinfCmd
    program::String
    more_opts::Vector{String} 
    in_f::Union{SamP, BamP, CramP}
    out_f::TableP
end

function build_cmd(obj::RunSamtoolsCovCmd)
    cmd = `$(obj.program) coverage $(obj.more_opts) -o $(obj.out_f.p) $(obj.in_f.p)` 
    return cmd
end

#endregion