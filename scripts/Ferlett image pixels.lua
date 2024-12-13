-- FERLETT IMAGE PIXELS


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



---- bindings

local dialogBinding = bindingX.dialogBinding()













---------------------------------------
--- HELPERS
---------------------------------------

-- initialises the colour table values with the values of the passed point
local function setOriginalColoursAtPoint(p)
    originalColours[p] = stringX.dumpPointRGBATable(p)
end














---------------------------------------
--- EVENT HANDLERS
---------------------------------------

local function onSampleClick()

    -- clear original colours
    originalColours = {}

    local firstPixel = selectionX.getPixelAtIndex(0)
    if firstPixel == nil then return end
    print(stringX.dumpTable(stringX.dumpPointRGBATable(firstPixel)))

end



















---------------------------------------
--- CONFIGURATION
---------------------------------------

-- creates and configures the dialog
local function configureDialog()

    -- create Dialog global
    dialog = Dialog { title = "Ferlett Image Pixels"}

    -- Sample button
    dialog:button {
        id = "Sample",
        text = "Sample",
        onclick = onSampleClick,
    }

    -- -- OK button
    -- dialog:button {
    --     id = OkButtonName,
    --     text = "OK",
    --     focus = true,
    -- }

end















---------------------------------------
--- MAIN
---------------------------------------

do
    -- -- (DEBUG) print the selection coordinates
    -- selectionX.iterateSelection(stringX.printPoint)

    -- configure the dialog
    configureDialog()
    if not dialog then return end

    -- show the dialog and wait for it to close
    dialog:show { wait = false }

end