-- module with binding functions.
-- expects a global Dialog `dialog` to be defined.
-- expects the custom widgets module `customWidgets` to be defined.
--
-- BINDINGS
-- * Dialog to customWidgets extension module
-- * Slider to Number text box
--
-- USAGE - dialogBinding()
--
-- Call dialogBinding() to create a binding and store the result table.
-- When defining the canvas containing the customWidgets, hook the canvas events to the functions in the result table.
--
-- e.g.
-- local dialogBinding = bindingX.dialogBinding()
-- ...
-- dialog:canvas {
--    ...
--    onpaint = dialogBinding.onPaint,
--    onmousemove = dialogBinding.onMouseMove,
--    onmousedown = dialogBinding.onMouseDown,
--    onmouseup = dialogBinding.onMouseUp,
--    ...
-- }
--
-- USAGE - sliderNumberBinding(sliderName, numberName)
--
-- Call sliderNumberBinding(), passing the name of the slider and number text box.  Store the result table.
-- When defining the slider on the Dialog, hook the `onchange` event to `onSliderChange()` in the result table.
-- When defining the number text box on the Dialog, hook the `onchange` event to `onNumberChange()` in the result table.
--
-- e.g.
-- local sliderNumberBinding = bindingX.sliderNumberBinding(sliderName, numberName)
-- ...
-- dialog:slider {
--    ...
--    id = sliderName,
--    onchange = function () sliderNumberBinding.onSliderChange() end,
--    ...
-- }
-- ...
-- dialog:number {
--    ...
--     id = numberName,
--     onchange = function () sliderNumberBinding.onNumberChange() end,
--    ...
-- }
-- ...










---------------------------------------
--- EVENT HANDLERS
---------------------------------------

local function onSliderChange(sliderName, numberName)
    local value = dialog.data[sliderName]
    dialog:modify { id=numberName, text=value }
end

local function onNumberChange(numberName, sliderName)
    local text = dialog.data[numberName]
    dialog:modify { id=sliderName, value=text }
end

local function onCanvasPaint(ev)

    local gc = ev.context

    -- (DEBUG) Draw canvas background for debugging
    -- local rect = Rectangle(0, 0, gc.width, gc.height)
    -- gc.color = Color(255, 0, 0, 255)
    -- gc:fillRect(rect)

    customWidgets.onPaint(ev, gc.width, gc.height)

end

local function onCanvasMouseMove(ev)
    customWidgets.onMouseMove(ev)
end

local function onCanvasMouseDown(ev)
    customWidgets.onMouseDown(ev)
end

local function onCanvasMouseUp(ev)
    customWidgets.onMouseUp(ev)
end








---------------------------------------
--- BINDINGS
---------------------------------------

local function sliderNumberBinding(sliderName, numberName)
    return {
        sliderName = sliderName,
        numberName = numberName,
        onSliderChange = function () onSliderChange(sliderName, numberName) end,
        onNumberChange = function () onNumberChange(numberName, sliderName) end,
    }
end

local function dialogBinding()
    return {
        onPaint = onCanvasPaint,
        onMouseMove = onCanvasMouseMove,
        onMouseDown = onCanvasMouseDown,
        onMouseUp = onCanvasMouseUp,
    }
end









---------------------------------------
--- MODULE
---------------------------------------

return {
    dialogBinding = dialogBinding,
    sliderNumberBinding = sliderNumberBinding,
}