export RunVirSorterCmd


struct RunVirSorterCmd <: BioinfCmd
    input_f::FnaP
    output_d::String
    db_p::String
    high_confidence_only::Bool
    num_threads::Int64
    min_score::Float64
    min_length::Int64
end

function build_cmd(obj::RunVirSorterCmd) 

    if obj.high_confidence_only
        hc = " --high-confidence-only"
    else
        hc = ""
    end

    cmd = `virsorter run -i $(obj.input_f.p) -w $(obj.output_d) -j $(obj.num_threads) -d $(obj.db_p) --min-length $(obj.min_length) --min-score $(obj.min_score) --tmpdir $(obj.output_d)/tmp --viral-gene-required --exclude-lt2gene --hallmark-required-on-short$(hc) --include-groups dsDNAphage,NCLDV,RNA,ssDNA,lavidaviridae --keep-original-seq --rm-tmpdir` # --prep-for-dramv 
    return cmd
end


function build_cmd(obj::RunVirSorterCmd, parentD::String) 

    if obj.high_confidence_only
        hc = " --high-confidence-only"
    else
        hc = ""
    end

    cmd = `virsorter run -i $parentD/$(obj.input_f.p) -w $(parentD)/$(obj.output_d) -j $(obj.num_threads) -d $(obj.db_p) --min-length $(obj.min_length) --min-score $(obj.min_score) --tmpdir $(parentD)/$(obj.output_d)/tmp --viral-gene-required --exclude-lt2gene --hallmark-required-on-short$(hc) --include-groups dsDNAphage,NCLDV,RNA,ssDNA,lavidaviridae --keep-original-seq --rm-tmpdir` # --prep-for-dramv 
    return cmd
end

#--rm-tmpdir # remove the tmp directory after the run