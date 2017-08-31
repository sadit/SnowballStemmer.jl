module SnowballStemmer

using BinDeps
# using Compat

export stemmer_types, Stemmer, release
export stem

include("stemmer.jl")
end
