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
    min_score::Union{Float64, Nothing}
    num_threads::Int64
    other_options::Union{String, Nothing}
end

function build_cmd(obj::RunGenomadCmd) 
    if isnothing(obj.other_options)
        if isnothing(obj.min_score)
            cmd = `genomad $(obj.task) --cleanup --splits 8 $(obj.input_f.p) $(obj.output_d) $(obj.database) --threads $(obj.num_threads)`
        else
            cmd = `genomad $(obj.task) --cleanup --splits 8 $(obj.input_f.p) $(obj.output_d) $(obj.database) --threads $(obj.num_threads) --min-score $(obj.min_score)`
        end
    else
        if isnothing(obj.min_score)
            cmd = `genomad $(obj.task) --cleanup --splits 8 $(obj.input_f.p) $(obj.output_d) $(obj.database) --threads $(obj.num_threads) $(obj.other_options)`
        else
            cmd = `genomad $(obj.task) --cleanup --splits 8 $(obj.input_f.p) $(obj.output_d) $(obj.database) --threads $(obj.num_threads) --min-score $(obj.min_score) $(obj.other_options)`
        end
    end

    return cmd
end

function build_cmd(obj::RunGenomadCmd, parentD::String) 
    if isnothing(obj.other_options)
        if isnothing(obj.min_score)
            cmd = `genomad $(obj.task) --cleanup --splits 8 $parentD/$(obj.input_f.p) $parentD/$(obj.output_d) $(obj.database) --threads $(obj.num_threads)`
        else
            cmd = `genomad $(obj.task) --cleanup --splits 8 $parentD/$(obj.input_f.p) $parentD/$(obj.output_d) $(obj.database) --threads $(obj.num_threads) --min-score $(obj.min_score)`
        end
    else
        if isnothing(obj.min_score)
            cmd = `genomad $(obj.task) --cleanup --splits 8 $parentD/$(obj.input_f.p) $parentD/$(obj.output_d) $(obj.database) --threads $(obj.num_threads) $(obj.other_options)`
        else
            cmd = `genomad $(obj.task) --cleanup --splits 8 $parentD/$(obj.input_f.p) $parentD/$(obj.output_d) $(obj.database) --threads $(obj.num_threads) --min-score $(obj.min_score) $(obj.other_options)`
        end
    end

    return cmd
end

