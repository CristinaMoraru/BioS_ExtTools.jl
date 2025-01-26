export build_cmd, RunBBMapIndex, RunBBMapMap

struct RunBBMapIndex <: BioinfCmd
    program::String
    inref::FnaP
end

build_cmd(cmd::RunBBMapIndex, parentD::String) = `$(cmd.program) ref=$(cmd.inref.p) -Xmx4g k=13`


struct RunBBMapMap <: BioinfCmd
    program::String
    num_threads::Int64
    read1::FastaQP
    read2::FastaQP
    out_f::SamP
    statsD::String
    idfilter::Float64
    subfilter::Int64
    insfilter::Int64
    delfilter::Int64
    indelfilter::Int64
    inslenfilter::Int64
    dellenfilter::Int64
    nfilter::Int64
    ambiguous::String
end

#outm outputs only mapped reads, help to keep the output sam file small
function build_cmd(cmd::RunBBMapMap)
    cmd = `$(cmd.program) 
            in=$(cmd.read1.p) in2=$(cmd.read2.p) outm=$(cmd.out_f.p) 
            qhist=$(cmd.statsD)/qhist.tsv 
            aqhist=$(cmd.statsD)/aqhist.tsv 
            lhist=$(cmd.statsD)/lhist.tsv 
            ihist=$(cmd.statsD)/ihist.tsv 
            ehist=$(cmd.statsD)/ehist.tsv 
            qahist=$(cmd.statsD)/qahist.tsv 
            indelhist=$(cmd.statsD)/indelhist.tsv 
            mhist=$(cmd.statsD)/mhist.tsv 
            idhist=$(cmd.statsD)/idhist.tsv 
            covstats=$(cmd.statsD)/covstats.tsv 
            basecov=$(cmd.statsD)/basecov.tsv 
            -Xmx10g mdtag=t xstag=t stoptag=t lengthtag=t idtag=t k=13 threads=1 
            pairedonly=t untrim=t mappedonly=t 32bit=t maxlen=600 local=f cigar=t 
            idfilter=$(cmd.idfilter) subfilter=$(cmd.subfilter) insfilter=$(cmd.insfilter) 
            delfilter=$(cmd.delfilter) indelfilter=$(cmd.indelfilter) 
            inslenfilter=$(cmd.inslenfilter) dellenfilter=$(cmd.dellenfilter) nfilter=$(cmd.nfilter) 
            ambiguous=$(cmd.ambiguous) 
            threads=$(cmd.num_threads)` 
            #2> $(cmd.statsD).stats.tsv 
            #`
end

function build_cmd(cmd::RunBBMapMap, parentD::String)
    cmd = `$(cmd.program) 
            in=$(cmd.read1.p) in2=$(cmd.read2.p) out=$parentD/$(cmd.out_f.p) 
            qhist=$parentD/$(cmd.statsD)/qhist.tsv 
            aqhist=$parentD/$(cmd.statsD)/aqhist.tsv 
            lhist=$parentD/$(cmd.statsD)/lhist.tsv 
            ihist=$parentD/$(cmd.statsD)/ihist.tsv 
            ehist=$parentD/$(cmd.statsD)/ehist.tsv 
            qahist=$parentD/$(cmd.statsD)/qahist.tsv 
            indelhist=$parentD/$(cmd.statsD)/indelhist.tsv 
            mhist=$parentD/$(cmd.statsD)/mhist.tsv 
            idhist=$parentD/$(cmd.statsD)/idhist.tsv 
            covstats=$parentD/$(cmd.statsD)/covstats.tsv 
            basecov=$parentD/$(cmd.statsD)/basecov.tsv 
            -Xmx10g mdtag=t xstag=t stoptag=t lengthtag=t idtag=t k=13 threads=1 
            pairedonly=t untrim=t mappedonly=t 32bit=t maxlen=600 local=f cigar=t 
            idfilter=$(cmd.idfilter) subfilter=$(cmd.subfilter) insfilter=$(cmd.insfilter) 
            delfilter=$(cmd.delfilter) indelfilter=$(cmd.indelfilter) 
            inslenfilter=$(cmd.inslenfilter) dellenfilter=$(cmd.dellenfilter) nfilter=$(cmd.nfilter) 
            ambiguous=$(cmd.ambiguous) 
            threads=$(cmd.num_threads)` 
            #2> $parentD/$(cmd.statsD).stats.tsv 
            #`
end