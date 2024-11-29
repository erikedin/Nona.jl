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

@testset "Parser Combinators" begin

@testset "EOF; Input is EOF; Result is nothing (OK)" begin
    # Arrange
    input = ParserInput("")

    # Act
    (_rest, result) = eofP(input)

    # Assert
    @test result === nothing
end

@testset "EOF; Input is EOF; Result is nothing (OK)" begin
    # Arrange
    input = ParserInput("a")

    # Act
    (_rest, result) = eofP(input)

    # Assert
    @test typeof(result) == BadParse
end

@testset "Any; Input is a; Result is a" begin
    # Arrange
    input = ParserInput("a")

    # Act
    (_rest, result) = Parsers.anyP(input)

    # Assert
    @test result == 'a'
end

@testset "Any; Input is b; Result is b" begin
    # Arrange
    input = ParserInput("b")

    # Act
    (_rest, result) = Parsers.anyP(input)

    # Assert
    @test result == 'b'
end

@testset "Any; Input is EOF; BadParse" begin
    # Arrange
    input = ParserInput("")

    # Act
    (_rest, result) = Parsers.anyP(input)

    # Assert
    @test typeof(result) == BadParse
end

@testset "Any then Any; Input is ab; Result is a then b" begin
    # Arrange
    input = ParserInput("ab")

    # Act
    (rest1, result1) = Parsers.anyP(input)
    (rest2, result2) = Parsers.anyP(rest1)

    # Assert
    @test result1 == 'a'
    @test result2 == 'b'
end

@testset "Choice of any or EOF; Input is a; Result is a" begin
    # Arrange
    input = ParserInput("a")
    parser = Parsers.choiceP(Parsers.anyP, Parsers.eofP)

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == 'a'
end

@testset "Choice of any or EOF; Input is EOF; Result is nothing" begin
    # Arrange
    input = ParserInput("")
    parser = Parsers.choiceP(Parsers.anyP, Parsers.eofP)

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result === nothing
end

@testset "Character a; Input is a; Result is a" begin
    # Arrange
    input = ParserInput("a")

    # Act
    (_rest, result) = Parsers.charC('a')(input)

    # Assert
    @test result == 'a'
end

@testset "Character a; Input is b; Result is BadParse" begin
    # Arrange
    input = ParserInput("b")

    # Act
    (_rest, result) = Parsers.charC('a')(input)

    # Assert
    @test typeof(result) == BadParse
end

@testset "Is space; Input is a space; Result is a space" begin
    # Arrange
    input = ParserInput(" ")

    # Act
    (_rest, result) = Parsers.isspaceP(input)

    # Assert
    @test result == ' '
end

@testset "Is space; Input is a; Result is BadParse" begin
    # Arrange
    input = ParserInput("a")

    # Act
    (_rest, result) = Parsers.isspaceP(input)

    # Assert
    @test typeof(result) == BadParse
end

end # Parser Combinators