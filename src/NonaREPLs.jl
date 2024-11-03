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

using Nona.Niancat

import Nona.Niancat: publish!

export FileDictionary
export NiancatREPL
export guess, start, userinput!
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


# ConsolePublisher prints all game events to the console.
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
    println(p.io, response.puzzle)
end

# Since the REPL is a single-user game, there is no need to distinguish
# between players. Thus, this is an empty implementation of the `User`
# abstract type.
struct ThisUser <: User end

#
# The REPL has two modes:
# - Game mode: Entering guesses
# - Command mode: Start new games, run game specific commands
#

const GameModeIndex = 1
const CommandModeIndex = 2

abstract type REPLMode end

struct GameMode <: REPLMode
    io::IO

    GameMode(io::IO) = new(io)
end
prompt(p::GameMode) = print(p.io, "Niancat> ")

function userinput!(::GameMode, text::String, game::NiancatGame)
    guess = Guess(Word(text))
    user = ThisUser()
    gameaction!(game, user, guess)
end

struct CommandMode <: REPLMode
    io::IO

    CommandMode(io::IO) = new(io)
end
prompt(p::CommandMode) = print(p.io, "Niancat# ")

function userinput!(::CommandMode, ::String, game::NiancatGame)
    command = ShowCurrentPuzzle()
    user = ThisUser()
    gameaction!(game, user, command)
end

#
# NonaREPL is the REPL for the games (currently only Niancat)
#

mutable struct NonaREPL
    publisher::ConsolePublisher
    modes::Tuple{GameMode, CommandMode}
    game::NiancatGame
    currentmode::Int

    function NonaREPL(dictionary::Dictionary; io::IO = stdout)
        publisher = ConsolePublisher(io)
        gamemode = GameMode(io)
        commandmode = CommandMode(io)

        puzzle = generatepuzzle(dictionary)
        game = NiancatGame(puzzle, publisher, dictionary)

        new(publisher, (gamemode, commandmode), game, GameModeIndex)
    end

    function NonaREPL(gamefactory::Function; io::IO = stdout)
        publisher = ConsolePublisher(io)
        gamemode = GameMode(io)
        commandmode = CommandMode(io)

        # The gamefactory is a method (::Publisher) -> Game
        game = gamefactory(publisher)

        new(publisher, (gamemode, commandmode), game, GameModeIndex)
    end
end

function prompt(game::NonaREPL)
    prompt(game.modes[game.currentmode])
end

function start(nona::NonaREPL)
    # Show the puzzle at game start
    user = ThisUser()
    command = ShowCurrentPuzzle()
    gameaction!(nona.game, user, command)

    # Start off by showing the prompt, where
    # the user will input new commands.
    prompt(nona)
end

function userinput!(nona::NonaREPL, text::String)
    if text == "#"
        nona.currentmode = CommandModeIndex
        prompt(nona)
    else
        userinput!(nona.modes[nona.currentmode], text, nona.game)
        # Show a new prompt.
        prompt(nona)
    end
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

Run a REPL in a loop until the user exits.
"""
function run(dictionary::Dictionary, io::IO = stdout)
    game = newgame(dictionary; io=io)

    while true
        text = readline(io)
        userinput!(game, text)
    end
end

end # module NonaREPLs
