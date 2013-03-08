
local ToolBase = require("editor.ToolBase")
local GeneralTool = class("GeneralTool", ToolBase)

function GeneralTool:ctor(toolbar, map)
    GeneralTool.super.ctor(self, "GeneralTool", toolbar, map)

    self.buttons = {
        {
            name          = "DragMap",
            image         = "#DragMapButton.png",
            imageSelected = "#DragMapButtonSelected.png",
        },
        {
            name          = "SaveMap",
            image         = "#SaveMapButton.png",
            imageSelected = "#SaveMapButtonSelected.png",
        },
        {
            name          = "ToggleDebug",
            image         = "#ToggleDebugButton.png",
            imageSelected = "#ToggleDebugButtonSelected.png",
        },
        {
            name          = "ToggleBackground",
            image         = "#ToggleBackgroundButton.png",
            imageSelected = "#ToggleBackgroundButtonSelected.png",
        },
        {
            name          = "PlayMap",
            image         = "#PlayMapButton.png",
            imageSelected = "#PlayMapButtonSelected.png",
        },
    }

    self.drag_           = nil
    self.debugIsVisible_ = true
end

function GeneralTool:selected(selectedButtonName)
    if selectedButtonName == "SaveMap" then
        local saveOk = self.map_:dumpToFile()
        self.toolbar_:selectButton("GeneralTool", 1)

        if saveOk then
            local label = display.newSprite("#SaveMapOkLabel.png")
            local x, y = self.buttons[2].sprite:getPosition()
            label:setPosition(x + 60, y + 46)
            self.toolbar_:getView():addChild(label)

            transition.moveBy(label, {y = 10, time = 0.5})
            transition.fadeOut(label, {time = 0.5, delay = 1.7, onComplete = function()
                label:removeSelf()
            end})
        end
    elseif selectedButtonName == "ToggleDebug" then
        local debugLayer = self.map_:getDebugLayer()
        debugLayer:setVisible(not debugLayer:isVisible())
        self.toolbar_:selectButton("GeneralTool", 1)
    elseif selectedButtonName == "ToggleBackground" then
        local backgroundLayer = self.map_:getBackgroundLayer()
        local opacity = backgroundLayer:getOpacity()
        if opacity == 255 then
            opacity = 80
        else
            opacity = 255
        end
        backgroundLayer:setOpacity(opacity)
        -- backgroundLayer:setVisible(not backgroundLayer:isVisible())
        self.toolbar_:selectButton("GeneralTool", 1)
    elseif selectedButtonName == "PlayMap" then
        self.toolbar_:dispatchEvent({name = "PLAY_MAP"})
        self.toolbar_:selectButton("GeneralTool", 1)
    end
end

function GeneralTool:onIgnoredTouch(event, x, y, isDefaultTouch)
    if event == "began" then
        self.drag_ = {
            startX  = x,
            startY  = y,
            lastX   = x,
            lastY   = y,
            offsetX = 0,
            offsetY = 0,
        }
        return true
    end

    if event == "moved" then
        self.drag_.offsetX = x - self.drag_.lastX
        self.drag_.offsetY = y - self.drag_.lastY
        self.drag_.lastX = x
        self.drag_.lastY = y
        self.map_:getCamera():moveOffset(self.drag_.offsetX, self.drag_.offsetY)

    else -- "ended" or CCTOUCHCANCELLED
        self.drag_ = nil
        if isDefaultTouch then
            return GeneralTool.DEFAULT_TOUCH_ENDED
        end
    end
end

function GeneralTool:onTouch(event, x, y)
    return self:onIgnoredTouch(event, x, y)
end

function GeneralTool:setPlayerControlPanel(panel)
    self.panel_ = panel
end

return GeneralTool