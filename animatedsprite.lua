local class = require 'lib.middleclass'

local Spritesheet = require 'spritesheet'

local AnimatedSprite = class('AnimatedSprite')

function AnimatedSprite:initialize(spritesheet)
    self.spritesheet = spritesheet
end

function AnimatedSprite:getFrameCount()
    return self.spritesheet:getNamedQuadCount()
end

function AnimatedSprite:draw(frameIndex, x, y, flipX)
    local animationQuad = self.spritesheet:getNamedQuad(frameIndex)
    local flipXScale = 1
    local flipOffset = 0
    if flipX then
        flipXScale = -1
        flipOffset = -self.spritesheet.tileWidth
    end
    love.graphics.draw(
        self.spritesheet.image,
        animationQuad,
        x - flipOffset,
        y,
        0, -- r
        flipXScale, -- sx
        1 -- sy
    )
end

return AnimatedSprite