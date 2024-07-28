"""This runs a ruby script to calculate the coverage"""

export RunCalcCovCmd, build_pipe

struct RunCalcCovCmd  <: BioinfPipe
    program::String
    inref::FnaP
    insam::SamP
    outcov::TableP
end

function build_pipe(obj::RunCalcCovCmd)
    pipe = pipeline(`$(obj.program) -s $(obj.inref.p) -f $(obj.insam.p)`, stdout= pipeline(`sort -k1,1`, obj.outcov.p))

    return pipe
end

