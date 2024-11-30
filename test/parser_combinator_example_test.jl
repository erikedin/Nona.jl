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

# These tests ensure that that the Nona.Parsers module has enough functionality
# to implement the game commands.
# Here we will create a parser that recognizes three forms:
# foo       : Corresponds to a guess, may not start with a !
# !bar      : A command without parameters
# !baz quux : A command with a single parameter

abstract type ExamplesCommand end

struct Foo <: ExamplesCommand
    value::String
end

struct Bar <: ExamplesCommand end

struct Baz <: ExamplesCommand
    value::String
end

const notExclamationP = satisfyC(x -> x != '!')
const guessTokenP = (notExclamationP >> tokenP) |> To{String}(join)
const guessP = guessTokenP |> To{Foo}()

const commandMarkerP = charC('!')
const barTokenP = commandMarkerP >> symbolC("bar")
const barP = barTokenP |> To{Bar}()

const examplesP = guessP | barP

@testset "Parser Combinator Examples" begin

@testset "Examples; Input is foo; Result is Foo(foo)" begin
    # Arrange
    input = ParserInput("foo")

    # Act
    (rest, result) = examplesP(input)

    # Assert
    @test result == Foo("foo")
end

@testset "Examples; Input is fnord; Result is Foo(fnord)" begin
    # Arrange
    input = ParserInput("fnord")

    # Act
    (rest, result) = examplesP(input)

    # Assert
    @test result == Foo("fnord")
end

@testset "Examples; Input is !foo; Result is BadParse" begin
    # Arrange
    input = ParserInput("!foo")

    # Act
    (rest, result) = examplesP(input)

    # Assert
    @test typeof(result) == BadParse
end

@testset "Examples; Input is !bar; Result is Bar()" begin
   # Arrange
   input = ParserInput("!bar")

   # Act
   (rest, result) = examplesP(input)

   # Assert
   @test result == Bar()
end

end # Parser Combinator Examples