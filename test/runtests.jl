module TestTextAnalysis
    using Base.Test
    using SnowballStemmer
    using Compat

    my_tests = [
        "stemmer.jl",
    ]

    println("Running tests:")
    println(typeof(Compat.String))

    for my_test in my_tests
        println(" * $(my_test)")
        include(my_test)
    end
end
