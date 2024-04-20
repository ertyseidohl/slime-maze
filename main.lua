local Spritesheet = require 'spritesheet'
local StateMenu = require 'statemenu'
local StatePlaying = require 'stateplaying'

local LAND_SPRITESHEET_PATH = "assets/Sprout Lands - Sprites - premium pack/Tilesets/ground tiles/New tiles/Grass_Hill_Tiles_v2.png"

local config = {
    mazeHeight = 12,
    mazeWidth = 14,
    scaleFactor = 3,
    tileSize = 16,
}
local currentTime = 0
local spritesheets = {}

-- Game States
local gameState = nil

local function stateTransition(toState)
    if gameState ~= nil then
        gameState.exitState()
    end
    if toState == 'menu' then
        gameState = StateMenu:new(stateTransition)
    elseif toState == 'playing' then
        gameState = StatePlaying:new(stateTransition, config, spritesheets)
    else
        error("Unrecognized state: " .. toState)
    end
    gameState:enterState()
end

function love.load()
    -- Land tiles
    spritesheets["land"] = Spritesheet:new(LAND_SPRITESHEET_PATH, config.tileSize, config.tileSize)
    spritesheets["land"]:nameQuads({
        -- skinny connections
        {"down", 4, 1},
        {"updown", 4, 2},
        {"up", 4, 3},
        {"right", 1, 4},
        {"rightleft", 2, 4},
        {"left", 3, 4},
        {"", 4, 4},

        -- skinny corners
        {"rightdown", 5, 1},
        {"downleft", 8, 1},
        {"upright", 5, 4},
        {"upleft", 8, 4},

        -- skinny threes
        {"rightdownleft", 9, 1},
        {"uprightleft", 9, 4},
        {"uprightdown", 5, 5},
        {"updownleft", 8, 5},

        -- skinny four
        {"uprightdownleft", 9, 5},
    })
    -- Manage state
    stateTransition('menu')
end

function love.update(dt)
    currentTime = currentTime + dt
    if gameState == nil then
        error('gameState was nil in update')
    end

    gameState:update(dt, currentTime)
end

function love.draw()
    if gameState == nil then
        error('gameState was nil in draw')
    end

    gameState:draw(currentTime)
end

function love.joystickpressed(joystick, button)
    print("joystick", joystick, button)
end

function love.gamepadpressed(gamepad, button )
    print("gamepad", gamepad, button)
end