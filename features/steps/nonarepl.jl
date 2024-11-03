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

using Behavior
using Nona.Niancat
using Nona.NonaREPLs

@given("a NonaREPL game Niancat with puzzle {String}") do context, puzzle
    # Niancat takes a publisher in the constructor method, but that publisher
    # is created by NonaREPL, so we need to make a factory method.
    dictionary = context[:dictionary]
    io = IOBuffer()
    context[:io] = io

    niancatfactory = publisher -> NiancatGame(Word(puzzle), publisher, dictionary)

    nona = NonaREPL(niancatfactory; io=io)
    start(nona)

    context[:game] = nona
end

@when("NonaREPL is started") do context
    io = IOBuffer()
    context[:io] = io
    dictionary = context[:dictionary]

    nona = NonaREPL(dictionary; io=io)
    start(nona)

    context[:game] = nona
end

@when("the player presses \"#\"") do context
    game = context[:game]
    userinput!(game, "#")
end

@when("the player enters command mode") do context
    # Clear the current output. The reason is that we would like to check
    # that the puzzle has been printed some time after this, for instance.
    # However, the puzzle is printed at the start for Niancat. So we need
    # to clear it, so that we can check that it is really printed after this.
    io = context[:io]
    mark(io)

    game = context[:game]
    userinput!(game, "#")
end

@when("the player inputs \"{String}\"") do context, command
    game = context[:game]
    userinput!(game, command)
end