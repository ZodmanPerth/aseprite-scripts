-- module with selection functions

-- USAGE - iterateSelection(func(p))
-- A function that takes a function with a single point parameter `func(p)`.
-- For each point in the selection(s) on the image, `func(p)` is called.
-- Works with multiple selections.
-- e.g. 
-- selectionX.iterateSelection(stringX.printPoint) -- prints the coordinates of all points in the selection


-- key variables
local selection = sprite.selection







---------------------------------------
--- ACTIONS
---------------------------------------

-- Iterates the points of the selection and calls `doWorkOnPoint` with the point
local function iterateSelection(doWorkOnPoint)
    local bounds = selection.bounds
    local selectionWidth = bounds.width
    local selectionHeight = bounds.height

    for yOffset = 0, selectionHeight, 1 do
        for xOffset = 0, selectionWidth, 1 do
            local testPoint = Point(bounds.x + xOffset, bounds.y + yOffset)
            if selection:contains(testPoint) then
                doWorkOnPoint(testPoint)
            end
        end
    end
end









---------------------------------------
--- MODULE
---------------------------------------

return {
    iterateSelection = iterateSelection
}