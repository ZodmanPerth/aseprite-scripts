-- v1.0.0
-- module with string functions
--
-- USAGE - concatWithCommas(...)
-- Returns all the passed parameters concatenated together with "," as a separator.
-- e.g.
-- local someValue = "Carl"
-- print(stringX.concatWithCommas("hello", someValue, 4.tostring())) -- prints "hello,Carl,4"
--
-- USAGE - concatWithSeparator(separator, ...)
-- Returns all the passed parameters concatenated together with the first parameter as a separator.
-- e.g.
-- local someValue = "Carl"
-- print(stringX.concatWithCommas("- ", someValue, "hello", 4.tostring())) -- prints "hello- Carl- 4"
--
-- USAGE - dumpTable(table)
-- Returns the passed table as a multiline and indented string suitable for printing.
-- The function is recursive and shows the name and values of the properties, including parsing
-- embedded tables.
-- Names are enclosed in square brackets, strings are enclosed in double quotes, and tables are
-- enclosed in curly brackets.
-- e.g.
-- local dialogData = customWidgets.getDialogData()
-- print(stringX.dumpTable(dialogData))
--
-- USAGE - dumpColourRGBA(colour)
-- Returns a string representing the red, green, blue, and alpha channels of the passed Colour.
-- Values are separated by commas.
-- e.g.
-- print(stringX.dumpColourRGBA(Color(5,10,15,20))) -- prints "5,10,15,20"
--
-- USAGE - dumpColourRGBATable(color)
-- Returns a table containing the RGBA channels and the passed Color as properties.
-- You can use dumpTable() to print the resulting table.
-- e.g
-- print(stringX.dumpTable(stringX.dumpColorRGBATable(Color(5,10,15,20)))) -- prints the table containing RGBA and colour value of the Color(5,10,15,20).
--
-- USAGE - dumpPointRGBA(point)
-- Returns a string representing the red, green, blue, and alpha channels of the colour value of 
-- the passed point.  Values are separated by commas.
-- e.g.
-- print(stringX.dumpPointRGBA(Point(0,0))) -- prints the RGBA colours of the point at 0,0 separated by commas
--
-- USAGE - dumpPointRGBATable(point)
-- Returns a table containing the RGBA channels and the colour value of the point as properties.
-- You can use dumpTable() to print the resulting table.
-- e.g
-- print(stringX.dumpTable(stringX.dumpPointRGBATable(Point(0,0)))) -- prints the table containing RGBA and colour value of point 0,0
--
-- USAGE - dumpPointPosition(point)
-- Returns the x and y coordinates of the passed point as a comma separated string.
-- e.g.
-- print(stringX.dumpPointPosition(Point(0,0))) -- prints "0,0"
--
-- USAGE - printPoint(point)
-- Prints the x and y coordinates of the passed point as a comma separated string.
-- Can be passed to selectionX.iterateSelection() to print the coordinates of all points in the current selection.
-- e.g.
-- stringX.printPoint(Point(0,0)) -- prints "0,0"
-- e.g. 
-- selectionX.iterateSelection(stringX.printPoint) -- prints the coordinates of all points in the selection
--
-- USAGE - indent(length)
-- Returns a string of spaces with the passed length.
-- e.g. print(stringX.indent(4)) -- prints "    "
--
-- USAGE - isNilOrWhiteSpace(variable)
-- Returns true if the passed parameter is a string that is either nil or only contains whitespace.
-- e.g. print(toString(stringX.isNilOrWhiteSpace("")))   -- prints "true"
-- e.g. print(toString(stringX.isNilOrWhiteSpace(" ")))  -- prints "true"
-- e.g. print(toString(stringX.isNilOrWhiteSpace("hi"))) -- prints "false"
-- e.g.
-- local text = nil
-- print(toString(stringX.isNilOrWhiteSpace(text)))      -- prints "true"
--
-- USAGE - trim(string)
-- Returns the passed string with all whitespace removed from the start and end.
-- e.g. print(stringX.trim(" hello   there   "))   -- prints "hello   there"


-- key variables
local image = app.image









---------------------------------------
--- ACTIONS
---------------------------------------

