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

module Hamming

using Nona.Games
import Nona.Games: gameaction!, gamename, publish!

export HammingGame

#
# Responses
#

struct Correct <: Response
    player::Player
    guess::Guess
end

struct Incorrect <: Response
    player::Player
    guess::Guess
    hammingdistance::Int
end

struct IncorrectLength <: Response
    player::Player
    guess::Guess
    wordlength::Int
end

struct NotInDictionary <: Response
    player::Player
    word::Word
end

struct CurrentPuzzle <: Response
    player::Player
    puzzlelength::Int
end

struct RevealSolution <: Response
    player::Player
    word::Word
end

#
# Game
#

function generatepuzzle(dictionary::Dictionary) :: Word
    shortword = x -> length(x) <= 9
    reasonablyshortwords = collect(dictionary) |> filter(shortword)
    rand(reasonablyshortwords)
end

struct HammingGame <: Game
    publisher::Publisher{HammingGame}
    dictionary::Dictionary
    puzzle::Word

    HammingGame(publisher::Publisher{HammingGame}, dictionary::Dictionary, puzzle::Word) = new(publisher, dictionary, puzzle)
    HammingGame(publisher::Publisher{HammingGame}, dictionary::Dictionary) = new(publisher, dictionary, generatepuzzle(dictionary))
end

gamename(::HammingGame) = "Hamming"

distancepair((x, y)) = if x == y 0 else 1 end

function hammingdistance(a::Word, b::Word) :: Int
    pairs = zip(a, b)
    mapreduce(distancepair, +, pairs; init = 0)
end

function gameaction!(game::HammingGame, player::Player, guess::Guess)
    response = if guess.word == game.puzzle
        Correct(player, guess)
    elseif length(guess.word) != length(game.puzzle)
        IncorrectLength(player, guess, length(game.puzzle))
    elseif !(guess.word in game.dictionary)
        NotInDictionary(player, guess.word)
    else
        d = hammingdistance(game.puzzle, guess.word)
        Incorrect(player, guess, d)
    end
    publish!(game.publisher, response)
end

function gameaction!(game::HammingGame, player::Player, ::ShowCurrentPuzzle)
    publish!(game.publisher, CurrentPuzzle(player, length(game.puzzle)))
end

function gameaction!(game::HammingGame, player::Player, ::ShowSolutions)
    publish!(game.publisher, RevealSolution(player, game.puzzle))
end

end