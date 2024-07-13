local class = require 'lib.middleclass'

local AnimatedSprite = require 'animatedsprite'

local StateMenu = class('StateMenu')

local WIGGLE_FACTOR = 10
local DEBOUNCE_AMOUNT = 60 -- 1 sec

local JOIN_BUTTONS = {
    [1] = "1",
    [2] = "2",
    [3] = "3",
    [4] = "4"
}

local PLAYER_COLORS = {
    {1, 0.5, 0.5}, -- pink
    {0.8, 0.2, 0.2}, -- red
    {0.2, 0.8, 0.2}, -- green
    {0.2, 0.2, 0.8} -- blue
}

local IDLE_COLOR = {
    0.3, 0.3, 0.3
}

local PLAYER_RECT_BUFFER = 10
local PLAYER_RECT_Y = 100
local PLAYER_RECT_HEIGHT = 300
local PLAYER_SPRITE_Y = 200
local SPRITE_X_OFFSET = 8
local MOVE_ANIMATION_RATE = 8

function StateMenu:initialize(stateTransitionFunction, transitionConfig, spritesheets)
    self.stateTransitionFunction = stateTransitionFunction
    self.time = 0
    self.debounceTimers = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0
    }

    self.playersIn = {
        [1] = false,
        [2] = false,
        [3] = false,
        [4] = false
    }

    self.playerIdleSprites = {
        [1] = AnimatedSprite(spritesheets["1idle"]),
        [2] = AnimatedSprite(spritesheets["2idle"]),
        [3] = AnimatedSprite(spritesheets["3idle"]),
        [4] = AnimatedSprite(spritesheets["4idle"])
    }

    self.playerMoveSprites = {
        [1] = AnimatedSprite(spritesheets["1move"]),
        [2] = AnimatedSprite(spritesheets["2move"]),
        [3] = AnimatedSprite(spritesheets["3move"]),
        [4] = AnimatedSprite(spritesheets["4move"])
    }

    local playersInCount = 0
end

function StateMenu:enterState()
    print("menu enter state")
end

function StateMenu:exitState()
    love.graphics.reset()
    print("menu exit state")
end

function StateMenu:update(dt)
    self.time = self.time + dt
    -- Roll down debounce timers
    for i, amount in ipairs(self.debounceTimers) do
        if amount > 0 then
            self.debounceTimers[i] = amount - 1
        end
    end

    for playerIndex, key in pairs(JOIN_BUTTONS) do
        if love.keyboard.isDown(key) and self.debounceTimers[playerIndex] == 0 then
            self.debounceTimers[playerIndex] = DEBOUNCE_AMOUNT
            self.playersIn[playerIndex] = not self.playersIn[playerIndex]
        end
    end

    local playersInCount = 0
    for playerIndex, isIn in pairs(self.playersIn) do
        if isIn then
            playersInCount = playersInCount + 1
        end
    end

    if love.keyboard.isDown("space") and playersInCount > 1 then
        self.stateTransitionFunction("playing", {
            playersIn = self.playersIn
        })
    end
end

local function drawCenteredText(rectX, rectY, rectWidth, rectHeight, text)
	local font = love.graphics.getFont()
	local textWidth = font:getWidth(text)
	local textHeight = font:getHeight()
	love.graphics.print(text, rectX+rectWidth/2, rectY+rectHeight/2, 0, 1, 1, textWidth/2, textHeight/2)
end

function StateMenu:draw(currentTime)
    local w = 400
    local h = 40
    local x = (love.graphics.getWidth() - w) / 2
    local y = (love.graphics.getHeight() - h) / 2
    local wiggleX = math.sin(currentTime * WIGGLE_FACTOR)
    local wiggleY = math.cos(currentTime * WIGGLE_FACTOR)
    love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", x + wiggleX, y - wiggleY, w, h)
	drawCenteredText(x, y, w, h, "Press [1,2,3,4] to join")

    local quarter = love.graphics.getWidth()  / 4
    for playerIndex, isIn in pairs(self.playersIn) do
        -- Draw rectangle
        if isIn then
            love.graphics.setColor(PLAYER_COLORS[playerIndex])
        else
            love.graphics.setColor(IDLE_COLOR)
        end

        love.graphics.rectangle(
            "line",
            quarter * (playerIndex - 1) + PLAYER_RECT_BUFFER,
            PLAYER_RECT_Y,
            quarter - (PLAYER_RECT_BUFFER  * 2),
            PLAYER_RECT_HEIGHT
        )

        -- Draw sprite
        if isIn then
            local spriteX = quarter * (playerIndex - 1) + (quarter / 2) - SPRITE_X_OFFSET
            local moveFrameCount = self.playerMoveSprites[playerIndex]:getFrameCount()
            local animationIndex = math.floor((self.time * MOVE_ANIMATION_RATE) % moveFrameCount) + 1
            self.playerMoveSprites[playerIndex]:draw(animationIndex, spriteX, PLAYER_SPRITE_Y - PLAYER_Y_OFFSET, true)
        end
    end


end

return StateMenu