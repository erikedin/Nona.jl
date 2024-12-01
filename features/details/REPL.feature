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

Feature: REPL details and additional tests

    Background: A dictionary
        Given a dictionary
            | REPSOLDAT |
            | DATORSPEL |
            | PUSSGURKA |
            | ORDPUSSEL |
            | SPELDATOR |
            | LEDARPOST |

    Scenario: Show the current puzzle using the "!visa" command
        Given a NonaREPL game Niancat with puzzle DATORPLES
         When the player inputs "!visa"
         Then the REPL shows "DATORPLES"

    Scenario: Using an invalid command shows an error
        Given a NonaREPL game Niancat with puzzle DATORPLES
         When the player inputs "!nonsense"
         Then the REPL shows "Okänt kommando: !nonsense"

    Scenario: Using an invalid command does not show the puzzle
        Given a NonaREPL game Niancat with puzzle DATORPLES
         When the player inputs "!nonsense"
         Then the REPL does not show "DATORPLES"

    @wip @command
    Scenario: Switch back to Niancat
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the player enters command mode
          And the player inputs "!byt Hamming"
          And the player inputs "!byt Niancat"
         Then the output ends with "Niancat> "