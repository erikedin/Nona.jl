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

module Accessories

export GameWithAccessories

using Nona.Games
import Nona.Games: gameaction!, gamename, gametype
import Nona.Games.States: gamestate, savestate

#
# GameWithAccessories
# Exposes a unified interface for sending commands to games or accessories.
#

struct GameWithAccessories{G <: Game} <: Game
    game::G
    accessory::Accessory{G}
end

gameaction!(game::GameWithAccessories{G}, player::Player, command::GameCommand) where {G} = gameaction!(game.game, player, command)
gameaction!(game::GameWithAccessories{G}, player::Player, command::AccessoryCommand) where {G} = gameaction!(game.accessory, player, command)
gamename(game::GameWithAccessories{G}) where {G} = gamename(game.game)
gametype(game::GameWithAccessories{G}) where {G} = gametype(game.game)

gamestate(g::GameWithAccessories) = gamestate(g.game)

# The generic implementation of this method saves only the game state.
# This implementation is specialized to save the state of all accessories, too.
function savestate(g::GameWithAccessories)
    savestate(gamestate(g.game))
    savestate(gamestate(g.accessory))
end

end