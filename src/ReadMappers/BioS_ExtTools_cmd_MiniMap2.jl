export RunMiniMap2IndexCmd, RunMiniMap2AligCmd, build_cmd

struct RunMiniMap2IndexCmd <: BioinfCmd
    program::String
    pressetX::String  # sr for Illumina reads; map-ont for Nanopore reads
    inref::FnaP
    index::MmiP
end

build_cmd(cmd::RunMiniMap2IndexCmd) = 
    `$(cmd.program) -I 10000G -x $(cmd.pressetX) -d $(cmd.index.p) $(cmd.inref.p) --secondary=no`

struct RunMiniMap2AligCmd <: BioinfCmd
    program::String
    num_threads::Int64
    pressetX::String  # sr for Illumina reads; map-ont for Nanopore reads
    index::MmiP
    read1::FastaQP
    read2::Union{Missing, FastaQP}
    out_p::SamP
end

function build_cmd(cmd::RunMiniMap2AligCmd)
    if ismissing(cmd.read2)
        cmd = `$(cmd.program) -o $(cmd.out_p.p) -t $(cmd.num_threads) -ax $(cmd.pressetX) $(cmd.index.p) --split-prefix mmsplit $(cmd.read1.p) --secondary=no --sam-hit-only` #  -N 5 (max number of secondary alignments to output for each primary alignment; default: 5)
    else
        cmd = `$(cmd.program) -o $(cmd.out_p.p) -t $(cmd.num_threads) -ax $(cmd.pressetX) $(cmd.index.p) --split-prefix mmsplit $(cmd.read1.p) $(cmd.read2.p) --secondary=no --sam-hit-only` #  -N 5 (max number of secondary alignments to output for each primary alignment; default: 5)
    end

end

#minimap2 -t 8 -N 5 -ax sr catalogue.mmi --split-prefix mmsplit /path/to/reads/sample1.fw.fq.gz /path/to/reads/sample1.rv.fq.gz 
#| samtools view -F 3584 -b --threads 8 > /path/to/bam/sample1.bam