-- returns the concatenation of all parameters separated by the passed separator
local function concatWithSeparator(separator, ...)

    separator = separator or ","
    local args = {...}

    local result = ""

    for index, value in ipairs(args) do
        if (value == nil) then break end
        if (index ~= 1) then
            result = result .. separator
        end
        result = result .. value
    end

    return result
end

-- returns the concatenation of all parameters separated by the passed separator
local function concatWithCommas(...)
    return concatWithSeparator(",", ...)
end

local function getIndent(size)
    return string.rep(" ", size)
end

-- returns the string with no leading or trailing whitespace
-- KUDOS: http://lua-users.org/wiki/StringTrim
local function trim(s)
    return s:match'^%s*(.*%S)' or ''
end


-- true when the string is nil or only contains whitespace
local function isNilOrWhiteSpace(s)
    if not s then return true end
    if type(s) ~= "string" then return false end
    if trim(s) == "" then return true end
    return false
end









---------------------------------------
--- ACTIONS - DUMP
---------------------------------------

-- returns the table as indented text
local function dumpTable(o, indentSize)
    if indentSize == nil then indentSize = 0 end
    if type(o) == "table" then
        local s = ""
        if indentSize ~= 0 then s = s .. "\n" .. getIndent(indentSize) end
        s = s .. "{\n"
        for k, v in pairs(o) do
            local type = type(k)
            if type == "userdata" then
                k = ' "' .. tostring(k) .. '" '
            elseif type ~=  "number" then
                k = ' "' .. k .. '" '
            end
            s = s .. getIndent(indentSize + 1) .. "[" .. k .. "] = " .. dumpTable(v, indentSize + 1) .. ",\n"
        end
        return s .. getIndent(indentSize) .. "}"
    elseif type(o) == "string" then
        return ' "' .. tostring(o) .. '"'
    else
        return tostring(o)
    end
end

-- returns the RGBA values of the colour as text
local function dumpColourRGBA(colour)
    local r = colour.red
    local g = colour.green
    local b = colour.blue
    local a = colour.alpha
    return concatWithCommas(r,g,b,a)
end

-- returns the RGBA values of the colour as a table
local function dumpColourRGBATable(colour)
    local result = {}
    result["r"] = colour.red
    result["g"] = colour.green
    result["b"] = colour.blue
    result["a"] = colour.alpha
    result["value"] = colour.rgbaPixel

    return result
end

-- returns the RGBA values of the point as text
local function dumpPointRGBA(p)
    local pixelValue = image:getPixel(p.x, p.y)
    local r = app.pixelColor.rgbaR(pixelValue)
    local g = app.pixelColor.rgbaG(pixelValue)
    local b = app.pixelColor.rgbaB(pixelValue)
    local a = app.pixelColor.rgbaA(pixelValue)

    return concatWithCommas(r,g,b,a)
end

  -- returns the RGBA values of the point as a table
local function dumpPointRGBATable(p)
    local result = {}
    local pixelValue = image:getPixel(p.x, p.y)
    result["r"] = app.pixelColor.rgbaR(pixelValue)
    result["g"] = app.pixelColor.rgbaG(pixelValue)
    result["b"] = app.pixelColor.rgbaB(pixelValue)
    result["a"] = app.pixelColor.rgbaA(pixelValue)
    result["value"] = pixelValue

    return result
end

-- returns the position of the point as text
local function dumpPointPosition(p)
    return concatWithCommas(p.x, p.y)
end







---------------------------------------
--- ACTIONS - PRINT
---------------------------------------


local function printPoint(p)
  print(dumpPointPosition(p))
end











---------------------------------------
--- MODULE
---------------------------------------

return {
    concatWithCommas = concatWithCommas,
    concatWithSeparator = concatWithSeparator,

    dumpTable = dumpTable,
    dumpColourRGBA = dumpColourRGBA,
    dumpColourRGBATable = dumpColourRGBATable,
    dumpPointRGBA = dumpPointRGBA,
    dumpPointRGBATable = dumpPointRGBATable,
    dumpPointPosition = dumpPointPosition,

    printPoint = printPoint,

    indent = getIndent,
    isNilOrWhiteSpace = isNilOrWhiteSpace,
    trim = trim,
}
