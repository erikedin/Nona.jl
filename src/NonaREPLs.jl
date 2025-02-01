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
using Nona.Games.Accessories
using Nona.Games.States
using Nona.Games.Niancat
using Nona.Games.Hamming
using Nona.Games.HammingAccessories
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
Base.in(word::Word, fd::FileDictionary) = word in fd.words


#
# ConsolePublisher prints all game Niancat events to the console.
#

struct ConsolePublisher <: Publisher{NiancatGame}
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

#
# HammingConsolePublisher prints HammingGame events to the console.
#

struct HammingConsolePublisher <: Publisher{HammingGame}
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

function publish!(p::HammingConsolePublisher, response::Hamming.NotInDictionary)
    println(p.io, "Ordet $(response.word) finns inte i ordlistan.")
end

function publish!(p::HammingConsolePublisher, response::Hamming.CurrentPuzzle)
    println(p.io, "Pusslet är $(response.puzzlelength) tecken långt.")
end

function publish!(p::HammingConsolePublisher, response::Hamming.RevealSolution)
    println(p.io, "$(response.word)")
end

function publish!(p::HammingConsolePublisher, response::HammingAccessories.NoGuesses)
    println(p.io, "Inga gissningar än.")
end

function publish!(p::HammingConsolePublisher, response::HammingAccessories.Guesses)
    for guess in response.guesses
        println(p.io, "$(guess.distance)")
        guesses = ["  $(word)"
                    for word in guessesatdistance(guess)]
        for word in guesses
            println(p.io, word)
        end
        println(p.io, "")
    end
end

# Since the REPL is a single-player game, there is no need to distinguish
# between players. Thus, this is an empty implementation of the `Player`
# abstract type.
struct ThisPlayer <: Player end

#
# NonaREPL is the REPL for the games.
#

# loadorcreatestate tries to load state from disk, and if the state can't be found,
# then a new state is created.
function loadorcreatestate(::Type{T}, dictionary::Dictionary) where {T}
    try
        loadstate(T)
    catch ex
        # SystemError is thrown if the file could not be read.
        # Create a new state, because this means a previous game has not been started.
        if typeof(ex) != SystemError
            rethrow()
        end
        newstate = T(dictionary)
        savestate(newstate)
        newstate
    end
end


function createnewgame(::Type{NiancatGame}, dictionary::Dictionary, io::IO)
    publisher = ConsolePublisher(io)
    NiancatGame(publisher, dictionary)
end

function switchgame(::Type{NiancatGame}, dictionary::Dictionary, io::IO)
    publisher = ConsolePublisher(io)
    # TODO: Implement state for NiancatGame.
    NiancatGame(publisher, dictionary)
end

# creategame creates a HammingGame with a given state.
# This is called from createnewgame with a newly created state (or supplied from tests).
# It's called from switchgame with state that is either read from disk or newly created.
function creategame(::Type{HammingGame}, dictionary::Dictionary, io::IO, state::HammingGameState, accessorystate::HammingGuessState)
    publisher = HammingConsolePublisher(io)
    accessory = HammingGuess(publisher, accessorystate)
    delegation = DelegationPublisher(publisher, accessory)
    game = HammingGame(delegation, dictionary, state)
    savestate(gamestate(game))
    GameWithAccessories(game, accessory)
end

function createnewgame(::Type{HammingGame}, dictionary::Dictionary, io::IO; providedstate = nothing)
    # This allows tests to create games with specific puzzles.
    state = if providedstate === nothing
        HammingGameState(dictionary)
    else
        providedstate
    end
    creategame(HammingGame, dictionary, io, state, HammingGuessState())
end

function switchgame(::Type{HammingGame}, dictionary::Dictionary, io::IO)
    state = loadorcreatestate(Hamming.HammingGameState, dictionary)
    guessstate = loadorcreatestate(HammingGuessState, dictionary)
    creategame(HammingGame, dictionary, io, state, guessstate)
end

# NonaREPL holds the game, and responds to player input by sending the game actions.
mutable struct NonaREPL
    io::IO
    dictionary::Dictionary
    game::Game

    """
        NonaREPL(dictionary::Dictionary; io::IO = stdout)

    Create a new game of the given game type.
    """
    function NonaREPL(gametype::Type{<:Game}, dictionary::Dictionary; io::IO = stdout)
        game = switchgame(gametype, dictionary, io)

        new(io, dictionary, game)
    end

    # Mainly for testing purposes, to provide an already constructed game.
    function NonaREPL(gamefactory::Function, dictionary::Dictionary; io::IO = stdout)
        # The gamefactory is a method (::IO) -> Game
        game = gamefactory(io)

        new(io, dictionary, game)
    end
end

