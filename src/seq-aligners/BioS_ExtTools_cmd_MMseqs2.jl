export MMseqs2ReciprocalSearchCmd, build_cmd

struct MMseqs2ReciprocalSearchCmd <: BioinfCmd
    query_f::FnaP
    output_f::TableP
    outformat::String  # 
    tmp_dir::String
    num_threads::Int64    
    search_type::Int64 # 3 is for nucleotide vs nucleotide
    sensitivity::Float16  #the bigger the number, the more sensitive the search, default is 5.7, I could set is as high as 8.5 (manual says this is blast sensitivity)
end

build_cmd(obj::MMseqs2ReciprocalSearchCmd) = `mmseqs easy-search $(obj.query_f.p) $(obj.query_f.p) $(obj.output_f.p) $(obj.tmp_dir) --threads $(obj.num_threads) --search-type $(obj.search_type) -s $(obj.sensitivity) --format-output $(obj.outformat) --max-seq-len 500 --max-seqs 3000 -k 8 -a`
#build_cmd(obj::MMseqs2ReciprocalSearchCmd) = `mmseqs align $(obj.query_f.p) $(obj.query_f.p) $(obj.output_f.p) `

struct MMSeqs2EasyClusterCmd <: BioinfCmd
    query_f::FnaP
    output_f::TableP
    tmp_dir::String
    num_threads::Int64    
    sensitivity::Float16  #the bigger the number, the more sensitive the search, default is 5.7, I could set is as high as 8.5 (manual says this is blast sensitivity)
end