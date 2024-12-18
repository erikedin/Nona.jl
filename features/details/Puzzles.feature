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

Feature: Puzzle requirements

    Scenario: The puzzle is a 9 letter word
        This is intended as a more stringent test than the similar scenario
        in Niancat.feature, which has a 50% chance of success even without
        proper implementation.

        Given a dictionary
            | DATORSPEL |
            | PUSSGURKA |
            | ORDPUSSEL |
            | LEKA      |
            | DATOR     |
            | PUSSEL    |
         When randomly generating a Niancat puzzle 30 times
         Then all randomly chosen puzzles have 9 letters

    Scenario: The puzzle can have the Swedish letters ÅÄÖ
        Given a dictionary
            | ÅTERTRÄDA |
         When randomly generating a Niancat puzzle
         Then the puzzle has 9 letters

    Scenario: Hamming puzzles are no more than 9 characters
        Given a dictionary
            | MEDELINKOMST |
            | RELATIVITET  |
            | DATORSPEL    |
            | PUSSEL       |
         When randomly generating a Hamming puzzle 30 times
         Then all randomly chosen puzzles have lengths <= 9