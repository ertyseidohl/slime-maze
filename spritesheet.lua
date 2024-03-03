local class = require 'lib.middleclass'

local Spritesheet = class('Spritesheet')

function Spritesheet:initialize(path, tileWidth, tileHeight)
    self.path = path
    self.tileWidth = tileWidth
    self.tileHeight = tileHeight
    self.image = love.graphics.newImage(path)
    self.namedQuads = {}
end

function Spritesheet:nameQuadAt(key, x, y)
    assert(
        self.namedQuads[key] == nil,
        "key '" .. key .. "' already defined for spritesheet" .. self.path
    )
    -- Note switch from 1-based index to 0-based pixel offset
    self.namedQuads[key] = love.graphics.newQuad(
        (x - 1) * self.tileWidth,
        (y - 1) * self.tileHeight,
        self.tileWidth,
        self.tileHeight,
        self.image
    )
end

function Spritesheet:nameQuads(quadInfo)
    for _, info in ipairs(quadInfo) do
        self:nameQuadAt(info[1], info[2], info[3])
    end
end

function Spritesheet:getNamedQuad(key)
    assert(
        key,
        "Key was nil in getNamedQuad"
    )
    assert(
        self.namedQuads[key],
        "Named quad '" .. key .. "' not in spritesheet" .. self.path
    )
    return self.namedQuads[key]
end

function Spritesheet:getNamedQuadCount()
    -- Only counts integer indexed quads
    return #self.namedQuads
end

return Spritesheet