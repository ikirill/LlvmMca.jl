module LlvmMca

export code_mca, @code_mca

using InteractiveUtils, Base.Meta
import InteractiveUtils: gen_call_with_extracted_types_and_kwargs

macro code_mca(expr...)
    gen_call_with_extracted_types_and_kwargs(__module__, :code_mca, expr)
end

#= TODO

It seems to inline or include some base functions, like log2. I would
like to strip them out before passing the assembly to mca.

See also: https://github.com/JuliaLang/julia/issues/28046

=#

function code_mca(func, argtypes; save::Bool=false)
    io = IOBuffer()
    code_native(io, func, argtypes)

    s = String(take!(io))
    s = replace(s, r"^;.*\n"m => "")
    tmp, tmpio = mktemp()
    if save
        println(tmpio, s)
        println(stderr, "Saved temporary output to $tmp")
    end

    open(`llvm-mca`, "w", stdout) do cin
        println(cin, s)
    end
end

"""    @region_mca <code-block>

tries to insert llvm-mca code region markers.
"""
macro region_mca(expr)
    quote
        ccall(:fesetround, Int32, (Int32,), 0)
        t1 = Base.llvmcall("""
call void asm sideeffect "pause", "~{memory}"()
ret void
    """, Cvoid, Tuple{})
        $(esc(expr))
        ccall(:fesetround, Int32, (Int32,), 0)
        t2 = Base.llvmcall("""
call void asm sideeffect "pause", "~{memory}"()
ret void
    """, Cvoid, Tuple{})
    end
end

end
