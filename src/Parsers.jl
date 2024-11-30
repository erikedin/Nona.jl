# MIT License
#
# Copyright (c) 2024 Erik Edin
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

module Parsers

# Methods named
# - xyzP: parser that take a ParserInput and produces a ParserInput and a result.
# - xyzC: combinators that combines values or parsers to create a new parser.

export
    ParserInput,
    eofP,
    anyP,
    charC,
    choiceC,
    spaceP,
    sequenceC,
    manyC,
    notC,
    transformC,
    tokenP,
    ignoreC,
    ignoreSuffixC,
    To,
    BadParse

struct ParserInput
    text::String
    position::Int

    ParserInput(text::String, position::Int = 1) = new(text, position)
    ParserInput(input::ParserInput, n::Int) = new(input.text, input.position + n)
end

Base.eof(input::ParserInput) = input.position > length(input.text)
consume(input::ParserInput) = (ParserInput(input, 1), input.text[input.position])

struct BadParse end

abstract type Parser{T} end
"""
    eofP(input::ParserInput) :: Tuple{ParserInput, Union{BadParse, Nothing}}

Parse EOF.
"""
struct eofC <: Parser{Nothing} end
(p::eofC)(input::ParserInput) = (input, eof(input) ? nothing : BadParse())
const eofP = eofC()

"""
    anyP(input::ParserInput) :: Tuple{ParserInput, Union{BadParse, Char}}

Parse any character. Fails on EOF.
"""
struct anyC <: Parser{Char} end
(::anyC)(input::ParserInput) = eof(input) ? (input, BadParse()) : consume(input)
const anyP = anyC()

struct satisfyC <: Parser{Char}
    predicate::Function
end
function (p::satisfyC)(input::ParserInput)
    (rest, x) = anyP(input)
    if p.predicate(x)
        (rest, x)
    else
        (input, BadParse())
    end
end

charC(c::Char) = satisfyC(x -> x == c)
notC(c::Char) = satisfyC(x -> x != c)

const spaceP = satisfyC(x -> x == ' ')


# The previous parser failed, returning a BadParse. Try the next parser in the list.
choice((input, _badParse)::Tuple{ParserInput, BadParse}, parser::Parser{T}) where {T} = parser(input)
# A previous parser was successful. Return the successful result and skip this parser.
choice(result::Tuple{ParserInput, S}, _parser::Parser{T}) where {S, T} = result

struct choiceC{S, T} <: Parser{Union{S, T}}
    p::Parser{S}
    q::Parser{T}
end

(parser::choiceC{S, T})(input::ParserInput) where {S, T} = choice(parser.p(input), parser.q)

function Base.:|(p::Parser{S}, q::Parser{T}) :: Parser{Union{S, T}} where {S, T}
    choiceC(p, q)
end

struct To{T}
    f::Function

    To{T}(f::Function) where {T} = new{T}(f)
    # Shorthand to convert to a given type.
    To{T}() where {T} = new{T}((xs...) -> T(xs...))
end
(to::To{T})(x...) where {T} = to.f(x...)

_transform(result::Tuple{ParserInput, BadParse}, _f::To{T}) where {T} = result
_transform((rest, value)::Tuple{ParserInput, S}, f::To{T}) where {S, T} = (rest, f(value))

struct transformC{S, T} <: Parser{T}
    p::Parser{S}
    f::To{T}
end

function (parser::transformC{S, T})(input::ParserInput) where {S, T}
    result = parser.p(input)
    _transform(parser.p(input), parser.f)
end

Base.:|>(p::Parser{S}, f::To{T}) where {S, T} = transformC(p, f)

# Sequences

struct Ignored
    Ignored(x...) = new()
end

ignoreC(p) = transformC(p, To{Ignored}())

# sequenceCombine(valuep::BadParse, _valueq) = valuep
# sequenceCombine(_valuep, valueq::BadParse) = valueq
# sequenceCombine(::Ignored, value) = value
# sequenceCombine(valuep, ::Ignored) = valuep
# sequenceCombine(valuep, valueq) = (valuep..., valueq)
# sequence(result::Tuple{ParserInput, BadParse}, _q) = result
# function sequence((restp, valuep)::Tuple{ParserInput, T}, q) where {T}
#     (restq, valueq) = q(restp)
#     (restq, sequenceCombine(valuep, valueq))
# end
#
# struct sequenceC{T} <: Parser{T}
#     parsers::Vector{Parser}
#
#     sequenceC(p::Parser{P}, q::Parser{Ignored}) where {P} = new{P}([p, q])
#     sequenceC(p::Parser{P}, q::Parser{Q}) where {P, Q} = new{Tuple{P, Q}}([p, q])
#     sequenceC(p::Parser{Tuple{S, U}}, q::Parser{Q}) where {S, U, Q} = new{Tuple{S, U, Q}}([p.parsers..., q])
# end
# function (parser::sequenceC{T})(input::ParserInput) where {T}
#     foldl(sequence, parser.parsers; init = (input, ()))
# end
#
# function Base.:>>(p::Parser{S}, q::Parser{T}) where {S, T}
#     sequenceC(p, q)
# end

function sequence((rest, value), p)
    (newrest, newvalue) = p(rest)
    (newrest, (value..., newvalue))
end

struct sequenceC{T} <: Parser{T}
    parsers::Vector{Parser}

    sequenceC(p::sequenceC{Tuple{S, U}}, q::Parser{Q}) where {S, U, Q} = new{Tuple{S, U, Q}}([p.parsers..., q])
    sequenceC(p::sequenceC{Tuple{S, U, V}}, q::Parser{Q}) where {S, U, V, Q} = new{Tuple{S, U, V, Q}}([p.parsers..., q])
    sequenceC(p::sequenceC{Tuple{S, U, V, W}}, q::Parser{Q}) where {S, U, V, W, Q} = new{Tuple{S, U, V, W, Q}}([p.parsers..., q])
    sequenceC(p::Parser{P}, q::Parser{Q}) where {P, Q} = new{Tuple{P, Q}}([p, q])
end

function (p::sequenceC{T})(input::ParserInput) where {T}
    foldl(sequence, p.parsers; init = (input, ()))
end

function Base.:>>(p::Parser{P}, q::Parser{Q}) where {P, Q}
    sequenceC(p, q)
end

many(value, (rest, _)::Tuple{ParserInput, BadParse}) = (rest, value, false)
many(value, (rest, nextvalue)) = (rest, (value..., nextvalue), true)

struct manyC{T} <: Parser{Vector{T}}
    p::Parser{T}

    manyC(p::Parser{T}) where {T} = new{T}(p)
end

function (parser::manyC{T})(input::ParserInput) :: Tuple{ParserInput, Vector{T}} where {T}
    value = ()
    rest = input
    successful = true
    while successful
        (rest, value, successful) = many(value, parser.p(rest))
    end
    (rest, collect(value))
end

# const tokenCharP = satisfyC(x -> x != ' ')
# const tokenCharsP = manyC(tokenCharP) >> ignoreC(manyC(spaceP))
# const tokenP = transformC(tokenCharsP, To{String}(join))

end # module Parsers