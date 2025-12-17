export KmerDB_Build_Cmd, build_cmd

struct KmerDB_Build_Cmd <: BioinfCmd
    software_p::String
    kmer_length::Int64
    multisamplefasta::Bool
    preserve_strand::Bool
    alphabet::String
    num_threads::Int64
    input_f::FnaP
    outDB::String
end

function build_cmd(obj::KmerDB_Build_Cmd) 
    if multisamplefasta == true && preserve_strand == true
        more = " -multisample-fasta -preserve-strand"
    elseif multisamplefasta == true && preserve_strand == false
        more = " -multisample-fasta"
    elseif multisamplefasta == false && preserve_strand == false    
        more = ""
    elseif multisamplefasta == false && preserve_strand == true  
        more = " -preserve-strand"
    end

    cmd =  `$(obj.software_p) -k $(obj.kmer_length)$(more) -alphabet $(obj.alphabet) -t $(obj.num_threads) $(obj.input_f) $(obj.outDB)`

    return cmd
end

struct KmerDB_New2All_Cmd <: BioinfCmd
    software_p::String
    multisamplefasta::Bool
    num_threads::Int64
    query_p::FnaP
    inDB::String
    out_p::TableP
end

function build_cmd(obj::KmerDB_New2All_Cmd)
    if obj.multisamplefasta
        more = " -multisample-fasta"
    else
        more = ""
    end

    cmd = `$(obj.software_p) new2all$(more) -t $(obj.num_threads) $(obj.inDB) $(obj.query_p) $(obj.out_p)`

    return cmd
end