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

Feature: Keeping track of the current guesses in Hamming
    In order to help the player keep track of good guesses
    a Hamming accessory will listen to guesses and show them.

    Background: A dictionary
        Given a dictionary
            | ABCDEF |
            | AXXXXX |
            | XBXXXX |
            | ABXXXX |
            | ABCXXX |
            | ABCDXX |

    Scenario: No guesses made yet
        Given a Hamming puzzle ABCDEF
          And a Hamming accessory for guesses
         When Alice requests all guesses
         Then there are no guesses

    Scenario: A single best guess
        Given a Hamming puzzle ABCDEF
          And a Hamming accessory for guesses
         When Alice guesses AXXXXX
          And Alice requests all guesses
         Then a guess is distance 5 with words
            | AXXXXX |

    Scenario: Two best guesses
        Given a Hamming puzzle ABCDEF
          And a Hamming accessory for guesses
         When Alice guesses AXXXXX
          And Alice guesses XBXXXX
          And Alice requests all guesses
         Then a guess is distance 5 with words
            | AXXXXX |
            | XBXXXX |

    Scenario: A new better guess does not invalidate worse guesses
        Given a Hamming puzzle ABCDEF
          And a Hamming accessory for guesses
         When Alice guesses AXXXXX
          And Alice guesses ABXXXX
          And Alice requests all guesses
         Then a guess is distance 4 with words
            | ABXXXX |
          And a guess is distance 5 with words
            | AXXXXX |

    Scenario: The best guesses are last in the list
        Given a Hamming puzzle ABCDEF
          And a Hamming accessory for guesses
         When Alice guesses AXXXXX
          And Alice guesses XBXXXX
          And Alice guesses ABXXXX
          And Alice guesses ABCXXX
          And Alice guesses ABCDXX
          And Alice requests all guesses
         Then guesses with distance 5 come before distance 4 guesses
          And guesses with distance 4 come before distance 3 guesses
          And guesses with distance 3 come before distance 2 guesses