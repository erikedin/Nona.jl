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

using Nona.Parsers
using Nona.Games
using Nona.NonaREPLs

# Testing parsing of commands from the player REPL command line.
@testset "Parser  " begin

@testset "Parse; Input is PUSSGURKA; Result is the Guess command" begin
    # Arrange
    input = ParserInput("PUSSGURKA")

    # Act
    parser = NonaREPLParser()
    result = parser(input)

    # Assert
    @test isok(result)
    @test result.value == Guess(Word("PUSSGURKA"))
end

@testset "Parse; Input is !visa; Result is the ShowCurrentPuzzle command" begin
    # Arrange
    input = ParserInput("!visa")

    # Act
    parser = NonaREPLParser()
    result = parser(input)

    # Assert
    @test isok(result)
    @test result.value == ShowCurrentPuzzle()
end

@testset "Parse; Input is !nytt; Result is the NewGameAction command" begin
    # Arrange
    input = ParserInput("!nytt")

    # Act
    parser = NonaREPLParser()
    result = parser(input)

    # Assert
    @test isok(result)
    @test result.value == NonaREPLs.NewGameAction()
end

end # Parser