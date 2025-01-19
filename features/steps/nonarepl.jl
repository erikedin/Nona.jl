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
using Nona.Games.Niancat
using Nona.Games.States
using Nona.Games.HammingAccessories
using Nona.NonaREPLs

function clearoutput(context)
    # Clear the current output. The reason is that we would like to check
    # that the puzzle has been printed some time after this, for instance.
    # However, the puzzle is printed at the start for Niancat. So we need
    # to clear it, so that we can check that it is really printed after this.
    io = context[:io]
    mark(io)
end

@given("a NonaREPL game Niancat with puzzle {String}") do context, puzzle
    # We need to create a specific NiancatGame object, with a specific puzzle,
    # so we do that using this factory method. It replaces the `NonaREPLs.createnewgame`
    # method, and does the same thing.
    dictionary = context[:dictionary]
    io = IOBuffer()
    context[:io] = io

    niancatfactory = io -> NiancatGame(Word(puzzle), NonaREPLs.ConsolePublisher(io), dictionary)

    nona = NonaREPL(niancatfactory, dictionary; io=io)
    start(nona)

    context[:game] = nona
end

@given("a NonaREPL game Hamming with puzzle {String}") do context, puzzle
    # We need to create a specific NiancatGame object, with a specific puzzle,
    # so we do that using this factory method. It replaces the `NonaREPLs.createnewgame`
    # method, and does the same thing.
    dictionary = context[:dictionary]
    io = IOBuffer()
    context[:io] = io

    state = HammingGameState(Word(puzzle))
    gamefactory = io -> NonaREPLs.creategame(HammingGame, dictionary, io, state, HammingGuessState())

    nona = NonaREPL(gamefactory, dictionary; io=io)
    start(nona)

    context[:game] = nona
end

@when("a NonaREPL game Hamming is continued") do context
    dictionary = context[:dictionary]
    io = IOBuffer()
    context[:io] = io

    gamefactory = io -> NonaREPLs.switchgame(HammingGame, dictionary, io)

    nona = NonaREPL(gamefactory, dictionary; io=io)
    start(nona)

    context[:game] = nona
end

@when("starting a NonaREPL game Niancat with puzzle {String}") do context, puzzle
    # Niancat takes a publisher in the constructor method, but that publisher
    # is created by NonaREPL, so we need to make a factory method.
    dictionary = context[:dictionary]
    io = IOBuffer()
    context[:io] = io

    niancatfactory = io -> NiancatGame(Word(puzzle), NonaREPLs.ConsolePublisher(io), dictionary)

    nona = NonaREPL(niancatfactory, dictionary; io=io)
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

@when("the player inputs \"{String}\"") do context, command
    clearoutput(context)

    game = context[:game]
    playerinput!(game, command)
end

@given("the game state is recorded") do context
    game = context[:game]

    state = gamestate(game.game)

    context[:gamestate] = state
end

@then("the game state is unchanged") do context
    game = context[:game]
    oldstate = context[:gamestate]

    newstate = gamestate(game.game)

    @expect newstate == oldstate
end

@then("the game state is changed") do context
    game = context[:game]
    oldstate = context[:gamestate]

    newstate = gamestate(game.game)

    @expect newstate != oldstate
end