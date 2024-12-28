-- v1.0.0
-- COLOUR SELECTED WIDGETS
--
-- Provides a dialog for the user to set/adjust the RGBA colour channels of selected pixels on image.assets/screenshots/colour-selected
-- Allows single or multiple selections for modification.
-- Pixels with no alpha value (transparent) can be opted in or out of the change (defaults to out).
-- The value can be modified with a slider or a numeric text box.
-- The dialog remembers and restores the values when toggling between absolute and relative modes.
-- The result of the operation are previewed live on the image and can be cancelled.
-- The accepted results are undoable/redoable.  Undo history contains a single event for the operation..
-- The RGBA and operation buttons on the dialog have tooltips that explain the state of the dialog when hovering.


---- key globals

sprite = app.sprite
if not sprite then return app.alert("there is no sprite present") end

selection = sprite.selection
if selection.isEmpty then return app.alert("there are no pixels selected") end

image = app.image
if not image then return app.alert("there is no image present") end



---- import

bindingX = dofile("modules/bindingExtensions.lua")
customWidgets = dofile("modules/customWidgets.lua")
luaX = dofile("modules/luaExtensions.lua")
selectionX = dofile("modules/selectionExtensions.lua")
stringX = dofile("modules/stringExtensions.lua")



---- script

local minimumCanvasWidth = 102
local minimumCanvasHeight = 44

local rgbaOperationButton = nil

local rgbaWidgetName = "rgba"
local numberName = "number"
local relativeSliderName = "relativeSlider"
local absoluteSliderName = "absoluteSlider"
local ignoreTransparentColourName = "ignoreTransparent"
local OkButtonName = "Ok"

local originalColours = {}
local newColours = {}
local isIgnoreTransparent = true



---- bindings

local dialogBinding = bindingX.dialogBinding()
local relativeValueBinding = bindingX.sliderNumberBinding(relativeSliderName, numberName)
local absoluteValueBinding = bindingX.sliderNumberBinding(absoluteSliderName, numberName)













---------------------------------------
--- HELPERS
---------------------------------------

-- sets the visible sliders and ensures the value is set to the stored state of the current operation mode
local function setDialogState(activeSliderName, inactiveSliderName, value)

    -- set visible sliders
    dialog:modify { id = activeSliderName, visible = true}
    dialog:modify { id = inactiveSliderName, visible = false}

    -- Restore previous value
    dialog:modify { id = numberName, text = tostring(value) }
    dialog:modify { id = activeSliderName, value = value }

end

-- initialises the colour table values with the values of the passed point
local function setOriginalColoursAtPoint(p)
    originalColours[p] = stringX.dumpPointRGBATable(p)
end

-- applies the colours to the points of the passed colour table.
-- `imageToApplyTo` (optional) - the image to apply the results to (defaults to the current image)
local function applyColours(colourTable, imageToApplyTo)
    imageToApplyTo = imageToApplyTo or image
    for point, colour in pairs(colourTable) do
        imageToApplyTo:drawPixel(point.x, point.y, colour)
    end
end

-- returns the state table of the rgba widget
local function getRGBAWidgetState()
    local dialogData = customWidgets.getDialogData()
    return dialogData[rgbaWidgetName]
end

-- true when any RGBA button is toggled on
local function isAnySelectedRGBA()
    local rgbaData = getRGBAWidgetState()
    local isUseR = rgbaData["r"]
    local isUseG = rgbaData["g"]
    local isUseB = rgbaData["b"]
    local isUseA = rgbaData["a"]

    -- ensure at least one channel is set to be applied
    local isUseAny = isUseR or isUseG or isUseB or isUseA
    if isUseAny then return true else return false end
end

