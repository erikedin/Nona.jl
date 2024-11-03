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

Feature: NonaREPL is a terminal based front-end for the games

    Background: A dictionary from a file
        Given a dictionary in the file "features/assets/test_dictionary.txt"

    Scenario: The default game is Niancat
        When NonaREPL is started
        Then the output ends with "Niancat> "

    Scenario: The prompt includes the game name
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         Then the output ends with "Niancat> "

    Scenario: Correct guess in Niancat
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the REPL user tries the guess PUSSGURKA
         Then the REPL shows "PUSSGURKA är rätt!"

    Scenario: Incorrect guess in Niancat
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the REPL user tries the guess PUSSGUKAR
         Then the REPL shows "PUSSGUKAR är inte korrekt."

    Scenario: Start a new game with a randomly generated puzzle
        When a new NonaREPL game is generated
        Then a puzzle is shown
         And that puzzle is an anagram of a word in the dictionary

    Scenario: Incorrect guesses show extra and missing letters
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the REPL user tries the guess PUSSGRUXY
         Then the REPL shows "För många: XY"
          And the REPL shows "För få   : AK"

    Scenario: If there are no extra letters, it is not shown
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the REPL user tries the guess PUSSGRUKA
         Then the REPL does not show "För många"

    Scenario: If there are no missing letters, it is not shown
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the REPL user tries the guess PUSSGRUKA
         Then the REPL does not show "För få"

    Scenario: Guess incorrectly, shows the next prompt
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the REPL user tries the guess PUSSAGURK
         Then the output ends with "> "

    Scenario: Entering command mode
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the player presses "#"
         Then the output ends with "Niancat# "

    @wip
    Scenario: Show the current puzzle using the "nian" command
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the player enters command mode
          And the player inputs "nian"
         Then the REPL shows "PUSSGRUKA"