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

Feature: Hamming distance game details
    Mostly these are additional test cases that don't contribute to
    understanding the game.

    Background: A dictionary
        Given a dictionary
            | DATORSPEL |
            | LEDARPOST |
            | PUSSGURKA |
            | PUSSGURAK |
            | ORDPUSSEL |
            | LEKA      |
            | KAKA      |
            | DATOR     |
            | GATOR     |
            | PUSSEL    |

    Scenario: Guesses must be the same length as the puzzle
        Given a Hamming puzzle LEKA
         When Alice guesses DATORSPE
         Then the response is that the word length must be 4 letters

    Scenario Outline: Distance for an incorrect guess
        Given a Hamming puzzle <puzzle>
         When Alice guesses <guess>
         Then the response is that the Hamming distance is <distance>

      Examples:
        | puzzle    | guess     | distance |
        | LEKA      | KAKA      | 2        |
        | DATORSPEL | LEDARPOST | 8        |
        | ORDPUSSEL | PUSSGURKA | 9        |

    Scenario: Correct guess in Hamming
        Given a NonaREPL game Hamming with puzzle PUSSGURKA
         When the REPL player tries the guess PUSSGURKA
         Then the REPL shows "PUSSGURKA är rätt!"

    Scenario: Incorrect guess in Hamming
        Given a NonaREPL game Hamming with puzzle PUSSGURKA
         When the REPL player tries the guess PUSSGURAK
         Then the REPL shows "2"

    Scenario: Incorrect word length in guess in Hamming
        Given a NonaREPL game Hamming with puzzle LEKA
         When the REPL player tries the guess PUSSGURKA
         Then the REPL shows "4"