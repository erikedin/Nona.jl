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

module States

using Nona.Games

export
    loadstate,
    savestate,
    gamestate,
    statename

function makestatepath(::Type{T}) where {T}
    statedirpath = get(ENV, "XDG_STATE_HOME", expanduser("~/.local/state"))
    joinpath(statedirpath, "Nona", "$(statename(T)).state")
end

function readstatedata(::Type{T}) :: String where {T}
    statepath = makestatepath(T)
    open(statepath, "r") do io
        read(io, String)
    end
end

function loadstate(::Type{T}) :: T where {T}
    statedata = readstatedata(T)
    T(statedata)
end

function savestate(state::T) where {T}
    statepath = makestatepath(T)

    # Ensure that the state directory exists.
    mkpath(dirname(statepath))

    open(statepath, "w") do io
        write(io, convert(String, state))
    end
end

# savestate gets the state of the game and saves it to disk.
# This is specialized by GameWithAccessories, because it needs to save
# the accessory state, too.
function savestate(game::Game)
    savestate(gamestate(game))
end

#
# Interface to the games.
# Games are expected to implement these functions.
#

# gamestate is an accessor that returns the game state for a given game object
gamestate(g::Game) = error("Implement gamestate($(typeof(g)))")
# Also for accessories.
gamestate(a::Accessory{<:Game}) = error("Implement gamestate($(typeof(a)))")

# statename returns the name of a state.
statename(t::Type{T}) where {T} = error("Implement statename($(t))")

end