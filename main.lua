local Maze = require 'maze'
local Player = require 'player'
local Spritesheet = require 'spritesheet'

local LAND_SPRITESHEET_PATH = "assets/Sprout Lands - Sprites - premium pack/Tilesets/ground tiles/New tiles/Grass_Hill_Tiles_v2.png"
local TILE_SIZE = 16

local SCALE_FACTOR = 3

local currentTime = 0

local mazeHeight = 12
local mazeWidth = 14

local spritesheets = {}
local maze = nil
local mazeCanvas = nil

-- debug player
local debugPlayer

local function createMaze()
    maze = Maze:new(mazeWidth, mazeHeight)
    maze:print()

    -- create maze canvas
    mazeCanvas = love.graphics.newCanvas(
        mazeWidth * TILE_SIZE + 1, -- add one extra for the end tile)
        mazeHeight * TILE_SIZE
    )
    love.graphics.setCanvas(mazeCanvas)
    assert(maze ~= nil, "maze is nil!")
    for y = 1, mazeHeight, 1 do
        for x = 1, mazeWidth, 1 do
            local tileKey = maze:tileKeyAt(x, y)
            love.graphics.draw(
                spritesheets["land"].image, -- drawable
                spritesheets["land"]:getNamedQuad(tileKey), -- quad
                TILE_SIZE * (x - 1), -- x, 1-based index to 0-based offet
                TILE_SIZE * (y - 1) -- y, 1-based index to 0-based offet
            )
        end
    end
    -- Add special end cell
    love.graphics.draw(
        spritesheets["land"].image, -- drawable
        spritesheets["land"]:getNamedQuad("left"), -- quad
        TILE_SIZE * (mazeWidth), -- x, 1-based index to 0-based offet
        TILE_SIZE * (mazeHeight - 1) -- y, 1-based index to 0-based offet
    )
    love.graphics.setCanvas()
end

function love.load()
    -- Land tiles
    spritesheets["land"] = Spritesheet:new(LAND_SPRITESHEET_PATH, TILE_SIZE, TILE_SIZE)
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

    createMaze()

    debugPlayer = Player:new(1, 1, maze, TILE_SIZE * SCALE_FACTOR)
end

function love.update(dt)
    currentTime = currentTime + dt

    -- update debug player
    debugPlayer:update(dt)

    if debugPlayer.mazeX == mazeWidth + 1 and debugPlayer.mazeY == mazeHeight then
        createMaze()
        debugPlayer = Player:new(1, 1, maze, TILE_SIZE * SCALE_FACTOR)
    end
end

function love.draw(dt)
    -- Set premultiplied alpha blend mode since we've already rendered the maze to canvas
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(
        mazeCanvas,
        0, -- x
        0, -- y
        0, -- r
        SCALE_FACTOR, -- sx
        SCALE_FACTOR -- sy
    )
    -- back to the default alpha blend mode
    love.graphics.setBlendMode("alpha")

    -- draw debug player
    debugPlayer:draw()

end

function love.joystickpressed(joystick, button)
    print("joystick", joystick, button)
end

function love.gamepadpressed(gamepad, button )
    print("gamepad", gamepad, button)
end