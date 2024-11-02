#!/usr/bin/env -S julia
#
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

# Activate the Nona environment automatically, from the path of this script,
# not where the user is running the script from.
using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))
Pkg.instantiate()

# The dictionary.txt config file contains the path to the dictionary.
# It is not the dictionary itself.
dictionaryconfigpath = expanduser("~/.config/niancatrepl/dictionary.txt")

# Read the dictionary path from the config file.
dictionarypath = open(dictionaryconfigpath, "r") do io
    strip(read(io, String))
end

using Nona.NonaREPL

dictionary = FileDictionary(String(dictionarypath))

#game = NonaREPL.newgame(dictionary)
#
#g = s -> guess(game, s)

NonaREPL.run(dictionary)
