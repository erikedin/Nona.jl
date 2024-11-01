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

using Nona

export FileDictionary
export NiancatREPL
export guess

struct FileDictionary <: Dictionary
    words::Set{String}

    function FileDictionary(path::String)
        words = open(path, "r") do io
            readlines(io, keep=false)
        end
        new(Set{String}(words))
    end
end

Base.iterate(fd::FileDictionary) = iterate(fd.words)
Base.iterate(fd::FileDictionary, state) = iterate(fd.words, state)
Base.length(fd::FileDictionary) = length(fd.words)


struct ConsolePublisher <: NiancatPublisher
    io::IO
end
Nona.publish!(p::ConsolePublisher, response::Correct) = println(p.io, "$(response.guess.word) är rätt!")
Nona.publish!(p::ConsolePublisher, response::Incorrect) = println(p.io, "$(response.guess.word) är inte korrekt.")

struct ThisUser <: User end

struct NiancatREPL
    publisher::ConsolePublisher
    game::NiancatGame

    function NiancatREPL(io::IO, puzzle::String, dictionary::Dictionary)
        publisher = ConsolePublisher(io)
        game = NiancatGame(puzzle, publisher, dictionary)

        new(publisher, game)
    end
end

Base.show(io::IO, replgame::NiancatREPL) = println(io, "NiancatRepl($(replgame.game.puzzle))")

function guess(replgame::NiancatREPL, word::String)
    guess = Guess(word)
    user = ThisUser()
    gameaction!(replgame.game, user, guess)
end

#
# Generate a new game
#

function newgame(dictionary::Dictionary; io::IO = stdout)
    chosenword = rand(collect(dictionary))
    puzzle = Nona.sortword(chosenword)

    # TODO: Make this a publishable event
    println(io, puzzle)
    NiancatREPL(io, puzzle, dictionary)
end

end # module NonaREPL
