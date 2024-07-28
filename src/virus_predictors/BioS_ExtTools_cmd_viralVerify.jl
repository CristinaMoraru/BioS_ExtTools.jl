export RunViralVerify, build_cmd

"""
    RunViralVerfify
    Data type to store the parameters for te viralverify command
"""

struct RunViralVerify <: BioinfCmd
    program::String #/software/conda/conda_viralVerify/viralVerify/bin/viralverify
    input_f::FnaP
    output_d::String
    database::String
    threshold::Int64
    num_threads::Int64
end

build_cmd(obj::RunViralVerify) = `$(obj.program) -f $(obj.input_f.p) -o $(obj.output_d) --hmm $(obj.database) --thr $(obj.threshold) -t $(obj.num_threads) -p`
build_cmd(obj::RunViralVerify, parentD::String) = `$(obj.program) -f $parentD/$(obj.input_f.p) -o $(parentD)/$(obj.output_d) --hmm $(obj.database) --thr $(obj.threshold) -t $(obj.num_threads) -p`

#=
viralverify 
        -f Input fasta file
        -o output_directory 
        --hmm HMM  Path to HMM database

        Optional arguments:
        -h, --help  Show the help message and exit
        --db DB     Run BLAST on input contigs against provided db
        -t          Number of threads
        -thr THR    Sensitivity threshold (minimal absolute score to classify sequence, default = 7)
        -p          Output predicted plasmidic contigs separately
=#