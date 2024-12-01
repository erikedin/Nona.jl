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

module NonaREPLs

using Nona.Games
using Nona.Games.Niancat
using Nona.Games.Hamming
using Nona.REPLCommands
using Nona.GameParsers
using Nona.REPLCommands
using Nona.Parsers

import Nona.Games.Niancat: publish!

export FileDictionary
export NiancatREPL
export guess, start, playerinput!
export NonaREPL

# FileDictionary reads words from a file, where each word is on its own line.
struct FileDictionary <: Dictionary
    words::Set{Word}

    function FileDictionary(path::AbstractString)
        words = open(path, "r") do io
            readlines(io, keep=false)
        end
        new(Set{Word}(Word[Word(s) for s in words]))
    end
end

Base.iterate(fd::FileDictionary) = iterate(fd.words)
Base.iterate(fd::FileDictionary, state) = iterate(fd.words, state)
Base.length(fd::FileDictionary) = length(fd.words)


# ConsolePublisher prints all game Niancat events to the console.
struct ConsolePublisher <: NiancatPublisher
    io::IO
end

publish!(p::ConsolePublisher, response::Correct) = println(p.io, "$(response.guess.word) är rätt!")

function publish!(p::ConsolePublisher, response::Incorrect)
    println(p.io, "$(response.guess.word) är inte korrekt.")

    if response.lettercorrection.extras != Word("")
        println(p.io, "För många: $(response.lettercorrection.extras)")
    end
    if response.lettercorrection.missings != Word("")
        println(p.io, "För få   : $(response.lettercorrection.missings)")
    end
end

function publish!(p::ConsolePublisher, response::CurrentPuzzle)
    println(p.io, "Pussel: $(response.puzzle)")

    if response.n_solutions > 1
        println(p.io, "Pusslet har $(response.n_solutions) lösningar!")
    end
end

function publish!(p::ConsolePublisher, response::Solutions)
    println(p.io, "Pusslet hade lösningar")
    solutions = ["  $(solution)"
                 for solution in response.solutions]
    for solution in solutions
        println(p.io, solution)
    end
    println(p.io, "")
end

struct HammingConsolePublisher <: Publisher
    io::IO
end

function publish!(p::HammingConsolePublisher, response::Hamming.Correct)
    println(p.io, "$(response.guess.word) är rätt!")
end

function publish!(p::HammingConsolePublisher, response::Hamming.Incorrect)
    println(p.io, "$(response.hammingdistance)")
end

function publish!(p::HammingConsolePublisher, response::Hamming.IncorrectLength)
    println(p.io, "Ordet måste vara $(response.wordlength) tecken långt.")
end

function publish!(p::HammingConsolePublisher, response::Hamming.CurrentPuzzle)
    println(p.io, "Pusslet är $(response.puzzlelength) tecken långt.")
end

# Since the REPL is a single-player game, there is no need to distinguish
# between players. Thus, this is an empty implementation of the `Player`
# abstract type.
struct ThisPlayer <: Player end

#
# NonaREPL is the REPL for the games (currently only Niancat)
#

function createnewgame(::Type{NiancatGame}, dictionary::Dictionary, io::IO)
    publisher = ConsolePublisher(io)
    NiancatGame(publisher, dictionary)
end

function createnewgame(::Type{HammingGame}, dictionary::Dictionary, io::IO)
    publisher = HammingConsolePublisher(io)
    HammingGame(publisher, dictionary)
end

mutable struct NonaREPL
    io::IO
    dictionary::Dictionary
    game::Game

    function NonaREPL(dictionary::Dictionary; io::IO = stdout)
        game = createnewgame(NiancatGame, dictionary, io)

        new(io, dictionary, game)
    end

    function NonaREPL(gamefactory::Function, dictionary::Dictionary; io::IO = stdout)
        # The gamefactory is a method (::IO) -> Game
        game = gamefactory(io)

        new(io, dictionary, game)
    end
end

prompt(nona::NonaREPL) = print(nona.io, "$(gamename(nona.game))> ")

function showpuzzle(nona::NonaREPL)
    player = ThisPlayer()
    command = ShowCurrentPuzzle()
    gameaction!(nona.game, player, command)
end

function showsolutions(nona::NonaREPL)
    player = ThisPlayer()
    command = ShowSolutions()
    gameaction!(nona.game, player, command)
end

function start(nona::NonaREPL)
    # Show the puzzle at game start
    showpuzzle(nona)

    # Start off by showing the prompt, where
    # the player will input new commands.
    prompt(nona)
end

function doaction(nona::NonaREPL, ::NewGameAction)
    showsolutions(nona)
    nona.game = createnewgame(typeof(nona.game), nona.dictionary, nona.io)
    showpuzzle(nona)
end

function doaction(nona::NonaREPL, newgame::NewGameTypeAction)
    showsolutions(nona)
    nona.game = createnewgame(newgame.gametype, nona.dictionary, nona.io)
    showpuzzle(nona)
end

function doaction(::NonaREPL, ::ExitAction)
    exit(0)
end

function playerinput!(nona::NonaREPL, text::String, ::BadParse, game::Game)
    println(nona.io, "Okänt kommando: $(text)")
    []
end
function playerinput!(::NonaREPL, ::String, command::GameCommand, game::Game)
    player = ThisPlayer()
    gameaction!(game, player, command)
    []
end

function playerinput!(::NonaREPL, ::String, command::REPLCommand, game::Game)
    [command]
end

function playerinput!(nona::NonaREPL, text::String, game::Game)
    input = ParserInput(text)
    (_rest, command) = GameParsers.commandP(input)
    playerinput!(nona, text, command, game)
end


function playerinput!(nona::NonaREPL, text::String)
    # The player input will result in possibly something published,
    # but also some actions for NonaREPL to take.
    # Examples: Go back to game mode. Start a new game.
    actions = playerinput!(nona, text, nona.game)
    for action in actions
        doaction(nona, action)
    end

    # Show a new prompt.
    prompt(nona)
end

#
# Generate a new game
#

"""
    newgame(dictionary::Dictionary; io::IO = stdout)

Create a new NonaREPL game with a randomly generated puzzle.
"""
function newgame(dictionary::Dictionary; io::IO = stdout)
    game = NonaREPL(dictionary; io=io)
    start(game)
    game
end

"""
    run(dictionary::Dictionary, io::IO = stdout)

Run a REPL in a loop until the player exits.
"""
function run(dictionary::Dictionary, io::IO = stdout)
    game = newgame(dictionary; io=io)

    while true
        text = readline(io)
        if !isreadable(io)
            exit(0)
        end
        playerinput!(game, text)
    end
end

end # module NonaREPLs
