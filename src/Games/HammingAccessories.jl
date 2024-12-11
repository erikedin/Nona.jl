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
    BestHammingGuess,
    ShowBestGuesses,
    NoBestGuesses

struct BestHammingGuess <: Accessory{HammingGame}
    publisher::Publisher{HammingGame}
    words::Vector{Word}

    BestHammingGuess(publisher::Publisher{HammingGame}) = new(publisher, Word[])
end

struct ShowBestGuesses <: GameCommand end

struct NoBestGuesses <: Response
    player::Player
end

struct BestGuesses <: Response
    player::Player
    distance::Int
    words::Vector{Word}
end

function gameaction!(best::BestHammingGuess, player::Player, ::ShowBestGuesses)
    if isempty(best.words)
        publish!(best.publisher, NoBestGuesses(player))
    else
        publish!(best.publisher, BestGuesses(player, 5, best.words))
    end
end

function publish!(best::BestHammingGuess, incorrect::Incorrect)
    push!(best.words, incorrect.guess.word)
end
publish!(::BestHammingGuess, ::Response) = nothing

end # module HammingAccessories