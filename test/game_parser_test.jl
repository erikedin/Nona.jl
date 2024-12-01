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

using Nona.Parsers
using Nona.GameParsers
using Nona.REPLCommands
using Nona.Games
using Nona.Games.Hamming
using Nona.Games.Niancat

const commandResults = [
    ("!visa", ShowCurrentPuzzle()),
    ("!visa ", ShowCurrentPuzzle()),
    (" !visa", ShowCurrentPuzzle()),
    ("PUSSGURKA", Guess("PUSSGURKA")),
    ("!nytt", NewGameAction()),
    ("!nytt Hamming", NewGameTypeAction(HammingGame)),
    ("!nytt Niancat", NewGameTypeAction(NiancatGame)),
]

const badCommandResults = [
    ("!visa extra", "Extra argument is not allowed"),
    ("!nosuchcommand", "Unknown commands are failures")
]

@testset "Game parsers      " begin

for (text, expected) in commandResults

@testset "Game command parser: '$(text)': Expects $(expected)" begin
    # Arrange
    input = ParserInput(text)
    parser = GameParsers.commandP

    # Act
    (rest, result) = parser(input)

    # Assert
    @test result == expected
end

end # for in commandResults

for (text, description) in badCommandResults

@testset "Game command parser fails: '$(text)' because $(description)" begin
    # Arrange
    input = ParserInput(text)
    parser = GameParsers.commandP

    # Act
    (rest, result) = parser(input)

    # Assert
    @test typeof(result) == BadParse
end

end # for in commandResults

end # Game parsers