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

@testset "EOF; Input is a; Result is BadParse" begin
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
    #parser = Parsers.choiceC(Parsers.anyP, Parsers.eofP)
    parser = Parsers.anyP | Parsers.eofP

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == 'a'
end

@testset "Choice of any or EOF; Input is EOF; Result is nothing" begin
    # Arrange
    input = ParserInput("")
    parser = Parsers.anyP | Parsers.eofP

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result === nothing
end

@testset "Character a; Input is a; Result is a" begin
    # Arrange
    input = ParserInput("a")
    parser = charC('a')

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == 'a'
end

@testset "Character a; Input is b; Result is BadParse" begin
    # Arrange
    input = ParserInput("b")

    # Act
    (_rest, result) = charC('a')(input)

    # Assert
    @test typeof(result) == BadParse
end

@testset "Space; Input is a space; Result is a space" begin
    # Arrange
    input = ParserInput(" ")

    # Act
    (_rest, result) = spaceP(input)

    # Assert
    @test result == ' '
end

@testset "Space; Input is a; Result is BadParse" begin
    # Arrange
    input = ParserInput("a")

    # Act
    (_rest, result) = spaceP(input)

    # Assert
    @test typeof(result) == BadParse
end

@testset "Choice of a or b; Input is a; Result is a" begin
    # Arrange
    input = ParserInput("a")
    parser = charC('a') | charC('b')

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == 'a'
end

@testset "Choice of a or b; Input is b; Result is b" begin
    # Arrange
    input = ParserInput("b")
    parser = charC('a') | charC('b')

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == 'b'
end

@testset "Choice of a or b; Input is c; Result is BadParse" begin
    # Arrange
    input = ParserInput("c")
    parser = charC('a') | charC('b')

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test typeof(result) == BadParse
end

@testset "Choice of a, b, or c; Input is c; Result is a" begin
    # Arrange
    input = ParserInput("a")
    parser = charC('a') | charC('b') | charC('c')

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == 'a'
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
    parser = charC('a') >> charC('b')

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == ('a', 'b')
end

@testset "Sequence b, b; Input is bb; Result is b, b" begin
    # Arrange
    input = ParserInput("bb")
    parser = charC('b') >> charC('b')

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == ('b', 'b')
end

@testset "Sequence a, b, c; Input is abc; Result is abc" begin
    # Arrange
    input = ParserInput("abc")
    parser = charC('a') >> charC('b') >> charC('c')

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == ('a', 'b', 'c')
end

@testset "4-sequence; Input is abcd; Result is abcd" begin
    # Arrange
    input = ParserInput("abcd")
    parser = charC('a') >> charC('b') >> charC('c') >> charC('d')

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == ('a', 'b', 'c', 'd')
end

@testset "5-sequence; Input is abcde; Result is abcde" begin
    # Arrange
    input = ParserInput("abcde")
    parser = charC('a') >> charC('b') >> charC('c') >> charC('d') >> charC('e')

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == ('a', 'b', 'c', 'd', 'e')
end

@testset "Sequence a, b, EOF; Input is ab; Result is ab, then nothing" begin
    # Arrange
    input = ParserInput("ab")
    parser = charC('a') >> charC('b') >> eofP

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == ('a', 'b', nothing)
end

@testset "Sequence a, b; Input is bb; Result is BadParse" begin
    # Arrange
    input = ParserInput("bb")
    parser = charC('a') >> charC('b')

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test typeof(result) == BadParse
end

@testset "Sequence a, b, EOF; Input is abc; Result is BadParse" begin
    # Arrange
    input = ParserInput("abc")
    parser = charC('a') >> charC('b') >> eofP

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
    @test result == ['a']
end

@testset "Many of any; Input is abc; Result is abc" begin
    # Arrange
    input = ParserInput("abc")
    parser = manyC(anyP)

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == ['a', 'b', 'c']
end

@testset "Many of a; Input is b; Result is empty" begin
    # Arrange
    input = ParserInput("b")
    parser = manyC(charC('a'))

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == []
end

@testset "Many of a, then b; Input is b; Result is empty list, then b" begin
    # Arrange
    input = ParserInput("b")
    parser = manyC(charC('a')) >> charC('b')

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == ([], 'b')
end

@testset "Many of a, then b; Input is ab; Result is a, then b" begin
    # Arrange
    input = ParserInput("ab")
    parser = manyC(charC('a')) >> charC('b')

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == (['a'], 'b')
end

end # ManyC

@testset "Parser transform" begin

