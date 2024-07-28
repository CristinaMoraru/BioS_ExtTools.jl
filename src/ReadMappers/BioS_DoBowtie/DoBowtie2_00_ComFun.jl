export initialize_bowtieproj, postmaping

"""
    initialize_bowtieproj(args)
    It takes a single parameter of type ARGS, and creates the project object.
    # Returns

"""
function initialize_bowtieproj(args::Vector{String})
    projtype = extract_args(args, "projtype", ALLOWED_VALS["projtype"])

    if projtype == "index"
        proj = ProjDoBowtie2_Index(args)
    end

    if projtype == "map"
        proj = ProjDoBowtie2_Map(args)
    end

    if projtype == "indexmap"
        proj = ProjDoBowtie2_IndexMap(args)
    end

    return proj
end

function postmaping(proj::Union{ProjDoBowtie2_Map, ProjDoBowtie2_IndexMap})
    println("Starting post-mapping operations: shrinking, filtering, sorting and converting to bam.")

    #=if ismissing(proj.Shrinksam) != true
        # shrink
        do_cmd(proj.Shrinksam, "Shrinksam", false)
    end =#

    if ismissing(proj.SamtoolsView2Sam) != true
        # convert to sam
        do_cmd(proj.SamtoolsView2Sam, "SamtoolsView2Sam", false)
    end
    
    rm_path(proj.Bowtie2.cmd.out_f.p)

    if ismissing(proj.SamtoolsSort2Sam) != true
        # sort
        do_cmd(proj.SamtoolsSort2Sam, "SamtoolsSort", false)
    end

    if ismissing(proj.SamtoolsView2Bam) != true
        # convert to bam
        do_cmd(proj.SamtoolsView2Bam, "SamtoolsView", false)
    end

    if ismissing(proj.SamtoolsCoverage) != true
        # calculate coverage
        do_cmd(proj.SamtoolsCoverage, "SamtoolsCoverage", false)
    end

    println("Post-mapping operations completed.")
    
    return nothing
end