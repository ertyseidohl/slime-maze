local class = require 'lib.middleclass'

local Cell = class('Cell')

local CELL_PRINT = {
    [""] = "X";
    ["upleft"] = "┛";
    ["up"] = "╹";
    ["upright"] = "┗";
    ["right"] = "╺";
    ["rightdown"] = "┏";
    ["down"] = "╻";
    ["downleft"] = "┓";
    ["left"] = "╸";
    ["updown"] = "┃";
    ["rightleft"] = "━";
    ["uprightdownleft"] = "╋";
    ["uprightdown"] = "┣";
    ["rightdownleft"] = "┳";
    ["updownleft"] = "┫";
    ["uprightleft"] = "┻";
}

function Cell:initialize(x, y)
    self.x = x
    self.y = y
    self.neighbors = {} -- array
    self.connections = {} -- set
    self.connectionsCount = 0 -- Manual tabulation
    self.key = Cell:key(x, y)
    self.distanceFromOrigin = nil
end

function Cell:key(x, y)
    return x .. "," .. y
end

function Cell:upKey()
    return Cell:key(self.x, self.y - 1)
end

function Cell:downKey()
    return Cell:key(self.x, self.y + 1)
end

function Cell:leftKey()
    return Cell:key(self.x - 1, self.y)
end

function Cell:rightKey()
    return Cell:key(self.x + 1, self.y)
end

function Cell:tileKey()
    local tileKey = ""
    -- up, right, down, left - clockwise order.
    if self.connections[self:upKey()] then
        tileKey = tileKey .. "up"
    end
    if self.connections[self:rightKey()] then
        tileKey = tileKey .. "right"
    end
    if self.connections[self:downKey()] then
        tileKey = tileKey .. "down"
    end
    if self.connections[self:leftKey()] then
        tileKey = tileKey .. "left"
    end
    return tileKey
end

function Cell:hasConnection(key)
    return self.connections[key] ~= nil
end

function Cell:print()
    return CELL_PRINT[self:tileKey()]
end

function Cell:addConnection(key)
    self.connectionsCount = self.connectionsCount + 1
    self.connections[key] = true
end

function Cell:debugPrintConnections()
    print("up", self.connections[self:upKey()])
    print("down", self.connections[self:downKey()])
    print("left", self.connections[self:leftKey()])
    print("right", self.connections[self:rightKey()])
end

return Cell