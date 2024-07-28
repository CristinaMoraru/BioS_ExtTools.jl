export RunMetaDecoderCovCmd, RunMetaDecoderMapCmd, RunMetadecoderClustCmd

struct RunMetaDecoderCovCmd <: BioinfCmd
    in_sams::Vector{String}
    outcov::String
end

function build_cmd(obj::RunMetaDecoderCovCmd)
    cmd = `metadecoder coverage -s $(obj.in_sams) -o $(obj.outcov)`

    return cmd
end


struct RunMetaDecoderMapCmd <: BioinfCmd
    in_ref::FnaP
    outseed::String
    num_threads::Int64
end

function build_cmd(obj::RunMetaDecoderMapCmd)
    cmd = `metadecoder seed --threads $(obj.num_threads) -f $(obj.in_ref.p) -o $(obj.outseed)`

    return cmd
end

struct RunMetadecoderClustCmd <: BioinfCmd
    in_ref::FnaP
    in_cov::String
    in_seed::String
    outclust::String
end

function build_cmd(obj::RunMetadecoderClustCmd)
    cmd = `metadecoder cluster -f $(obj.in_ref.p) -c $(obj.in_cov) -s $(obj.in_seed) -o $(obj.outclust)`

    return cmd
end