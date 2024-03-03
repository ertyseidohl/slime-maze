local class = require 'lib.middleclass'

local Player = class("Player")

local ACCEL_RATE = 0.5
local FRICTION_MULTIPLIER = 0.8
local MAX_VELOCITY = 3

function Player:initialize(x, y)
    self.x = x
    self.y = y
    self.vx = 0
    self.vy = 0
end

function Player:update()
    local movingUp = love.keyboard.isDown('w')
    local movingDown = love.keyboard.isDown('s')
    local movingLeft = love.keyboard.isDown('a')
    local movingRight = love.keyboard.isDown('d')

    local ax = 0
    local ay = 0

    if movingUp and not movingDown then
        ay = -ACCEL_RATE
    end
    if movingDown and not movingUp then
        ay = ACCEL_RATE
    end
    if movingLeft and not movingRight then
        ax = -ACCEL_RATE
    end
    if movingRight and not movingLeft then
        ax = ACCEL_RATE
    end

    -- Apply acceleration to velocity
    self.vx = self.vx + ax
    self.vy = self.vy + ay

    -- Cap velocity
    if self.vx > MAX_VELOCITY then
        self.vx = MAX_VELOCITY
    end
    if self.vy > MAX_VELOCITY then
        self.vy = MAX_VELOCITY
    end

    -- Apply velocity to position
    self.x = self.x + self.vx
    self.y = self.y + self.vy

    -- Apply friction to velocity for next frame
    self.vx = self.vx * FRICTION_MULTIPLIER
    self.vy = self.vy * FRICTION_MULTIPLIER
end

function Player:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", self.x, self.y, 10, 10)
end

return Player