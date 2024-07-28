# Primer3 related datatypes and methods

export Primer3Params

"""
    Primer3Params: datatype storing paths for input/output files (as in multiple files, one per oligo)
    of the primer3 program.
"""
struct Primer3Params <: BioinfCmd
    main_D::String
    in_D::String
    out_D::String
    err_D::String
    exit_err_D::String
    dna_conc::String
    salt_mono::String
    FA::String
    minTmDif::Int64
end

function Primer3Params(pd::String, sufix::String, dna_conc::Float64, salt_mono::Float64, FA::Int64, minTmDif::Int64)::Primer3Params
    main_D = "$pd/$sufix"
    in_D = "/$main_D/in"
    out_D = "/$main_D/out"
    err_D = "/$main_D/err"
    exit_err_D = "/$main_D/exit_err"
    my_mkpath([main_D, in_D, out_D, err_D, exit_err_D])

    return Primer3Params(main_D, in_D, out_D, err_D, exit_err_D, string(dna_conc), string(salt_mono), string(FA), minTmDif)
end
