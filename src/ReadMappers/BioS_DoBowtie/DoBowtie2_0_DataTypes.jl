export ProjDoBowtie2_Index, ProjDoBowtie2_Map, ProjDoBowtie2_IndexMap


const ALLOWED_VALS = Dict(
    "projtype" => ("index", "map", "indexmap")
)

### Data type, functions and constructor for Indexing

struct ProjDoBowtie2_Index <: ProjReadMapIndexing
    pd::String
    BowtieBuild::WrapCmd{RunBowtieBuildCmd}
end


function makeIndexParams(args::Vector{String}, pd::String)
    # Indexing
    indexD = "$pd/Bowtie2Index"
    logIndexD = "$indexD/Logs"
    my_mkpath([logIndexD])

    # ref input
    inref = extract_inFiles(args, "inref", BioS_Gen.ALLOWED_EXT["FnaP"]) |> FnaP
    indexname = getFileName(inref.p)

    return (indexD, logIndexD, inref, indexname)
end


function ProjDoBowtie2_Index(args::Vector{String})
    # folders
    pd = extract_args(args, "pd")
    remove_prev(args, "rm_prev", pd)
    
    # indexing
    indexD, logIndexD, inref, indexname = makeIndexParams(args, pd)

    # num_threads
    num_threads = extract_args(args, "cpu", Int64, 1, 1, 50)

    # commands
    BowtieBuild = WrapCmd(; cmd = RunBowtieBuildCmd(inref, indexD, indexname, num_threads), 
    log_p = "$logIndexD/log.txt", err_p = "$logIndexD/err.txt", exit_p = "$logIndexD/exit.txt")
    
    # returns
    return ProjDoBowtie2_Index(pd, BowtieBuild)   
end

### Data type, functions and constructor for Mapping
struct ProjDoBowtie2_Map <: ProjReadMapMapping
    pd::String
    Bowtie2::WrapCmd{RunBowtie2Cmd}
    #Shrinksam::Union{Missing, WrapCmd{RunShrinksamCmd}}
    SamtoolsView2Sam::Union{Missing, WrapCmd{RunSamtoolsViewCmd}}
    SamtoolsSort2Sam::Union{Missing, WrapCmd{RunSamtoolsSortCmd}}
    SamtoolsView2Bam::Union{Missing, WrapCmd{RunSamtoolsViewCmd}}
    SamtoolsCoverage::Union{Missing, WrapCmd{RunSamtoolsCovCmd}}
end

function makeMapParams(args::Vector{String}, pd::String, indexD::String, indexname::String)
    # Mapping
    mapD = "$pd/Bowtie2Map"
    logMapD = "$mapD/Logs"
    my_mkpath([logMapD])

    # read inputs
    read1 = extract_inFiles(args, "read1", BioS_Gen.ALLOWED_EXT["FastaQP"]) |> FastaQP
    read2 = extract_inFiles(args, "read2", BioS_Gen.ALLOWED_EXT["FastaQP"]) |> FastaQP
    readname = stringIntersect(read1.p, read2.p)[1]
    
    # preset_endtoend
    preset_endtoend = extract_args(args, "preset_endtoend", "sensitive"; allowed = ALLOWED_BOWTIE["preset_endtoend"])

    #paths
    #shrinksam_p = extract_inPaths(args, "shrinksam_p")

    samtools_p = extract_inPaths(args, "samtools_p")

    #samtools view options
    samview_flag4exclusion = extract_args(args, "samview_flag4exclusion", Bool, "false")
    if samview_flag4exclusion
        samview_flag4exclusion_val = extract_args(args, "samview_flag4exclusion_val")
    end

    if samview_flag4exclusion == false
        more_opts = ["-h"]
    else
        more_opts = ["-h", "-F", "$samview_flag4exclusion_val"]
    end



    outbase = "$mapD/$(indexname)_$(readname)"
    out_f = "$(outbase).sam" |> SamP
    #outs_f = "$(outbase)_shrink.sam" |> SamP
    outview2sam_f = "$(outbase)_shrink_filt.sam" |> SamP
    outsorts_f = "$(outbase)_shrink_filt_sorted.sam" |> SamP
    outsortb_f = "$(outbase)_shrink_filt_sorted.bam" |> BamP
    covout_p = "$(outbase)_shrink_filt_sorted_coverage.tsv" |> TableP

    
    # num_threads
    num_threads = extract_args(args, "cpu", Int64, 1, 1, 50)

    # commands
    Bowtie2 = WrapCmd(; cmd = RunBowtie2Cmd(indexD, indexname, read1, read2, out_f, preset_endtoend, num_threads), 
                        log_p = "$logMapD/logBowtie.txt", err_p = "$logMapD/errBowtie.txt", exit_p = "$logMapD/exitBowtie.txt")

                        # removes unpaired reads
    #=Shrinksam = WrapCmd(; cmd = RunShrinksamCmd(shrinksam_p, out_f, outs_f, true), 
                        log_p = "$logMapD/logShrink.txt", err_p = "$logMapD/errShrink.txt", exit_p = "$logMapD/exitShrink.txt")

                        # removes reads with Flag 3584 (read fails quality check, read is PCR or optical duplicate, supplementary alignment) =#
    SamtoolsView2Sam = WrapCmd(; cmd = RunSamtoolsViewCmd(samtools_p, more_opts, num_threads, out_f, outview2sam_f),
                        log_p = "$logMapD/logSamtoolsView2Sam.txt", err_p = "$logMapD/errSamtoolsView2Sam.txt", exit_p = "$logMapD/exitSamtoolsView2Sam.txt")
                        
                        # orders the sam file
    SamtoolsSort2Sam = WrapCmd(; cmd = RunSamtoolsSortCmd(samtools_p, ["-O", "SAM"], num_threads, outview2sam_f, outsorts_f),
                        log_p = "$logMapD/logSamtoolsSort2Sam.txt", err_p = "$logMapD/errSamtoolsSort2Sam.txt", exit_p = "$logMapD/exitSamtoolsSort2Sam.txt")

                        # converts the ordered sam to bam
    SamtoolsView2Bam = WrapCmd(; cmd = RunSamtoolsViewCmd(samtools_p, ["-h", "-b"], num_threads, outsorts_f, outsortb_f),
                        log_p = "$logMapD/logSamtoolsView2Bam.txt", err_p = "$logMapD/errSamtoolsView2Bam.txt", exit_p = "$logMapD/exitSamtoolsView2Bam.txt")

    SamtoolsCoverage = WrapCmd(; cmd = RunSamtoolsCovCmd(samtools_p, ["-l", "50"], outsorts_f, covout_p),  #["--min-MQ", "30"] removes reads with low MAPQ score
                        log_p = "$(logMapD)/logSamtoolsCov.txt", err_p = "$(logMapD)/errSamtoolsCov.txt", exit_p = "$(logMapD)/exitSamtoolsCov.txt")


    return num_threads, Bowtie2, SamtoolsView2Sam, SamtoolsSort2Sam, SamtoolsView2Bam, SamtoolsCoverage #Shrinksam
