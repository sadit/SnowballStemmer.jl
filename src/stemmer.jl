const _libsb = joinpath(dirname(@__FILE__),"..","deps","usr","lib", "libstemmer." * Libdl.dlext)
#@BinDeps.load_dependencies [:libstemmer=>:_libsb]
##
# character encodings supported by libstemmer
const UTF_8         = "UTF_8"

##
# lists the stemmer algorithms loaded
function stemmer_types()
    cptr = ccall((:sb_stemmer_list, _libsb), Ptr{Ptr{UInt8}}, ())
    (C_NULL == cptr) && error("error getting stemmer types")

    stypes = AbstractString[]
    i = 1
    while true
        name_ptr = unsafe_load(cptr, i)
        (C_NULL == name_ptr) && break
        push!(stypes, unsafe_string(name_ptr))
        i += 1
    end
    stypes
end

mutable struct Stemmer
    cptr::Ptr{Cvoid}
    alg::String
    enc::String

    function Stemmer(stemmer_type::String, charenc::String=UTF_8)
        cptr = ccall((:sb_stemmer_new, _libsb),
                    Ptr{Cvoid},
                    (Ptr{UInt8}, Ptr{UInt8}),
                    stemmer_type, charenc)

        if cptr == C_NULL
            if charenc == UTF_8
                error("stemmer '$(stemmer_type)' is not available")
            else
                error("stemmer '$(stemmer_type)' is not available for encoding '$(charenc)'")
            end
        end

        stm = new(cptr, stemmer_type, charenc)
        finalizer(release, stm)
        stm
    end
end

show(io::IO, stm::Stemmer) = println(io, "Stemmer algorithm:$(stm.alg) encoding:$(stm.enc)")

function release(stm::Stemmer)
    (C_NULL == stm.cptr) && return
    ccall((:sb_stemmer_delete, _libsb), Nothing, (Ptr{Cvoid},), stm.cptr)
    stm.cptr = C_NULL
    nothing
end

function stem(stemmer::Stemmer, bstr::String)::String
    sres = ccall((:sb_stemmer_stem, _libsb),
                Ptr{UInt8},
                (Ptr{UInt8}, Ptr{UInt8}, Cint),
                stemmer.cptr, bstr, sizeof(bstr))
    (C_NULL == sres) && error("error in stemming")
    slen = ccall((:sb_stemmer_length, _libsb), Cint, (Ptr{Cvoid},), stemmer.cptr)
    bytes = unsafe_wrap(Array, sres, Int(slen), own=false)
    String(copy(bytes))
end

function stem(stemmer::Stemmer, word::SubString{String})::String
    sres = ccall((:sb_stemmer_stem, _libsb),
                Ptr{UInt8},
                (Ptr{UInt8}, Ptr{UInt8}, Cint),
                stemmer.cptr, pointer(word.string)+word.offset, lastindex(word))
    (C_NULL == sres) && error("error in stemming")
    unsafe_string(sres)
    #slen = ccall((:sb_stemmer_length, _libsb), Cint, (Ptr{Cvoid},), stemmer.cptr)
    #bytes = pointer_to_array(sres, @compat(Int(slen)), false)
    #bytestring(bytes)
end
