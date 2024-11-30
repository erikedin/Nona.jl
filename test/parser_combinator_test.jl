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
    parser = Parsers.choiceC(Parsers.anyP, Parsers.eofP)

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == 'a'
end

@testset "Choice of any or EOF; Input is EOF; Result is nothing" begin
    # Arrange
    input = ParserInput("")
    parser = Parsers.choiceC(Parsers.anyP, Parsers.eofP)

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

@testset "Choice of a or b; Input is a; Result is a" begin
    # Arrange
    input = ParserInput("a")
    parser = Parsers.choiceC(charC('a'), charC('b'))

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == 'a'
end

@testset "Choice of a or b; Input is b; Result is b" begin
    # Arrange
    input = ParserInput("b")
    parser = Parsers.choiceC(charC('a'), charC('b'))

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == 'b'
end

@testset "Choice of a, b, or c; Input is c; Result is c" begin
    # Arrange
    input = ParserInput("c")
    parser = Parsers.choiceC(charC('a'), charC('b'), charC('c'))

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == 'c'
end

@testset "Choice of a, b, or c; Input is b; Result is b" begin
    # Arrange
    input = ParserInput("b")
    parser = charC('a') | charC('b') | charC('c')

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == 'b'
end

@testset "Choice of a, b, or c; Input is c; Result is c" begin
    # Arrange
    input = ParserInput("c")
    parser = charC('a') | charC('b') | charC('c')

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == 'c'
end

@testset "SequenceC" begin

@testset "Sequence a, b; Input is ab; Result is a, b" begin
    # Arrange
    input = ParserInput("ab")
    parser = sequenceC(charC('a'), charC('b'))

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == ('a', 'b')
end

@testset "Sequence b, b; Input is bb; Result is b, b" begin
    # Arrange
    input = ParserInput("bb")
    parser = sequenceC(charC('b'), charC('b'))

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == ('b', 'b')
end

@testset "Sequence a, b, c; Input is abc; Result is abc" begin
    # Arrange
    input = ParserInput("abc")
    parser = sequenceC(charC('a'), charC('b'), charC('c'))

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == ('a', 'b', 'c')
end

@testset "Sequence a, b, EOF; Input is ab; Result is ab, then nothing" begin
    # Arrange
    input = ParserInput("ab")
    parser = sequenceC(charC('a'), charC('b'), eofP)

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == ('a', 'b', nothing)
end

@testset "Sequence a, b; Input is bb; Result is BadParse" begin
    # Arrange
    input = ParserInput("bb")
    parser = sequenceC(charC('a'), charC('b'))

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test typeof(result) == BadParse
end

@testset "Sequence a, b, EOF; Input is abc; Result is BadParse" begin
    # Arrange
    input = ParserInput("abc")
    parser = sequenceC(charC('a'), charC('b'), eofP)

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test typeof(result) == BadParse
end

end # SequenceC

@testset "notC" begin

@testset "notC b; Input is a; Result is a" begin
    # Arrange
    input = ParserInput("a")
    parser = notC('b')

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == 'a'
end

@testset "notC b; Input is b; Result is BadParse" begin
    # Arrange
    input = ParserInput("b")
    parser = notC('b')

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test typeof(result) == BadParse
end

end # notC

@testset "ManyC" begin

@testset "Many of any; Input is a; Result is a" begin
    # Arrange
    input = ParserInput("a")
    parser = manyC(anyP)

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == ('a', )
end

@testset "Many of any; Input is abc; Result is abc" begin
    # Arrange
    input = ParserInput("abc")
    parser = manyC(anyP)

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == ('a', 'b', 'c')
end

end # ManyC

@testset "Parser transform" begin

@testset "Many chars joined; Input is abc; Result is abc" begin
    # Arrange
    input = ParserInput("abc")
    parser = transformC(manyC(anyP), join)

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == "abc"
end

end # Parser transformation

@testset "symbolC" begin

@testset "Symbol; Input is abc; Symbol is abc" begin
    # Arrange
    input = ParserInput("abc")

    # Act
    (_rest, result) = symbolP(input)

    # Assert
    @test result == "abc"
end

#@testset "Symbol; Input is 'abc '; Symbol is abc" begin
#    # Arrange
#    input = ParserInput("abc ")
#
#    # Act
#    (_rest, result) = symbolP(input)
#
#    # Assert
#    @test result == "abc"
#end

end # symbolC

@testset "Ignore suffix" begin

@testset "a then ignore b; Input is ab; Result is a" begin
    # Arrange
    input = ParserInput("ab")
    parser = sequenceC(charC('a'), ignoreC(charC('b')))

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == ('a', )
end

@testset "Ignore a then b; Input is ab; Result is b" begin
    # Arrange
    input = ParserInput("ab")
    parser = sequenceC(ignoreC(charC('a')), charC('b'))

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == ('b', )
end

@testset "a then ignore many b, then ignore EOF; Input is abb; Result is a" begin
    # Arrange
    input = ParserInput("abb")
    parser = sequenceC(charC('a'), ignoreC(manyC(charC('b'))), ignoreC(eofP))

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == ('a', )
end

end # Ignore suffix

end # Parser Combinators