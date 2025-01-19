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

using Behavior
using Base.Filesystem
using Nona.Games.States

@given("a state directory which does not exist") do context
    statepath = mktempdir(; prefix="nonadev_jl_")
    statehome = joinpath(statepath, "doesnotexist")
    ENV["XDG_STATE_HOME"] = statehome
end

@given("with the games state saved to disk") do context
    game = context[:game]
    savestate(game)
end

@when("the state is read from disk") do context
    game = context[:game]
    gamestatetype = typeof(gamestate(game))

    # This method isn't exported because it's an implementation detail,
    # but the exported functions decode the state data, and we want
    # to read the actual string stored on disk.
    statetext = States.readstatedata(gamestatetype)

    context[:statetext] = statetext
end

@then("the text {String} is not visible") do context, s
    statetext = context[:statetext]

    @expect !contains(statetext, s)
end