using GBGraph
using Documenter

DocMeta.setdocmeta!(GBGraph, :DocTestSetup, :(using GBGraph); recursive=true)

makedocs(;
    modules=[GBGraph],
    authors="Wimmerer <wrkimmerer@outlook.com> and contributors",
    repo="https://github.com/Wimmerer/GBGraph.jl/blob/{commit}{path}#{line}",
    sitename="GBGraph.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Wimmerer.github.io/GBGraph.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Wimmerer/GBGraph.jl",
    devbranch="main",
)
