local class = require 'lib.middleclass'

local Spritesheet = require 'spritesheet'
local AnimatedSprite = require 'animatedsprite'

local Player = class("Player")

NOT_MOVING = "s"
MOVING_UP = "u"
MOVING_RIGHT = "r"
MOVING_DOWN = "d"
MOVING_LEFT = "l"

PLAYER_SIZE = 10
PLAYER_SPEED = 1
CLOSE_ENOUGH = 1

PLAYER_Y_OFFSET = 8 -- the ground sprites are slightly low

IDLE_ANIMATION_RATE = 4
MOVE_ANIMATION_RATE = 8

local SLIME_IDLE_SPRITESHEET_PATH = "assets/Slimes/slime_idle_sheet.png"
local SLIME_MOVE_SPRITESHEET_PATH = "assets/Slimes/slime_move_sheet.png"

function Player:initialize(mazeX, mazeY, maze, tileSize)
    self.mazeX = mazeX
    self.mazeY = mazeY
    self.maze = maze
    self.tileSize = tileSize
    self.time = 0

    self.facingRight = true -- sprite is facing right by default

    -- velocity
    self.vx = 0
    self.vy = 0

    -- center self on current tile
    local startCenter = self:getCenterOf(self.mazeX, self.mazeY)
    self.x = startCenter["x"]
    self.y = startCenter["y"]

    self.targetMazeX = nil
    self.targetMazeY = nil

    self.moving = NOT_MOVING
    self.finishingMoveAnimation = false

    -- Idle sprite
    local idleSpritesheet = Spritesheet:new(SLIME_IDLE_SPRITESHEET_PATH, 21, 15)
    idleSpritesheet:nameQuads({
        {1, 1, 1},
        {2, 2, 1}
    })
    self.idleSprite = AnimatedSprite(idleSpritesheet)

    -- Moving sprite
    local moveSpritesheet = Spritesheet:new(SLIME_MOVE_SPRITESHEET_PATH, 21, 18)
    moveSpritesheet:nameQuads({
        {1, 1, 1},
        {2, 2, 1},
        {3, 3, 1},
        {4, 4, 1},
        {5, 5, 1},
        {6, 6, 1},
        {7, 7, 1}
    })
    self.moveSprite = AnimatedSprite(moveSpritesheet)
end

function Player:getCenterOf(mazeX, mazeY)
    -- assuming square tiles here
    return {
        ["x"] = (mazeX - 1) * self.tileSize + (self.tileSize / 2) - (PLAYER_SIZE / 2);
        ["y"] = (mazeY - 1) * self.tileSize + (self.tileSize / 2) - (PLAYER_SIZE / 2);
    }
end

function Player:validTarget(newMazeX, newMazeY)
    return self.maze:hasConnection(self.mazeX, self.mazeY, newMazeX, newMazeY)
end

function Player:update(dt)
    -- Update time for animations
    self.time = self.time + dt

    -- Figure out what keys the player is pressing
    local pressingUp = love.keyboard.isDown('w')
    local pressingDown = love.keyboard.isDown('s')
    local pressingLeft = love.keyboard.isDown('a')
    local pressingRight = love.keyboard.isDown('d')

    local pressingSomething = pressingUp or pressingDown or pressingLeft or pressingRight

    -- Update if we are facing right
    if pressingLeft and self.facingRight then
        self.facingRight = false
    elseif pressingRight and not self.facingRight then
        self.facingRight = true
    end

    -- Reset before calculating new velocity
    self.vx = 0
    self.vy = 0

    -- Case 1: player is currently still
    if self.moving == NOT_MOVING then
        if pressingUp and not pressingDown then
            if self:validTarget(self.mazeX, self.mazeY - 1) then
                self.moving = MOVING_UP
                self.targetMazeX = self.mazeX
                self.targetMazeY = self.mazeY - 1
            end
        elseif pressingDown and not pressingUp then
            if self:validTarget(self.mazeX, self.mazeY + 1) then
                self.moving = MOVING_DOWN
                self.targetMazeX = self.mazeX
                self.targetMazeY = self.mazeY + 1
            end
        elseif pressingLeft and not pressingRight then
            if self:validTarget(self.mazeX - 1, self.mazeY) then
                self.moving = MOVING_LEFT
                self.targetMazeX = self.mazeX - 1
                self.targetMazeY = self.mazeY
            end
        elseif pressingRight and not pressingLeft then
            if self:validTarget(self.mazeX + 1, self.mazeY) then
                self.moving = MOVING_RIGHT
                self.targetMazeX = self.mazeX + 1
                self.targetMazeY = self.mazeY
            end
        end
    else -- we are moving
        -- switching directions
        if self.moving == MOVING_RIGHT and pressingLeft then
            self.targetMazeX = self.mazeX
        elseif self.moving == MOVING_LEFT and pressingRight then
            self.targetMazeX = self.mazeX
        elseif self.moving == MOVING_UP and pressingDown then
            self.targetMazeY = self.mazeY
        elseif self.moving == MOVING_DOWN and pressingUp then
            self.targetMazeY = self.mazeY
        end

        -- update position toward target
        local target = self:getCenterOf(self.targetMazeX, self.targetMazeY)
        if math.abs(target["y"] - self.y) <= CLOSE_ENOUGH and math.abs(target["x"] - self.x) <= CLOSE_ENOUGH then
            self.moving = NOT_MOVING
            self.mazeX = self.targetMazeX
            self.mazeY = self.targetMazeY
            self.targetMazeX = nil
            self.targetMazeY = nil
        else
            if self.y < target["y"] then
                self.vy = PLAYER_SPEED
            elseif self.y > target["y"] then
                self.vy = -PLAYER_SPEED
            elseif self.x < target["x"] then
                self.vx = PLAYER_SPEED
            elseif self.x > target["x"] then
                self.vx = -PLAYER_SPEED
            end
        end
    end

    self.x = self.x + self.vx
    self.y = self.y + self.vy
end

function Player:draw(renderInfo)
    -- Draw debug player
    -- if self.finishingMoveAnimation then
    --     love.graphics.setColor(0, 1, 0)
    -- else
    --     love.graphics.setColor(1, 1, 1)
    -- end
    -- love.graphics.rectangle("fill", self.x, self.y, PLAYER_SIZE, PLAYER_SIZE)
    -- love.graphics.reset()

    -- Draw animated player sprite
    if self.moving == NOT_MOVING and not self.finishingMoveAnimation then
        local animationIndex = math.floor((self.time * IDLE_ANIMATION_RATE) % self.idleSprite:getFrameCount()) + 1
        self.idleSprite:draw(animationIndex, self.x, self.y - PLAYER_Y_OFFSET, not self.facingRight)
    else
        local moveFrameCount = self.moveSprite:getFrameCount()
        local animationIndex = math.floor((self.time * MOVE_ANIMATION_RATE) % moveFrameCount) + 1
        self.moveSprite:draw(animationIndex, self.x, self.y - PLAYER_Y_OFFSET, not self.facingRight)
        self.finishingMoveAnimation = animationIndex ~= 1 -- quit move anim on frame 1
    end

    -- Draw debug player target
    -- if self.targetMazeX and self.targetMazeY then
    --     local targetCenter = self:getCenterOf(self.targetMazeX, self.targetMazeY)
    --     love.graphics.setColor(1, 0, 0)
    --     love.graphics.rectangle("fill", targetCenter["x"], targetCenter["y"], PLAYER_SIZE, PLAYER_SIZE)
    --     love.graphics.reset()
    -- end
end

return Player