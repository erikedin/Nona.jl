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
    isspaceP,
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


"""
    eofP(input::ParserInput) :: Tuple{ParserInput, Union{BadParse, Nothing}}

Parse EOF.
"""
eofP(input::ParserInput) = (input, eof(input) ? nothing : BadParse())

"""
    anyP(input::ParserInput) :: Tuple{ParserInput, Union{BadParse, Char}}

Parse any character. Fails on EOF.
"""
anyP(input::ParserInput) = eof(input) ? (input, BadParse()) : consume(input)

function satisfyC(predicate)
    input -> begin
        (rest, x) = anyP(input)
        if predicate(x)
            (rest, x)
        else
            (input, BadParse())
        end
    end
end

charC(c::Char) = satisfyC(x -> x == c)

const isspaceP = satisfyC(x -> x == ' ')

# The previous parser failed, returning a BadParse. Try the next parser in the list.
choice((input, _badParse)::Tuple{ParserInput, BadParse}, parser) = parser(input)
# A previous parser was successful. Return the successful result and skip this parser.
choice(result::Tuple{ParserInput, T}, _parser) where {T} = result
# The first parser takes two parsers, and forwards to one of the above choice methods.
choice(p, q) = input -> choice(p(input), q)

"""
    choice(p, q)

Create a parser that chooses between several other parsers.
"""
choiceC(parsers...) = foldr(choice, collect(parsers))

Base.:|(p::Function, q::Function) = choiceC(p, q)

end # module Parsers