end


function ProjDoBowtie2_Map(args::Vector{String})
    #folders
    pd = extract_args(args, "pd")
    remove_prev(args, "rm_prev", pd)

    # index
    indexD = extract_args(args, "indexD")
    indexname = extract_args(args, "indexname")

    # mapping
    num_threads, Bowtie2, SamtoolsView2Sam, SamtoolsSort2Sam, SamtoolsView2Bam, SamtoolsCoverage = makeMapParams(args, pd, indexD, indexname)


    # returns
    return ProjDoBowtie2_Map(pd, Bowtie2, SamtoolsView2Sam, SamtoolsSort2Sam, SamtoolsView2Bam, SamtoolsCoverage) #Shrinksam
end



### Data type, functions and constructor for Indexing and Mapping


struct ProjDoBowtie2_IndexMap <: ProjReadMapIndexingMapping
    pd::String
    BowtieBuild::WrapCmd{RunBowtieBuildCmd}
    Bowtie2::WrapCmd{RunBowtie2Cmd}
    #Shrinksam::Union{Missing, WrapCmd{RunShrinksamCmd}}
    SamtoolsView2Sam::Union{Missing, WrapCmd{RunSamtoolsViewCmd}}
    SamtoolsSort2Sam::Union{Missing, WrapCmd{RunSamtoolsSortCmd}}
    SamtoolsView2Bam::Union{Missing, WrapCmd{RunSamtoolsViewCmd}}
    SamtoolsCoverage::Union{Missing, WrapCmd{RunSamtoolsCovCmd}}
end

function ProjDoBowtie2_IndexMap(args::Vector{String})
    # folders
    pd = extract_args(args, "pd")
    remove_prev(args, "rm_prev", pd)

    # indexing
    indexD, logIndexD, inref, indexname = makeIndexParams(args, pd)

    # mapping
    num_threads, Bowtie2, SamtoolsView2Sam, SamtoolsSort2Sam, SamtoolsView2Bam, SamtoolsCoverage = makeMapParams(args, pd, indexD, indexname) #Shrinksam

    # commands
    BowtieBuild = WrapCmd(; cmd = RunBowtieBuildCmd(inref, indexD, indexname, num_threads), 
                        log_p = "$logIndexD/log.txt", err_p = "$logIndexD/err.txt", exit_p = "$logIndexD/exit.txt")

    # returns
    return ProjDoBowtie2_IndexMap(pd, BowtieBuild, Bowtie2, SamtoolsView2Sam, SamtoolsSort2Sam, SamtoolsView2Bam, SamtoolsCoverage) #Shrinksam
end