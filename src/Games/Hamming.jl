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
import Nona.Games.States: statename, gamestate
using Base64

export HammingGame, HammingGameState

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

struct HammingGameState
    puzzle::Word
end

struct HammingGame <: Game
    publisher::Publisher{HammingGame}
    dictionary::Dictionary
    state::HammingGameState

    HammingGame(publisher::Publisher{HammingGame}, dictionary::Dictionary, puzzle::Word) = new(publisher, dictionary, HammingGameState(puzzle))
    HammingGame(publisher::Publisher{HammingGame}, dictionary::Dictionary, state::HammingGameState) = new(publisher, dictionary, state)
    # TODO: This constructor could be removed now that Nona can send in a state object every time.
    HammingGame(publisher::Publisher{HammingGame}, dictionary::Dictionary) = new(publisher, dictionary, HammingGameState(generatepuzzle(dictionary)))
end

gamename(::HammingGame) = "Hamming"

distancepair((x, y)) = if x == y 0 else 1 end

function hammingdistance(a::Word, b::Word) :: Int
    pairs = zip(a, b)
    mapreduce(distancepair, +, pairs; init = 0)
end

function gameaction!(game::HammingGame, player::Player, guess::Guess)
    response = if guess.word == game.state.puzzle
        Correct(player, guess)
    elseif length(guess.word) != length(game.state.puzzle)
        IncorrectLength(player, guess, length(game.state.puzzle))
    elseif !(guess.word in game.dictionary)
        NotInDictionary(player, guess.word)
    else
        d = hammingdistance(game.state.puzzle, guess.word)
        Incorrect(player, guess, d)
    end
    publish!(game.publisher, response)
end

function gameaction!(game::HammingGame, player::Player, ::ShowCurrentPuzzle)
    publish!(game.publisher, CurrentPuzzle(player, length(game.state.puzzle)))
end

function gameaction!(game::HammingGame, player::Player, ::ShowSolutions)
    publish!(game.publisher, RevealSolution(player, game.state.puzzle))
end

#
# Code for reading/writing state.
#

# statename is used in the filename for the state when saved to disk.
statename(::Type{HammingGameState}) = "Hamming"

gamestate(game::HammingGame) = game.state

# HammingGameState constructor. The data has been read from disk.
# The data is Base64 encoded (see Base.convert below), so it needs to be
# decoded here.
function HammingGameState(statedata::String)
    puzzle = String(Base64.base64decode(statedata))
    HammingGameState(Word(puzzle))
end

# HammingGameState constructor. This is a request to create a brand new state.
function HammingGameState(dictionary::Dictionary)
    HammingGameState(generatepuzzle(dictionary))
end

# Convert the state to a string, to be saved to disk.
# This is base64 encoded to prevent any user from accidentally revealing the puzzle
# by looking in the state file.
function Base.convert(::Type{String}, state::HammingGameState)
    Base64.base64encode(string(state.puzzle))
end

end