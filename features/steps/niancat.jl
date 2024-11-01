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
using Nona

struct MockNiancatPublisher <: NiancatPublisher
    responses::Vector{<:Response}

    MockNiancatPublisher() = new(Response[])
end

Nona.publish!(publisher::MockNiancatPublisher, response::Response) = push!(publisher.responses, response)

function hasresponse(publisher::MockNiancatPublisher, response::Response) :: Bool
    response in publisher.responses
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

@given("a dictionary") do context
    # Each row in context.datatables is an array of words,
    # but there is only one word in each array.
    dictionary = [
        words[1]
        for words in context.datatable
    ]
    context[:dictionary] = Dictionary(dictionary)
end

@given("a Niancat puzzle {String}") do context, puzzle
    publisher = MockNiancatPublisher()
    dictionary = context[:dictionary]
    context[:publisher] = publisher
    context[:game] = NiancatGame(puzzle, publisher, dictionary)
end

@when("Alice guesses {String}") do context, guess
    game = context[:game]

    alice = NickUser("Alice")
    guess = Guess(guess)

    gameaction!(game, alice, guess)
end

@then("the response is that {String} is incorrect") do context, guess
    publisher = context[:publisher]
    alice = NickUser("Alice")

    @expect hasresponse(publisher, Incorrect(alice, Guess(guess)))
end

@then("the response is that {String} is correct") do context, guess
    publisher = context[:publisher]
    alice = NickUser("Alice")

    @expect hasresponse(publisher, Correct(alice, Guess(guess), AnySolutionIndex()))
end

@then("the response is that {String} is the solution with index {Int}") do context, guess, index
    publisher = context[:publisher]
    alice = NickUser("Alice")

    @expect hasresponse(publisher, Correct(alice, Guess(guess), MultipleSolutionIndex(index)))
end

@then("the response indicates that Alice has found the only possible solution {String}") do context, guess
    publisher = context[:publisher]
    alice = NickUser("Alice")

    @expect hasresponse(publisher, Correct(alice, Guess(guess), SingleSolutionIndex()))
end