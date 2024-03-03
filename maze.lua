local class = require 'lib.middleclass'
local Cell = require 'cell'
local Maze = class('Maze')

function Maze:initialize(width, height)
    local seed = os.time()
    print("Initializing Maze with seed " .. seed)
    math.randomseed(seed)
    self.cells = {}
    self.width = width
    self.height = height
    for x = 1, width, 1 do
        for y = 1, height, 1 do
            local newCell = Cell:new(x, y)
            self.cells[Cell:key(x, y)] = newCell
            self:generateNeighbors(newCell)
        end
    end
    self:generate()
end

function Maze:generateNeighbors(cell)
    if self:isValid(cell.x - 1, cell.y) then
        table.insert(cell.neighbors, cell:leftKey())
    end
    if self:isValid(cell.x + 1, cell.y) then
        table.insert(cell.neighbors, cell:rightKey())
    end
    if self:isValid(cell.x, cell.y - 1) then
        table.insert(cell.neighbors, cell:upKey())
    end
    if self:isValid(cell.x, cell.y + 1) then
        table.insert(cell.neighbors, cell:downKey())
    end
end

function Maze:isValid(x, y)
    return x >= 1 and y >= 1 and x <= self.width and y <= self.height
end

function Maze:cellAt(key)
    return self.cells[key]
end

function Maze:tileKeyAt(x, y)
    return self:cellAt(Cell:key(x, y)):tileKey()
end

function Maze:hasConnection(x1, y1, x2, y2)
    return self:cellAt(Cell:key(x1, y1)):hasConnection(Cell:key(x2, y2))
end

function Maze:generate()
    print("Generating Maze")
    local visitedKeys = {}
    local stackKeys = {}

    local working = true
    local curr = self:cellAt(Cell:key(1, 1))
    local loopStop = 0
    local LOOP_STOP_MAX = 10000

    while working and loopStop < LOOP_STOP_MAX do
        loopStop = loopStop + 1 -- debug

        -- Mark that we have visited the current cell
        visitedKeys[curr.key] = true

        -- For each neighbor of the current cell
        local validNextCells = {}

        for _,neighborKey in ipairs(curr.neighbors) do
            -- Keep cells that we have not visited
            if visitedKeys[neighborKey] == nil then
                table.insert(validNextCells, neighborKey)
            end
        end

        -- If we have valid next cells, choose a random one
        if #validNextCells > 0 then
            -- Random number between 1 and #validNextCells inclusive
            local rand = math.random(#validNextCells)
            local nextCell = self:cellAt(validNextCells[rand])

            -- Create a connection between current and nextCell
            nextCell.connections[curr.key] = true
            curr.connections[nextCell.key] = true

            -- Push the previous cell onto the stack
            table.insert(stackKeys, curr.key)
            -- And move into the next cell
            curr = nextCell
        else
            -- If we have no valid neighbors, move back to the top cell on the stack
            curr = self:cellAt(table.remove(stackKeys))
        end

        if #stackKeys == 0 then
            working = false
        end
    end
    if loopStop == LOOP_STOP_MAX then
        print("warning: hit loopstop") -- debug
    end
end

function Maze:print()
    for y = 1, self.height, 1 do
        local row = ""
        for x = 1, self.width, 1 do
            row = row .. self:cellAt(Cell:key(x, y)):print()
        end
        print(row)
    end
end


return Maze