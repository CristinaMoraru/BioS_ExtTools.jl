export RunCheckVCmd, build_cmd

struct RunCheckVCmd <: BioinfCmd
    input_f::FnaP 
    output_d::String
    database::String
    num_threads::Int64
end

build_cmd(obj::RunCheckVCmd) = `checkv end_to_end $(obj.input_f.p) $(obj.output_d) -t $(obj.num_threads) -d $(obj.database) --remove_tmp`
build_cmd(obj::RunCheckVCmd, parentD::String) = `checkv end_to_end $(parentD)/$(obj.input_f.p) $(parentD)/$(obj.output_d) -t $(obj.num_threads) -d $(obj.database) --remove_tmp`
