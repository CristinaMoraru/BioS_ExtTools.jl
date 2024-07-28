# Blast data structures and methods

export ALLOWED_BL_STRINGENCY, MakeBlastDb_cmd, runBlastCmd, RunBlastNCmd, RunBlastPCmd, do_blastdb_runblast
export outfmt2header, load_blastout
export ProjBlast, set_ProjBlast

const ALLOWED_BL_STRINGENCY =Dict(
    "BLASTn_stringency" => ("low4", "low7", "average", "high20", "high28"),
    "BLASTp_stringency" => ("low", "average", "high")
)

## Data structure and constructors to create the makeblastdb command objects
"""
    MakeBlastDb_cmd(program, in, input_type, dbtype, out, title)
    This is the standard constructor for the MakeBlastDb_cmd data type. Here, the value for every field needs to be inputed. 
    This constructor has several methods, detailed below. These methods use multiple dispatch on parameter type and number, 
    to set the values of the "program", "input_type" and "dbtype" fields according to the data type of the input sequence.
    
    ## Returns 
    - a MakeBlastDb_cmd data type object.
"""
struct MakeBlastDb_cmd <: BlastCmd
    program::String
    in::Union{FnaP, FaaP}
    input_type::String
    dbtype::String
    out::String
    title::String
end

"""
    MakeBlastDb_cmd
    This function is a method of the MakeBlastDb_cmd() constructor. It accepts only the values for four fields of the MakeBlastDb_cmd data type. 
    It accepts as value for the "in" parameter only an object of the Union{FnaP, FaaP} abstract type. Therefore, it sets the values of the "program" and 
    "input_type" fields as "makeblast" and "fasta", respectively.
    
    ## Returns
    - a MakeBlastDb_cmd data type object created with the standard constructor.
"""
function MakeBlastDb_cmd(in::Union{FnaP, FaaP}, dbtype::String, out::String, title::String)
    program = "makeblastdb"
    in = in
    input_type = "fasta"
    return MakeBlastDb_cmd(program, in, input_type, dbtype, out, title)
end

"""
    MakeBlastDb_cmd(; in::FnaP, out::String, title::String)
    This function is a method of the MakeBlastDb_cmd() constructor. It accepts only the values for three fields of the MakeBlastDb_cmd data type.  
    It accepts as value for the "in" parameter only an object of the FnaP concrete type. Therefore, it sets the values of the "dbtype" field
    to "'nucl'".

    ## Returns
     - a MakeBlastDb_cmd data type object, by a call to another method of the MakeBlastDb_cmd() constructor.
"""
function MakeBlastDb_cmd(in::FnaP, out::String, title::String)
    dbtype =  "nucl"
    return MakeBlastDb_cmd(in, dbtype, out, title)
end

"""
    MakeBlastDb_cmd(; in::FaaP, out::String, title::String)
    This function is a method of the MakeBlastDb_cmd() constructor. It accepts only the values for three fields of the MakeBlastDb_cmd data type.  
    It accepts as value for the "in" parameter only an object of the FnaP concrete type. Therefore, it sets the values of the "dbtype" field
    to "'prot'".
                
    ## Returns
     - a MakeBlastDb_cmd data type object, by a call to another method of the MakeBlastDb_cmd() constructor.
"""

function MakeBlastDb_cmd(in::FaaP, out::String, title::String)
    dbtype =  "'prot'"
    return MakeBlastDb_cmd(in, dbtype, out, title)
end


## Data structure and constructors for BLAST

struct RunBlastNCmd <: RunBlastCmds
    program::String
    db::String
    query::FnaP
    out::TableP
    outfmt::String
    evalue::String
    max_target_seqs::Int
    word_size::Int
    reward::Int
    penalty::Int
    gapopen::Int
    gapextend::Int
    num_threads::Int
end

