export RunVibrantCmd, build_cmd

struct RunVibrantCmd <: BioinfCmd
    program::String
    input_f::FnaP 
    output_d::String
    database::String
    num_threads::Int64
    min_length::Int64
end

build_cmd(obj::RunVibrantCmd) = `python3 $(obj.program) -f nucl -i $(obj.input_f.p) -folder $(obj.output_d) -t $(obj.num_threads) -d $(obj.database) -l $(obj.min_length)`
build_cmd(obj::RunVibrantCmd, parentD::String) = `python3 $(obj.program) -f nucl -i $parentD/$(obj.input_f.p) -folder $(parentD)/$(obj.output_d) -t $(obj.num_threads) -d $(obj.database) -l $(obj.min_length)`