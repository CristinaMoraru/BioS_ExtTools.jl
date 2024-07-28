export RunPhaTYPCmd, build_cmd

"""
    RunPhaTYPCmd
    Data Type to store the parameters for the PhaTYP command.
"""

struct RunPhaTYPCmd <: BioinfCmd
    programD::String
    input_f::FnaP
    database_d::String
    parameters_d::String
    outputtemp_d::String
    output_d::String
    min_len::Int64
    num_threads::Int64
end

build_cmd(obj::RunPhaTYPCmd) = `python $(obj.programD)/PhaTYP_single.py --contigs $(obj.input_f.p) --threads $(obj.num_threads) --len $(obj.min_len) --rootpth $(obj.outputtemp_d) --out $(obj.output_d) --dbdir $(obj.database_d) --parampth $(obj.parameters_d)` #PhaTYP_single.py
build_cmd(obj::RunPhaTYPCmd, parentD::String) = `python $(obj.programD)/PhaTYP_single.py --contigs $(parentD)/$(obj.input_f.p) --threads $(obj.num_threads) --len $(obj.min_len) --rootpth $(parentD)/$(obj.outputtemp_d) --out $(obj.output_d) --dbdir $(obj.database_d) --parampth $(obj.parameters_d)` #PhaTYP_single.py