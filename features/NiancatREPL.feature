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

Feature: Niancat in the Julia REPL
    In order for the game to be abstracted from the service where it is played
    As a developer
    I want to be able to play the game in the Julia REPL

    Background: A dictionary from a file
        Given a dictionary in the file "features/assets/test_dictionary.txt"

    Scenario: Guess correctly
        Given a REPL Niancat game with puzzle PUSSGRUKA
         When the REPL user tries the guess PUSSGURKA
         Then the REPL shows "PUSSGURKA är rätt!"

    Scenario: Guess incorrectly
        Given a REPL Niancat game with puzzle PUSSGRUKA
         When the REPL user tries the guess PUSSAGURK
         Then the REPL shows "PUSSAGURK är inte korrekt."

    Scenario: Start a new game with a randomly generated puzzle
        When a new NiancatREPL game is generated
        Then a puzzle is shown
         And that puzzle is an anagram of a word in the dictionary

    Scenario: Incorrect guesses show extra and missing letters
        Given a REPL Niancat game with puzzle PUSSGRUKA
         When the REPL user tries the guess PUSSGRUXY
         Then the REPL shows "För många: XY"
          And the REPL shows "För få   : AK"

    Scenario: If there are no extra letters, it is not shown
        Given a REPL Niancat game with puzzle PUSSGRUKA
         When the REPL user tries the guess PUSSGRUKA
         Then the REPL does not show "För många"

    Scenario: If there are no missing letters, it is not shown
        Given a REPL Niancat game with puzzle PUSSGRUKA
         When the REPL user tries the guess PUSSGRUKA
         Then the REPL does not show "För få"
