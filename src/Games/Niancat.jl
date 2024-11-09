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

module Niancat

export NiancatGame
export Response, Incorrect, Correct, ShowCurrentPuzzle, CurrentPuzzle
export ShowSolutions, Solutions
export NiancatPublisher
export publish!
export generatepuzzle
export Dictionary
export SolutionIndex, SingleSolutionIndex, MultipleSolutionIndex
export LetterCorrection

using Nona.Games
import Nona.Games: gameaction!, publish!


"""
    Base.:(-)(word1::Word, word2::Word) :: Word

Find the word difference between `word1` and `word2`.
The difference is the list of characters that appear in
`word1`, but not in `word2`. This will list repeated letters,
if they are not repeated enough times in `word2`. That is,

    AAB - AB = A

because `A` only occurs once in `word2`, but twice in `word1`.
"""
function Base.:(-)(word1::Word, word2::Word) :: Word
    a = sort(word1)
    b = sort(word2)

    # Example of this algorithm:
    # word1 = BCA, word2 = ACD
    # Sorted:
    # a = ABC
    # b = ACD
    # Iterate over the letters.
    # If a[i] == b[j], then that letter is neither
    # missing or extra.
    # If a[i] != b[j]:
    #       a[i] < b[j]: Missing a[i] in b
    #       a[i] > b[j]: Extra b[j] in b
    #
    # Step 1:
    # ABC     ACD
    # i       j
    # Both are A, so they match. Move forward both i, j
    #
    # ABC     ACD
    #  i       j
    # B != C. The second word is missing a B, because B < C.
    # Move forward the first word, i.
    #
    # ABC     ACD
    #   i      j
    # Both are C, so this matches.
    # Move both indexes.
    #
    # ABC     ACD
    #    i      j
    # First word has no more letters. The remaining letters in
    # the second word are extra.

    i = 1
    j = 1
    length1 = length(a)
    length2 = length(b)

    missingletters = Char[]

    while i <= length1 && j <= length2
        if a[i] == b[j]
            i += 1
            j += 1
        else
            if a[i] < b[j]
                push!(missingletters, a[i])
                i += 1
            else
                # This clause means that there is an extra letter, but
                # we only care about missing letters here.
                j += 1
            end
        end
    end

    if i <= length1
        append!(missingletters, a[i:end])
    end

    Word(join(missingletters))
end

abstract type NiancatPublisher <: Publisher end
publish!(::NiancatPublisher, ::Response) = @error("Implement me")

isanagram(a::Word, b::Word) = sort(a) == sort(b)

struct NiancatGame <: Game
    puzzle::Word
    publisher::NiancatPublisher
    solutions::Vector{Word}

    function NiancatGame(puzzle::Word, publisher::NiancatPublisher, dictionary::Dictionary)
        # Find all solutions to the puzzle.
        solutions = Word[
            word
            for word in dictionary
            if isanagram(puzzle, word)
        ]

        # The solutions are sorted so that in the case of multiple solutions,
        # we know that word 1 is the first alphabetically. This actually gives
        # information to the player, but we keep forgetting how the current Niancat
        # sorts the words, if it does. So this is mostly so we'll stop asking.
        sortedsolutions = sort(solutions)

        new(puzzle, publisher, sortedsolutions)
    end
end

#
# Commands
#

struct ShowCurrentPuzzle  <: GameCommand end

struct ShowSolutions <: GameCommand end

#
# Responses
#

# LetterCorrection contains information on any extras or missing characters
# in a guess.
struct LetterCorrection
    missings::Word
    extras::Word
end

struct Incorrect <: Response
    player::Player
    guess::Guess
    lettercorrection::LetterCorrection
end

# SolutionIndex is an abstract type for letting the player know which
# of multiple solutions was just solved, or if there is a single solution.
abstract type SolutionIndex end

# MultipleSolutionIndex represents the case when there are multiple
# solutions, and this shows which one was just solved.
struct MultipleSolutionIndex <: SolutionIndex
    index::Int

    MultipleSolutionIndex(index::Int) = new(index)
end

# SingleSolutionIndex represents the case when there is a single solution,
# so it's not necessary to print which word it was.
struct SingleSolutionIndex <: SolutionIndex end

# Correct is a response to the player that the guess was correct.
struct Correct <: Response
    player::Player
    guess::Guess
    solutionindex::SolutionIndex

    Correct(player::Player, guess::Guess, index::SolutionIndex = SingleSolutionIndex()) = new(player, guess, index)
end

# CurrentPuzzle is a response to a player with the current puzzle.
struct CurrentPuzzle <: Response
    player::Player
    puzzle::Word
    n_solutions::Int
end

struct Solutions <: Response
    player::Player
    solutions::Vector{Word}
end

#
# Game actions
#

"""
    gameaction!(game::NiancatGame, player::Player, guess::Guess)

Guess a word. The game will reply with correct or incorrect.
"""
function gameaction!(game::NiancatGame, player::Player, guess::Guess)
    response = if guess.word in game.solutions
        solutionindex = if length(game.solutions) == 1
            SingleSolutionIndex()
        else
            index = findfirst(item -> item == guess.word, game.solutions)
            MultipleSolutionIndex(index)
        end

        Correct(player, guess, solutionindex)
    else
        missings = game.puzzle - guess.word
        extras = guess.word - game.puzzle
        lettercorrection = LetterCorrection(missings, extras)
        Incorrect(player, guess, lettercorrection)
    end

    publish!(game.publisher, response)
end

"""
    gameaction!(game::NiancatGame, player::Player, ::ShowCurrentPuzzle)

Show the current puzzle to the player.
"""
function gameaction!(game::NiancatGame, player::Player, ::ShowCurrentPuzzle)
    publish!(game.publisher, CurrentPuzzle(player, game.puzzle, length(game.solutions)))
end

function gameaction!(game::NiancatGame, player::Player, ::ShowSolutions)
    publish!(game.publisher, Solutions(player, game.solutions))
end

"""
    generatepuzzle(dictionary::Dictionary) :: Word

Generate a puzzle for the Niancat game. The puzzle is a word in
the dictionary. Its letters are sorted and it has 9 letters.
"""
function generatepuzzle(dictionary::Dictionary) :: Word
    nineletterword = w -> length(w) == 9
    nineletterwords = collect(dictionary) |> filter(nineletterword)
    chosenword = rand(nineletterwords)
    puzzle = sort(chosenword)

    puzzle
end

end # module Niancat