@enum Constant begin
    E
    EGAMMA
    FRAC_1_PI
    FRAC_1_SQRT_2
    FRAC_1_SQRT_3
    FRAC_1_SQRT_PI
    FRAC_2_PI
    FRAC_2_SQRT_PI
    FRAC_PI_2
    FRAC_PI_3
    FRAC_PI_4
    FRAC_PI_6
    FRAC_PI_8
    LN_10
    LN_2
    LOG10_2
    LOG10_E
    LOG2_10
    LOG2_E
    PHI
    PI
    SQRT_2
    SQRT_3
    TAU
end

function name(c::Constant)::String
    return String(Symbol(c))
end

function description(c::Constant)::String
    c == E && return "Euler’s number (e)"
    c == EGAMMA && return "The Euler-Mascheroni constant (γ)"
    c == FRAC_1_PI && return "1/π"
    c == FRAC_1_SQRT_2 && return "1/sqrt(2)"
    c == FRAC_1_SQRT_3 && return "1/sqrt(3)"
    c == FRAC_1_SQRT_PI && return "1/sqrt(π)"
    c == FRAC_2_PI && return "2/π"
    c == FRAC_2_SQRT_PI && return "2/sqrt(π)"
    c == FRAC_PI_2 && return "π/2"
    c == FRAC_PI_3 && return "π/3"
    c == FRAC_PI_4 && return "π/4"
    c == FRAC_PI_6 && return "π/6"
    c == FRAC_PI_8 && return "π/8"
    c == LN_10 && return "ln(10)"
    c == LN_2 && return "ln(2)"
    c == LOG10_2 && return "log10(2)"
    c == LOG10_E && return "log10(e)"
    c == LOG2_10 && return "log2(10)"
    c == LOG2_E && return "log2(e)"
    c == PHI && return "The golden ratio (φ)"
    c == PI && return "Archimedes’ constant (π)"
    c == SQRT_2 && return "sqrt(2)"
    c == SQRT_3 && return "sqrt(3)"
    c == TAU && return """
        The full circle constant (τ)

        Equal to 2π
        """
end

function value(c::Constant)::BigFloat
    # use bignum constants for all math for arbitrary precision
    big_pi = big(pi)
    big_e = big(MathConstants.e)
    big_phi = (1 + sqrt(big(5))) / 2

    c == E && return big_e
    c == EGAMMA && return MathConstants.eulergamma
    c == FRAC_1_PI && return 1/big_pi
    c == FRAC_1_SQRT_2 && return 1/sqrt(2)
    c == FRAC_1_SQRT_3 && return 1/sqrt(3)
    c == FRAC_1_SQRT_PI && return 1/sqrt(big_pi)
    c == FRAC_2_PI && return 2/big_pi
    c == FRAC_2_SQRT_PI && return 2/sqrt(big_pi)
    c == FRAC_PI_2 && return big_pi/2
    c == FRAC_PI_3 && return big_pi/3
    c == FRAC_PI_4 && return big_pi/4
    c == FRAC_PI_6 && return big_pi/6
    c == FRAC_PI_8 && return big_pi/8
    c == LN_10 && return log(10)
    c == LN_2 && return log(2)
    c == LOG10_2 && return log10(2)
    c == LOG10_E && return log10(big_e)
    c == LOG2_10 && return log2(10)
    c == LOG2_E && return log2(big_e)
    c == PHI && return big_phi
    c == PI && return big_pi
    c == SQRT_2 && return sqrt(2)
    c == SQRT_3 && return sqrt(3)
    c == TAU && return 2big_pi
end

function make_single_const_rust_source(c::Constant, ty::String, attributes::String)::String
    descr = strip(description(c))
    doc = join(map(line -> "/// $(strip(line))", split(descr, "\n")), "\n")
    
    s = """
        $doc
        $attributes
        const $(name(c)): $ty = $(value(c))_$ty;
        """
    return s
end

function make_single_ty_rust_source(ty::String, attributes::String)::String
    ret = ""

    for c in instances(Constant)
        ret *= "\n"
        ret *= make_single_const_rust_source(c, ty, attributes)
    end

    return ret
end

function indent(s::String)::String
    return join(map(line -> length(line) == 0 ? "" : "    $line", split(s, "\n")), "\n")
end

function main()
    println("/* automatically generated file */")

    setprecision(BigFloat, 100)
    println("\n\n\nmod f16_consts {")
    out = make_single_ty_rust_source("f16", """#[unstable(feature = "f16", issue = "116909")]""")
    println("$(indent(out))")
    println("}")

    setprecision(BigFloat, 190)
    println("\n\n\nmod f128_consts {")
    out = make_single_ty_rust_source("f128", """#[unstable(feature = "f128", issue = "116909")]""")
    println("$(indent(out))")
    println("}")
    
end

main()

