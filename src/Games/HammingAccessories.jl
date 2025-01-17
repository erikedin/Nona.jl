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

module HammingAccessories

using Nona.Games
using Nona.Games.Hamming
using Nona.Games.Hamming: Incorrect
import Nona.Games: gameaction!, publish!

export
    HammingGuess,
    ShowGuesses,
    NoGuesses

struct DistanceGuess
    distance::Int
    words::Vector{Word}

    DistanceGuess(n::Int) = new(n, Word[])
    DistanceGuess(n::Int, words::Vector{Word}) = new(n, words)
end

sortguesses(dg::DistanceGuess) = DistanceGuess(dg.distance, sort(dg.words))

struct AllGuesses
    guesses::Dict{Int, DistanceGuess}

    AllGuesses() = new(Dict{Int, Vector{Word}}())
end

function newguess!(g::AllGuesses, incorrect::Incorrect)
    distanceguess = get!(g.guesses, incorrect.hammingdistance, DistanceGuess(incorrect.hammingdistance))
    push!(distanceguess.words, incorrect.guess.word)
end

function guesses(g::AllGuesses) :: Vector{DistanceGuess}
    distanceguesses = collect(values(g.guesses))

    # Sort all words in alphabetical order in each DistanceGuess.
    alphabeticalguesses = [sortguesses(dg) for dg in distanceguesses]

    # Sort all DistanceGuesses in distance order, descending.
    # This ensures that the best guesses are at the bottom, where they
    # are most easily read.
    guesscomparison = (x, y) -> x.distance > y.distance
    sort(alphabeticalguesses; lt = guesscomparison)
end

hasguesses(g::AllGuesses) = !isempty(g.guesses)

struct HammingGuess <: Accessory{HammingGame}
    publisher::Publisher{HammingGame}
    guesses::AllGuesses

    HammingGuess(publisher::Publisher{HammingGame}) = new(publisher, AllGuesses())
end

struct ShowGuesses <: AccessoryCommand end

struct NoGuesses <: Response
    player::Player
end

struct Guesses <: Response
    player::Player
    guesses::Vector{DistanceGuess}
end

function gameaction!(best::HammingGuess, player::Player, ::ShowGuesses)
    if hasguesses(best.guesses)
        publish!(best.publisher, Guesses(player, guesses(best.guesses)))
    else
        publish!(best.publisher, NoGuesses(player))
    end
end

publish!(best::HammingGuess, incorrect::Incorrect) = newguess!(best.guesses, incorrect)
publish!(::HammingGuess, ::Response) = nothing

end # module HammingAccessories