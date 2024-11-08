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
export User
export Guess, Response, Incorrect, Correct, ShowCurrentPuzzle, CurrentPuzzle
export NiancatPublisher
export gameaction!, publish!
export generatepuzzle
export Dictionary
export SolutionIndex, SingleSolutionIndex, MultipleSolutionIndex
export Word, LetterCorrection

import Base: convert, hash, iterate, length, isless, show, sort

# Word is a normalized string that is case-insensitive, and
# ignores some diacritics, in a Swedish-specific manner.
struct Word
    letters::String

    Word(s::AbstractString) = new(uppercase(s))
end

iterate(word::Word) = iterate(word.letters)
iterate(word::Word, state) = iterate(word.letters, state)
length(word::Word) = length(word.letters)
convert(::Type{Word}, s::String) = Word(s)
Base.:(==)(a::Word, b::Word) = a.letters == b.letters
hash(w::Word, h::UInt) = hash(w.letters, h)
isless(a::Word, b::Word) = isless(a.letters, b.letters)
show(io::IO, w::Word) = print(io, w.letters)
function sort(
    w::Word;
    alg::Base.Sort.Algorithm=Base.Sort.QuickSort,
    lt=isless,
    by=identity,
    rev::Bool=false,
    order::Base.Order.Ordering=Base.Order.Forward)

    Word(String(
        sort([c for c in w.letters];
             alg=alg, lt=lt, by=by, rev=rev, order=order)
    ))
end
Base.getindex(w::Word, index) = getindex(w.letters, index)
Base.lastindex(w::Word) = lastindex(w.letters)

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

abstract type Response end

abstract type NiancatPublisher end
publish!(::NiancatPublisher, ::Response) =  @error("Implement me")

abstract type Dictionary end

isanagram(a::Word, b::Word) = sort(a) == sort(b)

abstract type User end

struct NiancatGame
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

struct Guess
    word::Word
end

struct ShowCurrentPuzzle end

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
    user::User
    guess::Guess
    lettercorrection::LetterCorrection
end

# SolutionIndex is an abstract type for letting the user know which
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

# Correct is a response to the user that the guess was correct.
struct Correct <: Response
    user::User
    guess::Guess
    solutionindex::SolutionIndex

    Correct(user::User, guess::Guess, index::SolutionIndex = SingleSolutionIndex()) = new(user, guess, index)
end

# CurrentPuzzle is a response to a user with the current puzzle.
struct CurrentPuzzle <: Response
    user::User
    puzzle::Word
    n_solutions::Int
end

#
# Game actions
#

"""
    gameaction!(game::NiancatGame, user::User, guess::Guess)

Guess a word. The game will reply with correct or incorrect.
"""
function gameaction!(game::NiancatGame, user::User, guess::Guess)
    response = if guess.word in game.solutions
        solutionindex = if length(game.solutions) == 1
            SingleSolutionIndex()
        else
            index = findfirst(item -> item == guess.word, game.solutions)
            MultipleSolutionIndex(index)
        end

        Correct(user, guess, solutionindex)
    else
        missings = game.puzzle - guess.word
        extras = guess.word - game.puzzle
        lettercorrection = LetterCorrection(missings, extras)
        Incorrect(user, guess, lettercorrection)
    end

    publish!(game.publisher, response)
end

"""
    gameaction!(game::NiancatGame, user::User, ::ShowCurrentPuzzle)

Show the current puzzle to the user.
"""
function gameaction!(game::NiancatGame, user::User, ::ShowCurrentPuzzle)
    publish!(game.publisher, CurrentPuzzle(user, game.puzzle, length(game.solutions)))
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