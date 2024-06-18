local class = require 'lib.middleclass'

local Spritesheet = require 'spritesheet'

local Egg = class('Egg')

local EGG_SPRITESHEET = "assets/eggs.png"
local EGG_QUADS = {
    [1] = {"brown", 2, 1},
    [2] = {"red", 3, 1},
    [3] = {"yellow", 1, 1},
    [4] = {"blue", 5, 1}
}
local WIGGLE_AMOUNT = 1
local WIGGLE_RATE = 3
local ACQUIRING_ANIMATION_FRAMES = {2, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 3, 2.7, 2.4, 1.6, 1.3, 1}

local WAITING_SCALE_FACTOR = 2
local ACQUIRED_SCALE_FACTOR = 1

local EGG_STATE_WAITING = 1
local EGG_STATE_ACQUIRING = 2
local EGG_STATE_ACQUIRED = 3

local ORBIT_DISTANCE = 32

local WAITING_OFFSET_X = 24
local WAITING_OFFSET_Y = 16
local ACQUIRED_OFFSET_X = 4
local ACQUIRED_OFFSET_Y = -8

function Egg:initialize(mazeX, mazeY, playerIndex, renderInfo)
    self.mazeX = mazeX
    self.mazeY = mazeY
    self.currentTime = 0
    self.renderInfo = renderInfo
    self.playerIndex = playerIndex
    self.state = EGG_STATE_WAITING
    self.acquiringAnimationFrame = 1
    self.player = nil
    -- sprite
    self.spritesheet = Spritesheet:new(EGG_SPRITESHEET, 16, 16)
    self.spritesheet:nameQuadAt(EGG_QUADS[playerIndex][1], EGG_QUADS[playerIndex][2], EGG_QUADS[playerIndex][3])
end

function Egg:update(dt, playerEggCount, eggIndex)
    local radiansPerEgg = (math.pi * 2) / playerEggCount
    local radiansOffset = eggIndex * radiansPerEgg
    self.currentTime = self.currentTime + (dt * WIGGLE_RATE)
    if self.state == EGG_STATE_WAITING then
        self.x = math.floor(self.renderInfo.tileSize * (self.mazeX - 1) + (math.cos(self.currentTime) * WIGGLE_AMOUNT))
        self.y = math.floor(self.renderInfo.tileSize * (self.mazeY - 1))
    elseif self.state == EGG_STATE_ACQUIRING then
        self.x = math.floor(self.renderInfo.tileSize * (self.mazeX - 1))
        self.y = math.floor(self.renderInfo.tileSize * (self.mazeY - 1))
        self.acquiringAnimationFrame = self.acquiringAnimationFrame + 1
        if (self.acquiringAnimationFrame > #ACQUIRING_ANIMATION_FRAMES) then
            self.state = EGG_STATE_ACQUIRED
        end
    elseif self.state == EGG_STATE_ACQUIRED then
        self.x = math.floor(self.player.x + (math.cos(self.currentTime + radiansOffset) * ORBIT_DISTANCE))
        self.y = math.floor(self.player.y + (math.sin(self.currentTime + radiansOffset) * ORBIT_DISTANCE))
    end
end

function Egg:draw(config)
    if self.state == EGG_STATE_WAITING then
        local spriteX = self.x + config.offsetX + WAITING_OFFSET_X
        local spriteY = self.y + config.offsetY + WAITING_OFFSET_Y
        love.graphics.draw(
            self.spritesheet.image, -- drawable
            self.spritesheet:getNamedQuad(EGG_QUADS[self.playerIndex][1]), -- quad
            spriteX - 1, -- x, 1-based index to 0-based offet
            spriteY - 1, -- y, 1-based index to 0-based offet
            0, -- r
            WAITING_SCALE_FACTOR, -- sx
            WAITING_SCALE_FACTOR -- sy
        )
    elseif self.state == EGG_STATE_ACQUIRED then
        local spriteX = self.x + config.offsetX + ACQUIRED_OFFSET_X
        local spriteY = self.y + config.offsetY + ACQUIRED_OFFSET_Y
        love.graphics.draw(
            self.spritesheet.image, -- drawable
            self.spritesheet:getNamedQuad(EGG_QUADS[self.playerIndex][1]), -- quad
            spriteX - 1, -- x, 1-based index to 0-based offet
            spriteY - 1, -- y, 1-based index to 0-based offet
            0, -- r
            ACQUIRED_SCALE_FACTOR, -- sx
            ACQUIRED_SCALE_FACTOR -- sy
        )
    elseif self.state == EGG_STATE_ACQUIRING then
        local spriteX = self.x + config.offsetX + WAITING_OFFSET_X
        local spriteY = self.y + config.offsetY + WAITING_OFFSET_Y
        love.graphics.draw(
            self.spritesheet.image, -- drawable
            self.spritesheet:getNamedQuad(EGG_QUADS[self.playerIndex][1]), -- quad
            spriteX - 1, -- x, 1-based index to 0-based offet
            spriteY - 1, -- y, 1-based index to 0-based offet
            0, -- r
            ACQUIRING_ANIMATION_FRAMES[self.acquiringAnimationFrame], -- sx
            ACQUIRING_ANIMATION_FRAMES[self.acquiringAnimationFrame] -- sy
        )
    end
end

function Egg:canBePickedUp()
    return self.state == EGG_STATE_WAITING
end

function Egg:getPickedUp(player)
    self.state = EGG_STATE_ACQUIRING
    self.player = player
end

return Egg