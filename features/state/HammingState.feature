# MIT License
#
# Copyright (c) 2025 Erik Edin
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

Feature: Store the state of a Hamming game
    As a user that plays sporadically
    I want the game to save the state
    So that I may continue playing the Hamming game

    Background: A dictionary
        Given a dictionary
            | DATORSPEL |
            | DATORSPEX |
            | LEDARPOST |
            | PUSSGURKA |
            | ORDPUSSEL |
            | LEKA      |
            | DATOR     |
            | PUSSEL    |

    Scenario: Create a game with state from a previous game
        Given a Hamming puzzle PUSSGURKA
          And with the games state saved to disk
          And a Hamming game started with an existing state
         When Alice guesses PUSSGURKA
         Then the Hamming response is that PUSSGURKA is correct

    Scenario: The puzzle should be encoded to prevent accidental reveal
        Given a Hamming puzzle PUSSGURKA
          And with the games state saved to disk
         When the state is read from disk
         Then the text PUSSGURKA is not visible

    Scenario: Guesses are also stored as state
        Given a Hamming game with a guess accessory and puzzle PUSSGURKA
          And Alice guesses ORDPUSSEL
          And with the games state saved to disk
         When a Hamming game with a guess accessory is continued
          And Alice requests all guesses
         Then there is a guess ORDPUSSEL

    # TODO: State is stored per dictionary. Change the dictionary in any way -> new state.