@testset "Many chars joined; Input is abc; Result is abc" begin
    # Arrange
    input = ParserInput("abc")
    parser = manyC(anyP) |> To{String}(join)

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == "abc"
end

end # Parser transformation

@testset "tokenP" begin

@testset "manyC(anyP) to string; Input is abc; Result is abc" begin
    # Arrange
    input = ParserInput("abc")
    parser = manyC(anyP) |> To{String}(join)

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == "abc"
end

@testset "manyC(anyP) to string, spaces; Input is 'abc '; Result is 'abc '" begin
    # Arrange
    input = ParserInput("abc ")
    notSpaceP = Parsers.satisfyC(x -> x != ' ')
    charsP = manyC(notSpaceP)  |> To{String}(join)
    parser = charsP >> spaceP

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == ("abc", ' ')
end

@testset "manyC(anyP) to string, ignore space; Input is 'abc '; Result is 'abc'" begin
    # Arrange
    input = ParserInput("abc ")
    notSpaceP = Parsers.satisfyC(x -> x != ' ')
    charsP = manyC(notSpaceP)  |> To{String}(join)
    parser = charsP >> ignoreC(spaceP)

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == "abc"
end

@testset "manyC(anyP), ignore space to string; Input is 'abc '; Result is 'abc'" begin
    # Arrange
    input = ParserInput("abc ")
    notSpaceP = Parsers.satisfyC(x -> x != ' ')
    charsP = manyC(notSpaceP) >> ignoreC(spaceP)
    parser = charsP |> To{String}(join)

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == "abc"
end

@testset "Token; Input is abc; Token is abc" begin
    # Arrange
    input = ParserInput("abc")

    # Act
    (_rest, result) = tokenP(input)

    # Assert
    @test result == "abc"
end

@testset "Token swallows trailing spaces; Input is 'abc '; Token is abc" begin
    # Arrange
    input = ParserInput("abc ")
    parser = tokenP

    # Act
    (rest, result) = parser(input)
    (_eofrest, eofresult) = eofP(rest)

    # Assert
    @test result == "abc"
    @test eofresult === nothing
end

@testset "Token swallows all trailing spaces; Input is 'abc  '; Token is abc" begin
    # Arrange
    input = ParserInput("abc  ")
    parser = tokenP >> ignoreC(eofP)

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == "abc"
end

@testset "One token; Input is abc def; Rest is def" begin
    # Arrange
    input = ParserInput("abc def")
    parser = tokenP

    # Act
    (rest, _result) = parser(input)

    # Assert
    @test rest == ParserInput("abc def", 5)
end

@testset "Two tokens; Input is abc def; Result is abc, def" begin
    # Arrange
    input = ParserInput("abc def")
    parser = tokenP

    # Act
    (rest1, result1) = parser(input)
    (rest2, result2) = parser(rest1)

    # Assert
    @test result1 == "abc"
    @test result2 == "def"
end

@testset "Two tokens; Input is abc def; Tokens are abc def" begin
   # Arrange
   input = ParserInput("abc def")
   parser = tokenP >> tokenP

   # Act
   (_rest, result) = parser(input)

   # Assert
   @test result == ("abc", "def")
end

end # tokenP

@testset "Ignore" begin

@testset "a then ignore b; Input is ab; Result is a" begin
    # Arrange
    input = ParserInput("ab")
    parser = charC('a') >> ignoreC(charC('b'))

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test typeof(parser) == sequenceC{Char}
    @test result == 'a'
end

@testset "Ignore a then b; Input is ab; Result is b" begin
    # Arrange
    input = ParserInput("ab")
    parser = ignoreC(charC('a')) >> charC('b')

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test typeof(parser) == sequenceC{Char}
    @test result == 'b'
end

@testset "a, b, then ignore EOF; Input is ab; Result is b" begin
    # Arrange
    input = ParserInput("ab")
    parser = charC('a') >> charC('b') >> ignoreC(eofP)

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test typeof(parser) == sequenceC{Tuple{Char, Char}}
    @test result == ('a', 'b')
end

@testset "a then ignore many b, then ignore EOF; Input is abb; Result is a" begin
    # Arrange
    input = ParserInput("abb")
    parser = charC('a') >> ignoreC(manyC(charC('b'))) >> ignoreC(eofP)

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test result == 'a'
end

@testset "a then ignore EOF; Input is ab; Result is BadParse" begin
    # Arrange
    input = ParserInput("ab")
    parser = charC('a') >> ignoreC(eofP)

    # Act
    (_rest, result) = parser(input)

    # Assert
    @test typeof(result) == BadParse
