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

Feature: REPL interface for accessories

    Background: A dictionary with words that are easy for counting distances
        Given a dictionary
            | ABCDEF |
            | AXXXXX |
            | XBXXXX |
            | ABXXXX |

    Scenario: Showing guesses includes the distance
        Given a NonaREPL game Hamming with puzzle ABCDEF
          And the REPL player tries the guess AXXXXX
         When the player inputs "!gissningar"
         Then the REPL shows "5"

    Scenario: Showing guesses includes all current best guesses
        Given a NonaREPL game Hamming with puzzle ABCDEF
          And the REPL player tries the guess AXXXXX
          And the REPL player tries the guess XBXXXX
         When the player inputs "!gissningar"
         Then the REPL shows "AXXXXX"
          And the REPL shows "XBXXXX"

    Scenario: When making a better guess, the old ones are still shown
        Given a NonaREPL game Hamming with puzzle ABCDEF
          And the REPL player tries the guess AXXXXX
          And the REPL player tries the guess ABXXXX
         When the player inputs "!gissningar"
         Then the REPL shows "ABXXXX"
          And the REPL shows "AXXXXX"

    Scenario: Guesses are saved in state
        Given a NonaREPL game Hamming with puzzle ABCDEF
          And the REPL player tries the guess AXXXXX
          And the REPL player tries the guess XBXXXX
         When a NonaREPL game Hamming is continued
          And the player inputs "!gissningar"
         Then the REPL shows "AXXXXX"
          And the REPL shows "XBXXXX"