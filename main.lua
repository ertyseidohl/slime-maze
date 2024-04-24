local Spritesheet = require 'spritesheet'
local StateMenu = require 'statemenu'
local StatePlaying = require 'stateplaying'

local LAND_SPRITESHEET_PATH = "assets/Grass_Hill_Tiles_v2.png"
local GROUND_SPRITESHEET_PATH = "assets/Soil_Ground_Tiles.png"

local config = {
    mazeHeight = 12,
    mazeWidth = 14,
    scaleFactor = 4,
    tileSize = 16
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
        gameState = StatePlaying:new(stateTransition, config, spritesheets, 4)
    else
        error("Unrecognized state: " .. toState)
    end
    gameState:enterState()
end

function love.load()
    -- Ground tiles
    spritesheets["ground"] = Spritesheet:new(GROUND_SPRITESHEET_PATH, config.tileSize, config.tileSize)
    spritesheets["ground"]:nameQuads({
        {"ground", 2, 2},
        {"grounddark1", 1, 6},
        {"grounddark2", 2, 6},
        {"grounddark3", 3, 6},
        {"grounddark4", 4, 6},
        {"grounddark5", 5, 6},
        {"groundlight1", 1, 7},
        {"groundlight2", 2, 7},
        {"groundlight3", 3, 7},
        {"groundlight4", 4, 7},
        {"groundlight5", 5, 7}
    })
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
    local fps = math.floor(1/dt)
    if fps < 60 then
        print("Warning: Long Frame (" .. fps .." fps, " .. dt .. "ms)")
    end
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