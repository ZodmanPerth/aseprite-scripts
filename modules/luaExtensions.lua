-- v1.0.0
-- module with lua helper functions
--
-- USAGE - clamp(value, min, max)
-- Returns a value closest to the range between a minimum and maximum value.
-- If the value is already on or in the range, the same value is returned.
-- e.g.
-- print(luaX.clamp(-5,1,5)) -- prints "1"
-- print(luaX.clamp(15,1,5)) -- prints "5"
-- print(luaX.clamp( 1,1,5)) -- prints "1"
-- print(luaX.clamp( 3,1,5)) -- prints "3"
--
-- USAGE - ternary(condition, trueValue, falseValue)
-- Returns either the trueValue or the falseValue, depending on the condition value.
-- e.g.
-- local value = 5
-- print(luaX.ternary(value < 10, "yes", "no")) -- prints "yes"
-- print(luaX.ternary(value > 10, "yes", "no")) -- prints "no"







---------------------------------------
--- ACTIONS
---------------------------------------

-- Returns the closest value within the range min/max from the passed value
local function clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

-- Returns trueValue or falseValue depending on whether the condition is true or false.
-- Both trueValue and falseValue will be evaluated before callint this function.
local function ternary(condition, trueValue, falseValue)
    if condition then return trueValue end
    return falseValue
end








---------------------------------------
--- MODULE
---------------------------------------

return {
    clamp = clamp,
    ternary = ternary,
}