-- true when new colours have been generated
local function generateNewColours(value, isRelative)

    if not isAnySelectedRGBA() then return false end

    local isAnyModified = false
    for point, colour in pairs(originalColours) do

        local newColour = nil
        local isTransparent = colour.a == 0
        local isModifyColour = not isIgnoreTransparent or not isTransparent

        if isModifyColour then

            local rgbaData = getRGBAWidgetState()
            local isUseR = rgbaData["r"]
            local isUseG = rgbaData["g"]
            local isUseB = rgbaData["b"]
            local isUseA = rgbaData["a"]

            if isRelative then

                local rAdjustment = isUseR and value or 0
                local gAdjustment = isUseG and value or 0
                local bAdjustment = isUseB and value or 0
                local aAdjustment = isUseA and value or 0

                -- apply adjustments and keep each channel in the range [0..255]
                local newR = luaX.clamp(colour.r + rAdjustment, 0, 255)
                local newG = luaX.clamp(colour.g + gAdjustment, 0, 255)
                local newB = luaX.clamp(colour.b + bAdjustment, 0, 255)
                local newA = luaX.clamp(colour.a + aAdjustment, 0, 255)

                newColour = Color(newR, newG, newB, newA)

            else -- absolute colour setting

                local newR = isUseR and luaX.clamp(value, 0, 255) or colour.r
                local newG = isUseG and luaX.clamp(value, 0, 255) or colour.g
                local newB = isUseB and luaX.clamp(value, 0, 255) or colour.b
                local newA = isUseA and luaX.clamp(value, 0, 255) or colour.a

                newColour = Color(newR, newG, newB, newA)

            end

            isAnyModified = true

        else -- not isModifyColour

            -- use originalColours
            newColour = originalColours[point]

        end

        newColours[point] = newColour

    end

    return isAnyModified

end

-- applies the results as a transaction for Aseprite's undo/redo history
local function applyResultAsTransaction()

    -- image:drawPixel doesn't work in transactions.
    -- Instead we clone the image, apply the results to the clone, then paint the cloned image.
    -- Drawing the image this way supports undo/redo.
    -- Note we have to draw using SRC blend mode to correctly apply alpha values

    local imageClone = image:clone()
    applyColours(newColours, imageClone)
    image:drawImage(imageClone, Point(0,0), 255, BlendMode.SRC)

end















---------------------------------------
--- EVENT HANDLERS
---------------------------------------

local function refreshOkButton()
    local isOkEnabled = isAnySelectedRGBA()
    dialog:modify{ id = OkButtonName, enabled = isOkEnabled }
end

-- called when the colour table needs to be recalculated after a value/state change
local function onValueChange()

    if rgbaOperationButton == nil then return end

    local isRelative = rgbaOperationButton.state.toggled
    local activeSliderName = isRelative and relativeSliderName or absoluteSliderName
    local value = dialog.data[activeSliderName]

    -- change newColours
    if generateNewColours(value, isRelative) then
        applyColours(newColours)
    else
        applyColours(originalColours)
    end

    refreshOkButton()

    -- Drawing while a dialog is open doesn't refresh the image
    app.refresh()

end

-- called when the operation button is toggled
-- isRelative - true when the operation is relative, false when it is absolute
local function onOperationButtonToggled(isRelative)

    if rgbaOperationButton == nil then return end

    local isRelative = rgbaOperationButton.state.toggled

    local restoredValue = 0
    local activeSliderName = ""
    local inactiveSliderName = ""

    if (isRelative) then
        restoredValue = dialog.data[relativeSliderName]
        activeSliderName = relativeSliderName
        inactiveSliderName = absoluteSliderName
    else -- absolute
        restoredValue = dialog.data[absoluteSliderName]
        activeSliderName = absoluteSliderName
        inactiveSliderName = relativeSliderName
    end

    -- update values from state
    setDialogState(activeSliderName, inactiveSliderName, restoredValue)

    -- handle value change
    onValueChange()

end



















---------------------------------------
--- CONFIGURATION
---------------------------------------

