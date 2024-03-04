local Maze = require 'maze'
local Player = require 'player'
local Spritesheet = require 'spritesheet'

local LAND_SPRITESHEET_PATH = "assets/Sprout Lands - Sprites - premium pack/Tilesets/ground tiles/New tiles/Grass_Hill_Tiles_v2.png"
local TILE_SIZE = 16

local SCALE_FACTOR = 3

local currentTime = 0

local mazeHeight = 10
local mazeWidth = 10

local spritesheets = {}
local maze = nil
local mazeCanvas = love.graphics.newCanvas(mazeWidth * TILE_SIZE)

-- debug player
local debugPlayer

function love.load()
    maze = Maze:new(mazeWidth, mazeHeight)
    maze:print()

    local tileKey = maze:tileKeyAt(1, 1)

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


    -- create maze canvas
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
            -- debug: show distance from origin
            local font = love.graphics.newFont(7, "mono")
            local text = love.graphics.newText(font, maze:cellAt(x .. "," .. y).distanceFromOrigin)
            love.graphics.draw(text, TILE_SIZE * (x - 1), TILE_SIZE * (y - 1))
        end
    end
    love.graphics.setCanvas()

    -- create player
    debugPlayer = Player:new(1, 1, maze, TILE_SIZE * SCALE_FACTOR)
end

function love.update(dt)
    currentTime = currentTime + dt

    -- update debug player
    debugPlayer:update(dt)
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