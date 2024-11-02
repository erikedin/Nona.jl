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

@given("a puzzle {String} and a {String}") do context, puzzle, guess
    context[:puzzle] = Word(puzzle)
    context[:guess] = Word(guess)
end

@when("finding the differences") do context
    puzzle = context[:puzzle]
    guess = context[:guess]

    missingletters = puzzle - guess
    extraletters = guess - puzzle

    context[:missing] = missingletters
    context[:extra] = extraletters
end

@then("the missing letters are {String}") do context, expectedstring
    missingletters = context[:missing]

    if expectedstring == "-"
        expectedstring = ""
    end
    expected = Word(expectedstring)

    @expect missingletters == expected
end

@then("the extra letters are {String}") do context, expectedstring
    extra = context[:extra]

    # Workaround for a bug in Behavior where an empty cell
    # causes an exception to be thrown. Instead, let - mean
    # that there are no extra letters.
    if expectedstring == "-"
        expectedstring = ""
    end
    expected = Word(expectedstring)

    @expect extra == expected
end
