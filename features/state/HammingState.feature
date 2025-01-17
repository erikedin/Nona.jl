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

@wip
Feature: Store the state of a Hamming game
    As a user that plays sporadically
    I want the game to save the state
    So that I may continue playing the Hamming game

    Background: State is stored in a temporary directory for testing
        Given a temporary directory for the state

    # TODO: When reading the state file, the puzzle should not be visible. Base64 encode the state.
    # TODO: The guesses are stored as well
    # TODO: Creating a new game, which stores the state. Then continuing the game with a loaded state has the same puzzle.
    # TODO: Create a game, store the state. Read the state back, but with a different dictionary. Check that the solution
    #       exists.
    # TODO: If the environment variable XDG_STATE_HOME is not set, it defaults to $HOME/.local/state
    #       We need to inspect the path without actually writing the state. Or make a chroot or something.