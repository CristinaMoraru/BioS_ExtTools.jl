export LZANI_Cmd, build_cmd

struct LZANI_Cmd <: BioinfCmd
    software_p::String 
    intype::String
    in_p::Union{String, FnaP}
    multisample_fasta::Bool
    min_reg::Int64
    out_fmt::String
    out_lzani::TableP
    out_alignment::TableP
    num_threads::Int64
end

function build_cmd(obj::LZANI_Cmd)
    if obj.intype == "dir" 
        #inp = "--in-dir $(obj.in_p)"
        cmd = `$(obj.software_p) all2all --in-dir $(obj.in_p) --multisample-fasta $(obj.multisample_fasta) --reg $(obj.min_reg) --out-format $(obj.out_fmt) --out $(obj.out_lzani.p) --out-alignment $(obj.out_alignment.p) -t $(obj.num_threads)`  
    elseif obj$intype == "fna"
        #inp = "--in-fasta $(obj.in_p.p)"
        cmd = `$(obj.software_p) all2all --in-fasta $(obj.in_p.p) --multisample-fasta $(obj.multisample_fasta) --reg $(obj.min_reg) --out-format $(obj.out_fmt) --out $(obj.out_lzani.p) --out-alignment $(obj.out_alignment.p) -t $(obj.num_threads)`  
    end
    

    return cmd 
end