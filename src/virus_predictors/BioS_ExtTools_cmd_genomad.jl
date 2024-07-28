export RunGenomadCmd, build_cmd

"""
    RunGenomadCmd
    Data Type to store the parameters for the Genomad command.
"""
struct RunGenomadCmd <: BioinfCmd
    task::String # "end-to-end", "annotate", "find-proviruses"
    input_f::FnaP
    output_d::String
    database::String
    min_score::Float64
end

build_cmd(obj::RunGenomadCmd) = `genomad $(obj.task) --cleanup --splits 8 $(obj.input_f.p) $(obj.output_d) $(obj.database) --min-score $(obj.min_score)`
build_cmd(obj::RunGenomadCmd, parentD::String) = `genomad $(obj.task) --cleanup --splits 8 $parentD/$(obj.input_f.p) $parentD/$(obj.output_d) $(obj.database) --min-score $(obj.min_score)`