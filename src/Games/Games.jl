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
#

module Games

import Base: convert, hash, iterate, length, isless, show, sort

export Player, Response, Publisher
export Dictionary, isindictionary
export Command, GameCommand, Game, gameaction!, gamename
export Word
export Guess, ShowCurrentPuzzle, ShowSolutions

abstract type Player end
abstract type Response end

abstract type Publisher{T} end
publish!(publisher::Publisher{T}, response::Response) where {T} = @error("Implement Publisher.publish! for publisher $(publisher) and response $(response)")

abstract type Command end
abstract type GameCommand <: Command end
abstract type Game end
gameaction!(game::Game, ::Player, command::GameCommand) = @error("Implement gameaction! for command $(command) in game $(game)")
function gamename(::Game) :: String
    @error("Implement gamename(::Game)")
end

# Word is a normalized string that is case-insensitive, and
# ignores some diacritics, in a Swedish-specific manner.
struct Word
    letters::String

    Word(s::AbstractString) = new(uppercase(s))
end

iterate(word::Word) = iterate(word.letters)
iterate(word::Word, state) = iterate(word.letters, state)
length(word::Word) = length(word.letters)
convert(::Type{Word}, s::String) = Word(s)
Base.:(==)(a::Word, b::Word) = a.letters == b.letters
hash(w::Word, h::UInt) = hash(w.letters, h)
isless(a::Word, b::Word) = isless(a.letters, b.letters)
show(io::IO, w::Word) = print(io, w.letters)
function sort(
    w::Word;
    alg::Base.Sort.Algorithm=Base.Sort.QuickSort,
    lt=isless,
    by=identity,
    rev::Bool=false,
    order::Base.Order.Ordering=Base.Order.Forward)

    Word(String(
        sort([c for c in w.letters];
             alg=alg, lt=lt, by=by, rev=rev, order=order)
    ))
end
Base.getindex(w::Word, index) = getindex(w.letters, index)
Base.lastindex(w::Word) = lastindex(w.letters)

abstract type Dictionary end
isindictionary(dictionary::Dictionary, word::Word) = @error("Implement isindictionary(::$(typeof(dictionary)), $(typeof(word)))")

# Guess is a command game command to guess a word.
struct Guess <: GameCommand
    word::Word
end

struct ShowCurrentPuzzle  <: GameCommand end
struct ShowSolutions <: GameCommand end

include("Niancat.jl")
include("Hamming.jl")

end # module Games