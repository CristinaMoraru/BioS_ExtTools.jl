export RunCenoteTaker3, build_cmdß

Base.@kwdef mutable struct RunCenoteTaker3 <: BioinfCmd
    input_f::FnaP
    out_dir::String
    num_threads::Int64
    annot_only::String="F" # F stands from False, that means bz default it will perform Discovery = Annotations
    hhsuite_tool::String="hhblits"
end

build_cmd(obj::RunCenoteTaker3) = `cenotetaker3 -c $(obj.input_f) -r $(obj.out_dir) -t $(obj.num_threads) -p T --lin_minimum_hallmark_genes 2 -am $(obj.annot_only)`


