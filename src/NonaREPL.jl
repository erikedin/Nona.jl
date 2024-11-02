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

module NonaREPL

using Nona.Niancat

import Nona.Niancat: publish!

export FileDictionary
export NiancatREPL
export guess, start, userinput!

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

struct PromptIO
    io::IO
end

# prompt shows a prompt for the user to input text.
prompt(p::PromptIO) = print(p.io, "> ")

struct NiancatREPL
    publisher::ConsolePublisher
    game::NiancatGame
    promptio::PromptIO

    function NiancatREPL(io::IO, puzzle::Word, dictionary::Dictionary)
        publisher = ConsolePublisher(io)
        game = NiancatGame(puzzle, publisher, dictionary)
        promptio = PromptIO(io)

        new(publisher, game, promptio)
    end
end

# Override show to avoid displaying the solutions.
Base.show(io::IO, replgame::NiancatREPL) = println(io, "NiancatRepl($(replgame.game.puzzle))")

"""
    guess(replgame::NiancatREPL, word::String)

The player guesses the word in `word` as the solution.
"""
function guess(replgame::NiancatREPL, word::String)
    guess = Guess(word)
    user = ThisUser()
    gameaction!(replgame.game, user, guess)
end

#
# REPL IO
#

prompt(game::NiancatREPL) = prompt(game.promptio)

"""
    start(game::NiancatREPL)

The game starts by showing the puzzle, then an input prompt.
"""
function start(game::NiancatREPL)
    # Show the puzzle at game start
    user = ThisUser()
    command = ShowCurrentPuzzle()
    gameaction!(game.game, user, command)

    # Start off by showing the prompt, where
    # the user will input new commands.
    prompt(game)
end

"""
    userinput!(game::NiancatREPL, text::String)

The user inputs `text` as the next command to the game.
"""
function userinput!(game::NiancatREPL, text::String)
    guess(game, text)
    prompt(game)
end

#
# Generate a new game
#

"""
    newgame(dictionary::Dictionary; io::IO = stdout)

Create a new NiancatREPL game with a randomly generated puzzle.
"""
function newgame(dictionary::Dictionary; io::IO = stdout)
    puzzle = generatepuzzle(dictionary)

    game = NiancatREPL(io, puzzle, dictionary)
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

end # module NonaREPL