function runBlastCmd(db::String, query::FnaP, out::TableP, stringency::String, num_threads::Int64)                            ##this is only for BlastN
    program = "blastn"
    outfmt = "6 qseqid sseqid evalue bitscore qstart qend sstart send qlen slen pident qseq sseq length nident mismatch gaps"
    evalue = "1"
    max_target_seqs = 1000000
    #= for more details about blastn options, see https://www.ncbi.nlm.nih.gov/books/NBK279690/pdf/Bookshelf_NBK279690.pdf =#

    if stringency == "low4" || stringency == "low7"       #similar to blastn-short, but it also needs another option: comp_based_stats = 0
        reward = 1
        penalty = -3
        gapopen = 5
        gapextend = 2

        if stringency == "low4"
            word_size = 4
        elseif stringency == "low7"
            word_size = 7
        end

    elseif stringency == "average"         # similar to blastn
        reward = 2
        penalty = -3
        gapopen = 5
        gapextend = 2
        word_size = 11

    elseif stringency == "high20" || stringency == "high28" #similar to megablast
        reward = 1
        penalty = -2
        gapopen = 0
        gapextend = 0

        if stringency == "high20"
            word_size = 20
        else 
            word_size = 28
        end
    end
    
    return RunBlastNCmd(program, db, query, out, outfmt, evalue, max_target_seqs, word_size, reward, penalty, 
                        gapopen, gapextend, num_threads)
end

struct RunBlastPCmd <: RunBlastCmds
    program::String
    db::String
    query::FaaP
    out::TableP
    outfmt::String
    evalue::String
    max_target_seqs::Int
    word_size::Int
    gapopen::Int
    gapextend::Int
    comp_based_stats::Int
    window_size::Int
    matrix::String
    threshold::Int
    num_threads::Int
end

function runBlastCmd(db::String, query::FaaP, out::TableP, max_target_seqs::Int64, stringency::String, num_threads::Int64)                            ##this is only for BlastN
    program = "blastp"
    outfmt = "6 qseqid sseqid evalue bitscore qstart qend sstart send qlen slen pident qseq sseq length nident mismatch gaps"
    evalue = "0.00001"

    #= for more details about blastp options, see https://www.ncbi.nlm.nih.gov/books/NBK279690/pdf/Bookshelf_NBK279690.pdf =#

    if stringency == "low"                          # similar to blastp-short
        word_size = 2
        gapopen = 9
        gapextend = 1
        comp_based_stats = 0
        window_size = 15
        matrix = "PAM30"
        threshold = 11           ##in manual is 16, and for blastp 11, but to me it makes more sense like that
    elseif stringency == "average"                   # similar to blastp
        word_size = 3
        gapopen = 11
        gapextend = 1
        comp_based_stats = 2
        window_size = 40
        matrix = "BLOSUM62"
        threshold = 16
    elseif stringency == "high"                       # similar to blastp-fast
        word_size = 6
        gapopen = 11
        gapextend = 1
        comp_based_stats = 2
        window_size = 40
        matrix = "BLOSUM62"
        threshold = 21
    end
    
    return RunBlastPCmd(program, db, query.p, out, outfmt, evalue, max_target_seqs, word_size,
                        gapopen, gapextend, comp_based_stats, window_size, matrix, threshold, num_threads)
end

#=
    outfmt::String = "'6 qseqid sseqid evalue bitscore qstart qend sstart send qlen slen pident qseq sseq length nident mismatch gaps'" #oligo design
                     "6 qseqid sseqid evalue bitscore qstart qend sstart send qlen slen        qseq sseq        nident          gaps" #VIRIDIC, BLASTN
                     "6 qseqid sseqid evalue bitscore qstart qend sstart send qlen slen pident"  #VirClust, BlastP
=#



# Functions to build the commands, return a Cmd data type.

function build_cmd(cmd::MakeBlastDb_cmd)
    cmd = `$(cmd.program) -in $(cmd.in.p) -input_type $(cmd.input_type) -dbtype $(cmd.dbtype) 
    -out $(cmd.out) -title $(cmd.title)`

    return cmd
end

function build_cmd(cmd::RunBlastNCmd)
    cmd = `$(cmd.program) -db $(cmd.db) -query $(cmd.query.p) -out $(cmd.out.p) -outfmt $(cmd.outfmt) 
    -evalue $(cmd.evalue) -max_target_seqs $(cmd.max_target_seqs) -word_size $(cmd.word_size) 
    -reward $(cmd.reward) -penalty $(cmd.penalty) -gapopen $(cmd.gapopen) -gapextend $(cmd.gapextend) 
    -num_threads $(cmd.num_threads)`

    return cmd
