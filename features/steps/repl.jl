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
using Nona.Niancat: isanagram
using Nona.NonaREPL

@given("a dictionary in the file \"{String}\"") do context, dictionarypath
    fullpath = pkgdir(Nona, dictionarypath)
    dictionary = FileDictionary(fullpath)
    context[:dictionary] = dictionary
end

@given("a REPL Niancat game with puzzle {String}") do context, puzzle
    dictionary = context[:dictionary]

    io = IOBuffer()
    context[:io] = io

    game = NiancatREPL(io, Word(puzzle), dictionary)
    start(game)
    context[:game] = game
end

@when("the REPL user tries the guess {String}") do context, word
    game = context[:game]

    #guess(game, word)
    userinput!(game, word)
end

@when("a new NiancatREPL game is generated") do context
    dictionary = context[:dictionary]

    io = IOBuffer()
    game = NonaREPL.newgame(dictionary; io=io)

    context[:game] = game
    context[:io] = io
end

@then("the REPL shows \"{String}\"") do context, message
    io = context[:io]

    # The stream position is at the end, after all output has been written.
    # Seek to the start so it can be read from the beginning.
    seekstart(io)

    output = read(io, String)
    @expect contains(output, message)
end

@then("the REPL does not show \"{String}\"") do context, message
    io = context[:io]

    # The stream position is at the end, after all output has been written.
    # Seek to the start so it can be read from the beginning.
    seekstart(io)

    output = read(io, String)
    @expect !contains(output, message)
end

@then("a puzzle is shown") do context
    io = context[:io]

    seekstart(io)
    output = read(io, String)
    # Remove the prompt, as a hack to get just the puzzle
    puzzle = replace(output, "> " => "")

    context[:puzzle] = Word(strip(puzzle))
end

@then("that puzzle is an anagram of a word in the dictionary") do context
    puzzle = context[:puzzle]
    dictionary = context[:dictionary]

    solutions = [
        word
        for word in dictionary
        if isanagram(word, puzzle)
    ]

    @expect length(solutions) > 0
end

@then("the output ends with \"{String}\"") do context, message
    io = context[:io]

    seekstart(io)
    output = read(io, String)

    @expect endswith(output, "> ")
end