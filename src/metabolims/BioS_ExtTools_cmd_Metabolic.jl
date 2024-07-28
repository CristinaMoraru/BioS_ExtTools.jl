export RunMetabolicGenomesCmd, build_cmd

struct RunMetabolicGenomesCmd <: BioinfCmd
    program::String
    indir::String #path_to_folder_with_genome_fasta_files
    outdir::String #output_directory_to_be_created
    num_threads::Int64
end

build_cmd(obj::RunMetabolicGenomesCmd) = `perl $(obj.programs) -in-gn $(obj.indir) -o $(obj.outdir) -t $(obj.num_threads)`