end

function build_cmd(cmd::RunBlastPCmd)
    cmd = `$(cmd.program) -db $(cmd.db) -query $(cmd.query.p) -out $(cmd.out.p) -outfmt $(cmd.outfmt) 
    -evalue $(cmd.evalue) -max_target_seqs $(cmd.max_target_seqs) -word_size $(cmd.word_size) -gapopen $(cmd.gapopen) 
    -gapextend $(cmd.gapextend) -comp_based_stats $(cmd.comp_based_stats) -window_size $(cmd.window_size)
    -matrix $(cmd.matrix) -threshold $(cmd.threshold) -num_threads $(cmd.num_threads)`
end


#region Project structs and constructors
struct ProjBlast <: BioinfProj
    pd::String
    inref::Union{FnaP, FaaP}
    blastdb::WrapCmd{MakeBlastDb_cmd}
    blastn::Union{WrapCmd{RunBlastNCmd}, WrapCmd{RunBlastPCmd}}
end

function set_ProjBlast(pd::String, inref::FnaP, num_threads::Int64, args::Vector{String})
    blast_D = "$(pd)/blast_dir"
    makeblastDB_D = "$(blast_D)/makeblastdb"
    makeblastDBLog_D = "$(makeblastDB_D)/log"
    blastres_D = "$(blast_D)/blastres"
    blastresLog_D = "$(blastres_D)/log"
    my_mkpath([blast_D, makeblastDB_D, makeblastDBLog_D, blastres_D, blastresLog_D])

    blast_env = extract_args(args, "blast_env")
    blast_th = extract_args(args, "blast_th", "low4"; allowed = ALLOWED_BL_STRINGENCY["BLASTn_stringency"])
    blastdb = "$(makeblastDB_D)/blastdb"
    blast_out = "$(blastres_D)/blastout.tsv" |> TableP

    projblast = ProjBlast(blast_D, inref, 
                WrapCmd(; cmd = MakeBlastDb_cmd(inref, blastdb, "blastdb"), 
                log_p = "$(makeblastDBLog_D)/makeblastdb.log", err_p = "$(makeblastDBLog_D)/makeblastdb.err", 
                exit_p = "$(makeblastDBLog_D)/makeblastdb.exit", env = blast_env),
                WrapCmd(; cmd = runBlastCmd(blastdb, inref, blast_out, blast_th, num_threads), 
                log_p = "$(blastresLog_D)/blast.log", err_p = "$(blastresLog_D)/blast.err",
                exit_p = "$(blastresLog_D)/blast.exit", env = blast_env))

    return projblast
end

#endregion

# Functions to build BLAST commands

"""
do_blastdb_runblast(makeblastdb::WrapCmd{MakeBlastDb_cmd}, runblast=WrapCmd{RunBlastNCmd})
    This function performs a a complete Blast process: first it creates the blast database, and then 
        it blast the query sequence(s) against the blast database. 
    
    ## Arguments:
        - makeblastdb: the WrapCmd{MakeBlastDb_cmd} object storying paths and other parameters
        - runblast: the WrapCmd{RunBlastNCmd} object storying blastn paths and params
    
    ## Returns
    - nothing
    
"""
function do_blastdb_runblast(makeblastdb::WrapCmd{MakeBlastDb_cmd}, runblast::WrapCmd{RunBlastNCmd})   ### for new proj objects, the paths will change
    do_cmd(makeblastdb, "makeblastdb", false)
    do_cmd(runblast, "BLAST", false)

    return nothing
end


# Functions to read the outputs
function outfmt2header(header::String)
    header = split(header, " ")
    header = header[2:end]
    header = Symbol.(header)
    return header
end

function load_blastout(cmd::RunBlastCmds)
    header = outfmt2header(cmd.outfmt)
    #[:qseqid, :sseqid, :evalue, :bitscore, :qstart, :qend, :sstart, :send, :qlen, :slen, :pident, :qseq, :sseq, :length, :nident, :mismatch, :gaps]
    #blastout_df = CSV.File(cmd.out; delim='\t', header=header) |> DataFrame
    blastout_df = CSV.read(cmd.out, DataFrame; delim='\t', header=header)
    return blastout_df
end