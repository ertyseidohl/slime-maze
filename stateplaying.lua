local class = require 'lib.middleclass'

local Maze = require 'maze'
local Player = require 'player'

local StatePlaying = class('StatePlaying')

local maze = nil
local mazeCanvas = nil

-- debug player
local debugPlayer

function StatePlaying:createMaze()
    maze = Maze:new(self.config.mazeWidth, self.config.mazeHeight)
    maze:print()

    -- create maze canvas
    mazeCanvas = love.graphics.newCanvas(
        self.config.mazeWidth * self.config.tileSize + 1, -- add one extra for the end tile)
        self.config.mazeHeight * self.config.tileSize
    )
    love.graphics.setCanvas(mazeCanvas)
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
    print("Initialize state playing")
    self.stateTransitionFunction = stateTransitionFunction
    self.config = config
    self.spritesheets = spritesheets
end

function StatePlaying:enterState()
    print("Enter state playing")
    self:createMaze()
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