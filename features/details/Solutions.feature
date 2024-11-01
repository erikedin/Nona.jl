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

Feature: Solutions
    As a group of players
    We need to have consistent identifiers for each solution
    So that we compare progress between ourselves


    Background: A dictionary
        Given a dictionary
            | REPSOLDAT |
            | DATORSPEL |
            | PUSSGURKA |
            | ORDPUSSEL |
            | SPELDATOR |
            | LEDARPOST |

    @wip
    Scenario Outline: Solutions are indexed in alphabetical order
        Given a Niancat puzzle DATORSPLE
         When Alice guesses <word>
         Then the response is that <word> is the solution with index <index>

      Examples:
            | word      | index |
            | DATORSPEL | 1     |
            | LEDARPOST | 2     |
            | REPSOLDAT | 3     |
            | SPELDATOR | 4     |

    # If a puzzle has several possible solutions, we want to see which solution it is:
    # > Alice solved the puzzle with word 2
    # but if there is only a single possible solution, then we omit the index
    # > Alice solved the puzzle
    # This scenario ensures that the front-end has enough information in the response
    # itself, that it does not have to keep in its state how many solutions there are.
    Scenario: Puzzles with a single solution may ignore the index
        Given a Niancat puzzle PUSSGUKAR
         When Alice guesses PUSSGURKA
         Then the response indicates that Alice has found the only possible solution PUSSGURKA