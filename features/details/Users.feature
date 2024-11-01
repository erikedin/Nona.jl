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

Feature: Users
    In order to support different types of users, the game
    needs to be transparent to the type of user.

    Background: A dictionary
        Given a dictionary
            | DATORSPEL |
            | LEDARPOST |
            | PUSSGURKA |
            | ORDPUSSEL |

    # The main scenarios use a simple user implementation that is simply
    # a string. More complex user implementations, such as in Slack where
    # there is a distinction between the user id and the display name,
    # need to be supported. This scenario tests that such users are
    # supported.
    Scenario: Front-end specific users
        Given a Niancat puzzle ORDPUSSLE
          And a front-end specific user Angleton with display name James
         When Angleton guesses ORDPUSSEL
         Then the response is that Angleton guessed ORDPUSSEL correctly