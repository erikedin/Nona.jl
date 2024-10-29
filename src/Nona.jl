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
export NickUser
export Guess, Response, Incorrect, Correct
export NiancatPublisher
export gameaction!, publish!
export Dictionary

abstract type Response end

abstract type NiancatPublisher end

publish!(::NiancatPublisher, ::Response) =  @error("Implement me")

struct Dictionary
    words::Set{String}

    Dictionary(words::AbstractVector{String}) = new(Set{String}(words))
end

sortword(word::String) = String(sort([c for c in word]))

isanagram(a::String, b::String) = sortword(a) == sortword(b)

struct NickUser
    nick::String
end

struct NiancatGame
    puzzle::String
    publisher::NiancatPublisher
    solutions::Vector{String}
end

function NiancatGame(puzzle::String, publisher::NiancatPublisher, dictionary::Dictionary)
    solutions = String[
        word
        for word in dictionary.words
        if isanagram(puzzle, word)
    ]
    NiancatGame(puzzle, publisher, solutions)
end

struct Guess
    word::String
end

struct Incorrect <: Response
    user::NickUser
    guess::Guess
end

struct Correct <: Response
    user::NickUser
    guess::Guess
end

function gameaction!(game::NiancatGame, user::NickUser, guess::Guess)
    response = if guess.word in game.solutions
        Correct(user, guess)
    else
        Incorrect(user, guess)
    end

    publish!(game.publisher, response)
end

end # module Nona