prompt(nona::NonaREPL) = print(nona.io, "$(gamename(nona.game))> ")

"""
    showpuzzle(nona::NonaREPL)

Sends the game a command to show the current puzzle to the user.
"""
function showpuzzle(nona::NonaREPL)
    player = ThisPlayer()
    command = ShowCurrentPuzzle()
    gameaction!(nona.game, player, command)
end

"""
    showsolutions(nona::NonaREPL)

Asks the game to show the solutions to the current game.
This is useful when a new game is started, and the solutions to the old
game should be revealed.
"""
function showsolutions(nona::NonaREPL)
    player = ThisPlayer()
    command = ShowSolutions()
    gameaction!(nona.game, player, command)
end

"""
    doaction(nona::NonaREPL, ::NewGameAction)

Start a new game of the same type as the current game.
"""
function doaction(nona::NonaREPL, ::NewGameAction)
    showsolutions(nona)
    nona.game = createnewgame(gametype(nona.game), nona.dictionary, nona.io)
    showpuzzle(nona)
end

"""
    doaction(nona::NonaREPL, newgame::NewGameTypeAction)

Start a new game of the given type.
"""
function doaction(nona::NonaREPL, newgame::NewGameTypeAction)
    showsolutions(nona)
    nona.game = createnewgame(newgame.gametype, nona.dictionary, nona.io)
    showpuzzle(nona)
end

"""
    doaction(nona::NonaREPL, switchgame::SwitchGameAction)

Continue an existing game, or start a new game of the given type.
"""
function doaction(nona::NonaREPL, action::SwitchGameAction)
    showsolutions(nona)
    nona.game = switchgame(action.gametype, nona.dictionary, nona.io)
    showpuzzle(nona)
end

function doaction(::NonaREPL, ::ExitAction)
    exit(0)
end

"""
    playerinput!(nona::NonaREPL, text::String, ::BadParse, game::Game)

Called when the command parser fails to parse a command successfully.
"""
function playerinput!(nona::NonaREPL, text::String, ::BadParse, game::Game)
    println(nona.io, "Okänt kommando: $(text)")
    []
end

"""
    playerinput!(::NonaREPL, ::String, command::GameCommand, game::Game)

Called when a GameCommand is parsed. That is a command that goes to the game,
as opposed to being handled by the REPL here.
"""
function playerinput!(nona::NonaREPL, ::String, command::GameCommand, game::Game)
    player = ThisPlayer()
    gameaction!(game, player, command)
    savestate(nona.game)
    []
end

"""
    playerinput!(::NonaREPL, ::String, command::REPLCommand, game::Game)

Called when a REPLCOmmand is parsed. These commands are handled here, and not
by the specific game.
Returns a list with that single command, as the REPL command is handled by the
caller of this function.
"""
function playerinput!(::NonaREPL, ::String, command::REPLCommand, game::Game)
    [command]
end

"""
    playerinput!(nona::NonaREPL, text::String, game::Game)

Parse a line of input as a command.
The parser will create a
- Guess, or
- Game command, to be sent to the specific game being played, or
- REPL command, a command handled by the REPL itself (such as starting a new game)
"""
function playerinput!(nona::NonaREPL, text::String, game::Game)
    input = ParserInput(text)
    (_rest, command) = GameParsers.commandP(input)
    playerinput!(nona, text, command, game)
end

"""
    playerinput!(nona::NonaREPL, text::String)

Handle player input. This results in a list of REPL actions to perform, such as
starting a new game or exiting.
"""
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
    start(nona::NonaREPL)

Start the game right after NonaREPL has been created.
"""
function start(nona::NonaREPL)
    # Show the puzzle at game start
    showpuzzle(nona)

    # Start off by showing the prompt, where
    # the player will input new commands.
    prompt(nona)
end

"""
    newgame(dictionary::Dictionary; io::IO = stdout)

Create a new NonaREPL game with a randomly generated puzzle.
"""
function newgame(defaultgametype::Type{<:Game}, dictionary::Dictionary; io::IO = stdout)
    nona = NonaREPL(defaultgametype, dictionary; io=io)
    start(nona)
    nona
end

"""
    run(dictionary::Dictionary, io::IO = stdout)

Run a REPL in a loop until the player exits.
"""
function run(dictionary::Dictionary, defaultgamename::String, io::IO = stdout)
    defaultgametype = try
        GameParsers.games[defaultgamename]
    catch
        println("Unrecognized default game '$(defaultgamename)'. Defaulting to Niancat.")
        NiancatGame
    end

    nona = newgame(defaultgametype, dictionary; io=io)

    while true
        text = readline(io)
        if !isreadable(io)
            exit(0)
        end
        playerinput!(nona, text)
    end
end

end # module NonaREPLs
