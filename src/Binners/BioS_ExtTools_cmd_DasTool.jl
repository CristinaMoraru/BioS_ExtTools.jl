export RunDasToolCmd, build_cmd, build_string_cmd

struct RunDasToolCmd <: BioinfCmd
    contig::FnaP
    binsvscontigs::Vector{String}
    binlabels::Vector{String}
    outbase::String
    num_threads::Int64
end

build_cmd(obj::RunDasToolCmd) = `DAS_Tool -i $(join(obj.binsvscontigs, ",")) -l $(join(obj.binlabels, ",")) -c $(obj.contig.p) -o $(obj.outbase) -t $(obj.num_threads) --search_engine diamond --write_bins --write_unbinned`

function build_string_cmd(obj::RunDasToolCmd) 
    cmd = "DAS_Tool -i $(join(obj.binsvscontigs, ",")) -l $(join(obj.binlabels, ",")) -c $(obj.contig.p) -o $(obj.outbase) -t $(obj.num_threads) --search_engine diamond --write_bins --write_unbinned"
    return cmd
end