export RunDVFCmd, build_cmd, modif_dvf_out

"""
    RunDVFCmd
    Data Type to store the parameters for the DeepVirusFinder command.
"""
struct RunDVFCmd <: BioinfCmd
    program::String
    input_f::FnaP
    output_d::String
    min_contig_len::Int64
    num_threads::Int64
end


## Functions to build the commands, return a Cmd data type.
build_cmd(obj::RunDVFCmd) = `python $(obj.program) -i $(obj.input_f.p) -o $(obj.output_d) -l $(obj.min_contig_len) -c $(obj.num_threads)`
build_cmd(obj::RunDVFCmd, parentD::String) = `python $(obj.program) -i $(parentD)/$(obj.input_f.p) -o $(parentD)/$(obj.output_d) -l $(obj.min_contig_len) -c $(obj.num_threads)`


#= Functions to process the outputs of DVF for the use cases when the DVF inputs were modified 
(the long contigs were split). =#

"""
    keep_high_score_rows!
    In an DVF output dataframe, it keeps only the rows with a score higher or equal than the score threshold.
    # Returns: the modified dataframe.
"""
function keep_high_score_rows!(df::DataFrame, scoreTh::Float64, pThreshold::Float64)
    for row in nrow(df):-1:1
        if df[row, :score] < scoreTh
            deleteat!(df, row)
        elseif df[row, :pvalue] > pThreshold
            deleteat!(df, row)
        end
    end

    return df
end

"""
    unsplit_dvf_out!
    DVF can't process contigs longer than a certain threshold. To overcome this, the large contigs can be split in smaller pieces 
    (e.g. by using the contigSplit function BioS module), and the resulted .fna file can be inputed in DVF.
    The unsplit_dvf_out! function takes the DVF output and a dictionary recording which contigs where split. 
    If it finds that a contig was split, it will merge the results for the split contigs. 
    Merging is performed by calculating the median score and pvalues. If the median score is higher than the score threshold, the contig is considered a putative virus.
    A new row is added to the dataframe, with the name of the original contig, the sum of the lengths of the split contigs, the median score and pvalue, 
    and the label "putative virus" in the "prediction" column.
    The corresponding split contigs are deleted from the table in all cases.
    
    ## Arguments
    ## Returns
    - the modified dataframe.

"""
function unsplit_dvf_out!(dvfdf::DataFrame, split_contigs::Dict{String, Vector{String}}, scoreTh::Float64, pThreshold::Float64)

    dvfdf[:, :prediction_long_contig_dvf] = Vector{Union{Missing, String}}(missing, nrow(dvfdf))  # add a new column to store the prediction
    

    for (contig, split_contigs) in split_contigs
        len = 0
        scores = Vector{Float64}()  # collect values from the "score" column
        pvals = Vector{Float64}()   # collect values from the "pval" column

        for row in nrow(dvfdf):-1:1
            if occursin("$(contig)__Subcontig", dvfdf[row, :name])
                len = len + dvfdf[row, :len]
                push!(scores, dvfdf[row, :score])
                push!(pvals, dvfdf[row, :pvalue])
                deleteat!(dvfdf, row)
            end
        end

        if !isempty(scores) && !isempty(pvals)
            meansc = mean(scores)
            meanpval = mean(pvals)

            if meansc >= scoreTh && meanpval <= pThreshold
                push!(dvfdf, (contig, len, meansc, meanpval, "putative virus"))
            end
        end 
    end

    return dvfdf
end

function modif_dvf_out(in_path::TableP, scoreTh::Float64, pThreshold::Float64, split_contigs::Dict{String, Vector{String}})
    dvfdf = CSV.read(in_path.p, DataFrame; delim = '\t', header = 1)

    if !isempty(split_contigs)
        dvfdf = unsplit_dvf_out!(dvfdf, split_contigs, scoreTh, pThreshold)
    end

    dvfdf = keep_high_score_rows!(dvfdf, scoreTh, pThreshold)

    return dvfdf
end