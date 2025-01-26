export build_cmd, RunFeatureCounts

struct RunFeatureCounts <: BioinfCmd
    program::String
    in_annots::SafP
    in_bam::BamP
    out_f::TableP
    num_threads::Int64
end

function build_cmd(obj::RunFeatureCounts, parentD::String)
    cmd = `$(obj.program) -T $(obj.num_threads) -F SAF --minOverlap 10 --fracOverlap 0.6 --largestOverlap -p -a $(obj.in_annots.p) -o $parentD/$(obj.out_f.p) $(obj.in_bam.p)` 
    #= [options] -s ?
    --countReadPairs ? =#

    return cmd
end