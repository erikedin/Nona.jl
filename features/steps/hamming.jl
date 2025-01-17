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
using Nona.Games
using Nona.Games.Hamming
using Nona.Games.HammingAccessories
import Nona.Games: publish!

struct MockHammingPublisher <: Publisher{HammingGame}
    responses::Vector{Response}

    MockHammingPublisher() = new(Response[])
end

function publish!(publisher::MockHammingPublisher, response::Response)
    push!(publisher.responses, response)
end

function getonlyresponse(publisher::MockHammingPublisher) :: Response
    only(publisher.responses)
end

function getonlyresponse(::Type{T}, publisher::MockHammingPublisher) :: Response where {T}
    responses = [resp
                 for resp in publisher.responses
                 if typeof(resp) == T]
    only(responses)
end

@given("a Hamming puzzle {String}") do context, puzzle
    io = IOBuffer()
    context[:io] = io

    publisher = MockHammingPublisher()
    delegationpublisher = DelegationPublisher(publisher)

    dictionary = context[:dictionary]
    game = HammingGame(delegationpublisher, dictionary, Word(puzzle))

    context[:publisher] = publisher
    context[:delegationpublisher] = delegationpublisher
    context[:game] = game

    # The default player is Alice, unless otherwise stated.
    # Other players are stored in the :players map.
    alice = NickPlayer("Alice")
    context[:players] = Dict{String, Player}(["Alice" => alice])
    context[:defaultplayer] = alice
end

@given("a Hamming accessory for guesses") do context
    # publisher is the mock publisher where events can be queried by the tests.
    publisher = context[:publisher]
    # delegationpublisher is a publisher that sends events to any accessories
    # as well as to the publisher
    delegationpublisher = context[:delegationpublisher]

    accessory = HammingGuess(publisher)
    register!(delegationpublisher, accessory)

    game = context[:game]
    context[:game] = GameWithAccessories(game, accessory)
end

@when("a Hamming game is created with a randomly generated puzzle") do context
    io = IOBuffer()
    context[:io] = io

    publisher = MockHammingPublisher()
    dictionary = context[:dictionary]
    game = HammingGame(publisher, dictionary)

    context[:publisher] = publisher
    context[:game] = game

    # The default player is Alice, unless otherwise stated.
    # Other players are stored in the :players map.
    alice = NickPlayer("Alice")
    context[:players] = Dict{String, Player}(["Alice" => alice])
    context[:defaultplayer] = alice
end

@when("randomly generating a Hamming puzzle {Int} times") do context, n
    io = IOBuffer()
    context[:io] = io

    # The default player is Alice, unless otherwise stated.
    # Other players are stored in the :players map.
    alice = NickPlayer("Alice")
    context[:players] = Dict{String, Player}(["Alice" => alice])
    context[:defaultplayer] = alice

    dictionary = context[:dictionary]

    generategame = () -> begin
        publisher = MockHammingPublisher()
        game = HammingGame(publisher, dictionary)
        (game, publisher)
    end
    games = [generategame() for i = 1:n]

    context[:games] = games
end

@when("Alice requests all guesses") do context
    game = context[:game]
    alice = context[:defaultplayer]

    gameaction!(game, alice, ShowGuesses())
end

@then("the Hamming response is that {String} is correct") do context, guess
    publisher = context[:publisher]
    player = context[:defaultplayer]

    response = getonlyresponse(publisher)
    @expect response == Hamming.Correct(player, Guess(guess))
end

@then("the Hamming puzzle response is \"{Int}\"") do context, n
    publisher = context[:publisher]
    player = context[:defaultplayer]

    response = getonlyresponse(publisher)
    @expect response == Hamming.CurrentPuzzle(player, n)
end

@then("the response is that the Hamming distance is {Int}") do context, d
    publisher = context[:publisher]

    response = getonlyresponse(publisher)
    @expect response.hammingdistance == d
end

@then("the response is that the word length must be {Int} letters") do context, n
    publisher = context[:publisher]

    response = getonlyresponse(publisher)
    @expect response.wordlength == n
end

@then("the response is that the word \"{String}\" is not in the dictionary") do context, word
    publisher = context[:publisher]

    response = getonlyresponse(publisher)
    @expect response.word == Word(word)
    @expect typeof(response) == Hamming.NotInDictionary
end

@then("the puzzle length is <= {Int}") do context, n
    game = context[:game]
    player = context[:defaultplayer]
    publisher = context[:publisher]

    gameaction!(game, player, ShowCurrentPuzzle())

    response = getonlyresponse(publisher)
    @test response.puzzlelength <= n
end

@then("all randomly chosen puzzles have lengths <= {Int}") do context, n
    player = context[:defaultplayer]
    games = context[:games]

    for (game, publisher) in games
        gameaction!(game, player, ShowCurrentPuzzle())

        response = getonlyresponse(publisher)
        @test response.puzzlelength <= n
    end
end

@then("there are no guesses") do context
    publisher = context[:publisher]

    response = getonlyresponse(publisher)
    @expect typeof(response) == HammingAccessories.NoGuesses
end

@then("a guess is distance {Int} with words") do context, n
    publisher = context[:publisher]

    expectedwords = [Word(w[1]) for w in context.datatable]

    response = getonlyresponse(HammingAccessories.Guesses, publisher)
    nguesses = [guesses.words for guesses in response.guesses if guesses.distance == n]
    @expect length(nguesses) == 1
    actualwords = nguesses[1]
    @expect sort(actualwords) == sort(expectedwords)
end

@then("guesses with distance {Int} come before distance {Int} guesses") do context, k, l
    publisher = context[:publisher]
    response = getonlyresponse(HammingAccessories.Guesses, publisher)

    indexk = findfirst(x -> x.distance == k, response.guesses)
    indexl = findfirst(x -> x.distance == l, response.guesses)

    @expect indexk < indexl
end

@then("the guess {String} comes before {String}") do context, word1, word2
    publisher = context[:publisher]
    response = getonlyresponse(HammingAccessories.Guesses, publisher)

    distanceguess = only(response.guesses)
    words = distanceguess.words
    indexk = findfirst(x -> x == Word(word1), words)
    indexl = findfirst(x -> x == Word(word2), words)

    @expect indexk !== nothing
    @expect indexl !== nothing
    @expect indexk < indexl
end