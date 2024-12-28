-- v1.0.0
-- module with custom widgets to a Dialog canvas.
-- expects a global Dialog "dialog" to be defined.
--
-- USAGE
--
-- Widgets are painted on a custom canvas on the dialog.  You must consume the `onPaint`, `onMouseMove`,
-- `onMouseDown`, and `onMouseUp` events of the canvas and call the corresponding functions on this module.
-- You can use the `dialogBinding` function of the binding extensions module to bind these events for you.
-- 
-- Add widgets to the canvas using the `add..` functions.  Each has their own parameters.
--
-- `dialog.data` has an issue that prevents adding the state of custom widgets to it in a usable manner
-- (see https://github.com/aseprite/aseprite/issues/4707 for issue description).  To get `dialog.data`
-- that includes the data from this module, call `getDialogData`.
--
-- WIDGETS
-- 
-- All widgets can have custom names.  If you don't provide a name, one will be provided for you.
-- 
-- Label    - Text at a position on the canvas
-- Button   - Text on a button with defined width and height at a position on the canvas.
--            Can be a normal button or a toggle button.
--            Can define tooltip(s) to display when the user hovers over the button.
--            Toggle buttons can have 2 tooltips (one for each toggle state).
--            Can set the "onClick" function.
--            For specifics, see the "addButton" function definition
-- Tooltip  - A tooltip to display over custom widgets.  Only one tooltip can be displayed at a time.
--            At the moment, tooltips are only shown for custom widgets.
--            A triangular notch on the tooltip is shown in the horizontal center pointing down.
--            The body of the tooltip will be moved horizontally to ensure the whole tooltip fits on the 
--            canvas if possible.
-- RGBA     - A cluster of 4 toggle buttons labelled "R", "G", "B", and "A" with an "operation" toggle
--            button underneath.  Toggle state, tooltips, and text on toggles can be defined - use the
--            functions getRGBAToggleState(), getRGBATooltipText(), and getRGBAToggleText() to get
--            the default values and adjust accordingly.
--
-- FUNCTIONS
--
-- getDialogData
-- Gets the extended data of the dialog including the data for custom widgets.
-- `dialog.data` has an issue that prevents it to be used for this purpose with custom widgets.
-- See https://github.com/aseprite/aseprite/issues/4707.
--
-- getRGBAToggleState
-- The default toggle state of an RGBA widget.  Can be used to create custom configuration to an RGBA button.
--
-- getRGBAToggleText
-- The default text of an RGBA widget.  Can be used to create custom configuration to an RGBA button.
--
-- getRGBATooltipText
-- The default tooltip text of an RGBA widget.  Can be used to create custom configuration to an RGBA button.
--
-- EVENT HANDLERS
--
-- onPaint
-- Call this from the onPaint event of the canvas that consumes custom widgets.
-- 
-- onMouseMove
-- Call this from the onMouseMove event of the canvas that consumes custom widgets.
-- 
-- onMouseDown
-- Call this from the onMouseDown event of the canvas that consumes custom widgets.
-- 
-- onMouseUp
-- Call this from the onMouseUp event of the canvas that consumes custom widgets.


local ColourChannelButtonWidth = 14
local ColourChannelButtonHeight = 16
local offCanvasPosition = Point(-10, -10)

local mouseInput = {
    position = offCanvasPosition,     -- start off canvas so selection state of widgets aren't affected
    leftButtonDown = false,
    isFirstButtonDownHandled = false,
}

-- a counter for uniquely identifying widgets when no name is provided
local widgetNameCounter = 1

-- the widget that has focus
local focusedWidget = nil

-- the tooltip on the widget the mouse is over - only one is allowed at a time
local activeTooltip = nil


-- the widget the mouse is over during a single paint pass.  Used to enforce only one activeTooltip at a time.
local paintPassMouseOverWidget = nil

-- whether a tooltip was visible before the paint pass
local paintPassIsVisibleTooltip = false

-- true when a tooltip has timed out
local isCustomTooltipTimedOut = false


local customLabels = {}
local customButtons = {}
local tooltipWidgets = {}
















---------------------------------------
--- HELPERS
---------------------------------------

local function getRGBAToggleState()
    return { r = false, g = false, b = false, a = false }
end

local function getRGBAToggleText()
    return { r = "R", g = "G", b = "B", a = "A", operations = { "absolute", "relative" }}
end

local function getRGBATooltipText()
    return
    {
        r = { "Ignore red channel", "Modify red channel" },
        g = { "Ignore green channel", "Modify green channel" },
        b = { "Ignore blue channel", "Modify blue channel" },
        a = { "Ignore alpha channel", "Modify alpha channel" },
        operations = { "Apply the value", "Modify the value" },
    }
end

-- For widgets with dual tooltips, this sets the tooltips to show/hide
-- visibleTooltip - the tooltip that should be visible
-- partnerTooltip - the other tooltip in this dual tooltip arrangement
local function setDualTooltipState(visibleTooltip, partnerTooltip)

    if visibleTooltip then

        -- check if changing from a visible partner tooltip (change immediately)
        if partnerTooltip and partnerTooltip.isVisible and not isCustomTooltipTimedOut then

            visibleTooltip.isVisible = true
            partnerTooltip.isVisible = false

            isCustomTooltipTimedOut = false
            customTooltipHideTimer:stop()
            customTooltipHideTimer:start()

        -- check if changing tooltip controls
        elseif visibleTooltip and not visibleTooltip.isVisible then

            if not paintPassIsVisibleTooltip then -- no tooltip is visible 

                -- restart show timer if it didn't time out
                if not isCustomTooltipTimedOut then

                    customTooltipHideTimer:stop()
                    customTooltipShowTimer:stop()
                    customTooltipShowTimer:start()
                end

            else -- a tooltip is already visible

                if visibleTooltip ~= activeTooltip then

                    visibleTooltip.isVisible = true

                    isCustomTooltipTimedOut = false
                    customTooltipHideTimer:stop()
                    customTooltipHideTimer:start()

                end
                -- else start timer Carl TODO: 
            end
        end

    else  -- no visibleTooltip

        -- ensure partnerTooltip is not visible
        if partnerTooltip then partnerTooltip.isVisible = false end

    end

    -- set activeTooltip to the tooltip that should be visible
    activeTooltip = visibleTooltip

end

local function getWidgetName(name, default)

    if name == nil or stringX.trim(name) == "" then
        name = default .. widgetNameCounter
    end

    widgetNameCounter = widgetNameCounter + 1

    return name

end

-- This function provides customised dialog.data results as you can't currently customise dialog.data.
-- I logged an issue about this: https://github.com/aseprite/aseprite/issues/4707
local function getDialogData()

    local myData = dialog.data

    for _, button in ipairs(customButtons) do

        local isToggleButton = button.type == "toggle"
        if (isToggleButton) then

            local isToggled = button.state.toggled
            local buttonName = button.name
            local parentName = button.parentName

            -- Add parent table to results
            if parentName then
                if myData[parentName] == nil then
                    myData[parentName] = {}
                end

                myData[parentName][buttonName] = isToggled
            else
                myData[buttonName] = isToggled
            end
        end

    end

    for _, label in ipairs(customLabels) do

        local labelGroupName = "customLabels"
        local parentName = myData[labelGroupName]
        if parentName == nil then
            myData[labelGroupName] = {}
        end

        myData[labelGroupName][label.name] = label.text

    end

    return myData
end










---------------------------------------
--- WIDGETS
---------------------------------------
-- KUDOS: https://stackoverflow.com/a/27028488/117797

-- returns a table containing the properties of the button.
-- `args` is a table with the following properties:
-- buttonType   : the type of button ["button","toggle"]
-- toggled      : the value of a toggle button
-- text         : the text on the button.
--                For toggle buttons, can be a string or a table { "toggle off text", "toggle on text" }
-- x            : the x position of the button on the canvas
-- y            : the y position of the button on the canvas
-- width        : the width of the button
-- height       : the height of the button
-- tooltipText  : the text of a tooltip on the button.
--                For toggle buttons, can be a string or a table { "toggle off tooltip text", "toggle on tooltip text" }
-- parentName   : the name of the parent control (if there is one)
-- name         : the name of the button
-- onclick      : the function to call when the button is clicked
local function addButton(args)

    local buttonType = args.buttonType or "button"
    local toggled = args.toggled or false
    local text = args.text or "button"
    local x = args.x or 0
    local y = args.y or 0
    local width = args.width or ColourChannelButtonWidth
    local height = args.height or ColourChannelButtonHeight
    local tooltipText = args.tooltipText
    local parentName = args.parentName
    local name = args.name
    local onclick = args.onclick

    if parentName and stringX.trim(parentName) == "" then
        parentName = nil
    end

    name = getWidgetName(name, buttonType)


    local bounds = Rectangle(x, y, width, height)

    local state = {
        parentName = parentName,
        name = name,
        type = buttonType,
        bounds = bounds,
        state = {
            normal = { part = "buttonset_item_normal", color = "button_normal_text" },
            hot = { part = "buttonset_item_hot", color = "button_hot_text" },
            selected = { part = "buttonset_item_pushed", color = "button_selected_text" },
            focused = { part = "buttonset_item_focused", color = "button_normal_text" },
        },
        text = text,                        -- can be a string or a table of 2 strings (toggle off/on text)
        tooltipText = tooltipText,          -- can be a string or a table of 2 strings (toggle off/on text)
        onclick = onclick,
        tooltip = nil,                      -- set tooltipText to create tooltips automatically
    }

    local isToggle = buttonType == "toggle"
    if isToggle then

        -- set toggle value
        state.state.toggled = toggled       -- true when the toggle button is selected

        -- set toggle text
        if type(text) == "table" then       -- can be a string or a table of 2 strings (toggle off/on text)
            state.state.toggleText = text
            state.text = text[1]
        else
            state.state.toggleText = text
        end

    end

    -- add to customWidgets
    customButtons[#customButtons + 1] = state

    return state

end

-- returns a table containing the properties of the RGBA widget.
--
-- `toggleState` is a table with the following properties:
--      r:   true/false for the toggle state of the r button
--      g:   true/false for the toggle state of the g button
--      b:   true/false for the toggle state of the b button
--      a:   true/false for the toggle state of the a button
-- See `getRGBAToggleState()`.
--
-- `toggleText` is a table similar to `toggleState` that defines the text of the RGBA buttons
-- and 2 strings defining the text on the operation button on an `operations` entry.
-- See `getRGBAToggleText()`.
--
-- `tooltipText` is a table similar to `toggleText` that defines a string or a table of 2 strings for
-- the tooltips of the RGBA and operation buttons.
-- See `getRGBATooltipText()`.
local function addRGBAWidget(name, x, y, toggleState, toggleText, tooltipText)

    name = getWidgetName(name, "rgba")
    x = x or 10
    y = y or 10
    if toggleState == nil then toggleState = getRGBAToggleState() end
    if toggleText == nil then toggleText = getRGBAToggleText() end
    if tooltipText == nil then tooltipText = getRGBATooltipText() end

    local rChannelButton =  addButton
    ({
        buttonType = "toggle",
        toggled = toggleState.r,
        parentName = name,
        name = "r",
        text = toggleText.r,
        x = x,
        y = y,
        width = ColourChannelButtonWidth,
        height = ColourChannelButtonHeight,
        tooltipText = tooltipText.r,
    })

    local gChannelButton =  addButton
    ({
        buttonType = "toggle",
        toggled = toggleState.g,
        parentName = name,
        name = "g",
        text = toggleText.g,
        x = x + ColourChannelButtonWidth - 1,
        y = y,
        width = ColourChannelButtonWidth,
        height = ColourChannelButtonHeight,
        tooltipText = tooltipText.g,
    })

    local bChannelButton =  addButton
    ({
        buttonType = "toggle",
        toggled = toggleState.b,
        parentName = name,
        name = "b",
        text = toggleText.b,
        x = x + 2 * (ColourChannelButtonWidth - 1),
        y = y,
        width = ColourChannelButtonWidth,
        height = ColourChannelButtonHeight,
        tooltipText = tooltipText.b,
    })

    local aChannelButton =  addButton
    ({
        buttonType = "toggle",
        toggled = toggleState.a,
        parentName = name,
        name = "a",
        text = toggleText.a,
        x = x + 3 * (ColourChannelButtonWidth - 1),
        y = y,
        width = ColourChannelButtonWidth,
        height = ColourChannelButtonHeight,
        tooltipText = tooltipText.a,
    })

    local operationButton =  addButton
    ({
        buttonType = "toggle",
        toggled = false,
        parentName = name,
        name = "operation",
        text = toggleText.operations,
        x = x,
        y = y + ColourChannelButtonHeight - 3,
        width = 4 * (ColourChannelButtonWidth - 1) + 1,
        height = ColourChannelButtonHeight,
        tooltipText = tooltipText.operations,
    })

    -- (DEBUG) These comments contain test values
    -- rChannelButton.tooltipText = "Hello"
    -- gChannelButton.tooltipText = { "Off", "" }
    -- bChannelButton.tooltipText = {nil, "on"}

    return {
        name = name,

        rChannelButton = rChannelButton,
        gChannelButton = gChannelButton,
        bChannelButton = bChannelButton,
        aChannelButton = aChannelButton,
        operationButton = operationButton,

        isToggled = isToggled,
    }

end

-- When tooltip is visible, it will be painted.  We ensure only one tooltip is visible at a time.
local function addTooltip(text, x, y)

    text = text or "tooltip"
    x = x or 0
    y = y or 0

    local state = {
        type = "tooltip",
        x = x,
        y = y,
        text = text,
        isVisible = false,
    }

    -- add to tooltip widgets
    tooltipWidgets[#tooltipWidgets + 1] = state

    return state

end

local function addLabel(text, x, y, name)

    text = text or "tooltip"
    x = x or 0
    y = y or 0

    name = getWidgetName(name, "label")

    local state = {
        type = "label",
        x = x,
        y = y,
        text = text,
        name = name,
    }

    -- add to tooltip widgets
    customLabels[#customLabels + 1] = state

    return state
end

-- Creates tooltips for widgets that are defined through tooltip text and don't yet have tooltips created
local function createNewTooltips()

    -- buttons
    for _, button in ipairs(customButtons) do

        if button.tooltipText and not button.tooltip then

            local tooltipX = button.bounds.x + button.bounds.width / 2
            local tooltipY = button.bounds.y

            if type(button.tooltipText) == "table" then
                local tooltips = {}

                local newTooltip = nil
                local text = button.tooltipText[1]
                if not stringX.isNilOrWhiteSpace(text) then
                    newTooltip = addTooltip(text, tooltipX, tooltipY)
                end
                tooltips[#tooltips+1] = newTooltip

                newTooltip = nil
                local text = button.tooltipText[2]
                if not stringX.isNilOrWhiteSpace(text) then
                    newTooltip = addTooltip(text, tooltipX, tooltipY)
                end
                tooltips[#tooltips+1] = newTooltip

                button.tooltip = tooltips
            else
                local tooltip = addTooltip(button.tooltipText, tooltipX, tooltipY)
                button.tooltip = tooltip
            end
        end
    end

end












---------------------------------------
--- HELPERS - PAINT
---------------------------------------

local function paintLabels(ev)

    local gc = ev.context
    gc:save()

    -- draw text
    for _, label in ipairs(customLabels) do
        gc.color = app.theme.color["text"]
        gc:fillText(label.text, label.x, label.y)
    end
    
    gc:restore()
end

local function paintButtons(ev)

    local gc = ev.context

    for _, button in ipairs(customButtons) do

        -- define a base state
        local state = button.state.normal

        -- set focus state
        if button == focusedWidget then
            state = button.state.focused
        end

        local bounds = button.bounds
        local buttonCollisionArea = Rectangle(bounds.x + 2, bounds.y + 2, bounds.width - 2, bounds.height - 4)

        local isMouseDown = mouseInput.leftButtonDown
        local isMouseOver = buttonCollisionArea:contains(mouseInput.position)
        local isToggleButton = button.type == "toggle"
        local isToggled = isToggleButton and button.state.toggled

        -- set selected state for toggle button
        if isToggled then
            state = button.state.selected
        end

        -- set states from mouse
        if isMouseOver then

            paintPassMouseOverWidget = button

            if isMouseDown and mouseInput.isFirstButtonDownHandled == false then

                -- set widget to selected state
                state = button.state.selected

                if isToggleButton then

                    -- set toggle value
                    isToggled = not isToggled
                    button.state.toggled = isToggled

                    -- toggle text with selected state (if required)
                    if #button.state.toggleText == 2 then
                        local textIndex = 1
                        if isToggled then textIndex = 2 end
                        button.text = button.state.toggleText[textIndex]
                    end

                end

                mouseInput.isFirstButtonDownHandled = true

            else  -- mouse over widget but already handled

                state = button.state.hot or state

            end
        end


        -- draw the widget using Aseprite theme
        gc:drawThemeRect(state.part, button.bounds)


        -- draw hot/selected face for toggle buttons
        if isToggled then
            if isMouseOver and button.state.hot then
                gc.color = app.theme.color["check_hot_face"]
            else
                gc.color = app.theme.color["background"]
            end
            local buttonFace = Rectangle(bounds.x + 2, bounds.y + 2, bounds.width - 4, bounds.height - 6)
            gc:fillRect(buttonFace)
        end


        local center = Point(
            button.bounds.x + button.bounds.width / 2,
            button.bounds.y + button.bounds.height / 2
        )

        -- draw icon
        if button.icon then

            -- Draw the icon
            -- assumes icon size of 16x16 pixels
            local size = Rectangle(0, 0, 16, 16)
            gc:drawThemeImage
            (
                button.icon, center.x - size.width / 2,
                center.y - size.height / 2
            )

        -- draw text
        elseif button.text then

            local textSize = gc:measureText(button.text)
            gc.color = app.theme.color[state.color]

            -- override colour for selected toggle buttons
            if isToggled then
                gc.color = app.theme.color["textbox_text"]
            end

            -- draw the button text
            gc:fillText(
                button.text,
                center.x - textSize.width / 2 + 1,
                center.y - textSize.height / 2
            )

        end

        -- show/hide tooltips
        if button.tooltip then

            if #button.tooltipText == 2 then

                local toggledOffTooltip = button.tooltip[1]
                local toggledOnTooltip = button.tooltip[2]

                 if isMouseOver then

                    -- show appropriate tooltip
                    if isToggled then
                        setDualTooltipState(toggledOnTooltip, toggledOffTooltip)
                    else
                        setDualTooltipState(toggledOffTooltip, toggledOnTooltip)
                    end

                else

                    if toggledOnTooltip then toggledOnTooltip.isVisible = false end
                    if toggledOffTooltip then toggledOffTooltip.isVisible = false end

                end

            else -- single tooltip
                local tooltip = button.tooltip
                if isMouseOver and tooltip then  -- tooltip should be shown
                    if activeTooltip ~= tooltip and not tooltip.isVisible then
                        customTooltipHideTimer:stop()
                        customTooltipShowTimer:start()
                    end
                    activeTooltip = tooltip
                else
                    tooltip.isVisible = false
                end
            end

        end

    end     -- widget loop

end

local function paintTooltips(ev, maxWidth, maxHeight)

    local gc = ev.context
    gc:save()

    for _, tooltip in ipairs(tooltipWidgets) do

        local isVisible = tooltip.isVisible
        if isVisible then

            local text = tooltip.text
            if type(text) == "table" then
                local indexedText = text[tooltip.textIndex]
                text = indexedText or text
            end

            local textSize = gc:measureText(text)
            local bodyWidth = textSize.width + 5
            local bodyHeight = textSize.height + 3
            local bodyX = tooltip.x - bodyWidth / 2
            if bodyX + bodyWidth > maxWidth - 1 then bodyX = maxWidth - bodyWidth - 1 end
            if bodyX < 1 then bodyX = 1 end
            local bodyY = tooltip.y - bodyHeight - 3


            -- body

            local bodyRect = Rectangle(bodyX, bodyY, bodyWidth, bodyHeight)
            local leftBuff = Rectangle(bodyX - 1, bodyY + 1, 1, bodyHeight - 2)
            local rightBuff = Rectangle(bodyX + bodyWidth, bodyY + 1, 1, bodyHeight - 2)

            gc.color = app.theme.color["tooltip_face"]
            gc:beginPath()
            gc:rect(bodyRect)
            gc:rect(leftBuff)
            gc:rect(rightBuff)
            gc:fill()


            -- shadow

            local shadowBody = Rectangle(bodyX, bodyY + bodyHeight, bodyWidth, 2)
            local shadowLeft = Rectangle(bodyX - 1, bodyY + bodyHeight - 1, 1, 2)
            local shadowRight = Rectangle(bodyX + bodyWidth, bodyY + bodyHeight - 1, 1, 2)

            gc.color = app.theme.color["tooltip_text"]
            gc.opacity = 128
            gc:beginPath()
            gc:rect(shadowBody)
            gc:rect(shadowLeft)
            gc:rect(shadowRight)
            gc:fill()
            gc.opacity = 255


            -- pointer down

            local pointMiddle = Point(tooltip.x, tooltip.y)
            local pointLeft = Point(pointMiddle.x - 3, pointMiddle.y - 3)
            local pointRight = Point(pointMiddle.x + 3, pointMiddle.y - 3)

            gc.color = app.theme.color["tooltip_face"]
            gc:beginPath()
            gc:moveTo(pointMiddle.x, pointMiddle.y)
            gc:lineTo(pointLeft.x, pointLeft.y)
            gc:lineTo(pointRight.x, pointRight.y)
            gc:closePath()
            gc:fill()


            -- text

            gc.color = app.theme.color["tooltip_text"]
            gc:fillText(
                text,
                bodyX + 3,
                bodyY + 2
            )
        end

    end

    gc:restore()

end














---------------------------------------
--- EVENT HANDLERS
---------------------------------------

-- KUDOS: https://github.com/aseprite/Aseprite-Script-Examples/blob/main/Custom%20Widgets.lua
-- This is the main paint pass.  We iterate over the different widgets and paint the canvas
-- based on the state of each widget.
local function onPaint(ev, maxWidth, maxHeight)

    createNewTooltips()

    local gc = ev.context

    -- initialise paint pass variables
    paintPassMouseOverWidget = nil              -- we set this when we find a suitable widget during this pass
    paintPassIsVisibleTooltip = activeTooltip ~= nil and activeTooltip.isVisible and not isCustomTooltipTimedOut   -- this will identify if a tooltip was visible before this pass

    paintLabels(ev)
    paintButtons(ev)

    -- paint tooltips last so they go on top
    if paintPassMouseOverWidget then
        paintTooltips(ev, maxWidth, maxHeight)
    else
        activeTooltip = nil
        isCustomTooltipTimedOut = false
        customTooltipShowTimer:stop()
        customTooltipHideTimer:stop()
    end

end

local function onMouseMove(ev)
    mouseInput.position = Point(ev.x, ev.y)
    isCustomTooltipTimedOut = false
    dialog:repaint()
end

local function onMouseDown(ev)
    isCustomTooltipTimedOut = false
    mouseInput.leftButtonDown = ev.button == MouseButton.LEFT
    dialog:repaint()
end

local function onMouseUp(ev)

    -- when releasing left mouse button over a widget, call `onclick` method
    if mouseInput.leftButtonDown then
        for _, widget in ipairs(customButtons) do
            local isMouseOver = widget.bounds:contains(mouseInput.position)
            if isMouseOver then
                if widget.onclick then widget.onclick() end

                -- Last clicked widget has focus on it
                focusedWidget = widget
            end
        end
    end

    mouseInput.leftButtonDown = false
    mouseInput.isFirstButtonDownHandled = false

    dialog:repaint()

end

local function onShowCustomTooltipTimerTick()

    customTooltipShowTimer:stop()

    if not activeTooltip then return end

    isCustomTooltipTimedOut = false
    activeTooltip.isVisible = true
    dialog:repaint()

    -- start timer to hide this tooltip
    customTooltipHideTimer:start()

end

local function onHideCustomTooltipTimerTick()

    local isRunning = customTooltipHideTimer.isRunning

    customTooltipHideTimer:stop()

    if not isRunning then return end
    isCustomTooltipTimedOut = true

    if not activeTooltip then return end
    activeTooltip.isVisible = false
    activeTooltip = nil

    dialog:repaint()

end

















---------------------------------------
--- MODULE
---------------------------------------

-- timer to show a tooltip after hovering over a widget with a defined tooltip for a short time
customTooltipShowTimer = Timer {
    interval = 0.4,
    ontick = onShowCustomTooltipTimerTick
}

-- timer to hide a tooltip after a tooltip has been visible for some time.
-- This is a defensive tooltip.  Usually tooltips will be hidden when moving off the widget
-- without this timer, but if the user hovers for a long time or they move the mouse cursor
-- so fast we don't capture the move event, this will ensure the tooltip is hidden appropriately.
customTooltipHideTimer = Timer {
    interval = 2.0,
    ontick = onHideCustomTooltipTimerTick
}

return {
    -- widgets
    addTooltip = addTooltip,
    addLabel = addLabel,
    addButton = addButton,
    addRGBAWidget = addRGBAWidget,

    -- helpers
    getDialogData = getDialogData,
    getRGBAToggleState = getRGBAToggleState,
    getRGBAToggleText = getRGBAToggleText,
    getRGBATooltipText = getRGBATooltipText,

    -- event Handlers
    onPaint = onPaint,
    onMouseMove = onMouseMove,
    onMouseDown = onMouseDown,
    onMouseUp = onMouseUp,
}