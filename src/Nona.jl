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

module Nona

export NiancatGame
export User
export Guess, Response, Incorrect, Correct
export NiancatPublisher
export gameaction!, publish!
export Dictionary
export SolutionIndex, SingleSolutionIndex, MultipleSolutionIndex
export Word

import Base: convert, hash, iterate, length, isless, show

struct Word
    letters::String
end

iterate(word::Word) = iterate(word.letters)
iterate(word::Word, state) = iterate(word.letters, state)
length(word::Word) = length(word.letters)
convert(::Type{Word}, s::String) = Word(s)
Base.:(==)(a::Word, b::Word) = a.letters == b.letters
hash(w::Word, h::UInt) = hash(w.letters, h)
isless(a::Word, b::Word) = isless(a.letters, b.letters)
show(io::IO, w::Word) = print(io, w.letters)

abstract type Response end

abstract type NiancatPublisher end
publish!(::NiancatPublisher, ::Response) =  @error("Implement me")

abstract type Dictionary end

sortword(word::Word) = Word(String(sort([c for c in word])))

isanagram(a::Word, b::Word) = sortword(a) == sortword(b)

abstract type User end

struct NiancatGame
    puzzle::Word
    publisher::NiancatPublisher
    solutions::Vector{Word}

    function NiancatGame(puzzle::Word, publisher::NiancatPublisher, dictionary::Dictionary)
        solutions = Word[
            word
            for word in dictionary
            if isanagram(puzzle, word)
        ]
        sortedsolutions = sort(solutions)
        new(puzzle, publisher, sortedsolutions)
    end
end


struct Guess
    word::Word
end

struct Incorrect <: Response
    user::User
    guess::Guess
end

abstract type SolutionIndex end

struct MultipleSolutionIndex <: SolutionIndex
    index::Int

    MultipleSolutionIndex() = new(0)
    MultipleSolutionIndex(index::Int) = new(index)
end

struct SingleSolutionIndex <: SolutionIndex end

struct Correct <: Response
    user::User
    guess::Guess
    solutionindex::SolutionIndex

    Correct(user::User, guess::Guess, index::SolutionIndex = SingleSolutionIndex()) = new(user, guess, index)
end

function gameaction!(game::NiancatGame, user::User, guess::Guess)
    response = if guess.word in game.solutions
        solutionindex = if length(game.solutions) == 1
            SingleSolutionIndex()
        else
            index = findfirst(item -> item == guess.word, game.solutions)
            MultipleSolutionIndex(index)
        end

        Correct(user, guess, solutionindex)
    else
        Incorrect(user, guess)
    end

    publish!(game.publisher, response)
end

include("NonaREPL.jl")

end # module Nona
