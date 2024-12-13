-- module with selection functions

-- USAGE - iterateSelection(func(p))
-- A function that takes a function with a single point parameter `func(p)`.
-- For each point in the selection(s) on the image, `func(p)` is called.
-- Works with multiple selections.
-- e.g. 
-- selectionX.iterateSelection(stringX.printPoint) -- prints the coordinates of all points in the selection


-- key variables
local selection = sprite.selection


-- script
local isIterationCancelled = false
local pixelCount = 0
local currentPixelIndex = 0
local findPixelIndex = 0
local foundPixel = nil





---------------------------------------
--- HELPERS
---------------------------------------

local function countPixel(p)
    pixelCount = pixelCount + 1
end

local function findPixelAtIndex(p)
    if currentPixelIndex == findPixelIndex then
        foundPixel = p
        isIterationCancelled = true
        return
    end
    currentPixelIndex = currentPixelIndex + 1
end












---------------------------------------
--- ACTIONS
---------------------------------------

-- Iterates the points of the selection (left to right, top to bottom) and calls `doWorkOnPoint` with the point
-- Carl TODO: update docs
local function iterateSelection(doWorkOnPoint)

    isIterationCancelled = false

    local bounds = selection.bounds
    local selectionWidth = bounds.width
    local selectionHeight = bounds.height

    for yOffset = 0, selectionHeight, 1 do
        for xOffset = 0, selectionWidth, 1 do
            local testPoint = Point(bounds.x + xOffset, bounds.y + yOffset)
            if selection:contains(testPoint) then
                doWorkOnPoint(testPoint)
                if isIterationCancelled then return end
            end
        end
    end
end

-- Returns the number of pixels in the selection
-- Carl TODO: docs
local function getPixelCount()
    pixelCount = 0
    iterateSelection(countPixel)
    return pixelCount
end

-- Returns the pixel at the zero-based index in the selection (left to right, top to bottom)
-- Carl TODO: docs
local function getPixelAtIndex(index)
    if index == nil or index < 0 then return nil end

    currentPixelIndex = 0
    findPixelIndex = index
    foundPixel = nil
    
    iterateSelection(findPixelAtIndex)
    return foundPixel
end







---------------------------------------
--- MODULE
---------------------------------------

return {
    iterateSelection = iterateSelection,
    getPixelCount = getPixelCount,
    getPixelAtIndex = getPixelAtIndex,
}