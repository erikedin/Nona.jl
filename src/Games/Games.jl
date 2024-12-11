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

export Player, Response, Publisher, DelegationPublisher, register!
export Dictionary
export Command, GameCommand, Game, gameaction!, gamename
export Word
export Guess, ShowCurrentPuzzle, ShowSolutions
export Accessory

abstract type Player end
# Response is an abstract type for all messages sent to the players from the game.
abstract type Response end

# Command is an abstract type for all commands entered by the players.
# This is either a command for the specific word game, or a command to the game wrapper,
# to switch game types for instance.
abstract type Command end

# GameCommands are commands sent to the specific games, as opposed to commands handled
# by the REPL in the case of NonaREPL.
abstract type GameCommand <: Command end

# Game is the abstract type for all specific word games, such as NiancatGame or HammingGame.
abstract type Game end
gameaction!(game::Game, ::Player, command::GameCommand) = @error("Implement gameaction! for command $(command) in game $(game)")

# Accessory is an abstract type for keeping track of game related data.
abstract type Accessory{G <: Game} end

"""
    gamename(::Game) :: String

The name of the game. Implemented by each game type.
Example: Niancat, Hamming
"""
function gamename(::Game) :: String
    @error("Implement gamename(::Game)")
end

# Publisher{G} is for publishing responses to the players, from game G.
abstract type Publisher{G <: Game} end
publish!(publisher::Publisher{G}, response::Response) where {G <: Game} = @error("Implement Publisher.publish! for publisher $(publisher) and response $(response)")

#
# DelegationPublisher sends events to accessories as well as the final publisher.
#

struct DelegationPublisher{G} <: Publisher{G}
    publisher::Publisher{G}
end

function publish!(delegation::DelegationPublisher{G}, response::Response) where {G}
    publish!(delegation.publisher, response)
end

function register!(delegation::DelegationPublisher{G}, accessory::Accessory{G}) where {G}
end

#
# Word
#

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

#
# Dictionary
#

abstract type Dictionary end
Base.in(word::Word, dictionary::Dictionary) = @error("Implement Base.in(::WOrd, ::$(typeof(dictionary)))")

#
# Universal commands
# These commands should work for every game type.
#

struct Guess <: GameCommand
    word::Word
end

struct ShowCurrentPuzzle  <: GameCommand end
struct ShowSolutions <: GameCommand end

#
# Game modules
#

include("Niancat.jl")
include("Hamming.jl")
include("HammingAccessories.jl")

end # module Games