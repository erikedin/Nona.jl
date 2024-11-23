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

using Nona.Games
using Nona.NonaREPLs: NewGameAction

export ParserInput, OKParseResult
export NonaREPLParser
export isok

struct ParserInput
    text::String
end

abstract type Parser{T} end

abstract type ParseResult{T} end

struct OKParseResult{T} <: ParseResult{T}
    value::T
end

struct NonaREPLParser <: Parser{Command} end

function (p::NonaREPLParser)(input::ParserInput) :: ParseResult{Command}
    if input.text == "!visa"
        OKParseResult{Command}(ShowCurrentPuzzle())
    elseif input.text == "!nytt"
        OKParseResult{Command}(NewGameAction())
    else
        OKParseResult{Command}(Guess(Word("PUSSGURKA")))
    end
end

isok(::OKParseResult{T}) where {T} = true

end # module Parsers