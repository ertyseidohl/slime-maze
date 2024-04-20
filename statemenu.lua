local class = require 'lib.middleclass'

local StateMenu = class('StateMenu')

local WIGGLE_FACTOR = 10

function StateMenu:initialize(stateTransitionFunction)
    self.stateTransitionFunction = stateTransitionFunction
end

function StateMenu:enterState()
    print("menu enter state")
end


function StateMenu:exitState()
    print("menu exit state")
end

function StateMenu:update(dt)
    if love.keyboard.isDown("x") then
        self.stateTransitionFunction("playing")
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
	love.graphics.rectangle("line", x + wiggleX, y - wiggleY, w, h)
	drawCenteredText(x, y, w, h, "Press x to start")
end

return StateMenu