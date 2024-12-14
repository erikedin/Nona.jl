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

Feature: Language behavior
    In order to reduce tedious gameplay
    As a player
    I want to the game to ignore certain word features, such as case
    and some diacritics.

    Scenario: Guesses can be uppercase even if the dictionary has lowercase letters
        Given a dictionary
            | datorspel |
          And a Niancat puzzle datorsple
         When Alice guesses DATORSPEL
         Then the response is that DATORSPEL is correct

    Scenario: Guesses can be lowercase even if the dictionary is uppercase
        Given a dictionary
            | DATORSPEL |
          And a Niancat puzzle DATORSPLE
         When Alice guesses datorspel
         Then the response is that DATORSPEL is correct

    Scenario Outline: Difference between the puzzle and the guess
        Given a puzzle <puzzle> and a <guess>
         When finding the differences
         Then the missing letters are <missing>
          And the extra letters are <extra>

        Examples:
            | puzzle | guess | missing | extra |
            | A      | B     | A       | B     |
            | AB     | B     | A       | -     |
            | ABC    | ABC   | -       | -     |
            | ABC    | ABCD  | -       | D     |
            | ABCD   | ABC   | D       | -     |
            | ABCD   | ABCE  | D       | E     |
            | AAAB   | AB    | AA      | -     |
            | ABA    | ABÖ   | A       | Ö     |
            | ABÖ    | ABA   | Ö       | A     |
            | ABÖ    | AB    | Ö       | -     |
            | AB     | ABÖ   | -       | Ö     |