end

end # Ignore

@testset "RepeatC" begin

@testset "Repeat anyP 1 times; Input is a; Result is a" begin
    # Arrange
    input = ParserInput("a")
    parser = repeatC(anyP, 1)

    # Act
    (rest, result) = parser(input)

    # Assert
    @test result == ['a']
end

@testset "Repeat anyP 1 times; Input is b; Result is b" begin
    # Arrange
    input = ParserInput("b")
    parser = repeatC(anyP, 1)

    # Act
    (rest, result) = parser(input)

    # Assert
    @test result == ['b']
end

@testset "Repeat anyP 2 times; Input is ab; Result is a, b" begin
    # Arrange
    input = ParserInput("ab")
    parser = repeatC(anyP, 2)

    # Act
    (rest, result) = parser(input)

    # Assert
    @test result == ['a', 'b']
end

end # RepeatC

@testset "SymbolC" begin

@testset "Symbol abc; Input is abc; Symbol is abc" begin
    # Arrange
    input = ParserInput("abc")
    parser = symbolC("abc")

    # Act
    (rest, result) = parser(input)

    # Assert
    @test result == "abc"
end

@testset "Symbol abc; Input is abb; Result is BadParse" begin
    # Arrange
    input = ParserInput("abb")
    parser = symbolC("abc")

    # Act
    (rest, result) = parser(input)

    # Assert
    @test typeof(result) == BadParse
end

@testset "! followed by Symbol abc; Input is !abc; Symbol is abc" begin
    # Arrange
    input = ParserInput("!abc")
    parser = charC('!') >> symbolC("abc")

    # Act
    (rest, result) = parser(input)

    # Assert
    @test result == ('!', "abc")
end

@testset "a or ! then abc; Input is !abc; Symbol is abc " begin
    # Arrange
    input = ParserInput("!abc")
    abcP = charC('!') >> symbolC("abc")
    aP = charC('a')
    parser = aP | abcP

    # Act
    (rest, result) = parser(input)

    # Assert
    @test result == ('!', "abc")
end

@testset "a or ! then abc; Input is !foo; BadResult" begin
    # Arrange
    input = ParserInput("!foo")
    abcP = charC('!') >> symbolC("abc")
    aP = charC('a')
    parser = aP | abcP

    # Act
    (rest, result) = parser(input)

    # Assert
    @test typeof(result) == BadParse
end

@testset "a or ! then abc; Input is baz; BadResult" begin
    # Arrange
    input = ParserInput("baz")
    abcP = charC('!') >> symbolC("abc")
    aP = charC('a')
    parser = aP | abcP

    # Act
    (rest, result) = parser(input)

    # Assert
    @test typeof(result) == BadParse
end

end # SymbolC

@testset "BadParse behavior when combining parsers" begin

@testset "EOF or a; Input is a; Result is a" begin
    # Arrange
    input = ParserInput("a")
    parser = eofP | charC('a')

    # Act
    (rest, result) = parser(input)

    # Assert
    @test result == 'a'
end

@testset "Symbol ab or cd; Input is ab; Result is ab" begin
    # Arrange
    input = ParserInput("ab")
    parser = symbolC("ab") | symbolC("cd")

    # Act
    (rest, result) = parser(input)

    # Assert
    @test result == "ab"
end

@testset "Symbol ab or cd; Input is cd; Result is cd" begin
    # Arrange
    input = ParserInput("cd")
    parser = symbolC("ab") | symbolC("cd")

    # Act
    (rest, result) = parser(input)

    # Assert
    @test result == "cd"
end

@testset "Many a or b; Input is aa; Result is aa" begin
    # Arrange
    input = ParserInput("aa")
    parser = manyC(charC('a')) | manyC(charC('b'))

    # Act
    (rest, result) = parser(input)

    # Assert
    @test result == ['a', 'a']
end

@testset "Many a or b; Input is bb; Result is empty" begin
    # Arrange
    input = ParserInput("bb")
    parser = manyC(charC('a')) | manyC(charC('b'))

    # Act
    (rest, result) = parser(input)

    # Assert
    @test result == []
end

@testset "Many; Input is bb; Result is bb" begin
    # Arrange
    input = ParserInput("bb")
    notB = satisfyC(x -> x != 'b')
    firstPart = notB >> manyC(charC('a'))
    parser = firstPart | manyC(charC('b'))

    # Act
    (rest, result) = parser(input)

    # Assert
    @test result == ['b', 'b']
end

end # BadParse behavior

end # Parser Combinators