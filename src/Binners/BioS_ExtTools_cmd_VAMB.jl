export RunvambCmd, build_cmd

struct RunvambCmd <:BioinfCmd
    inref::FnaP
    in_bams::Vector{String}
    outdir::String
    minbinsize::Int64
    num_threads::Int64
end

build_cmd(obj::RunvambCmd) = `vamb --outdir $(obj.outdir) --fasta $(obj.inref.p) --bamfiles $(obj.in_bams) -m 1000 --minfasta $(obj.minbinsize) -p $(obj.num_threads)`

# vamb --outdir path/to/outdir --fasta /path/to/catalogue.fna.gz --bamfiles /path/to/bam/*.bam -o C 