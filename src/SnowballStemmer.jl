module SnowballStemmer

using BinDeps
using Libdl

export stemmer_types, Stemmer, release
export stem

include("stemmer.jl")
end
