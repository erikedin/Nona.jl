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

@wip @newcommand
Feature: Command mode removal
    The command mode will not function as anticipated, so it should be removed
    in favor of a simpler command syntax. This feature collects scenarios
    that ensures that command mode is removed properly.

    Scenario: Entering command mode
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the player presses "#"
         Then the output ends with "Niancat> "

    Scenario: Show the current puzzle using the "!nian" command
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the player enters command mode
          And the player inputs "!nian"
         Then the REPL shows "PUSSGRUKA"

    Scenario: Showing the puzzle changes the mode back to game mode
        Given a NonaREPL game Niancat with puzzle PUSSGRUKA
         When the player enters command mode
          And the player inputs "!nian"
         Then the output ends with "Niancat> "
