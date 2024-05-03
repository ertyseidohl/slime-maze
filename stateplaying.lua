local class = require 'lib.middleclass'

local Maze = require 'maze'
local Player = require 'player'

local StatePlaying = class('StatePlaying')

local CAMERA_BUFFER = 100
local SLIME_RADIUS = 16

local KEY_CONFIG = {
    {
        up = "w",
        down = "s",
        left = "a",
        right = "d"
    },
    {
        up = "t",
        down = "g",
        left = "f",
        right = "h"
    },
    {
        up = "i",
        down = "k",
        left = "j",
        right = "l"
    },
    {
        up = "up",
        down = "down",
        left = "left",
        right = "right"
    }
}

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

function StatePlaying.CreateQuarterScreens()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- TODO: center cameras on players at beginning
    return {
        {
            x = 0,
            y = 0,
            width = screenWidth / 2,
            height = screenHeight / 2,
            cameraX = 0,
            cameraY = 0,
            cameraVX = 0,
            cameraVY = 0,
            canvas = nil
        },
        {
            x = screenWidth / 2,
            y = 0,
            width = screenWidth / 2,
            height = screenHeight / 2,
            cameraX = 0,
            cameraY = 0,
            cameraVX = 0,
            cameraVY = 0,
            canvas = nil
        },
        {
            x = 0,
            y = screenHeight / 2,
            width = screenWidth / 2,
            height = screenHeight / 2,
            cameraX = 0,
            cameraY = 0,
            cameraVX = 0,
            cameraVY = 0,
            canvas = nil
        },
        {
            x = screenWidth / 2,
            y = screenHeight / 2,
            width = screenWidth / 2,
            height = screenHeight / 2,
            cameraX = 0,
            cameraY = 0,
            cameraVX = 0,
            cameraVY = 0,
            canvas = nil
        }
    }
end

