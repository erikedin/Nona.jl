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

Feature: Niancat
    As a resident of the Konsulatet Slack
    I want to play the Konsulatet variant of nian
    So that I can enjoy myself

    Background: A dictionary
        Given a dictionary
            | DATORSPEL |
            | LEDARPOST |
            | PUSSGURKA |
            | ORDPUSSEL |

    Scenario: Guess a word
        Given a Niancat puzzle DATORSPLE
         When Alice guesses DATORPLES
         Then the response is that DATORPLES is incorrect

    Scenario: Solve the puzzle with one of two possible solution
        Given a Niancat puzzle DATORSPLE
         When Alice guesses DATORSPEL
         Then the response is that DATORSPEL is correct

    Scenario: Solve the puzzle with the other of two possible solution
        Given a Niancat puzzle DATORSPLE
         When Alice guesses LEDARPOST
         Then the response is that LEDARPOST is correct

    Scenario: Solve the puzzle with the only possible solution
        Given a Niancat puzzle PUSSGUKRA
         When Alice guesses PUSSGURKA
         Then the response is that PUSSGURKA is correct

    Scenario: Get the current puzzle
        Given a Niancat puzzle PUSSGUKRA
         When Alice gets the puzzle
         Then the puzzle response is PUSSGUKRA

    Scenario: Showing the puzzle also includes how many solutions there are
        Given a Niancat puzzle DATORSPLE
         When Alice gets the puzzle
         Then the puzzle response includes that there are 2 solutions

    Scenario: The first alphabetical solution has index 1
        Given a Niancat puzzle DATORSPLE
         When Alice guesses DATORSPEL
         Then the response is that DATORSPEL is the solution with index 1

    Scenario: The second alphabetical solution has index 2
        Given a Niancat puzzle DATORSPLE
         When Alice guesses LEDARPOST
         Then the response is that LEDARPOST is the solution with index 2

    Scenario: Guess a word with the wrong letters
        Given a Niancat puzzle DATORSPLE
         When Alice guesses DATORSPXY
         Then the response is that DATORSPXY is incorrect
          And the letters EL are missing
          And the letters XY are extra

    Scenario: The puzzle is chosen from a dictionary
        Given a dictionary
            | DATORSPEL |
            | PUSSGURKA |
            | ORDPUSSEL |
            | LEKA      |
            | DATOR     |
            | PUSSEL    |
         When randomly generating a Niancat puzzle
         Then the puzzle is an anagram of a word in the dictionary

    Scenario: The puzzle is an anagram sorted in alphabetical order
        Given a dictionary
            | DATORSPEL |
            | PUSSGURKA |
            | ORDPUSSEL |
            | LEKA      |
            | DATOR     |
            | PUSSEL    |
         When randomly generating a Niancat puzzle
         Then the letters in the puzzle are sorted in alphabetical order

    Scenario: The puzzle is a 9 letter word
        Given a dictionary
            | DATORSPEL |
            | PUSSGURKA |
            | ORDPUSSEL |
            | LEKA      |
            | DATOR     |
            | PUSSEL    |
         When randomly generating a Niancat puzzle
         Then the puzzle has 9 letters

    Scenario: Show solution
        Given a Niancat puzzle PUSSGUKRA
         When Alice shows the solutions
         Then the solutions response is
            | PUSSGURKA |