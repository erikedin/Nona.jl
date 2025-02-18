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
         When the REPL player tries the guess PUSSGURKA
         Then the REPL shows "PUSSGURKA är rätt!"

    Scenario: Incorrect guess in Niancat
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the REPL player tries the guess PUSSGUKAR
         Then the REPL shows "PUSSGUKAR är inte korrekt."

    Scenario: Start a new game with a randomly generated puzzle
        When a new NonaREPL game is generated
        Then a puzzle is shown
         And that puzzle is an anagram of a word in the dictionary

    Scenario: Incorrect guesses show extra and missing letters
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the REPL player tries the guess PUSSGRUXY
         Then the REPL shows "För många: XY"
          And the REPL shows "För få   : AK"

    Scenario: If there are no extra letters, it is not shown
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the REPL player tries the guess PUSSGRUKA
         Then the REPL does not show "För många"

    Scenario: If there are no missing letters, it is not shown
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the REPL player tries the guess PUSSGRUKA
         Then the REPL does not show "För få"

    Scenario: Guess incorrectly, shows the next prompt
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the REPL player tries the guess PUSSAGURK
         Then the output ends with "> "

    Scenario: Show the current puzzle using the "!nian" command
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the player inputs "!visa"
         Then the REPL shows "PUSSGRUKA"

    Scenario: Nona shows the number of solutions when starting a new game
        Given a dictionary
            | DATORSPEL |
            | LEDARPOST |
            | SPELDATOR |
            | REPSOLDAT |
            | PUSSGURKA |
            | ORDPUSSEL |
         When starting a NonaREPL game Niancat with puzzle DATORSPLE
         Then the REPL shows "4"

    Scenario: Nona does not show the number of solutions when there is only one
        Given a dictionary
            | DATORSPEL |
            | PUSSGURKA |
            | ORDPUSSEL |
         When starting a NonaREPL game Niancat with puzzle DATORSPLE
         Then the REPL does not show "1"

    Scenario: Start a new game
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the player inputs "!nytt"
         Then a puzzle is shown
          And that puzzle is an anagram of a word in the dictionary

    Scenario: Starting a new game shows the solutions to the previous puzzle
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the player inputs "!nytt"
         Then the REPL shows "PUSSGURKA"

    Scenario: Starting a new game shows all solutions to the previous puzzle
        Given a dictionary
            | DATORSPEL |
            | LEDARPOST |
            | SPELDATOR |
            | REPSOLDAT |
            | PUSSGURKA |
            | ORDPUSSEL |
          And a NonaREPL game Niancat with puzzle DATORSPLE
         When the player inputs "!nytt"
         Then the REPL shows "DATORSPEL"
          And the REPL shows "SPELDATOR"
          And the REPL shows "LEDARPOST"
          And the REPL shows "REPSOLDAT"

    Scenario: Start another type of new game
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the player inputs "!nytt Hamming"
         Then the output ends with "Hamming> "

    Scenario: Starting a new Hamming game shows the solutions to the previous puzzle
        Given a NonaREPL game Hamming with puzzle PUSSGURKA
         When the player inputs "!nytt"
         Then the REPL shows "PUSSGURKA"

    Scenario: Hamming guesses must be in the dictionary
        Given a NonaREPL game Hamming with puzzle PUSSGURKA
         When the REPL player tries the guess PUSSGURAK
         Then the REPL shows "Ordet PUSSGURAK finns inte i ordlistan."

    Scenario: Switch to another type of new game
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the player inputs "!spel Hamming"
         Then the output ends with "Hamming> "

    Scenario: Switching back retains the same puzzle as before
        Given a NonaREPL game Hamming with puzzle PUSSGRUKA
          And the game state is recorded
         When the player inputs "!spel Niancat"
          And the player inputs "!spel Hamming"
         Then the game state is unchanged

    Scenario: Starting a new game resets the state
        Given a NonaREPL game Hamming with puzzle PUSSGRUKA
          And the game state is recorded
         When the player inputs "!spel Niancat"
          And the player inputs "!nytt Hamming"
         Then the game state is changed

    Scenario: Switching to a game with no previous state, saves the state
        This checks that the state is saved when a new game is created
        using the switching mechanic.

        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the player inputs "!spel Hamming"
          And the game state is recorded
          And the player inputs "!spel Niancat"
          And the player inputs "!spel Hamming"
         Then the game state is unchanged

    Scenario: The state directory is created if it does not exist
        This works by ensuring that the state directory does not exist, then
        check that the state is really recorded.

        Given a state directory which does not exist
          And a NonaREPL game Hamming with puzzle PUSSGURKA
         When the game state is recorded
          And the player inputs "!spel Niancat"
          And the player inputs "!spel Hamming"
         Then the game state is unchanged