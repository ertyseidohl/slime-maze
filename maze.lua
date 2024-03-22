local class = require 'lib.middleclass'
local Cell = require 'cell'
local Maze = class('Maze')

-- local MAZE_ALGO = "backtracker"
local MAZE_ALGO = "kruskal"

function Maze:initialize(width, height)
    local seed = os.time()
    print("Initializing Maze with seed " .. seed)
    math.randomseed(seed)
    self.cells = {}
    self.cellsByDistanceFromOrigin = {}
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
    if MAZE_ALGO == "backtracker" then
        self:generateBacktracker()
    elseif MAZE_ALGO == "kruskal" then
        self:generateKruskal()
    else
        assert(false, "Unrecognized maze algo")
    end

    -- Add special end cell
    local endCell = Cell:new(self.width + 1, self.height)
    self.cells[endCell.key] = endCell
    local penultimateCell = self.cells[Cell:key(self.width, self.height)]
    endCell.connections[penultimateCell.key] = true
    penultimateCell.connections[endCell.key] = true
end

function Maze:generateKruskal()
    local allEdges = {}
    local cellIds = {}
    -- Label all cells with a unique id
    local uniqueId = 1
    for y = 1, self.height, 1 do
        for x = 1, self.width, 1 do
            cellIds[Cell:key(x, y)] = uniqueId
            uniqueId = uniqueId + 1
        end
    end
    -- Create a list of all edges in the graph
    for y = 1, self.height, 1 do
        for x = 1, self.width, 1 do
            if self:isValid(x + 1, y) then
                table.insert(allEdges, {
                    ["a"] = Cell:key(x, y);
                    ["b"] = Cell:key(x + 1, y);
                })
            end
            if self:isValid(x, y + 1) then
                table.insert(allEdges, {
                    ["a"] = Cell:key(x, y);
                    ["b"] = Cell:key(x, y + 1);
                })
            end
        end
    end
    -- Shuffle the list of all edges in the graph
    for i = 1, #allEdges, 1 do
        local rand = math.random(#allEdges)
        allEdges[i], allEdges[rand] = allEdges[rand], allEdges[i]
    end

    for _, edge in ipairs(allEdges) do
        -- If the cells have different ids
        assert(cellIds[edge.a], "cell id for edge a was nil")
        assert(cellIds[edge.b], "cell id for edge b was nil")
        if cellIds[edge.a] ~= cellIds[edge.b] then
            -- Connect the two cells
            local cellA = self:cellAt(edge.a)
            local cellB = self:cellAt(edge.b)

            cellA.connections[edge.b] = true
            cellB.connections[edge.a] = true

             -- Update all cells with id same as cell B
             -- This could be optimized!!
             local oldCellId = cellIds[edge.b]
             for y = 1, self.height, 1 do
                for x = 1, self.width, 1 do
                    if cellIds[Cell:key(x, y)] == oldCellId then
                        cellIds[Cell:key(x, y)] = cellIds[edge.a]
                    end
                end
             end
        end
    end
end


function Maze:generateBacktracker()
    local visitedKeys = {}
    local stackKeys = {}

    local working = true
    local curr = self:cellAt(Cell:key(1, 1))
    curr.distanceFromOrigin = 0
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

            -- Push nextCell into cellsByDistanceFromOrigin
            nextCell.distanceFromOrigin = curr.distanceFromOrigin + 1
            if not self.cellsByDistanceFromOrigin[nextCell.distanceFromOrigin] then
                self.cellsByDistanceFromOrigin[nextCell.distanceFromOrigin] = {}
            end
            table.insert(self.cellsByDistanceFromOrigin[nextCell.distanceFromOrigin], nextCell)

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