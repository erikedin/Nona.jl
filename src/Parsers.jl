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

# ParseResult is the abstract type. A ParseResult is either an
# - OKParseResult, which is a successful parse
# - BadParseResult, which is unsuccessful
abstract type ParseResult{T} end

struct OKParseResult{T} <: ParseResult{T}
    value::T
end
isok(::OKParseResult{T}) where {T} = true

struct BadParseResult{T} <: ParseResult{T} end
isok(::BadParseResult{T}) where {T} = false

#
# Parsers
#

# Is matches an exact string, and is used for most commands without parameters.
struct Is{T} <: Parser{T}
    text::String
end

function (parser::Is{T})(input::ParserInput) :: ParseResult{Command} where {T}
    if input.text == parser.text
        OKParseResult{Command}(T())
    else
        BadParseResult{Command}()
    end
end

# Character matches a single character.
struct Character <: Parser{Char}
    c::Char
end

function (parser::Character)(input::ParserInput) :: ParseResult{Char}
    if parser.c == input.text[1]
        OKParseResult{Char}(parser.c)
    else
        BadParseResult{Char}()
    end
end

# Not inverses a parse result from the supplied parser, but throws away any result value.
struct Not{T} <: Parser{Nothing}
    inner::Parser{T}
end

function (parser::Not{T})(input::ParserInput) :: ParseResult{Nothing} where {T}
    result = parser.inner(input)
    if isok(result)
        BadParseResult{Nothing}()
    else
        OKParseResult{Nothing}(nothing)
    end
end

# And parses two inner parsers, and only succeeds if they succeed.
struct And{S, T} <: Parser{Tuple{S, T}}
    first::Parser{S}
    second::Parser{T}
end

function (parser::And{S, T})(input::ParserInput) :: ParseResult{Tuple{S, T}} where {S, T}
    result1 = parser.first(input)
    result2 = parser.second(input)

    if isok(result1) && isok(result2)
        OKParseResult{Tuple{S, T}}((result1.value, result2.value))
    else
        BadParseResult{Tuple{S, T}}()
    end
end

# WordParser produces a Word from the rest of the input
struct WordParser <: Parser{Word} end

function (parser::WordParser)(input::ParserInput) :: ParseResult{Word}
    OKParseResult{Word}(input.text)
end

# OrParser parses one of a list of parsers.
struct OrParser{S}
    parsers::Vector{Parser{<:S}}
end

function (parser::OrParser{S})(input::ParserInput) :: ParseResult{<:S} where {S}
    for p in parser.parsers
        result = p(input)
        if isok(result)
            return result
        end
    end
    BadParseResult{S}()
end

# GuessParser ensures that a guess does not start with a !.
struct GuessParser <: Parser{Guess} end

function (parser::GuessParser)(input::ParserInput) :: ParseResult{Guess}
    notexclamation = Not{Char}(Character('!'))
    inner = And(notexclamation, WordParser())
    result = inner(input)
    if isok(result)
        # The word is the second part of the tuple (nothing, word)
        # produced by the inner parser.
        word = result.value[2]
        OKParseResult{Guess}(Guess(word))
    else
        BadParseResult{Guess}()
    end
end

# NonaREPLParser is the main parser for all commands that are either
# - generic game commands, applicable to all games
# - REPL commands, such as switching games or exiting
# Game specific commands are not included here.
struct NonaREPLParser <: Parser{Command} end

function (p::NonaREPLParser)(input::ParserInput) :: ParseResult{<:Command}
    commands = OrParser{Command}([Is{ShowCurrentPuzzle}("!visa"), Is{NewGameAction}("!nytt"), GuessParser()])
    commands(input)
end


end # module Parsers