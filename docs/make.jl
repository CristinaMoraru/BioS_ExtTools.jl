using BioS_ExtTools
using Documenter

DocMeta.setdocmeta!(BioS_ExtTools, :DocTestSetup, :(using BioS_ExtTools); recursive=true)

makedocs(;
    modules=[BioS_ExtTools],
    authors="Cristina Moraru",
    sitename="BioS_ExtTools.jl",
    format=Documenter.HTML(;
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
