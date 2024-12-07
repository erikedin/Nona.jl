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

@wip
Feature: Keeping track of the current best guesses in Hamming
    In order to help the player keep track of good guesses
    a Hamming accessory will listen to guesses and show them.

    Background: A dictionary
        Given a dictionary
            | ABCDEF |
            | AXXXXX |
            | XBXXXX |
            | ABXXXX |

    # TODO: Insert the accesory somewhere
    Scenario: No guesses made yet
        Given a Hamming puzzle ABCDEF
         When Alice requests the best guesses
         Then there are not best guesses

    Scenario: A single best guess
        Given a Hamming puzzle ABCDEF
         When Alice guesses AVWXYZ
          And Alice requests the best guesses
         Then the best guesses are distance 5

    Scenario: Two best guesses
        Given a Hamming puzzle ABCDEF
         When Alice guesses AXXXXX
          And Alice guesses XBXXXX
          And Alice requests the best guesses
         Then the best guesses are distance 5
            | AXXXXX |
            | XBXXXX |

    Scenario: A new better guess clears the older worse guesses
        Given a Hamming puzzle ABCDEF
         When Alice guesses AXXXXX
          And Alice guesses ABXXXX
          And Alice requests the best guesses
         Then the best guesses are distance 4
            | ABXXXX |