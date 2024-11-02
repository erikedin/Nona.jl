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

module Niancat

export NiancatGame
export User
export Guess, Response, Incorrect, Correct
export NiancatPublisher
export gameaction!, publish!
export generatepuzzle
export Dictionary
export SolutionIndex, SingleSolutionIndex, MultipleSolutionIndex
export Word

import Base: convert, hash, iterate, length, isless, show, sort

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

abstract type Response end

abstract type NiancatPublisher end
publish!(::NiancatPublisher, ::Response) =  @error("Implement me")

abstract type Dictionary end

isanagram(a::Word, b::Word) = sort(a) == sort(b)

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

function generatepuzzle(dictionary::Dictionary) :: Word
    nineletterword = w -> length(w) == 9
    nineletterwords = collect(dictionary) |> filter(nineletterword)
    chosenword = rand(nineletterwords)
    puzzle = sort(chosenword)

    puzzle
end

end # module Niancat