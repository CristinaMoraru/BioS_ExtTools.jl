export RunSumBamContCmd, RunMetaBat2Cmd, build_cmd

struct RunSumBamContCmd <: BioinfCmd
    in_bams::Vector{String} ##a vector with the paths toward bamfiles
    outdepth::String
end

function build_cmd(obj::RunSumBamContCmd)
    cmd = `jgi_summarize_bam_contig_depths --outputDepth $(obj.outdepth) $(obj.in_bams)`
    return cmd
end

struct RunMetaBat2Cmd <: BioinfCmd
    in_ref::FnaP
    in_depth::String
    outbase::String
end

function build_cmd(obj::RunMetaBat2Cmd)
    cmd = `metabat2 -i $(obj.in_ref.p) -a $(obj.in_depth) -o $(obj.outbase)` 

    return cmd
end