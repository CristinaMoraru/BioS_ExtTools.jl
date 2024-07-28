export ALLOWED_MAXBIN2, RunMaxBin2Cmd, build_cmd

const ALLOWED_MAXBIN2 = Dict(
    "markerset" => [40, 107]
)

struct RunMaxBin2Cmd <: BioinfCmd
    contig::FnaP
    abund_list::TableP
    outbase::String  ##replace with out_f, and compose it earlier at project building
    markerset::Int64
    num_threads::Int64
end

function build_cmd(obj::RunMaxBin2Cmd)
    cmd = `run_MaxBin.pl -contig $(obj.contig.p) -abund_list $(obj.abund_list.p) -out $(obj.outbase) -thread $(obj.num_threads) -markerset $(obj.markerset)`
   
    return cmd
end