-- creates and configures the dialog
local function configureDialog()

    -- create Dialog global
    dialog = Dialog { title = "Pixel Colour"}

    -- canvas
    -- this will host the custom widgets
    dialog:canvas {
        width = minimumCanvasWidth,
        height = minimumCanvasHeight,
        onpaint = dialogBinding.onPaint,
        onmousemove = dialogBinding.onMouseMove,
        onmousedown = dialogBinding.onMouseDown,
        onmouseup = dialogBinding.onMouseUp,
    }

    -- ignore transparent colours checkbox
    dialog:check {
        id = ignoreTransparentColourName,
        text = "ignore transparent",
        selected = isIgnoreTransparent,
        onclick = function ()
            isIgnoreTransparent = not isIgnoreTransparent
            onValueChange()
        end,
    }

    dialog:label { text = "value:" }

    -- relative slider
    dialog:slider {
        id = relativeSliderName,
        min = -255,
        max = 255,
        value = 0,
        visible = false,
        onchange = function ()
            relativeValueBinding.onSliderChange()
            onValueChange()
        end,
    }

    -- absolute slider
    dialog:slider {
        id = absoluteSliderName,
        min = 0,
        max = 255,
        value = 128,
        visible = false,
        onchange = function ()
            absoluteValueBinding.onSliderChange()
            onValueChange()
        end,
    }

    -- value text box
    dialog:number {
        id = numberName,
        decimals = 0,
        onchange = function ()

            if rgbaOperationButton == nil then return end

            local isRelative = rgbaOperationButton.state.toggled
            if isRelative then
                relativeValueBinding.onNumberChange()
            else
                absoluteValueBinding.onNumberChange()
            end

            onValueChange()
        end,
    }

    -- OK button
    dialog:button {
        id = OkButtonName,
        text = "OK",
        focus = true
    }

    -- Add custom widgets
    customWidgets.addLabel("set/adjust channel value", 0, 2)
    customWidgets.addLabel("channel:", 0, 19)
    customWidgets.addLabel("operation:", 0, 32)

    -- (DEBUG) rgba properties
    -- local rgbaToggleState = customWidgets.getRGBAToggleState()
    -- local rgbaToggleText = customWidgets.getRGBAToggleText()
    -- local rgbaTooltipText = customWidgets.getRGBATooltipText()
    -- rgbaToggleState.g = true
    -- rgbaToggleText.b = "b"
    -- rgbaTooltipText.r = "Red only"
    -- local rgba = customWidgets.addRGBAWidget(rgbaWidgetName, 49, 15, rgbaToggleState, rgbaToggleText, rgbaTooltipText)

    local rgba = customWidgets.addRGBAWidget(rgbaWidgetName, 49, 15)

    -- Hook custom widget event handlers.
    -- This is where the UI functionality of this script is tied in to the dialog.
    rgbaOperationButton = rgba.operationButton
    rgbaOperationButton.onclick = onOperationButtonToggled

    rgba.rChannelButton.onclick = onValueChange
    rgba.gChannelButton.onclick = onValueChange
    rgba.bChannelButton.onclick = onValueChange
    rgba.aChannelButton.onclick = onValueChange

    -- set initial state
    setDialogState(absoluteSliderName, relativeSliderName, dialog.data[absoluteSliderName])
    onValueChange()

end















---------------------------------------
--- MAIN
---------------------------------------

do
    -- remember original details of all points in the selection
    selectionX.iterateSelection(setOriginalColoursAtPoint)

    -- -- (DEBUG) print the selection coordinates
    -- selectionX.iterateSelection(stringX.printPoint)

    -- configure the dialog
    configureDialog()
    if not dialog then return end

    -- show the dialog and wait for it to close
    dialog:show { wait = true }


    -- get the extended results of the dialog
    local dialogData = customWidgets.getDialogData()

    -- (DEBUG) print the table data of the dialog
    -- print(stringX.dumpTable(dialogData))
    -- print(stringX.dumpTable(originalColours))
    -- for point, colour in pairs(newColours) do
    --     print(stringX.dumpTable(stringX.dumpColourRGBATable(colour)))
    --     print(stringX.dumpTable(stringX.dumpPointRGBATable(point)))
    -- end

    -- restore original colours
    applyColours(originalColours)

    -- exit if the user cancelled
    if not dialogData[OkButtonName] then return end

    -- apply the results inside a transaction (to support undo/redo)
    app.transaction("set/adjust rgba", applyResultAsTransaction)

end