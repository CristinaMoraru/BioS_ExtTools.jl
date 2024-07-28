

struct RunPPanGGolinCmd <: BioinfCmd
    intsv::TableP
end

build_cmd(obj::RunPPanGGolinCmd) = `ppanggolin all `