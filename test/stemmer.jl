module TestStemmer
using Base.Test
using SnowballStemmer

algs = stemmer_types()

@test !isempty(algs)

for alg in algs
    stmr = Stemmer(alg)
    release(stmr)
end

test_cases = @compat Dict{String, Any}(
    "english" => @compat Dict{String, String}(
        "working" => "work",
        "worker" => "worker",
        "aβc" => "aβc",
        "a∀c" => "a∀c"
    )
)

for (alg, test_words) in test_cases
    stmr = Stemmer(alg)
    for (n,v) in test_words
        @test v == stem(stmr, n)
    end
end

end
