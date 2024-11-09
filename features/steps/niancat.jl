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

import Nona.Niancat: publish!

# This is the most basic type of user, where the user is identified by a single
# string, which is also the display name.
struct NickUser <: User
    nick::String
end

struct MockNiancatPublisher <: NiancatPublisher
    responses::Vector{<:Response}

    MockNiancatPublisher() = new(Response[])
end

publish!(publisher::MockNiancatPublisher, response::Response) = push!(publisher.responses, response)

function hasresponse(publisher::MockNiancatPublisher, response::Response) :: Bool
    response in publisher.responses
end

function getonlyresponse(publisher::MockNiancatPublisher) :: Response
    only(publisher.responses)
end

struct AnySolutionIndex <: SolutionIndex end

# When comparing equality, AnySolutionIndex should be compared as equal to any other
# SolutionIndex type.
Base.:(==)(::SolutionIndex, ::AnySolutionIndex) = true
Base.:(==)(::AnySolutionIndex, ::SolutionIndex) = true
Base.:(==)(index1::MultipleSolutionIndex, index2::MultipleSolutionIndex) = index1.index == index2.index
Base.:(==)(::SingleSolutionIndex, ::SingleSolutionIndex) = true
Base.:(==)(::MultipleSolutionIndex, ::SingleSolutionIndex) = false
Base.:(==)(::SingleSolutionIndex, ::MultipleSolutionIndex) = false

Base.:(==)(r1::Correct, r2::Correct) = r1.user == r2.user && r1.guess == r2.guess && r1.solutionindex == r2.solutionindex

struct SetDictionary <: Dictionary
    words::Set{Word}

    SetDictionary(words::AbstractVector{String}) = new(Set{Word}(Word[Word(s) for s in words]))
end

Base.iterate(sd::SetDictionary) = iterate(sd.words)
Base.iterate(sd::SetDictionary, state) = iterate(sd.words, state)
Base.length(sd::SetDictionary) = length(sd.words)

const AnyLetterCorrection = LetterCorrection("", "")

# WARNING: This equality does not look at lettercorrection, so we don't have to exactly
# specify the letter correction in every step.
Base.:(==)(a::Incorrect, b::Incorrect) = a.user == b.user && a.guess == b.guess # && a.lettercorrection == b.lettercorrection

@given("a dictionary") do context
    # Each row in context.datatables is an array of words,
    # but there is only one word in each array.
    dictionary = [
        words[1]
        for words in context.datatable
    ]
    context[:dictionary] = SetDictionary(dictionary)
end

@given("a Niancat puzzle {String}") do context, puzzle
    publisher = MockNiancatPublisher()
    dictionary = context[:dictionary]
    context[:publisher] = publisher
    context[:game] = NiancatGame(Word(puzzle), publisher, dictionary)

    # The default user is Alice, unless otherwise stated.
    # Other users are stored in the :users map.
    alice = NickUser("Alice")
    context[:users] = Dict{String, User}(["Alice" => alice])
    context[:defaultuser] = alice
end

@when("{String} guesses {String}") do context, username, guess
    game = context[:game]

    # Users are expected to be stored in a Map in the context.
    users = context[:users]
    user = users[username]

    guess = Guess(guess)

    gameaction!(game, user, guess)
end

@when("Alice gets the puzzle") do context
    game = context[:game]
    user = context[:defaultuser]

    gameaction!(game, user, ShowCurrentPuzzle())
end

@when("Alice shows the solutions") do context
    game = context[:game]
    user = context[:defaultuser]

    gameaction!(game, user, ShowSolutions())
end

@then("the response is that {String} is incorrect") do context, guess
    publisher = context[:publisher]
    user = context[:defaultuser]

    @expect hasresponse(publisher, Incorrect(user, Guess(guess), AnyLetterCorrection))
end

@then("the response is that {String} is correct") do context, guess
    publisher = context[:publisher]
    user = context[:defaultuser]

    @expect hasresponse(publisher, Correct(user, Guess(guess), AnySolutionIndex()))
end

@then("the response is that {String} is the solution with index {Int}") do context, guess, index
    publisher = context[:publisher]
    user = context[:defaultuser]

    @expect hasresponse(publisher, Correct(user, Guess(guess), MultipleSolutionIndex(index)))
end

@then("the response indicates that Alice has found the only possible solution {String}") do context, guess
    publisher = context[:publisher]
    user = context[:defaultuser]

    @expect hasresponse(publisher, Correct(user, Guess(guess), SingleSolutionIndex()))
end

@then("the puzzle response is {String}") do context, puzzle
    publisher = context[:publisher]
    user = context[:defaultuser]

    response = getonlyresponse(publisher)
    @expect response.puzzle == Word(puzzle)
end

@then("the puzzle response includes that there are {Int} solutions") do context, n
    publisher = context[:publisher]
    user = context[:defaultuser]

    response = getonlyresponse(publisher)
    @expect response.n_solutions == n
end

@then("the letters {String} are missing") do context, missingletters
    publisher = context[:publisher]
    response = getonlyresponse(publisher)

    @expect response.lettercorrection.missings == Word(missingletters)
end

@then("the letters {String} are extra") do context, extraletters
    publisher = context[:publisher]
    response = getonlyresponse(publisher)

    @expect response.lettercorrection.extras == Word(extraletters)
end

@then("the solutions response is") do context
    # Each row in context.datatables is an array of words,
    # but there is only one word in each array.
    solutions = [
        Word(words[1])
        for words in context.datatable
    ]

    publisher = context[:publisher]
    response = getonlyresponse(publisher)

    @expect solutions == response.solutions
end

#
# Users
# These steps are specific to the `details/Users.feature` scenarios.
#

struct DisplayNameUser <: User
    userid::String
    displayname::String
end

@given("a front-end specific user Angleton with display name James") do context
    users = context[:users]
    users["Angleton"] = DisplayNameUser("Angleton", "James")
end


@then("the response is that {String} guessed {String} correctly") do context, username, guess
    publisher = context[:publisher]
    user = context[:users][username]

    @expect hasresponse(publisher, Correct(user, Guess(guess), AnySolutionIndex()))
end

#
# Puzzle selection
#

@when("randomly generating a Niancat puzzle") do context
    dictionary = context[:dictionary]

    puzzle = generatepuzzle(dictionary)

    context[:puzzle] = puzzle
end

@when("randomly generating a Niancat puzzle {Int} times") do context, n
    dictionary = context[:dictionary]

    puzzles = [
        generatepuzzle(dictionary)
        for i in 1:n
    ]

    context[:puzzles] = puzzles
end

@then("the puzzle is an anagram of a word in the dictionary") do context
    dictionary = context[:dictionary]
    puzzle = context[:puzzle]

    anagrams = [
        word
        for word in dictionary
        if isanagram(word, puzzle)
    ]

    @expect anagrams != []
end

@then("the letters in the puzzle are sorted in alphabetical order") do context
    dictionary = context[:dictionary]
    puzzle = context[:puzzle]

    @expect sort(puzzle) == puzzle
end

@then("the puzzle has 9 letters") do context
    puzzle = context[:puzzle]

    @expect length(puzzle) == 9
end

@then("all randomly chosen puzzles have 9 letters") do context
    puzzles = context[:puzzles]

    @expect all(w -> length(w) == 9, puzzles)
end