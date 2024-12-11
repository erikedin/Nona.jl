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

@given("a Hamming accessory for the best guesses") do context
    # publisher is the mock publisher where events can be queried by the tests.
    publisher = context[:publisher]
    # delegationpublisher is a publisher that sends events to any accessories
    # as well as to the publisher
    delegationpublisher = context[:delegationpublisher]

    accessory = BestHammingGuess(publisher)
    register!(delegationpublisher, accessory)

    context[:bestguessaccessory] = accessory
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

@when("Alice requests the best guesses") do context
    accessory = context[:bestguessaccessory]
    alice = context[:defaultplayer]

    gameaction!(accessory, alice, ShowBestGuesses())
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

@then("there are no best guesses") do context
    publisher = context[:publisher]

    response = getonlyresponse(publisher)
    @expect typeof(response) == HammingAccessories.NoBestGuesses
end