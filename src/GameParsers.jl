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

module GameParsers

using Nona.Parsers
using Nona.Games
using Nona.Games.Hamming
using Nona.Games.HammingAccessories
using Nona.Games.Niancat
using Nona.REPLCommands

const spacesP = manyC(spaceP)

const commandChar = '!'
const commandMarkerP = charC(commandChar)
const showCurrentPuzzleP = symbolC("visa") |> To{ShowCurrentPuzzle}(_ -> ShowCurrentPuzzle())
const newGameP = symbolC("nytt") |> To{NewGameAction}(x -> NewGameAction())

# TODO Do not hard code these game types.
const games = Dict{String, Type{<:Game}}("Hamming" => HammingGame, "Niancat" => NiancatGame)
const gamesymbolP = symbolC("Hamming") | symbolC("Niancat")
const gametypeP = gamesymbolP |> To{Game}(gamename -> games[gamename])

const newGameTypeP = (ignoreC(symbolC("nytt")) >> ignoreC(spacesP) >> gametypeP) |> To{NewGameTypeAction}(gametype -> NewGameTypeAction(gametype))
const switchGameP = (ignoreC(symbolC("spel")) >> ignoreC(spacesP) >> gametypeP) |> To{SwitchGameAction}(gametype -> SwitchGameAction(gametype))

const guessTokenP = (notC(commandChar) >> tokenP) |> To{String}(join)
const guessP = guessTokenP |> To{Guess}()

const gameCommandsP = showCurrentPuzzleP | switchGameP | newGameTypeP | newGameP
const gameCommandP = ignoreC(commandMarkerP) >> gameCommandsP

const showGuessP = symbolC("gissningar") |> To{ShowGuesses}(x -> ShowGuesses())
const accessoryCommandsP = showGuessP
const accessoryCommandP = ignoreC(commandMarkerP) >> accessoryCommandsP

const afterP = spacesP >> eofP
const beforeP = spacesP
const commandP = ignoreC(beforeP) >> (gameCommandP | accessoryCommandP | guessP) >> ignoreC(afterP)

end