function StatePlaying:createMaze()
    self.maze = Maze:new(self.config.mazeWidth, self.config.mazeHeight)
    self.maze:print()

    -- create maze canvas
    local unscaledMazeCanvas = love.graphics.newCanvas(
        self.config.mazeWidth * self.config.tileSize,
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
    assert(self.maze ~= nil, "maze is nil!")
    for y = 1, self.config.mazeHeight, 1 do
        for x = 1, self.config.mazeWidth, 1 do
            local tileKey = self.maze:tileKeyAt(x, y)
            love.graphics.draw(
                self.spritesheets["land"].image, -- drawable
                self.spritesheets["land"]:getNamedQuad(tileKey), -- quad
                self.config.tileSize * (x - 1), -- x, 1-based index to 0-based offet
                self.config.tileSize * (y - 1) -- y, 1-based index to 0-based offet
            )
        end
    end
    -- Draw
    self.mazeCanvas = love.graphics.newCanvas(
        self.config.mazeWidth * self.config.scaleFactor * self.config.tileSize,
        self.config.mazeHeight * self.config.scaleFactor * self.config.tileSize
    )
    love.graphics.setCanvas(self.mazeCanvas)
    -- Set premultiplied alpha blend mode since we've
    -- already rendered the maze to canvas
    love.graphics.setBlendMode("alpha", "premultiplied")
    unscaledMazeCanvas:setFilter("linear", "nearest")
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

    self.maze = nil
    self.mazeCanvas = nil
    self.slimeCanvases = {}
    self.currentSlimeCanvas = 1

    -- Create two slime canvases, to flip back and forth (to simulate slime fading)
    self.slimeCanvases[1] = love.graphics.newCanvas(
        self.config.mazeWidth * self.config.scaleFactor * self.config.tileSize,
        self.config.mazeHeight * self.config.scaleFactor * self.config.tileSize
    )
    self.slimeCanvases[2] = love.graphics.newCanvas(
        self.config.mazeWidth * self.config.scaleFactor * self.config.tileSize,
        self.config.mazeHeight * self.config.scaleFactor * self.config.tileSize
    )
end

function StatePlaying:enterState()
    self:restart()
end

function StatePlaying:restart()
    self:createMaze()
    local startConfig = {
        {x = 1, y = 1},
        {x = 1, y = self.config.mazeHeight},
        {x = self.config.mazeWidth, y = 1},
        {x = self.config.mazeWidth, y = self.config.mazeHeight}
    }

    self.players = {}
    for i = 1, self.numPlayers, 1 do
        self.players[i] = Player:new(
            startConfig[i]["x"], -- mazeX
            startConfig[i]["y"], -- mazeY
            self.maze, -- maze
            self.config.tileSize * self.config.scaleFactor, -- tileSize
            KEY_CONFIG[i], -- keys
            i -- playerIndex
        )
    end
    self.quarterScreens = self:CreateQuarterScreens()
end

function StatePlaying:exitState()

end

function StatePlaying:update(dt)
    -- Update slime canvas
    if self.currentSlimeCanvas == 1 then
        self.currentSlimeCanvas = 2
    else
        self.currentSlimeCanvas = 1
    end

    -- Update players
    for _, player in ipairs(self.players) do
        player:update(dt)
    end
end

function StatePlaying:renderPlayerScreen(playerNum, rect)
    if self.players[playerNum].canvas == nil then
        self.players[playerNum].canvas = love.graphics.newCanvas(rect.width, rect.height)
    end

    love.graphics.setCanvas(self.players[playerNum].canvas)
    local loopStop = 100

    while self.players[playerNum].x - rect.cameraX < CAMERA_BUFFER and rect.cameraX > 0 and loopStop > 0 do
        rect.cameraX  = rect.cameraX - 1
        loopStop = loopStop - 1
    end
    while self.players[playerNum].x - rect.cameraX > rect.width - CAMERA_BUFFER and rect.cameraX + rect.width < self.mazeCanvas:getWidth() and loopStop > 0 do
        rect.cameraX = rect.cameraX + 1
        loopStop = loopStop - 1
    end

    while self.players[playerNum].y - rect.cameraY < CAMERA_BUFFER and rect.cameraY > 0 and loopStop > 0 do
        rect.cameraY = rect.cameraY - 1
        loopStop = loopStop - 1
    end
    while self.players[playerNum].y - rect.cameraY > rect.height - CAMERA_BUFFER and rect.cameraY + rect.height < self.mazeCanvas:getHeight() and loopStop > 0 do
        rect.cameraY = rect.cameraY + 1
        loopStop = loopStop - 1
    end

    if loopStop == 0 then
        print("WARNING: LoopStop hit 0 in statePlaying draw!!")
    end

    -- Set premultiplied alpha blend mode to draw from one canvas to another
    love.graphics.setBlendMode("alpha", "premultiplied")

    love.graphics.draw(
        self.mazeCanvas, -- source
        love.graphics.newQuad(
            rect.cameraX, -- x
            rect.cameraY, -- y
            rect.width, -- width
            rect.height, -- height
            self.mazeCanvas -- texture
        ) -- quad
    )

    -- Now draw the slime canvas
    love.graphics.draw(
        self.slimeCanvases[self.currentSlimeCanvas], -- source
        love.graphics.newQuad(
            rect.cameraX, -- x
            rect.cameraY, -- y
            rect.width, -- width
            rect.height, -- height
            self.slimeCanvases[self.currentSlimeCanvas] -- texture
        ) -- quad
    )
    -- back to the default alpha blend mode
    love.graphics.setBlendMode("alpha")

    -- debug
    -- for i, d in ipairs({
    --     "cameraX " .. rect.cameraX,
    --     "cameraY " .. rect.cameraY,
    --     "cameraVX " .. rect.cameraVX,
    --     "cameraVY " .. rect.cameraVY,
    --     "cameraRelativeX " .. self.players[playerNum].x - rect.cameraX,
    --     "cameraRelativeY " .. self.players[playerNum].y - rect.cameraY,
    --     "rect.width " .. rect.width,
    --     "rect.height " .. rect.height
    -- }) do
    --     love.graphics.print(d , 0, 0 + (i * 10))
    -- end

    for i = 1, #self.players, 1 do
        -- This draws all players, which is not optimal (since many are not visible)
        self.players[i]:draw({
            offsetX = -rect.cameraX,
            offsetY = -rect.cameraY
        })
    end

    -- Overlay
    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", 0, 0, rect.width, rect.height)
    love.graphics.reset()

    -- Back to default canvas
    love.graphics.setCanvas()

    -- Render our QuarterCanvas to the main drawing buffer
    love.graphics.draw(self.players[playerNum].canvas, rect.x, rect.y)
end

function CopySlimeCanvas(fromCanvas, toCanvas)
    -- Set premultiplied alpha blend mode since we've
    -- already rendered the maze to canvas
    love.graphics.setCanvas(toCanvas)
    love.graphics.clear()
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.setColor(255, 255, 255, 0.5)
    love.graphics.draw(fromCanvas, 0, 0)
    love.graphics.reset()
end

function StatePlaying:drawSlimeCanvas()
    love.graphics.setCanvas(self.slimeCanvases[self.currentSlimeCanvas])
    for _, player in ipairs(self.players) do
        love.graphics.setColor(255, 0, 255, 0.5)
        love.graphics.circle("fill", player.x, player.y, SLIME_RADIUS)
    end
    love.graphics.reset()
end

function StatePlaying:draw(dt)
    if self.mazeCanvas == nil then
        error("mazeCanvas was nil in StatePlaying:draw")
    end

    -- Draw slime canvas
    -- CopySlimeCanvas(self.slimeCanvases[1], self.slimeCanvases[2])
    -- self:drawSlimeCanvas()

    -- Draw the four quadrants
    for playerNum, rect in ipairs(self.quarterScreens) do
        if playerNum <= self.numPlayers then
            self:renderPlayerScreen(playerNum, rect)
        end
    end
end

return StatePlaying