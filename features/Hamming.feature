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

Feature: Hamming distance game
    The game is to guess a word, and only the length of the word and the
    Hamming distance to any guess is known.

    Background: A dictionary
        Given a dictionary
            | DATORSPEL |
            | LEDARPOST |
            | PUSSGURKA |
            | ORDPUSSEL |
            | LEKA      |
            | DATOR     |
            | PUSSEL    |

    Scenario: A correct guess has Hamming distance 0
        Given a Hamming puzzle DATORSPEL
         When Alice guesses DATORSPEL
         Then the Hamming response is that DATORSPEL is correct

    @wip
    Scenario: Get the current puzzle
        Given a Hamming puzzle PUSSGURKA
         When Alice gets the Hamming puzzle
         Then the Hamming puzzle response is "9"

    @wip
    Scenario: Get the current puzzle
        Given a Hamming puzzle LEKA
         When Alice gets the Hamming puzzle
         Then the Hamming puzzle response is "4"

    @wip
    Scenario: A guess with only one different letter has distance 1
        Given a Hamming puzzle DATORSPEL
         When Alice guesses DATORSPEX
         Then the response is that the Hamming distance is 1

    @wip
    Scenario: Guesses must be the same length as the puzzle
        Given a Hamming puzzle DATORSPEL
         When Alice guesses DATORSPE
         Then the response is that the word must be 9 letters