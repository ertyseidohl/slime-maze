local class = require 'lib.middleclass'

local Maze = require 'maze'
local Player = require 'player'

local StatePlaying = class('StatePlaying')

local maze = nil
local mazeCanvas = nil

local GROUND_TILE_NAMES = {
    "ground",
    "grounddark1",
    "grounddark2",
    "grounddark3",
    "grounddark4",
    "grounddark5",
    "groundlight1",
    "groundlight2",
    "groundlight3",
    "groundlight4",
    "groundlight5"
}

-- Cameras
local quarterScreens = nil

-- debug player
local debugPlayer

function CreateQuarterScreens()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    return {
        {
            x = 0,
            y = 0,
            width = screenWidth / 2,
            height = screenHeight / 2
        },
        {
            x = screenWidth / 2,
            y = 0,
            width = screenWidth / 2,
            height = screenHeight / 2
        },
        {
            x = 0,
            y = screenHeight / 2,
            width = screenWidth / 2,
            height = screenHeight / 2
        },
        {
            x = screenWidth / 2,
            y = screenHeight / 2,
            width = screenWidth / 2,
            height = screenHeight / 2
        }
    }
end

function StatePlaying:createMaze()
    maze = Maze:new(self.config.mazeWidth, self.config.mazeHeight)
    maze:print()

    -- create maze canvas
    mazeCanvas = love.graphics.newCanvas(
        self.config.mazeWidth * self.config.tileSize + 1, -- add one extra for the end tile)
        self.config.mazeHeight * self.config.tileSize
    )
    love.graphics.setCanvas(mazeCanvas)
    -- Draw ground

    for y = 1, self.config.mazeHeight, 1 do
        for x = 1, self.config.mazeWidth, 1 do
            love.graphics.draw(
                self.spritesheets["ground"].image, -- drawable
                self.spritesheets["ground"]:getNamedQuad(GROUND_TILE_NAMES[math.random(#GROUND_TILE_NAMES)]), -- quad
                self.config.tileSize * (x - 1), -- x, 1-based index to 0-based offet
                self.config.tileSize * (y - 1) -- y, 1-based index to 0-based offet
            )
        end
    end
    -- Draw maze
    assert(maze ~= nil, "maze is nil!")
    for y = 1, self.config.mazeHeight, 1 do
        for x = 1, self.config.mazeWidth, 1 do
            local tileKey = maze:tileKeyAt(x, y)
            love.graphics.draw(
                self.spritesheets["land"].image, -- drawable
                self.spritesheets["land"]:getNamedQuad(tileKey), -- quad
                self.config.tileSize * (x - 1), -- x, 1-based index to 0-based offet
                self.config.tileSize * (y - 1) -- y, 1-based index to 0-based offet
            )
        end
    end
    -- Add special end cell
    love.graphics.draw(
        self.spritesheets["land"].image, -- drawable
        self.spritesheets["land"]:getNamedQuad("left"), -- quad
        self.config.tileSize * (self.config.mazeWidth), -- x, 1-based index to 0-based offet
        self.config.tileSize * (self.config.mazeHeight - 1) -- y, 1-based index to 0-based offet
    )
    love.graphics.setCanvas()
end

function StatePlaying:initialize(stateTransitionFunction, config, spritesheets)
    self.stateTransitionFunction = stateTransitionFunction
    self.config = config
    self.spritesheets = spritesheets
end

function StatePlaying:enterState()
    self:createMaze()
    self.quarterScreens = CreateQuarterScreens()
    debugPlayer = Player:new(1, 1, maze, self.config.tileSize * self.config.scaleFactor)
end


function StatePlaying:exitState()

end

function StatePlaying:update(dt)
    -- update debug player
    debugPlayer:update(dt)

    if debugPlayer.mazeX == self.config.mazeWidth + 1 and debugPlayer.mazeY == self.config.mazeHeight then
        self:createMaze()
        debugPlayer = Player:new(1, 1, maze, self.config.tileSize * self.config.scaleFactor)
    end
end

function StatePlaying:draw(dt)
    -- Draw the four quadrants
    for _, rect in ipairs(self.quarterScreens) do
        love.graphics.rectangle("line", rect.x, rect.y, rect.width, rect.height)
    end
    -- Set premultiplied alpha blend mode since we've
    -- already rendered the maze to canvas
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(
        mazeCanvas,
        0, -- x
        0, -- y
        0, -- r
        self.config.scaleFactor, -- sx
        self.config.scaleFactor -- sy
    )
    -- back to the default alpha blend mode
    love.graphics.setBlendMode("alpha")

    -- draw debug player
    debugPlayer:draw()
end

return StatePlaying