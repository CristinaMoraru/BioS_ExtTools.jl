export ALLOWED_BOWTIE, RunBowtieBuildCmd, RunBowtie2Cmd, build_cmd, do_build_bowtie2


const ALLOWED_BOWTIE = Dict(
    "preset_endtoend" => ["sensitive", "very-sensitive", "very-fast", "fast"],
    "preset_local" => ["sensitive-local", "very-sensitive-local", "very-fast-local", "fast-local"]
)

# Bowtie2-build command for building reference indexes for mapping.
struct RunBowtieBuildCmd <: BioinfCmd
    #program="bowtie2-build"
    inref::FnaP
    indexD::String
    indexname::String
    num_threads::Int64
end


function build_cmd(obj::RunBowtieBuildCmd)
    cmd = `bowtie2-build $(obj.inref.p) $(obj.indexname) --threads $(obj.num_threads)`

    return cmd
end

# Bowtie2 command for mapping reads to a reference.

struct RunBowtie2Cmd <: BioinfCmd
    #program::String
    indexD::String
    indexname::String
    read1::FastaQP
    read2::FastaQP
    out_f::SamP
    preset_endtoend::String   #--end-to-end read alignment is the default mode for bowtie2
    num_threads::Int64
end

function build_cmd(obj::RunBowtie2Cmd)
    cmd = `bowtie2 -x $(obj.indexname) -1 $(obj.read1.p) -2 $(obj.read2.p) --threads $(obj.num_threads) --$(obj.preset_endtoend) -S $(obj.out_f.p) --no-unal`
    return cmd
end

# Combined bowtie2-build and bowtie2 commands for mapping reads to a reference.

function do_build_bowtie2(build::WrapCmd{RunBowtieBuildCmd}, map::WrapCmd{RunBowtie2Cmd})
    do_cmd(build, "Bowtie2-build", false)
    do_cmd(map, "Bowtie2", false)

    return nothing
end