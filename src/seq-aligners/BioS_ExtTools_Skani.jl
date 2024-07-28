export RunSkaniReciprDistCmd, build_cmd, ProjSkaniPondDist, set_ProjSkaniPondDist, run_workflow
export RunSkaniSketchCmd, build_string_cmd
export RunSkaniDBDistCmd, build_cmd, ProjSkaniDBDist, set_ProjSkaniDBDist

#region Skani to calculate reciprocal distances

# command to run skani
struct RunSkaniReciprDistCmd <: BioinfCmd
    inref::FnaP
    outfile::TableP
end

build_cmd(obj::RunSkaniReciprDistCmd) = `skani dist --slow -m 100 --qi $(obj.inref.p) --ri $(obj.inref.p) -o $(obj.outfile.p)`

# project objects and constructor functions
struct ProjSkaniPondDist <: BioinfProj
    pd::String
    runskanirecipdist::WrapCmd{RunSkaniReciprDistCmd}
    skani_out_pondav::TableP
end

function set_ProjSkaniPondDist(pd::String, inref::FnaP, args::Vector{String})
    skani_D = "$(pd)/skani_pondav"
    skaniLog_D = "$(skani_D)/log"
    my_mkpath([skani_D, skaniLog_D])

    skani_env = extract_args(args, "skani_env")
    skani_outfile = "$(skani_D)/skani_out.tsv" |> TableP
    skani_out_pondav = "$(skani_D)/skani_out_pondav.tsv" |> TableP

    skanirecipdist = ProjSkaniPondDist(skani_D, WrapCmd(; cmd = RunSkaniReciprDistCmd(inref, skani_outfile),
        log_p = "$(skaniLog_D)/skani.log", err_p = "$(skaniLog_D)/skani.err", exit_p = "$(skaniLog_D)/skani.exit",
        env = skani_env), skani_out_pondav)

    return skanirecipdist
end


# get DF with ponderated average for Skani results

function skani_pondav(inref::FnaP, inf::TableP, outf::TableP)
    df = CSV.read(inf.p, DataFrame; delim = '\t', header = 1)
    select!(df, Not(:Ref_file, :Query_file))

    dft = get_contig_pairs(inref)

    df = leftjoin(dft, df, on = [:query => :Query_name, :ref => :Ref_name])
    sort!(df, [:ANI])

    df[!, :PondANI] = zeros(nrow(df))
    df[!, :PondDist] = fill(100, nrow(df))

    withvals_dict = Dict()

    for i in 1:nrow(df)
        pair = (min(df[i, :query], df[i, :ref]), max(df[i, :query], df[i, :ref]))

        if ismissing(df[i, :ANI]) == false

            PondANI = round((( (df[i, :ANI] * df[i, :Align_fraction_ref]) + (df[i, :ANI] * df[i, :Align_fraction_query]) )/200), digits = 0)

            if haskey(withvals_dict, pair)
                if withvals_dict[pair][1] != PondANI && abs(withvals_dict[pair][1] - PondANI) > 2
                    println("Genomes pairs for $(pair) have different PondANI values!!!: $(PondANI) and $(withvals_dict[pair][1]), they have been corrected to $(withvals_dict[pair][1])")
                end
                
                df[i, :PondANI] = withvals_dict[pair][1]
                df[i, :PondDist] = (100 - df[i, :PondANI])
            
            else
                df[i, :PondANI] = PondANI
                df[i, :PondDist] = (100 - df[i, :PondANI])
                withvals_dict[pair] = (df[i, :PondANI], df[i, :PondDist])
            end

        elseif haskey(withvals_dict, pair)
            df[i, :PondANI] = withvals_dict[pair][1]
            df[i, :PondDist] = withvals_dict[pair][2]

            println("Genome pair $(pair) had no ANI, the PondANI was adjusted based on its mathching pair")          
        end
    end

    CSV.write(outf.p, df, delim = '\t', header = true)
    return df
end

# workflow function	
function run_workflow(proj::ProjSkaniPondDist)
    do_cmd(proj.runskanirecipdist, "skani", true)

    df = skani_pondav(proj.runskanirecipdist.cmd.inref, proj.runskanirecipdist.cmd.outfile, proj.skani_out_pondav)
    return df
end

#endregion

#region Skani database make

struct RunSkaniSketchCmd <: BioinfCmd
    indir::String    # needs to be a folder
    outdir::String
end

build_string_cmd(obj::RunSkaniSketchCmd) = "skani sketch $(obj.indir)/* -o $(obj.outdir)"

#endregion

#region Skani database search
struct RunSkaniDBDistCmd <: BioinfCmd
    inref::FnaP
    indb::String  #needs to b the folder for the database
    outfile::TableP
end

function build_string_cmd(obj::RunSkaniDBDistCmd)
    cmd = "skani dist --slow -m 100 --qi -q $(obj.inref.p) -r $(obj.indb)/* -o $(obj.outfile.p)"
    return cmd
end

struct ProjSkaniDBDist <: BioinfProj
    pd::String
    runSkaniDBDist::WrapCmd{RunSkaniDBDistCmd}
    rel_ANI_th::Float64
    rel_aligfrac_th::Float64
    skani_DB_fnas::String ## the path toward the folder with the fna files from the database
    skani_rel_p::FnaP
end

function set_ProjSkaniDBDist(pd::String, inref::FnaP, indb_sketch::String, indb_fnas::String, env::String, rel_ANI_th::Float64, rel_aligfrac_th::Float64)
    dbname = basename(indb_sketch)
    skani_D = "$(pd)/$(dbname)"
    skaniLog_D = "$(skani_D)/log"
    my_mkpath([skani_D, skaniLog_D])

    runSkaniDBDist = WrapCmd(; cmd = RunSkaniDBDistCmd(inref, indb_sketch, "$(skani_D)/skani_out.tsv" |> TableP),
        log_p = "$(skaniLog_D)/skani.log", err_p = "$(skaniLog_D)/skani.err", exit_p = "$(skaniLog_D)/skani.exit",
        env = env)

    skani_rel_p = "$(skani_D)/skani_relatives.fna" |> FnaP

    proj = ProjSkaniDBDist(skani_D, runSkaniDBDist, rel_ANI_th, rel_aligfrac_th, indb_fnas, skani_rel_p)
    return proj
end


function get_skani_relatives(df_p::TableP, rel_ANI_th::Float64, rel_aligfrac_th::Float64)
    df = CSV.read(df_p.p, DataFrame; delim = '\t', header = 1)
    if nrow(df) > 0
        select!(df, Not(:Ref_file, :Query_file))
        subset!(df, :ANI => a -> a .>= rel_ANI_th, 
                    :Align_fraction_ref => b -> b .>= rel_aligfrac_th, 
                    :Align_fraction_query => c -> c .>= rel_aligfrac_th)

        if nrow(df) > 0
            select!(df, :Ref_name)
            derepDf!(df, :Ref_name)

            outfna_v = fill("", nrow(df))

            for i in 1:nrow(df)
                outfna_v[i] = "$(df[i, :Ref_name])"
            end
            
            df = nothing
            return outfna_v
        else
            return missing
        end
    else
        return missing
    end
end



function run_workflow(proj::ProjSkaniDBDist)
    do_string_cmd(proj.runSkaniDBDist, "skani DB search", true)

    ### implent case Skani does not return any relatives (is the Table empty or what?)
    outfna_v = get_skani_relatives(proj.runSkaniDBDist.cmd.outfile, proj.rel_ANI_th, proj.rel_aligfrac_th)
    
    return outfna_v
end

#endregion