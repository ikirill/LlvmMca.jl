# LlvmMca.jl

`LlvmMca.jl` provides access to
[`llvm-mca`](https://llvm.org/docs/CommandGuide/llvm-mca.html) through
Julia's `@code_native` macro.

Note that there is currently an issue with Julia's `@code_native`
producing incorrect output on MacOS, so the example below may or may
not work (https://github.com/JuliaLang/julia/issues/28046). In
particular, llvm-mca may complain that it is being given 32-bit
assembly.

Example
```
julia> f1(x::AbstractFloat) = fma(x, fma(x, fma(x, 0.2f0, 0.3f0), 0.4f0), 0.5f0)
f1 (generic function with 1 method)

julia> LlvmMca.@code_mca f1(0.f0)
IPC:               0.83
Block RThroughput: 2.5


Instruction Info:
[1]: #uOps
[2]: Latency
[3]: RThroughput
[4]: MayLoad
[5]: MayStore
[6]: HasSideEffects (U)

[1]    [2]    [3]    [4]    [5]    [6]    Instructions:
 1      1     0.25                        movabsq       $140140900870252, %rax
 1      5     0.50    *                   vmovss        (%rax), %xmm1
 1      1     0.25                        movabsq       $140140900870256, %rax
 2      9     0.50    *                   vfmadd213ss   (%rax), %xmm0, %xmm1
 1      1     0.25                        movabsq       $140140900870260, %rax
 2      9     0.50    *                   vfmadd213ss   (%rax), %xmm0, %xmm1
 1      1     0.25                        movabsq       $140140900870264, %rax
 2      9     0.50    *                   vfmadd213ss   (%rax), %xmm1, %xmm0
 3      7     1.00                  U     retq
 1      1     0.17                        nopl  (%rax)


Resources:
[0]   - SKLDivider
[1]   - SKLFPDivider
[2]   - SKLPort0
[3]   - SKLPort1
[4]   - SKLPort2
[5]   - SKLPort3
[6]   - SKLPort4
[7]   - SKLPort5
[8]   - SKLPort6
[9]   - SKLPort7


Resource pressure per iteration:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]
 -      -     2.56   2.56   2.50   2.50    -     1.53   2.35    -

Resource pressure by instruction:
[0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    Instructions:
 -      -     0.06   0.46    -      -      -     0.07   0.41    -     movabsq   $140140900870252, %rax
 -      -      -      -     0.50   0.50    -      -      -      -     vmovss    (%rax), %xmm1
 -      -     0.48   0.05    -      -      -     0.45   0.02    -     movabsq   $140140900870256, %rax
 -      -     0.09   0.91   0.50   0.50    -      -      -      -     vfmadd213ss       (%rax), %xmm0, %xmm1
 -      -     0.43   0.05    -      -      -     0.05   0.47    -     movabsq   $140140900870260, %rax
 -      -     0.48   0.52   0.50   0.50    -      -      -      -     vfmadd213ss       (%rax), %xmm0, %xmm1
 -      -     0.04   0.04    -      -      -     0.47   0.45    -     movabsq   $140140900870264, %rax
 -      -     0.92   0.08   0.91   0.09    -      -      -      -     vfmadd213ss       (%rax), %xmm1, %xmm0
 -      -     0.06   0.45   0.09   0.91    -     0.49   1.00    -     retq
 -      -      -      -      -      -      -      -      -      -     nopl      (%rax)
```
