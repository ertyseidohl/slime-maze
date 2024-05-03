local class = require 'lib.middleclass'

local Spritesheet = require 'spritesheet'

local Egg = class('Egg')

local EGG_SPRITESHEET = "assets/eggs.png"

function Egg.initialize()
    -- sprite
    local spritesheet = Spritesheet:new(EGG_SPRITESHEET, 16, 16)
    spritesheet:nameQuads({
        {"yellow", 1, 1},
        {"brown", 2, 1},
        {"red", 3, 1},
        {"green", 4, 1},
        {"blue", 5, 1}
    })
end

function Egg.update()
    
end

function Egg.draw()

end