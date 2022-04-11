using NewickTreeTools
using Documenter

DocMeta.setdocmeta!(NewickTreeTools, :DocTestSetup, :(using NewickTreeTools); recursive=true)

makedocs(;
    modules=[NewickTreeTools],
    authors="Benjamin Doran and collaborators",
    repo="https://github.com/aramanlab/NewickTreeTools.jl/blob/{commit}{path}#{line}",
    sitename="NewickTreeTools.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://aramanlab.github.io/NewickTreeTools.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/aramanlab/NewickTreeTools.jl",
    devbranch="main",
)
