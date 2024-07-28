export RunShrinksamCmd, build_cmd

struct RunShrinksamCmd <: BioinfCmd
    program::String
    input::SamP
    output::SamP
    delete::Bool
end

function build_cmd(obj::RunShrinksamCmd)
    cmd = `$(obj.program) -i $(obj.input.p) -k $(obj.output.p) -d $(obj.delete)`

    return cmd
end