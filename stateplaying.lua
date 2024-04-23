local class = require 'lib.middleclass'

local Maze = require 'maze'
local Player = require 'player'

local StatePlaying = class('StatePlaying')

local maze = nil
local mazeCanvas = nil

local CAMERA_BUFFER = 100

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

function CreateQuarterScreens()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    return {
        {
            x = 0,
            y = 0,
            width = screenWidth / 2,
            height = screenHeight / 2,
            cameraX = 0,
            cameraY = 0,
            cameraVX = 0,
            cameraVY = 0
        },
        {
            x = screenWidth / 2,
            y = 0,
            width = screenWidth / 2,
            height = screenHeight / 2,
            cameraX = 0,
            cameraY = 0,
            cameraVX = 0,
            cameraVY = 0
        },
        {
            x = 0,
            y = screenHeight / 2,
            width = screenWidth / 2,
            height = screenHeight / 2,
            cameraX = 0,
            cameraY = 0,
            cameraVX = 0,
            cameraVY = 0
        },
        {
            x = screenWidth / 2,
            y = screenHeight / 2,
            width = screenWidth / 2,
            height = screenHeight / 2,
            cameraX = 0,
            cameraY = 0,
            cameraVX = 0,
            cameraVY = 0
        }
    }
end

function StatePlaying:createMaze()
    maze = Maze:new(self.config.mazeWidth, self.config.mazeHeight)
    maze:print()

    -- create maze canvas
    local unscaledMazeCanvas = love.graphics.newCanvas(
        self.config.mazeWidth * self.config.tileSize + 1, -- add one extra for the end tile)
        self.config.mazeHeight * self.config.tileSize
    )
    love.graphics.setCanvas(unscaledMazeCanvas)
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
    mazeCanvas = love.graphics.newCanvas(
        self.config.mazeWidth * self.config.scaleFactor * self.config.tileSize + 1, -- add one extra for the end tile)
        self.config.mazeHeight * self.config.scaleFactor * self.config.tileSize
    )
    love.graphics.setCanvas(mazeCanvas)
    -- Set premultiplied alpha blend mode since we've
    -- already rendered the maze to canvas
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(unscaledMazeCanvas, love.math.newTransform(
        0, -- x
        0, -- y
        0, -- r
        self.config.scaleFactor, -- sx
        self.config.scaleFactor -- sy
    ))
    -- Back to default blend mode
    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas()
end

function StatePlaying:initialize(stateTransitionFunction, config, spritesheets, numPlayers)
    self.stateTransitionFunction = stateTransitionFunction
    self.config = config
    self.spritesheets = spritesheets
    self.numPlayers = numPlayers
end

function StatePlaying:enterState()
    self:restart()
end

function StatePlaying:restart()
    self:createMaze()
    self.quarterScreens = CreateQuarterScreens()
    self.players = {}
    for i = 0, self.numPlayers, 1 do
        self.players[i] = Player:new(1, 1, maze, self.config.tileSize * self.config.scaleFactor)
    end
end

function StatePlaying:exitState()

end

function StatePlaying:update(dt)
    for _, player in ipairs(self.players) do
        player:update(dt)
    end
end

function StatePlaying:renderPlayerScreen(playerNum, rect, mazeCanvas)
    love.graphics.rectangle("line", rect.x, rect.y, rect.width, rect.height)
    local loopStop = 100

    while self.players[playerNum].x - rect.cameraX < CAMERA_BUFFER and rect.cameraX > 0 and loopStop > 0 do
        rect.cameraX  = rect.cameraX - 1
        loopStop = loopStop - 1
    end
    while self.players[playerNum].x - rect.cameraX > rect.width - CAMERA_BUFFER and rect.cameraX + rect.width < mazeCanvas:getWidth() and loopStop > 0 do
        rect.cameraX = rect.cameraX + 1
        loopStop = loopStop - 1
    end

    while self.players[playerNum].y - rect.cameraY < CAMERA_BUFFER and rect.cameraY > 0 and loopStop > 0 do
        rect.cameraY = rect.cameraY - 1
        loopStop = loopStop - 1
    end
    while self.players[playerNum].y - rect.cameraY > rect.height - CAMERA_BUFFER and rect.cameraY + rect.height < mazeCanvas:getHeight() and loopStop > 0 do
        rect.cameraY = rect.cameraY + 1
        loopStop = loopStop - 1
    end

    if loopStop == 0 then
        print("WARNING: LoopStop hit 0 in statePlaying draw!!")
    end

    -- Set premultiplied alpha blend mode since we've
    -- already rendered the maze to canvas
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(
        mazeCanvas, -- source
        love.graphics.newQuad(
            rect.cameraX, -- x
            rect.cameraY, -- y
            rect.width, -- width
            rect.height, -- height
            mazeCanvas -- texture
        ), -- quad
        love.math.newTransform(
            rect.x, -- x
            rect.y -- y
        )
    )
    -- back to the default alpha blend mode
    love.graphics.setBlendMode("alpha")

    -- debug
    for i, d in ipairs({
        "cameraX " .. rect.cameraX,
        "cameraY " .. rect.cameraY,
        "cameraVX " .. rect.cameraVX,
        "cameraVY " .. rect.cameraVY,
        "cameraRelativeX " .. self.players[playerNum].x - rect.cameraX,
        "cameraRelativeY " .. self.players[playerNum].y - rect.cameraY,
        "rect.width " .. rect.width,
        "rect.height " .. rect.height
    }) do
        love.graphics.print(d , rect.x, rect.y + (i * 10))
    end

    self.players[playerNum]:draw({
        offsetX = -rect.cameraX + rect.x,
        offsetY = -rect.cameraY + rect.y
    })
end

function StatePlaying:draw(dt)
    if mazeCanvas == nil then
        error("mazeCanvas was nil in StatePlaying:draw")
    end
    -- Draw the four quadrants
    for playerNum, rect in ipairs(self.quarterScreens) do
        if playerNum <= self.numPlayers then
            self:renderPlayerScreen(playerNum, rect, mazeCanvas)
        end
    end
end

return StatePlaying