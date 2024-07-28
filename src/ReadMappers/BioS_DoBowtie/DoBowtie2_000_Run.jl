export run_workflow

"""
    run_workflow    
    This function represents a simple genome/metageme indexing workflow, 
        for a single ref. 
"""
function run_workflow(proj::ProjDoBowtie2_Index)
    # make index
    cd(proj.BowtieBuild.cmd.indexD)
    
    do_cmd(proj.BowtieBuild, "Bowtie2Build", false)

    return nothing
end

"""
    run_workflow    
    This function represents a simple mapping workflow, for a single ref (already indexed) and a its corresponding pair of reads.
"""
function run_workflow(proj::ProjDoBowtie2_Map)
    # map
    cd(proj.Bowtie2.cmd.indexD)

    println("Starting Bowtie mapping.")
    println("Searching index in $(pwd())")
    do_cmd(proj.Bowtie2, "Bowtie2", false)

    # shrink and sort, convert to bam
    postmaping(proj)
    
    #println("removing unsorted sam file")
    #rm_path(proj.Shrinksam.cmd.output.p)

    return nothing
end

"""
    run_workflow    
    This function represents a simple index-map workflow, for a single ref and a its corresponding pair of reads. 

"""
function run_workflow(proj::ProjDoBowtie2_IndexMap)
    cd(proj.Bowtie2.cmd.indexD)

    # index and map
    println("Starting Bowtie indexing and mapping.")
    do_build_bowtie2(proj.BowtieBuild, proj.Bowtie2)

    # shrink and sort, convert to bam, calculate coverage
    postmaping(proj)

    #println("removing unsorted sam file")
    #rm_path(proj.Shrinksam.cmd.output.p)

    return nothing
end