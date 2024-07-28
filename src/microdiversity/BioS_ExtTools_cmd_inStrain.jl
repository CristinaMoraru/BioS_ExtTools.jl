export RunInstrainProfile, build_cmd

struct RunInstrainProfile <: BioinfCmd
    inref::FnaP
    bam::BamP
    scaf2bin::TableP
    out::String
    num_threads::Int64
end

function build_cmd(obj::RunInstrainProfile)
    cmd = `inStrain profile $(obj.bam.p) $(obj.inref.p) -s $(obj.scaf2bin.p) -o $(obj.out) -p $(obj.num_threads) --skip_plot_generation`

    return cmd
end