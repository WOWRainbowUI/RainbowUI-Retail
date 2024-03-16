--[[---------------------------------------------------------------------------
FILE:   Controls.lua
DESC:   Adds functions to your addon's private data block that can be used
        to create various UI controls.
        Credits: Based on code by Mikord (MSBT Options Controls).

REQUIREMENTS / DEPENDANCIES:
        The following files must be placed in your addon's folder ...
            - Controls.lua
        Also, any icon artwork used in calls to CreateIconButton() must also
        be placed in your addon's folder.
        Finally, add Controls.lua to your TOC file.

USAGE:  See examples at end of this comment block.
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
CHANGE HISTORY:
    Jan 23, 2024
        - Updated example for customizing listbox lines.
        - Removed dropdown.listbox variable since it created cyclic references.
          Replaced it with dropdown:GetListBoxFrame(), which essentially does the
          same thing without causing cyclic references.  (Added DropDown_GetListBoxFrame().)
        - Moved setpointFunc() to be a direct member of the dropdown object since
          it's listbox doesn't exist until after the dropdown is clicked.
        - Added vdt_dump() helper function.
    Jan 18, 2024
        - Updated color picker functionality to support the API changes in WoW 10.2.5.
        - Added DisplayAllFonts() for use by developers.
    Aug 13, 2023
        - Modified CreateListBox() to accept a parameter for creating a listbox border.
        - Added a ListBox example.
        - Added GetSelectedItemNumber() to listboxes.
        - Updated ListBox_SelectItem() with a 'bScrollIntoView' parameter to
          automatically scroll the selected item into view.
        - Added a smart delay to ListBox_ScrollSelectionIntoView() and 
          TextScrollFrame's SetVerticalScroll() in case they are called shortly after
          the control was created.  This gives the control enough time to fully initialize
          itself so scrolling, and the scrollbar thumb position, work properly.
        - Uncommented CreateIconButton() functionality.
    Aug 03, 2023
        - Renamed instances of "Checkbox", "Listbox", "Groupbox", "Editbox" to
          use the more common upper-casing found in other addons.
    Aug 02, 2023
        - Added setpointFunc to the dropdown.listbox variable, for changing the
          alignment of a dropdown's listbox relative to its editbox part.
        - Fixed dropdown Enable() and Disable() so they affect the fullWidthButton variable.
    Jul 22, 2023
        - Added handleGlobalMouseClick() to handle closing dropdowns when users
          click somewhere else while one is open.
        - Added CreateGroupBox().
        - Renamed some internal variables.

    Jul 09, 2023
        - Updated DropDown_AddItem() with a parameter to prevent adding duplicate items.
          (e.g. dropdown:AddItem(name, nil, true) adds 'name' only if it doesn't exist.)
          Updated DropDown_RemoveItem() so it works with text as well as an ID.
          Improved performance of DropDown_ClearSelection().

    Jun 30, 2023
        - Original version.
-------------------------------------------------------------------------------

================================[ INTERFACES ]=================================
~~~~~~~~~~~~~~~
    Creator
   Functions
~~~~~~~~~~~~~~~

        CreateCheckBox()        - Returns a CheckBox object.
        CreateColorSwatch()     - Returns a ColorSwatch object.
        CreateDropDown()        - Returns a DropDown object.
        CreateGroupBox()        - Returns a group box frame.
        CreateIconButton()      - Returns a standard button frame.
        CreateListBox()         - Returns a ListBox object.
        CreateOptionsButton()   - Returns a standard button frame.
        CreateSlider()          - Returns a Slider object.
        CreateTextScrollFrame() - Returns a TextScrollFrame object.
        DisplayAllFonts()       - Creates and shows a window of all game fonts. (For development use.)

        handleGlobalMouseClick() - (OPTIONAL) Register your addon for the GLOBAL_MOUSE_DOWN event, and
                                  call this function when it occurs.  Do this to close a dropdown when
                                  users click somewhere else while it is open.  (See dropdown example.)
                                  Ideally, register this event when your UI is shown, and unregister it
                                  when your UI is closed.  This will minimize event handling to just
                                  while the UI is open.

~~~~~~~~~~~~~~~
   CheckBox
~~~~~~~~~~~~~~~

    Functions:
        Configure()
        Disable()
        Enable()
        GetChecked()
        SetChecked()
        SetClickHandler( func )
        SetLabel()
        SetTooltip()

    Callbacks:
        clickHandler()      - Called when the checkbox is clicked.

    Variables:
        checkFrame
        fontString

~~~~~~~~~~~~~~~~~~~
    ColorSwatch
~~~~~~~~~~~~~~~~~~~
    * See AceGUIWidget-ColorPicker.lua for future enhancement ideas.

    Functions:
        Disable()
        Enable()
        GetColor()
        SetColor()
        SetColorChangedHandler()
        SetTooltip()
        CloseColorPicker()

    Variables:
        borderTexture
        oldDisableHandler
        oldEnableHandler

~~~~~~~~~~~~~~~
   DropDown
~~~~~~~~~~~~~~~

    Functions:
        AddItem( text, ID )  - ID can be a number or text.
        Clear()
        ClearSelection()
        Configure()
        Disable()
        Enable()
        GetNumItems()
        GetSelectedID()
        GetSelectedIndex()
        GetSelectedText()
        HideSelections()
        RemoveItem()
        SelectID( ID )  - ID can be a number or string.
        SelectIndex( itemNum )  - itemNum starts at 1, not 0.
        SelectNext()
        SelectPrevious()
        SelectText()
        SetChangeHandler( func )
        SetBackdropBorderColor()
        SetBackdropColor()
        SetLabel()
        SetListBoxHeight()
        SetListBoxWidth()
        SetTooltip()
        Sort()

    Callbacks:
        changeHandler( ID )  - Called when one of the dropdown's options is selected.

    Variables:
        buttonFrame
        items
        itemIDs
        listbox             - See the ListBox section.
        listboxHeight
        selectedItem        - Selected item's index #.
        setpointFunc

~~~~~~~~~~~~~~~
   ListBox
~~~~~~~~~~~~~~~

    Functions:
        AddItem( text, bScrollIntoView )
        Clear()
        Configure()
        Disable()
        Enable()
        GetItem()
        GetLine()
        GetNumItems()
        GetNumLines()
        GetOffset()
        GetSelectedItem()   - Returns selected item (text).
        Refresh()
        RemoveItem()
        SetClickHandler( func )
        SetCreateLineHandler( func )
        SetDisplayHandler( func )
        SetOffset()
        SelectItem( itemNumber )

    Callbacks:
        clickHandler()      - Called when a line in the listbox is clicked.
        displayHandler()    - Called when a line is being displayed.
        lineHandler()       - Called when a new line needs to be created.

    Variables:
        displayFrame
        sliderFrame
        upButton
        downButton
        highlightFrame
        items
        lines
        lineCache
        selectedItem        - Selected item's index #.

~~~~~~~~~~~~~~~
    Slider
~~~~~~~~~~~~~~~

    Functions:
        Configure()
        SetLabel()
        SetTooltip()
        SetValueChangedHandler( func )
        SetMinMaxValues()
        SetValueStep()
        GetValue()
        SetValue()
        Enable()
        Disable()

    Callbacks:
        valueChangedHandler()   - Called when the value of the slider is changed.

    Variables:
        sliderFrame
        labelFontString
        labelText

~~~~~~~~~~~~~~~~~~~~~
   TextScrollFrame
~~~~~~~~~~~~~~~~~~~~~

    Functions:
        AddText()
        GetNextVerticalPosition()
        SetScrollTextBackColor()
        SetVerticalScroll()

    Variables:
        bg
        closeBtn
        nextVertPos
        scrollChild
        scrollFrame
        strings
        title

~~~~~~~~~~~~~~
   GroupBox
~~~~~~~~~~~~~~

    Functions:
        SetTitleBackColor
        UpdateTitleSize

    Variables:
        title
        titleBackground

=================================[ EXAMPLES ]==================================
~~~~~~~~~~~~~~~~~~~~~
 ColorSwatch Example
~~~~~~~~~~~~~~~~~~~~~

    local kAddonFolderName, private = ...  -- First line of LUA file that will use these controls.
        .                                  -- (The variable names can be changed to anything you like.)
        .
        .

    -- Assume "YourObjectTexture" already exists and is the thing you want to change the color of.
    -- Something like this ...
    --    YourObjectFrame = CreateFrame("Frame", nil, UIParent)
    --    YourObjectTexture = YourObjectFrame:CreateTexture()

    local colorswatch = private.Controls.CreateColorSwatch( YourOptionsFrame )
    colorswatch:SetPoint("TOPLEFT", YourOptionsFrame, "TOPLEFT", 16, -16)

    colorswatch:SetColor(1,0,0)  -- RGB (No alpha value.  Opacity slider will be hidden in the color picker.)
        - OR -
    colorswatch:SetColor(1,0,0, 1)  -- RGBA (Alpha value specified.  Opacity slider will be shown in the color picker.)

    colorswatch:SetColorChangedHandler(function(self) YourObjectTexture:SetVertexColor(self.r, self.g, self.b, self.a) end)


~~~~~~~~~~~~~~~~~~
 DropDown Example
~~~~~~~~~~~~~~~~~~

    local kAddonFolderName, private = ...  -- First line of LUA file that will use these controls.
        .                                  -- (The variable names can be changed to anything you like.)
        .
        .

    --************************** OPTIONAL **************************
    -- Add these lines to your main addon file to close our dropdown control
    -- when users click somewhere else while the dropdown is open.

        yourEventFrame:RegisterEvent("GLOBAL_MOUSE_DOWN")
        function yourEventFrame:GLOBAL_MOUSE_DOWN(button)
            private.Controls.handleGlobalMouseClick(button)
        end

    -- Even better, don't call the RegisterEvent() line until the UI using our
    -- dropdown control is shown, and unregister the event when the UI is closed.
    -- Then there is no overhead at all while the UI is closed.
    -- For example:

        YourOptionsFrame:SetScript("OnShow", function(self)
                private.yourEventFrame:RegisterEvent("GLOBAL_MOUSE_DOWN")
            end)

        YourOptionsFrame:SetScript("OnHide", function(self)
                private.yourEventFrame:UnregisterEvent("GLOBAL_MOUSE_DOWN")
            end)
    --************************ END OPTIONAL ************************

    local width = 200

    local dropdown = private.Controls.CreateDropDown(YourOptionsFrame)
    dropdown.listbox:SetScale( 0.95 )  -- (Optional) Shrinks the dropdown.
    dropdown:SetBackdropBorderColor(0.7, 0.7, 0.0)  -- (Optional) Colorize the dropdown edges.
    dropdown:SetPoint("TOPLEFT", YourOptionsFrame, "TOPLEFT", 16, -16)
    dropdown:Configure(width, "Color Names:", "")  -- (width, label, tooltip_text)

    dropdown:SetChangeHandler( function(self, selectedID)
            print( "Selected Item ==>  Index: " .. self:GetSelectedIndex()
                   ..",  ID: " .. (selectedID or "nil")
                   ..",  Text: " .. self:GetSelectedText() )
        end)

    dropdown:AddItem("Red", 101)      -- or AddItem("Red") if not using ID#s.
    dropdown:AddItem("White", 102)    -- or AddItem("White") if not using ID#s.
    dropdown:AddItem("Blue", 103)     -- or AddItem("Blue") if not using ID#s.

    dropdown:SelectID(102)  -- Selects "White" by ID.  Requires ID#s when calling AddItem().
        -- OR --
    dropdown:SelectIndex(1)  -- Selects first item in the dropdown.
        -- OR --
    dropdown:SelectText("Blue") -- Selects "Blue".

    -- Show a tooltip while hovering over any part of the dropdown.
    local function myDropDown_OnEnter(self, motion)
        GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
        GameTooltip:SetText("Some helpful info about this dropdown menu.")
    end
    local function myDropDown_OnLeave(self, motion)
        GameTooltip:Hide()
    end

    dropdown.fullWidthButton:SetScript("OnEnter", myDropDown_OnEnter)
    dropdown.fullWidthButton:SetScript("OnLeave", myDropDown_OnLeave)
    dropdown.buttonFrame:SetScript("OnEnter", myDropDown_OnEnter)
    dropdown.buttonFrame:SetScript("OnLeave", myDropDown_OnLeave)

    -- (Optional) To change the size of the dropdown's listbox ...
    dropdown:SetListBoxWidth(250)
    dropdown:SetListBoxHeight( UIParent:GetHeight() * 0.5 )  -- Limit expanded height to 1/2 screen height.

    -- (Optional) To change the alignment of the dropdown's listbox (relative to its editbox ) ...
    dropdown.setpointFunc = function(listbox, editbox)
            -- LEFT alignment ...
            listbox:SetPoint("TOPLEFT", editbox, "BOTTOMLEFT", 2, 5)
                -- OR --
            -- CENTER alignment ...
            listbox:SetPoint("TOP", editbox, "BOTTOM", 0, 5)
            listbox:SetPoint("CENTER", editbox, "CENTER", 0, 0)
                -- OR --
            -- RIGHT alignment ...
            listbox:SetPoint("TOPRIGHT", editbox, "BOTTOMRIGHT", 0, 5)
        end

~~~~~~~~~~~~~~~~~~
 GroupBox Example
~~~~~~~~~~~~~~~~~~

    local kAddonFolderName, private = ...  -- First line of LUA file that will use these controls.
        .                                  -- (The variable names can be changed to anything you like.)
        .
        .

    local groupbox = private.Controls.CreateGroupBox("Options", "TOPLEFT", YourOptionsFrame, "TOPLEFT", x, y, width, height)
    groupbox:SetBackdropColor(0,0,0, 0.3)        -- (Optional) Darken the area inside the groupbox.
    groupbox.title:SetPoint("TOPLEFT", 10, 3)    -- (Optional) Reposition the title.
    groupbox.title:SetTextColor(1, 1, 1)         -- (Optional) Make the title text white.
    groupbox:SetTitleBackColor(0.15, 0.15, 0.15) -- (Optional) Give the title a solid background color.

    -- (Optional) Give the title text a stronger shadow.
    local shadowOfs = 2
    groupbox.title:SetShadowOffset(shadowOfs, -shadowOfs)
    groupbox:UpdateTitleSize( {left=3, right=shadowOfs-2, top=1, bottom=shadowOfs} )

~~~~~~~~~~~~~~~~~
 ListBox Example
~~~~~~~~~~~~~~~~~

    local listboxW = 150
    local listboxLineH = 20
    local listboxLinesPerPage = 5
    local listboxH = (listboxLineH * listboxLinesPerPage) + 4

    -- - - - - - - - - - - - - - - - - - - - - - - - - - --
    local function listboxCreateLine(thisLB)
        local line = CreateFrame("Button", nil, thisLB)
        line.parentListBox = thisLB

        -- Text.
        line.fontString = line:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        line.fontString:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        line.fontString:SetPoint("LEFT", line, "LEFT", 4, 0)
        line.fontString:SetPoint("RIGHT", line, "RIGHT")
        line.fontString:SetJustifyH("LEFT")

        -- (OPTIONAL) "Delete Item" button.
        local iconPath = "Interface\\Addons\\" .. kAddonFolderName .. "\\Media\\"
        line.deleteBtn = private.Controls.CreateIconButton(line, listboxLineH-8, iconPath, "DeleteIcon", "DeleteIconHighlight")
        line.deleteBtn:SetTooltip("Click to delete the item.")
        line.deleteBtn:SetPoint("RIGHT", line, "RIGHT", -1, 0)
        line.deleteBtn:SetClickHandler( function(self)
                local listboxLine = self:GetParent()
                local listbox = listboxLine.parentListBox
                local itemNum = listboxLine.itemNumber
                local itemText = listboxLine.fontString:GetText()
                listbox:RemoveItem(itemNum)
                listbox:Refresh()
                print("Deleted listbox item:", itemText)
            end)

        return line
    end
    -- - - - - - - - - - - - - - - - - - - - - - - - - - --
    local function listboxDisplayLine(thisLB, line, value, isSelected)
        ----local color = isSelected and HIGHLIGHT_FONT_COLOR or NORMAL_FONT_COLOR
        ----line.fontString:SetTextColor(color.r, color.g, color.b)
        line.fontString:SetText(value)
    end
    -- - - - - - - - - - - - - - - - - - - - - - - - - - --
    local function listboxOnClickLine(thisLB, line, value)
        thisLB.SelectItem(value)
        print("Selected listbox item:", value)
    end
    -- - - - - - - - - - - - - - - - - - - - - - - - - - --

    -- Create listbox.
    local listbox = private.Controls.CreateListBox(YourOptionsFrame)
    listbox:Configure(listboxW, listboxH, listboxLineH)
	listbox:SetPoint("TOPLEFT", YourOptionsFrame, "TOPLEFT", 18, -35)
	listbox:SetCreateLineHandler( listboxCreateLine )
	listbox:SetDisplayHandler( listboxDisplayLine )
	listbox:SetClickHandler( listboxOnClickLine )

    -- Create listbox label.
    listbox.label = listbox:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    listbox.label:SetText("Animals:")
    listbox.label:SetPoint("BOTTOMLEFT", listbox, "TOPLEFT", 4, 2)

    -- Fill the listbox.
    local animals = {"Dog","Cat","Horse","Cow","Elephant","Lion","Zebra","Eagle","Snake","Fish","Penguin"}
	listbox:Clear()
	for index, value in pairs(animals) do
		listbox:AddItem( value )
	end
    listbox:SelectItem(1)

    YourOptionsFrame.listbox = listbox

~~~~~~~~~~~~~~~~~~~~~~~~~
 TextScrollFrame Example
~~~~~~~~~~~~~~~~~~~~~~~~~

    local kAddonFolderName, private = ...  -- First line of LUA file that will use these controls.
        .                                  -- (The variable names can be changed to anything you like.)
        .
        .

    local tsf = private.Controls.CreateTextScrollFrame(YourOptionsFrame, "*** Scroll Window Test ***", 333)

    local title = tsf.scrollChild:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -4)
    title:SetText("General Info")

    local firstLine = tsf.scrollChild:CreateFontString("ARTWORK", nil, "GameFontNormal")
    firstLine:SetPoint("TOP", title, "BOTTOM", 0, -1)
    firstLine:SetJustifyH("LEFT")  -- Specify this when using text with carriage returns in it.
    firstLine:SetText("This is the first line.\n  (Scroll way down to see the last!)")

    local footer = tsf.scrollChild:CreateFontString("ARTWORK", nil, "GameFontNormal")
    footer:SetPoint("TOP", 0, -5000)
    footer:SetText("This is 5000 pixels below the top, so scrollChild automatically adjusts its height.")

        -- < OR > --

    local indent = 16 -- pixels
    tsf:AddText("General Info:", 0, 4, "GameFontNormalLarge")
    tsf:AddText("This is the first line.\n  (Scroll way down to see the last!)")
    tsf:AddText("|cffEE5500Line #2 is orange.|r", indent)
    tsf:AddText("This is line #3.  It is a very long line in order to test the .:.:.:. word wrap feature of the scroll frame.\n ", indent)
    tsf:AddText("This is 5000 pixels below the top, so scrollChild automatically adjusts its height.", 0, 5000)

-------------------------------------------------------------------------------]]


local kAddonFolderName, private = ...
private.Controls = private.Controls or {}


--#############################################################################
-------------------------------------------------------------------------------
-- Aliases to Globals.
-------------------------------------------------------------------------------
--#############################################################################

local _  -- Prevent tainting global _ .
local assert = assert
local C_Timer = C_Timer
local ColorPickerFrame = ColorPickerFrame
local CreateFrame = CreateFrame
local DevTools_Dump = DevTools_Dump
local GameTooltip = GameTooltip
local GetAddOnMetadata = GetAddOnMetadata
local GetBuildInfo = GetBuildInfo
local GetTime = GetTime
local HIGHLIGHT_FONT_COLOR = HIGHLIGHT_FONT_COLOR
local InCombatLockdown = InCombatLockdown
local ipairs = ipairs
local math = math
local next = next
local NORMAL_FONT_COLOR = NORMAL_FONT_COLOR
local pairs = pairs
local PlaySound = PlaySound
local PlaySoundFile = PlaySoundFile
local print = print
local select = select
local SOUNDKIT = SOUNDKIT
local string = string
local table = table
local tinsert = tinsert
local type = type
local UIParent = UIParent
local unpack = unpack


--#############################################################################
-------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------
--#############################################################################

-- Templates compatible with all versions of WoW.
local kGameTocVersion = select(4, GetBuildInfo())
local kButtonTemplate = ((kGameTocVersion >= 100000) and "UIPanelButtonTemplate") or "OptionsButtonTemplate"
local kBoxTemplate = ((kGameTocVersion >= 100000) and "TooltipBorderBackdropTemplate") or "OptionsBoxTemplate"
local kMinVer_10_2_5 = (kGameTocVersion >= 100205)  -- WoW 10.2.5 or newer?

-- Backdrop table to be reused for sliders.
local gSliderBackdrop

-- Emphasis shown when a listbox entry is moused over.
local gEmphasizeFrame

-- Frame used for accessing the last clicked/opened dropdown.
local gDropDownListBoxFrame

-- Used for correctly calculating string widths.
local gCalcFontString

-- Height of lines in listboxes and dropdown menus.
local kListBoxLineHeight = 17  --DJUadded  (and changed from 20)

-- Customized Color Picker vars.
local gColorPickerAttributes
local gAssociatedColorSwatch
local kCustomizedTag = "customizedBy" .. kAddonFolderName
local kColorPickerDefaultHeight = kMinVer_10_2_5 and 210 or 200
local kColorPickerButtonWidth = kMinVer_10_2_5 and 150 or 138  -- Default width is 144.
local gColorPaletteFrame


--#############################################################################
-------------------------------------------------------------------------------
-- Version independent color picker functions and variables.
-------------------------------------------------------------------------------
--#############################################################################

local gOpacitySlider = kMinVer_10_2_5 and OpacityFrameSlider or OpacitySliderFrame
assert(gOpacitySlider)
local gColorPickerOkayBtn = kMinVer_10_2_5 and ColorPickerFrame.Footer.OkayButton or ColorPickerOkayButton
assert(gColorPickerOkayBtn)
local gColorPickerCancelBtn = kMinVer_10_2_5 and ColorPickerFrame.Footer.CancelButton or ColorPickerCancelButton
assert(gColorPickerCancelBtn)
local gColorPickerWheel = kMinVer_10_2_5 and ColorPickerFrame.Content.ColorPicker.Wheel or ColorPickerWheel

-------------------------------------------------------------------------------
local function ColorPickerFrame_SetColorRGB(r, g, b)
    if kMinVer_10_2_5 then
        ColorPickerFrame.Content.ColorPicker:SetColorRGB(r, g, b)
    else  -- Older version.
        ColorPickerFrame:SetColorRGB(r, g, b)
    end
end

-------------------------------------------------------------------------------
local function OpacitySlider_GetValue()
    if kMinVer_10_2_5 then
        ----return OpacityFrameSlider:GetValue() --<BUG> Associated color swatch not updated when opacity slider changed.
        return ColorPickerFrame.Content.ColorPicker:GetColorAlpha()
    else  -- Older version.
        return OpacitySliderFrame:GetValue()
    end
end

-------------------------------------------------------------------------------
local function OpacitySlider_SetValue(opacity)
    if kMinVer_10_2_5 then
        ----return OpacityFrameSlider:SetValue(opacity) --<BUG> Associated color swatch not updated when opacity slider changed.
        return ColorPickerFrame.Content.ColorPicker:SetColorAlpha(opacity)
    else  -- Older version.
        return OpacitySliderFrame:SetValue(opacity)
    end
end


--#############################################################################
-------------------------------------------------------------------------------
-- Helper functions.
-------------------------------------------------------------------------------
--#############################################################################


-- ****************************************************************************
-- Dumps a variable to the ViragDevTools addon, if it is loaded.
-- ****************************************************************************
local function vdt_dump(varValue, varDescription)  -- e.g.  vdt_dump(someVar, "Checkpoint 1")
    if _G.ViragDevTool_AddData then
        _G.ViragDevTool_AddData(varValue, varDescription)
    end
end


-- ****************************************************************************
-- Calls GetPoint() for the specified frame and returns a single table 
-- containing all the parameters returned by that function.
-- ****************************************************************************
local function getPointTable(frame)
    return { frame:GetPoint() }
end


-- ****************************************************************************
-- Unpacks the point parameters in the supplied table (pointTable), and then
-- calls SetPoint() for the specified frame using those unpacked parameters.
-- ****************************************************************************
local function setPointTable(frame, pointTable)
    frame:ClearAllPoints()
    frame:SetPoint( unpack(pointTable) )
end


--#############################################################################
-------------------------------------------------------------------------------
-- ListBox functions.
-------------------------------------------------------------------------------
--#############################################################################


-- ****************************************************************************
-- Shows the highlight frame over the passed line.
-- ****************************************************************************
local function ListBox_ShowHighlight(this, line)
    local highlight = this.highlightFrame
    highlight:ClearAllPoints()
    highlight:SetParent(line)
    highlight:SetPoint("TOPLEFT")
    highlight:SetPoint("BOTTOMRIGHT")
    highlight:Show()

    if (gEmphasizeFrame:GetParent() == line) then gEmphasizeFrame:Hide() end
end


-- ****************************************************************************
-- Shows or hides the scroll bar and resizes the display area as necessary.
-- ****************************************************************************
local function ListBox_ShowHideScrollBar(this)
    -- Show or hide the scroll bar if there are more items than will fit on the page.
    local display = this.displayFrame
    local slider = this.sliderFrame
    local dx = -1*slider:GetWidth()
    if not this.bHideBorder then  -- Showing listbox border?
        dx = dx - (2*display.margin)
    end

    if (#this.items <= #this.lines) then
        slider:Hide()
        display:SetPoint("BOTTOMRIGHT")
    else
        display:SetPoint("BOTTOMRIGHT", display:GetParent(), "BOTTOMRIGHT", dx, 0)
        slider:Show()
    end
end


-- ****************************************************************************
-- Returns whether the listbox is fully configured.
-- ****************************************************************************
local function ListBox_IsConfigured(this)
    return this.configured and this.lineHandler and this.displayHandler
end


-- ****************************************************************************
-- Returns the current offset.
-- ****************************************************************************
local function ListBox_GetOffset(this)  -- Returned offset is 0-based.
    return this.sliderFrame:GetValue()
end


-- ****************************************************************************
-- Returns the current offset.
-- ****************************************************************************
local function ListBox_SetOffset(this, offset)  -- 'offset' is 0-based.
    this.sliderFrame:SetValue(offset)
end


-- ****************************************************************************
-- Called when the listbox needs to be refreshed.
-- ****************************************************************************
local function ListBox_Refresh(this)
    -- Don't do anything if the listbox isn't configured.
    if (not ListBox_IsConfigured(this)) then return end

    -- Handle scroll bar showing / resizing.
    ListBox_ShowHideScrollBar(this)

    -- Hide the highlight.
    this.highlightFrame:Hide()

    -- Show or hide the correct lines depending on how many items there are and
    -- apply a highlight to the selected item.
    local selectedItem = this.selectedItem
    local isSelected
    for lineNum, line in ipairs(this.lines) do
        if (lineNum > #this.items) then
            line:Hide()
        else
            line.itemNumber = lineNum + ListBox_GetOffset(this)
            line:Show()

            -- Move the highlight to the selected line and show it.
            if (selectedItem == line.itemNumber) then
                ListBox_ShowHighlight(this, line)
                isSelected = true
            else
                isSelected = false
            end

            if (this.displayHandler) then this:displayHandler(line, this.items[line.itemNumber], isSelected) end
        end
    end
end


-- ****************************************************************************
-- Called when the listbox is scrolled up.
-- ****************************************************************************
local function ListBox_ScrollUp(this)
    local slider = this.sliderFrame
    slider:SetValue(slider:GetValue() - slider:GetValueStep())
end


-- ****************************************************************************
-- Called when the listbox is scrolled down.
-- ****************************************************************************
local function ListBox_ScrollDown(this)
    local slider = this.sliderFrame
    slider:SetValue(slider:GetValue() + slider:GetValueStep())
end


-- ****************************************************************************
-- Called when one of the lines in the listbox is clicked.
-- ****************************************************************************
local function ListBox_OnClickLine(this)
    local listbox = this:GetParent():GetParent()
    listbox.selectedItem = this.lineNumber + ListBox_GetOffset(listbox)

    ListBox_ShowHighlight(listbox, this)

    if (listbox.clickHandler) then listbox:clickHandler(this, listbox.items[listbox.selectedItem]) end
end


-- ****************************************************************************
-- Called when the mouse enters a line.
-- ****************************************************************************
local function ListBox_OnEnterLine(this)
    local listbox = this:GetParent():GetParent()
    if (this.itemNumber ~= listbox.selectedItem) then
        gEmphasizeFrame:ClearAllPoints()
        gEmphasizeFrame:SetParent(this)
        gEmphasizeFrame:SetPoint("TOPLEFT")
        gEmphasizeFrame:SetPoint("BOTTOMRIGHT")
        gEmphasizeFrame:Show()
    end

    if (this.tooltip) then
        GameTooltip:SetOwner(this, this.tooltipAnchor or "ANCHOR_RIGHT")
        GameTooltip:SetText(this.tooltip, nil, nil, nil, nil, 1)
    end
end


-- ****************************************************************************
-- Called when the mouse leaves a line.
-- ****************************************************************************
local function ListBox_OnLeaveLine(this)
    gEmphasizeFrame:Hide()
    GameTooltip:Hide()
end


-- ****************************************************************************
-- Called when the scroll up button is pressed.
-- ****************************************************************************
local function ListBox_OnClickUp(this)
    local listbox = this:GetParent():GetParent()
    ListBox_ScrollUp(listbox)
    PlaySound(826)
end


-- ****************************************************************************
-- Called when the scroll down button is pressed.
-- ****************************************************************************
local function ListBox_OnClickDown(this)
    local listbox = this:GetParent():GetParent()
    ListBox_ScrollDown(listbox)
    PlaySound(827)
end


-- ****************************************************************************
-- Called when the mouse wheel is scrolled in the display frame.
-- ****************************************************************************
local function ListBox_OnMouseWheel(this, delta)
    local listbox = this:GetParent()
    local scrollAmt = math.ceil( listbox.linesPerPage - 1 )  --DJUadded
    if (delta < 0) then
        for i = 1, scrollAmt do  --DJUadded
            ListBox_ScrollDown(listbox)
        end
    elseif (delta > 0) then
        for i = 1, scrollAmt do  --DJUadded
            ListBox_ScrollUp(listbox)
        end
    end
end


-- ****************************************************************************
-- Called when the scroll bar slider is changed.
-- ****************************************************************************
local function ListBox_OnSliderChanged(thisSlider, value)
    ListBox_Refresh( thisSlider:GetParent() )
end


-- ****************************************************************************
-- Creates a new line using the register create line handler.
-- ****************************************************************************
local function ListBox_CreateLine(this)
    -- Get a line from cache if there are any otherwise call the registered line
    -- handler to create a new line.
    local lineCache = this.lineCache
    local line = (#lineCache > 0) and table.remove(lineCache) or this:lineHandler()

    line:SetParent(this.displayFrame)
    line:SetHeight(this.lineHeight)
    line:ClearAllPoints()
    line:SetScript("OnClick", ListBox_OnClickLine)
    line:SetScript("OnEnter", ListBox_OnEnterLine)
    line:SetScript("OnLeave", ListBox_OnLeaveLine)

    local lines = this.lines
    if (#lines == 0) then
        line:SetPoint("TOPLEFT")
        line:SetPoint("TOPRIGHT")
    else
        line:SetPoint("TOPLEFT", lines[#lines], "BOTTOMLEFT")
        line:SetPoint("TOPRIGHT", lines[#lines], "BOTTOMRIGHT")
    end

    lines[#lines+1] = line
    line.lineNumber = #lines
end


-- ****************************************************************************
-- Reconfigures the listbox if it was already configured.
-- ****************************************************************************
local function ListBox_Reconfigure(this, width, height, lineHeight)
    -- Don't allow negative widths.
    if (width < 0) then width = 0 end

    -- Setup container frame.
    this:SetWidth(width)
    this:SetHeight(height)

    -- Setup line calculations.
    this.lineHeight = lineHeight
    this.linesPerPage = math.floor(height / lineHeight)

    -- Resize the line height of existing lines.
    for _, line in ipairs(this.lines) do
        line:SetHeight(this.lineHeight)
    end

    -- Add lines if more will fit on the page and they are needed.
    local lines = this.lines
    if (#this.items > #lines) then
        while (#lines < this.linesPerPage and #this.items > #lines) do
            ListBox_CreateLine(this)
        end
    end

    -- Remove and cache lines that will no longer fit on the page.
    local lineCache = this.lineCache
    for x = this.linesPerPage+1, #lines do
        lines[#lines]:Hide()
        lineCache[#lineCache+1] = table.remove(lines)
    end

    -- Setup slider frame.
    local slider = this.sliderFrame
    slider:Hide()
    slider:SetMinMaxValues(0, math.max(#this.items - #this.lines, 0))
    slider:SetValue(0)

    ListBox_Refresh(this)
end


-- ****************************************************************************
-- Configures the listbox.
-- ****************************************************************************
local function ListBox_Configure(this, width, height, lineHeight)
    -- Don't do anything if required parameters are invalid.
    if (not width or not height or not lineHeight) then return end

    if (ListBox_IsConfigured(this)) then ListBox_Reconfigure(this, width, height, lineHeight) return end

    -- Don't allow negative widths.
    if (width < 0) then width = 0 end

    -- Setup container frame.
    this:SetWidth(width)
    this:SetHeight(height)

    -- Setup slider frame.
    local slider = this.sliderFrame
    slider:SetMinMaxValues(0, 0)
    slider:SetValue(0)

    -- Setup line calculations.
    this.lineHeight = lineHeight
    this.linesPerPage = math.floor(height / lineHeight)

    this.configured = true
end


-- ****************************************************************************
-- Set the function to be called when a new line needs to be created.  The
-- called function must return a "Button" frame.
-- ****************************************************************************
local function ListBox_SetCreateLineHandler(this, handler)
    this.lineHandler = handler
end


-- ****************************************************************************
-- Set the function to be called when a line is being displayed.
-- It is passed the line frame to be populated, and the value associated
-- with that line.
-- ****************************************************************************
local function ListBox_SetDisplayHandler(this, handler)
    this.displayHandler = handler
end


-- ****************************************************************************
-- Set the function to be called when a line in the listbox is clicked.
-- It is passed the line frame, and the value associated with that line.
-- ****************************************************************************
local function ListBox_SetClickHandler(this, handler)
    this.clickHandler = handler
end


-- ****************************************************************************
-- Adds the passed item to the listbox.
-- ****************************************************************************
local function ListBox_AddItem(this, newItem, bScrollIntoView)
    -- Don't do anything if the listbox isn't configured.
    if (not ListBox_IsConfigured(this)) then return end

    -- Add the passed item to the items list.
    local items = this.items
    items[#items + 1] = newItem

    --  Create a new line if the max number allowed per page hasn't been reached.
    local lines = this.lines
    if (#lines < this.linesPerPage) then
        ListBox_CreateLine(this)
    end

    -- Set the new max offset value.
    local maxOffset = math.max(#items - #lines, 0)
    this.sliderFrame:SetMinMaxValues(0, maxOffset)

    -- Make sure the newly added item is visible if the force flag is set.
    if (bScrollIntoView) then ListBox_SetOffset(this, maxOffset) end

    ListBox_Refresh(this)
end


-- ****************************************************************************
-- Removes the passed item number from the listbox.
-- ****************************************************************************
local function ListBox_RemoveItem(this, itemNumber)
    -- Don't do anything if the listbox isn't configured.
    if (not ListBox_IsConfigured(this)) then return end

    local items = this.items
    table.remove(items, itemNumber)

    -- Set the new max offset value.
    this.sliderFrame:SetMinMaxValues(0, math.max(#items - #this.lines, 0))

    ListBox_Refresh(this)
end


-- ****************************************************************************
-- Returns the number of items in the listbox.
-- ****************************************************************************
local function ListBox_GetNumItems(this)
    return #this.items
end


-- ****************************************************************************
-- Returns the number of visible lines in the listbox.
-- ****************************************************************************
local function ListBox_GetNumLines(this)
    return math.min(#this.lines, #this.items)
end


-- ****************************************************************************
-- Sets the listbox offset so that the selected item is shown.
-- ****************************************************************************
local function ListBox_ScrollSelectionIntoView(this)  --DJUadded
    local delaySecs = 0.1
    if GetTime() - this.creationTime < delaySecs then
        -- Must delay executing this function until 0.1 secs after the listbox
        -- was created.  Otherwise, the scrollbar's thumb position and/or listbox
        -- contents do not scroll correctly.
        C_Timer.After(delaySecs, function() ListBox_ScrollSelectionIntoView(this) end)
        return  -- Stop here.
    end

    -- Scroll the selected line into view.
    local lineNum = this.selectedItem - ListBox_GetOffset(this)
    if not this.lines[lineNum] then
        ListBox_SetOffset(this, this.selectedItem - #this.lines)
        ListBox_Refresh(this)
    end
end


-- ****************************************************************************
-- Selects the specified item number in the listbox.
-- ****************************************************************************
local function ListBox_SelectItem(this, itemNumber, bScrollIntoView)  --DJUadded bScrollIntoView.
    -- Don't do anything if the listbox isn't configured.
    if (not ListBox_IsConfigured(this)) then return end

    itemNumber = itemNumber or 0  --DJUadded
    if type(itemNumber) ~= "number" then itemNumber = 0 end  --DJUadded

    this.selectedItem = itemNumber <= #this.items and itemNumber or 0
    if bScrollIntoView then ListBox_ScrollSelectionIntoView(this) end  --DJUadded

    -- Highlight the selected line if it's visible.
    local line = this.lines[this.selectedItem - ListBox_GetOffset(this)]
    if (line) then ListBox_ShowHighlight(this, line) end
end


-- ****************************************************************************
-- Returns the item for the specified item number from the listbox.
-- ****************************************************************************
local function ListBox_GetItem(this, itemNumber)
    return this.items[itemNumber]
end


-- ****************************************************************************
-- Returns the selected item from the listbox.
-- ****************************************************************************
local function ListBox_GetSelectedItem(this)
    if (this.selectedItem ~= 0) then return this.items[this.selectedItem] end
end


-- ****************************************************************************
-- Returns the selected item number for the listbox.  (0 means nothing selected.)
-- ****************************************************************************
local function ListBox_GetSelectedItemNumber(this)  --DJUadded
    return this.selectedItem or 0
end


-- ****************************************************************************
-- Returns the line object from the listbox.
-- ****************************************************************************
local function ListBox_GetLine(this, lineNumber)
    local lines = this.lines
    if (lineNumber <= #lines) then return lines[lineNumber] end
end


-- ****************************************************************************
-- Clears the listbox contents.
-- ****************************************************************************
local function ListBox_Clear(this)
    -- Don't do anything if the listbox isn't configured.
    if (not ListBox_IsConfigured(this)) then return end

    local items = this.items
    for k, v in ipairs(items) do
        items[k] = nil
    end

    -- Set the new max offset value.
    this.sliderFrame:SetMinMaxValues(0, 0)

    this.selectedItem = 0

    ListBox_Refresh(this)
end


-- ****************************************************************************
-- Disables the listbox.
-- ****************************************************************************
local function ListBox_Disable(this)
    this.displayFrame:EnableMouseWheel(false)
    this.sliderFrame:EnableMouse(false)
    this.upButton:Disable()
    this.downButton:Disable()
end


-- ****************************************************************************
-- Enables the listbox.
-- ****************************************************************************
local function ListBox_Enable(this)
    this.displayFrame:EnableMouseWheel(true)
    this.sliderFrame:EnableMouse(true)
    this.upButton:Enable()
    this.downButton:Enable()
end


-- ****************************************************************************
-- Creates and returns a listbox object ready to be configured.
-- ****************************************************************************
local function CreateListBox(parent, bHideBorder)  --DJUadded 'bHideBorder' to this function.
    -- Create the frame used to emphasize the entry the mouse is over.
    if (not gEmphasizeFrame) then
        gEmphasizeFrame = CreateFrame("Frame")

        local texture = gEmphasizeFrame:CreateTexture(nil, "ARTWORK")
        texture:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
        texture:SetBlendMode("ADD")
        texture:SetPoint("TOPLEFT", gEmphasizeFrame, "TOPLEFT")
        texture:SetPoint("BOTTOMRIGHT", gEmphasizeFrame, "BOTTOMRIGHT")
    end

    -- Create container frame.
    local listbox = CreateFrame("Frame", nil, parent, bHideBorder or "InsetFrameTemplate")
    listbox.bHideBorder = bHideBorder

    -- Highlight frame.
    local highlight = CreateFrame("Frame")

    local texture = highlight:CreateTexture(nil, "ARTWORK")
    texture:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    texture:SetBlendMode("ADD")
    texture:SetPoint("TOPLEFT", highlight, "TOPLEFT")
    texture:SetPoint("BOTTOMRIGHT", highlight, "BOTTOMRIGHT")

    -- Create display area.
    local display = CreateFrame("Frame", nil, listbox)
    display.margin = 0
    display:SetPoint("TOPLEFT", listbox, "TOPLEFT")
    display:SetPoint("BOTTOMRIGHT", listbox, "BOTTOMRIGHT")

    -- Create slider (scrollbar) to track the position.
    local slider = CreateFrame("Slider", nil, listbox)
    slider:Hide()
    slider:SetWidth(16)
    slider:SetPoint("TOPRIGHT", listbox, "TOPRIGHT", 5, -11)  --DJUchanged from 0,-16 to 5,-11.
    slider:SetPoint("BOTTOMRIGHT", listbox, "BOTTOMRIGHT", 5, 9)  --DJUchanged from 0,16 to 5,9.
    slider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)
    slider:SetScript("OnValueChanged", ListBox_OnSliderChanged)

    -- Up button.
    local upButton = CreateFrame("Button", nil, slider, "UIPanelScrollUpButtonTemplate")
    upButton:SetPoint("BOTTOM", slider, "TOP", 0, -6)  --DJUadded offsets.
    upButton:SetScript("OnClick", ListBox_OnClickUp)

    -- Down button.
    local downButton = CreateFrame("Button", nil, slider, "UIPanelScrollDownButtonTemplate")
    downButton:SetPoint("TOP", slider, "BOTTOM", 0, 6)  --DJUadded offsets.
    downButton:SetScript("OnClick", ListBox_OnClickDown)

    if not bHideBorder then  -- Show border for listbox?
        local dx = -0.2  -- Used to shift scrollbox horizontally while keeping all its parts aligned.
        local margin = 2
        display.margin = margin

        display:SetPoint("TOPLEFT", listbox, "TOPLEFT", margin, -margin)
        upButton:SetSize(18.7, 17)  -- was 18,16
        downButton:SetSize(18.7, 17)  -- was 18,16

        upButton:ClearAllPoints()
        upButton:SetPoint("TOPRIGHT", listbox, "TOPRIGHT", dx-margin+0.5, -4)
        downButton:ClearAllPoints()
        downButton:SetPoint("BOTTOMRIGHT", listbox, "BOTTOMRIGHT", dx-margin+0.5, 2)

        slider:SetPoint("TOPRIGHT", listbox, "TOPRIGHT", dx-margin-1, -13)
        slider:SetPoint("BOTTOMRIGHT", listbox, "BOTTOMRIGHT", dx-margin-1, 11)

        slider.texture = slider:CreateTexture(nil, "BACKGROUND")
        ----slider.texture:SetAllPoints()
        slider.texture:SetPoint("TOPLEFT", 0, 0)
        slider.texture:SetPoint("BOTTOMRIGHT", -1, 0)
        slider.texture:SetColorTexture(0.06, 0.06, 0.06)
    end

    -- Make it work with the mouse wheel.
    display:EnableMouseWheel(true)
    display:SetScript("OnMouseWheel", ListBox_OnMouseWheel)


    -- Extension functions.
    listbox.Configure               = ListBox_Configure
    listbox.SetCreateLineHandler    = ListBox_SetCreateLineHandler
    listbox.SetDisplayHandler       = ListBox_SetDisplayHandler
    listbox.SetClickHandler         = ListBox_SetClickHandler
    listbox.GetOffset               = ListBox_GetOffset
    listbox.SetOffset               = ListBox_SetOffset
    listbox.AddItem                 = ListBox_AddItem
    listbox.RemoveItem              = ListBox_RemoveItem
    listbox.GetItem                 = ListBox_GetItem
    listbox.GetSelectedItem         = ListBox_GetSelectedItem
    listbox.GetSelectedItemNumber   = ListBox_GetSelectedItemNumber  --DJUadded
    listbox.SelectItem              = ListBox_SelectItem
    listbox.GetLine                 = ListBox_GetLine
    listbox.GetNumItems             = ListBox_GetNumItems
    listbox.GetNumLines             = ListBox_GetNumLines
    listbox.Refresh                 = ListBox_Refresh
    listbox.Clear                   = ListBox_Clear
    listbox.Disable                 = ListBox_Disable
    listbox.Enable                  = ListBox_Enable

    -- Track internal values.
    listbox.creationTime = GetTime()  --DJUadded
    listbox.displayFrame = display
    listbox.sliderFrame = slider
    listbox.upButton = upButton
    listbox.downButton = downButton
    listbox.highlightFrame = highlight
    listbox.items = {}
    listbox.lines = {}
    listbox.lineCache = {}
    listbox.selectedItem = 0
    return listbox
end


--#############################################################################
-------------------------------------------------------------------------------
-- CheckBox functions.
-------------------------------------------------------------------------------
--#############################################################################


-- ****************************************************************************
-- Called when the internal checkbutton is clicked.
-- ****************************************************************************
local function CheckBox_OnClick(this)
    local isChecked = this:GetChecked() and true or false
    if (isChecked) then PlaySound(856) else PlaySound(857) end

    local checkbox = this:GetParent()
    if (checkbox.clickHandler) then checkbox:clickHandler(isChecked) end
end


-- ****************************************************************************
-- Called when the mouse enters the internal checkbutton.
-- ****************************************************************************
local function CheckBox_OnEnter(this)
    if (this.tooltip) then
        GameTooltip:SetOwner(this, this.tooltipAnchor or "ANCHOR_RIGHT")
        GameTooltip:SetText(this.tooltip, nil, nil, nil, nil, 1)
    end
end


-- ****************************************************************************
-- Called when the mouse leaves the internal checkbutton.
-- ****************************************************************************
local function CheckBox_OnLeave(this)
    GameTooltip:Hide()
end


-- ****************************************************************************
-- Sets the label for the checkbox.
-- ****************************************************************************
local function CheckBox_SetLabel(this, label)
    local fontString = this.fontString
    fontString:SetText(label or "")
    gCalcFontString:SetText(label or "")
    local width = this.checkFrame:GetWidth() + gCalcFontString:GetStringWidth() + 2
    this:SetWidth(math.ceil(width))
end


-- ****************************************************************************
-- Sets the tooltip for the checkbox.
-- ****************************************************************************
local function CheckBox_SetTooltip(this, tooltip)
    this.checkFrame.tooltip = tooltip
end


-- ****************************************************************************
-- Configures the checkbox.
-- ****************************************************************************
local function CheckBox_Configure(this, size, label, tooltip)
    -- Don't do anything if required parameters are invalid.
    if (not size) then return end

    -- Setup the container frame.
    this:SetHeight(size)

    -- Setup the checkbox dimensions.
    local check = this.checkFrame
    check:SetWidth(size)
    check:SetHeight(size)

    -- Setup the label and tooltip.
    CheckBox_SetLabel(this, label)
    CheckBox_SetTooltip(this, tooltip)

    this.configured = true
end


-- ****************************************************************************
-- Sets the function to be called when the checkbox is clicked.
-- It is passed the checkbox and whether or not it's checked.
-- ****************************************************************************
local function CheckBox_SetClickHandler(this, handler)
    this.clickHandler = handler
end


-- ****************************************************************************
-- Returns whether or not the checkbox is checked.
-- ****************************************************************************
local function CheckBox_GetChecked(this)
    return this.checkFrame:GetChecked() and true or false
end


-- ****************************************************************************
-- Sets the checked state.
-- ****************************************************************************
local function CheckBox_SetChecked(this, isChecked)
    this.checkFrame:SetChecked(isChecked)
end


-- ****************************************************************************
-- Disables the checkbox.
-- ****************************************************************************
local function CheckBox_Disable(this)
    this.checkFrame:Disable()
    this.fontString:SetTextColor(0.5, 0.5, 0.5)
end


-- ****************************************************************************
-- Enables the checkbox.
-- ****************************************************************************
local function CheckBox_Enable(this)
    this.checkFrame:Enable()
    this.fontString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
end


-- ****************************************************************************
-- Creates and returns a checkbox object ready to be configured.
-- ****************************************************************************
local function CreateCheckBox(parent)
    -- XXX Hack to work around apparent WoW API bug not returning correct string width.
    if (not gCalcFontString) then
        gCalcFontString = UIParent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    end

    -- Create container frame.
    local checkbox = CreateFrame("Frame", nil, parent)

    -- Create check button.
    local checkbutton = CreateFrame("CheckButton", nil, checkbox)
    checkbutton:SetPoint("TOPLEFT")
    checkbutton:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
    checkbutton:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
    checkbutton:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
    checkbutton:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
    checkbutton:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
    checkbutton:SetScript("OnClick", CheckBox_OnClick)
    checkbutton:SetScript("OnEnter", CheckBox_OnEnter)
    checkbutton:SetScript("OnLeave", CheckBox_OnLeave)

    -- Label.
    local fontString = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fontString:SetPoint("LEFT", checkbutton, "RIGHT", 2, 0)
    fontString:SetPoint("RIGHT", checkbox, "RIGHT", 0, 0)
    fontString:SetJustifyH("LEFT")


    -- Extension functions.
    checkbox.Configure          = CheckBox_Configure
    checkbox.SetLabel           = CheckBox_SetLabel
    checkbox.SetTooltip         = CheckBox_SetTooltip
    checkbox.SetClickHandler    = CheckBox_SetClickHandler
    checkbox.GetChecked         = CheckBox_GetChecked
    checkbox.SetChecked         = CheckBox_SetChecked
    checkbox.Disable            = CheckBox_Disable
    checkbox.Enable             = CheckBox_Enable

    -- Track internal values.
    checkbox.checkFrame = checkbutton
    checkbox.fontString = fontString
    return checkbox
end


--#############################################################################
-------------------------------------------------------------------------------
-- Button functions.
-------------------------------------------------------------------------------
--#############################################################################


-- ****************************************************************************
-- Called when the button is clicked.
-- ****************************************************************************
local function Button_OnClick(this)
    PlaySound(856)
    if (this.clickHandler) then this:clickHandler() end
end


-- ****************************************************************************
-- Called when the mouse enters the button.
-- ****************************************************************************
local function Button_OnEnter(this)
    if (this.tooltip) then
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:SetText(this.tooltip, nil, nil, nil, nil, 1)
    end
end


-- ****************************************************************************
-- Called when the mouse leaves the button.
-- ****************************************************************************
local function Button_OnLeave(this)
    GameTooltip:Hide()
end


-- ****************************************************************************
-- Sets the tooltip for the button.
-- ****************************************************************************
local function Button_SetTooltip(this, tooltip)
    this.tooltip = tooltip
end


-- ****************************************************************************
-- Sets the function to be called when the button is clicked.
-- ****************************************************************************
local function Button_SetClickHandler(this, handler)
    this.clickHandler = handler
end


-- ****************************************************************************
-- Creates and returns a generic button object.  Only used internally.
-- ****************************************************************************
local function CreateButton(parent)
    -- Create button frame.
    local button = CreateFrame("Button", nil, parent)
    button:SetScript("OnClick", Button_OnClick)
    button:SetScript("OnEnter", Button_OnEnter)
    button:SetScript("OnLeave", Button_OnLeave)

    -- Extension functions.
    button.SetClickHandler  = Button_SetClickHandler
    button.SetTooltip = Button_SetTooltip

    return button
end


--#############################################################################
-------------------------------------------------------------------------------
-- OptionButton functions.
-------------------------------------------------------------------------------
--#############################################################################


-- ****************************************************************************
-- Set the label for the option button.
-- ****************************************************************************
local function OptionButton_SetLabel(this, label)
    this:SetText(label or "")
    this:SetWidth(this:GetFontString():GetStringWidth() + 50)
end


-- ****************************************************************************
-- Configures the option button.
-- ****************************************************************************
local function OptionButton_Configure(this, height, label, tooltip)
    this:SetHeight(height)
    OptionButton_SetLabel(this, label)
    Button_SetTooltip(this, tooltip)
end


-- ****************************************************************************
-- Creates and returns a push button object ready to be configured.
-- ****************************************************************************
local function CreateOptionButton(parent)
    -- Create generic button.
    local button = CreateButton(parent)
    local fontString = button:CreateFontString(nil, "OVERLAY")
    fontString:SetPoint("CENTER")
    button:SetFontString(fontString)
    button:SetNormalFontObject(GameFontNormalSmall)
    button:SetHighlightFontObject(GameFontHighlightSmall)
    button:SetDisabledFontObject(GameFontDisableSmall)
    button:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
    button:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
    button:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
    button:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
    button:GetNormalTexture():SetTexCoord(0, 0.625, 0, 0.6875)
    button:GetPushedTexture():SetTexCoord(0, 0.625, 0, 0.6875)
    button:GetDisabledTexture():SetTexCoord(0, 0.625, 0, 0.6875)
    button:GetHighlightTexture():SetTexCoord(0, 0.625, 0, 0.6875)


    -- Extension functions.
    button.SetLabel         = OptionButton_SetLabel
    button.Configure        = OptionButton_Configure

    return button
end


--#############################################################################
-------------------------------------------------------------------------------
-- IconButton functions.
-------------------------------------------------------------------------------
--#############################################################################


-- ****************************************************************************
-- Creates and returns an icon button object ready to be configured.
-- Requires three icon BLP files to be specified.  'iconPath' can be set to the
-- path where these files reside, or if left nil, the addon's folder will be used.
-- Each icon file's name must begin.
-- (The ".blp" file extension must not be specified. 'iconPath' must end with "\\".)
-- An example for a delete button:
--   local deleteBtn = CreateIconButton(YourOptionsFrame, 24, "Interface\\Addons\\YourAddonName\\YourIcons\\"
--                                     "DeleteIcon", "DeleteIconHighlight", "DeleteIconDisable")
-- ****************************************************************************
local function CreateIconButton(parent, iconSize, iconPath, iconFname, iconHighlightFname, iconDisableFname)  --DJUchanged
    iconSize = iconSize or 24
    iconPath = iconPath or "Interface\\Addons\\" .. kAddonFolderName .. "\\"
    local button = CreateButton(parent)
    button:SetWidth(iconSize)
    button:SetHeight(iconSize)
    if iconFname then button:SetNormalTexture(iconPath .. iconFname) end
    if iconHighlightFname then button:SetHighlightTexture(iconPath .. iconHighlightFname) end
    if iconDisableFname then button:SetDisabledTexture(iconPath .. iconDisableFname) end
    return button
end


--#############################################################################
-------------------------------------------------------------------------------
-- Slider functions.
-------------------------------------------------------------------------------
--#############################################################################


-- ****************************************************************************
-- Called when the value of the slider changes.
-- ****************************************************************************
local function Slider_OnValueChanged(this, value)
    local slider = this:GetParent()
    if (slider.labelText ~= "") then
        slider.labelFontString:SetText(slider.labelText .. ": " .. value)
    else
        slider.labelFontString:SetText(value)
    end
    if (slider.valueChangedHandler) then slider:valueChangedHandler(value) end
end


-- ****************************************************************************
-- Called when the mouse enters the slider.
-- ****************************************************************************
local function Slider_OnEnter(this)
    if (this.tooltip) then
        GameTooltip:SetOwner(this, this.tooltipAnchor or "ANCHOR_RIGHT")
        GameTooltip:SetText(this.tooltip, nil, nil, nil, nil, 1)
    end
end


-- ****************************************************************************
-- Called when the mouse leaves the slider.
-- ****************************************************************************
local function Slider_OnLeave(this)
    GameTooltip:Hide()
end


-- ****************************************************************************
-- Sets the label for the slider.
-- ****************************************************************************
local function Slider_SetLabel(this, label)
    this.labelText = label or ""
    if (this.labelText ~= "") then
        this.labelFontString:SetText(this.labelText .. ": " .. this:GetValue())
    else
        this.labelFontString:SetText(this:GetValue())
    end
end


-- ****************************************************************************
-- Sets the tooltip for the slider.
-- ****************************************************************************
local function Slider_SetTooltip(this, tooltip)
    this.sliderFrame.tooltip = tooltip
end


-- ****************************************************************************
-- Configures the slider.
-- ****************************************************************************
local function Slider_Configure(this, width, label, tooltip)
    this:SetWidth(width)
    Slider_SetLabel(this, label)
    Slider_SetTooltip(this, tooltip)
end


-- ****************************************************************************
-- Sets the function to be called when the value of the slider is changed.
-- It is passed the slider and the new value.
-- ****************************************************************************
local function Slider_SetValueChangedHandler(this, handler)
    this.valueChangedHandler = handler
end


-- ****************************************************************************
-- Sets the minimum and maximum values for the slider.
-- ****************************************************************************
local function Slider_SetMinMaxValues(this, minValue, maxValue)
    this.sliderFrame:SetMinMaxValues(minValue, maxValue)
end


-- ****************************************************************************
-- Sets how far the slider moves with each "tick."
-- ****************************************************************************
local function Slider_SetValueStep(this, value)
    this.sliderFrame:SetValueStep(value)
end


-- ****************************************************************************
-- Sets the current value of the slider.
-- ****************************************************************************
local function Slider_GetValue(this)
    return this.sliderFrame:GetValue()
end


-- ****************************************************************************
-- Sets the current value of the slider.
-- ****************************************************************************
local function Slider_SetValue(this, value)
    this.sliderFrame:SetValue(value)
end


-- ****************************************************************************
-- Disables the slider.
-- ****************************************************************************
local function Slider_Disable(this)
    this.sliderFrame:EnableMouse(false)
    this.labelFontString:SetTextColor(0.5, 0.5, 0.5)
end


-- ****************************************************************************
-- Enables the slider.
-- ****************************************************************************
local function Slider_Enable(this)
    this.sliderFrame:EnableMouse(true)
    this.labelFontString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
end


-- ****************************************************************************
-- Creates and returns a slider object ready to be configured.
-- ****************************************************************************
local function CreateSlider(parent)
    -- Create the backdrop table if it hasn't already been so it can be reused.
    if (not gSliderBackdrop) then
        gSliderBackdrop = {
            bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
            edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
            tile = true, tileSize = 8, edgeSize = 8,
            insets = {left=3, right=3, top=6, bottom=6},
        }
    end

    -- Create container frame.
    local slider = CreateFrame("Frame", nil, parent)
    slider:SetHeight(30)

    -- Create slider.
    local sliderFrame = CreateFrame("Slider", nil, slider)
    sliderFrame:SetOrientation("HORIZONTAL")
    sliderFrame:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    sliderFrame:SetPoint("LEFT")
    sliderFrame:SetPoint("RIGHT")
    sliderFrame:SetHeight(16)
    sliderFrame:SetBackdrop(gSliderBackdrop)
    sliderFrame:SetObeyStepOnDrag(true)
    sliderFrame:SetScript("OnValueChanged", Slider_OnValueChanged)
    sliderFrame:SetScript("OnEnter", Slider_OnEnter)
    sliderFrame:SetScript("OnLeave", Slider_OnLeave)


    -- Label.
    local label = slider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("BOTTOM", sliderFrame, "TOP", 0, 0)

    -- Extension functions.
    slider.Configure                = Slider_Configure
    slider.SetLabel                 = Slider_SetLabel
    slider.SetTooltip               = Slider_SetTooltip
    slider.SetValueChangedHandler   = Slider_SetValueChangedHandler
    slider.SetMinMaxValues          = Slider_SetMinMaxValues
    slider.SetValueStep             = Slider_SetValueStep
    slider.GetValue                 = Slider_GetValue
    slider.SetValue                 = Slider_SetValue
    slider.Enable                   = Slider_Enable
    slider.Disable                  = Slider_Disable


    -- Track internal values.
    slider.sliderFrame = sliderFrame
    slider.labelFontString = label
    slider.labelText = ""
    return slider
end


--#############################################################################
-------------------------------------------------------------------------------
-- DropDown functions.
-------------------------------------------------------------------------------
--#############################################################################


-- ****************************************************************************
-- Hides the dropdown listbox frame that holds the selections.
-- ****************************************************************************
local function DropDown_HideSelections(this)
    if (gDropDownListBoxFrame:IsShown() and gDropDownListBoxFrame.dropdown == this) then
        gDropDownListBoxFrame:Hide()
    end
end

-- ****************************************************************************
-- Called when the mouse enters the dropdown.
-- ****************************************************************************
local function DropDown_OnEnter(this)
    if (this.tooltip) then
        GameTooltip:SetOwner(this, this.tooltipAnchor or "ANCHOR_RIGHT")
        GameTooltip:SetText(this.tooltip, nil, nil, nil, nil, 1)
    end
end


-- ****************************************************************************
-- Called when the mouse leaves the dropdown.
-- ****************************************************************************
local function DropDown_OnLeave(this)
    GameTooltip:Hide()
end


-- ****************************************************************************
-- Called when the dropdown is hidden.
-- ****************************************************************************
local function DropDown_OnHide(this)
    DropDown_HideSelections(this)
end


-- ****************************************************************************
-- Returns the common listbox frame used by all dropdown menus to display 
-- their items when clicked open.
-- ****************************************************************************
local function DropDown_GetListBoxFrame(this)  --DJUadded
    return gDropDownListBoxFrame
end


-- ****************************************************************************
-- Called when the button for the dropdown is pressed.
-- ****************************************************************************
local function DropDown_OnClick(this)
    -- Close the listbox and exit if it's already open for the dropdown.
    local dropdown = this:GetParent()
    if (gDropDownListBoxFrame:IsShown() and gDropDownListBoxFrame.dropdown == dropdown) then
        gDropDownListBoxFrame:Hide()
        return
    end
    ----vdt_dump(gDropDownListBoxFrame, "gDropDownListBoxFrame")    

    -- Resize and move the dropdown listbox frame for the clicked dropdown.
    local kListBoxBottomMargin = 18  --DJUadded and changed value from 24 to 18.
    local totalHeight = #dropdown.items * kListBoxLineHeight
    local listboxHeight = dropdown.listboxHeight or (kListBoxLineHeight * 7)  -- Use specified height, or default to 7 lines.
    local listboxWidth = dropdown.listboxWidth or dropdown:GetWidth()
    listboxWidth = listboxWidth - 4  --DJUchanged: From +20 to -4.
    totalHeight = math.max(math.min(totalHeight, listboxHeight), kListBoxLineHeight)

    --DJUadded vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    -- Limit height of listbox so its bottom is always on screen.
    local maxHeight = (this:GetBottom() - kListBoxBottomMargin) / gDropDownListBoxFrame:GetScale()  -- GetBottom() is relative to screen, not parent.
    if (totalHeight > maxHeight) then
        ----totalHeight = maxHeight  -- Leaves different amounts of space at bottom of listbox.
        totalHeight = math.floor(maxHeight / kListBoxLineHeight) * kListBoxLineHeight  -- Keeps it a multiple of line height.
    end
    --DJUadded ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    gDropDownListBoxFrame:SetParent(dropdown:GetParent())
    gDropDownListBoxFrame:SetHeight(totalHeight + kListBoxBottomMargin)
    gDropDownListBoxFrame:SetWidth(listboxWidth)
    gDropDownListBoxFrame:ClearAllPoints()
    if dropdown.setpointFunc then  --DJUadded
       dropdown.setpointFunc(gDropDownListBoxFrame, dropdown) --DJUadded
    else
        gDropDownListBoxFrame:SetPoint("TOPRIGHT", dropdown, "BOTTOMRIGHT", 0, 5)  --DJUchanged to work better when scaling listbox.
    end
    gDropDownListBoxFrame:SetFrameLevel( dropdown:GetFrameLevel()+5 )
    gDropDownListBoxFrame.dropdown = dropdown

    -- Setup the listbox.
    local listbox = gDropDownListBoxFrame.listbox
    ListBox_Clear(listbox)
    listbox:SetPoint("TOPLEFT", gDropDownListBoxFrame, "TOPLEFT", 7, -9)  --DJUchanged: From 8,-12 to 7,-9.
    listbox:SetPoint("BOTTOMRIGHT", gDropDownListBoxFrame, "BOTTOMRIGHT", -12, 12)
    ListBox_Configure(listbox, 0, totalHeight, kListBoxLineHeight)
    for itemNum in ipairs(dropdown.items) do
        ListBox_AddItem(listbox, itemNum)
    end
    ListBox_SelectItem(listbox, dropdown.selectedItem)
    ListBox_SetOffset(listbox, dropdown.selectedItem - 1)

    gDropDownListBoxFrame:Show()
    gDropDownListBoxFrame:Raise()
end


-- ****************************************************************************
-- Called by listbox to create a line.
-- ****************************************************************************
local function DropDown_CreateLine(this)
    local frame = CreateFrame("Button", nil, this)
    local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fontString:SetPoint("LEFT", frame, "LEFT", 4, 0)  --DJUadded X offset.
    fontString:SetPoint("RIGHT", frame, "RIGHT")
    fontString:SetJustifyH("LEFT")  --DJUadded

    frame.fontString = fontString
    return frame
end


-- ****************************************************************************
-- Called by listbox to display a line.
-- ****************************************************************************
local function DropDown_DisplayLine(this, line, value, isSelected)
    line.fontString:SetText(gDropDownListBoxFrame.dropdown.items[value])
    local color = isSelected and HIGHLIGHT_FONT_COLOR or NORMAL_FONT_COLOR
    line.fontString:SetTextColor(color.r, color.g, color.b)
end


-- ****************************************************************************
-- Called when a line is clicked.
-- ****************************************************************************
local function DropDown_OnClickLine(this, line, value)
    local dropdown = gDropDownListBoxFrame.dropdown
    dropdown.selectedFontString:SetText(dropdown.items[value])
    dropdown.selectedItem = value
    gDropDownListBoxFrame:Hide()

    -- Call the registered change handler for the dropdown.
    if (dropdown.changeHandler) then dropdown:changeHandler(dropdown.itemIDs[value]) end
end


-- ****************************************************************************
-- Sets the label for the dropdown.
-- ****************************************************************************
local function DropDown_SetLabel(this, label)
    this.labelFontString:SetText(label or "")
end


-- ****************************************************************************
-- Sets the tooltip for the dropdown.
-- ****************************************************************************
local function DropDown_SetTooltip(this, tooltip)
    this.tooltip = tooltip
    this.fullWidthButton.tooltip = tooltip  --DJUadded
    this.buttonFrame.tooltip = tooltip  --DJUadded
end


-- ****************************************************************************
-- Configures the dropdown.
-- ****************************************************************************
local function DropDown_Configure(this, width, label, tooltip)
    -- Don't do anything if required parameters are invalid.
    ----DJUremoved:  if (not width) then return end
    assert(width ~= nil and width > 0)  --DJUadded

    -- Set the width of the dropdown and the max height of the listbox is shown.
    this:SetWidth(width)

    DropDown_SetLabel(this, label)
    DropDown_SetTooltip(this, tooltip)
end


-- ****************************************************************************
-- Sets the max height the listbox frame can be for the dropdown.
-- ****************************************************************************
local function DropDown_SetListBoxHeight(this, height)
    this.listboxHeight = height
end

-- ****************************************************************************
-- Sets the width of the listbox frame for the dropdown.
-- ****************************************************************************
local function DropDown_SetListBoxWidth(this, width)
    this.listboxWidth = width
end


-- ****************************************************************************
-- Sets the function to be called when one of the dropdown's options is
-- selected. It is passed the ID for the selected item.
-- ****************************************************************************
local function DropDown_SetChangeHandler(this, handler)
    this.changeHandler = handler
end


-- ****************************************************************************
-- Returns the number of items in the listbox.
-- ****************************************************************************
local function DropDown_GetNumItems(this)  --DJUadded
    return #this.items
end


-- ****************************************************************************
-- Adds the passed text and id to the dropdown.
-- ****************************************************************************
local function DropDown_AddItem(this, text, id, bPreventDuplicate)
    if bPreventDuplicate then
        -- Check if 'text' already exists.  If so, update its ID and return.
        for itemNum, itemText in ipairs(this.items) do
            if (itemText == text) then
                this.itemIDs[itemNum] = id  -- Update existing item's ID.
                return  -- Done.
            end
        end
    end

    -- New item, so add it.
    this.items[#this.items+1] = text
    this.itemIDs[#this.items] = id
end


-- ****************************************************************************
-- Remove the passed item id from the dropdown.
-- ****************************************************************************
local function DropDown_RemoveItem_Helper(this, itemNumToRemove)
    -- Hide dropdown if it is shown.
    DropDown_HideSelections(this)

    -- Clear the selected item if it's the item being removed.
    if (itemNumToRemove == this.selectedItem) then
        this.selectedItem = 0
        this.selectedFontString:SetText("")
    end

    table.remove(this.items, itemNumToRemove)
    table.remove(this.itemIDs, itemNumToRemove)
    return true
end
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
local function DropDown_RemoveItem(this, id)
    assert(id)

    -- Compare id with ID entries.
    for itemNum, itemID in ipairs(this.itemIDs) do
        if (itemID == id) then
            return DropDown_RemoveItem_Helper(this, itemNum)  -- DONE.
        end
    end

    -- Compare id with text entries.
    if (type(id) == "string") then
        for itemNum, itemText in ipairs(this.items) do
            if (itemText == id) then
                return DropDown_RemoveItem_Helper(this, itemNum)  -- DONE.
            end
        end
    end

    return false  -- FAILED.
end


-- ****************************************************************************
-- Clears the dropdown.
-- ****************************************************************************
local function DropDown_Clear(this)
    local items = this.items
    for k, v in ipairs(items) do
        items[k] = nil
    end

    local itemIDs = this.itemIDs
    for k, v in ipairs(itemIDs) do
        itemIDs[k] = nil
    end

    this.selectedFontString:SetText(nil)
    this.selectedItem = nil  --DJUadded
end


-- ****************************************************************************
-- Clears the dropdown selection.  (The popup menu contents will still exist.)
-- ****************************************************************************
local function DropDown_ClearSelection(this)  --DJUadded
    if (this.selectedItem ~= nil and this.selectedItem ~= 0) then
        this.selectedItem = 0
        this.selectedFontString:SetText("")
    end
end


-- ****************************************************************************
-- Gets the selected index (item number) from the dropdown.
-- ****************************************************************************
local function DropDown_GetSelectedIndex(this)  --DJUadded
    return this.selectedItem
end


-- ****************************************************************************
-- Sets the selected item for the dropdown given an item number (1-based index).
-- Returns true if successful, nil otherwise.
-- ****************************************************************************
local function DropDown_SelectIndex(this, itemNum)  --DJUadded
    if (itemNum == nil) then return end  -- Fail.
    this.selectedFontString:SetText(this.items[itemNum])
    this.selectedItem = itemNum

--~     -- Call the registered change handler for the dropdown.
--~     if (this.changeHandler) then this:changeHandler(this.itemIDs[itemNum]) end
    return true
end


-- ****************************************************************************
-- Gets the selected id from the dropdown.
-- ****************************************************************************
local function DropDown_GetSelectedID(this)
    if (this.selectedItem) then return this.itemIDs[this.selectedItem] end
end


-- ****************************************************************************
-- Sets the selected item for the dropdown given an item ID.
-- Returns true if successful, nil otherwise.
-- ****************************************************************************
local function DropDown_SelectID(this, id)
    if (id == nil) then return end  -- Fail.
    for itemNum, itemID in ipairs(this.itemIDs) do
        if (itemID == id) then
            DropDown_SelectIndex(this, itemNum)  --DJUadded
            return true  -- Done, exit loop.     --DJUadded
            --DJUremoved:  this.selectedFontString:SetText(this.items[itemNum])
            --DJUremoved:  this.selectedItem = itemNum
            --DJUremoved:  return
        end
    end
end


-- ****************************************************************************
-- Gets the selected text from the dropdown.
-- ****************************************************************************
local function DropDown_GetSelectedText(this)
    return this.selectedFontString:GetText()
end


-- ****************************************************************************
-- Sets the selected item for the dropdown given the text shown in the menu.
-- Returns true if successful, nil otherwise.
-- ****************************************************************************
local function DropDown_SelectText(this, text)  --DJUadded
    if (text == nil or text == "") then return end  -- Fail.
    for itemNum, itemText in ipairs(this.items) do
        if (itemText == text) then
            DropDown_SelectIndex(this, itemNum)
            return true  -- Done, exit loop.
        end
    end
end


-- ****************************************************************************
-- Selects next item in the dropdown and invokes the change handler (if set).
-- ****************************************************************************
local function DropDown_SelectNext(this)  --DJUadded
    if gDropDownListBoxFrame:IsShown() then gDropDownListBoxFrame:Hide() end
    local itemNum = this:GetSelectedIndex()
    if (itemNum < this:GetNumItems()) then
        this:SelectIndex( itemNum+1 )
        if this.changeHandler then
            local selectedID = DropDown_GetSelectedID(this)
            this:changeHandler( this.itemIDs[selectedID] )
        end
    end
end


-- ****************************************************************************
-- Selects previous item in the dropdown and invokes the change handler (if set).
-- ****************************************************************************
local function DropDown_SelectPrevious(this)  --DJUadded
    if gDropDownListBoxFrame:IsShown() then gDropDownListBoxFrame:Hide() end
    local itemNum = this:GetSelectedIndex()
    if (itemNum > 1) then
        this:SelectIndex( itemNum-1 )

        -- Call the registered change handler for the dropdown.
        if this.changeHandler then
            local selectedID = DropDown_GetSelectedID(this)
            this:changeHandler( this.itemIDs[selectedID] )
        end
    end
end


-- ****************************************************************************
-- Sorts the contents of the dropdown.
-- ****************************************************************************
local function DropDown_Sort(this)
    local selectedID = DropDown_GetSelectedID(this)

    -- Sort the dropdown items and associated IDs using an insertion sort.
    local items = this.items
    local itemIDs = this.itemIDs
    local tempItem, tempID, j
    for i = 2, #items do
        tempItem = items[i]
        tempID = itemIDs[i]
        j = i - 1
        while (j > 0 and items[j] > tempItem) do
            items[j + 1] = items[j]
            itemIDs[j + 1] = itemIDs[j]
            j = j - 1
        end
        items[j + 1] = tempItem
        itemIDs[j + 1] = tempID
    end

    DropDown_SelectID(this, selectedID)
end


-- ****************************************************************************
-- Disables the dropdown.
-- ****************************************************************************
local function DropDown_Disable(this)
    DropDown_HideSelections(this)
    this:EnableMouse(false)
    this.buttonFrame:Disable()
    this.fullWidthButton:Disable()  --DJUadded
    this.labelFontString:SetTextColor(0.5, 0.5, 0.5)
    this.selectedFontString:SetTextColor(0.5, 0.5, 0.5)
end


-- ****************************************************************************
-- Enables the dropdown.
-- ****************************************************************************
local function DropDown_Enable(this)
    this:EnableMouse(true)
    this.buttonFrame:Enable()
    this.fullWidthButton:Enable()  --DJUadded
    this.labelFontString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    this.selectedFontString:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
end


-- ****************************************************************************
-- Sets the color of the dropdown's background.  ('alpha' is optional.)
-- ****************************************************************************
local function DropDown_SetBackdropColor(this, r, g, b, alpha)  --DJUadded
    ----if (gDropDownListBoxFrame.dropdown == this) then
        gDropDownListBoxFrame:SetBackdropColor(r, g, b, (alpha or 1.0))
    ----end
end

-- ****************************************************************************
-- Sets the color of the dropdown's edges.  ('alpha' is optional.)
-- ****************************************************************************
local function DropDown_SetBackdropBorderColor(this, r, g, b, alpha)  --DJUadded
    ----if (gDropDownListBoxFrame.dropdown == this) then
        gDropDownListBoxFrame:SetBackdropBorderColor(r, g, b, (alpha or 1.0))
    ----end
end

-- ****************************************************************************
-- Creates the listbox frame that dropdowns use.
-- ****************************************************************************
local function DropDown_CreateListBoxFrame(parent, bDropDown)  --DJUchanged: Added bDropDown.
    gDropDownListBoxFrame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    gDropDownListBoxFrame:EnableMouse(true)
    gDropDownListBoxFrame:SetToplevel(true)
    gDropDownListBoxFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    gDropDownListBoxFrame:SetBackdrop{  --DJUchanged ...
        ----bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        -----bgFile = "Interface\\Addons\\" .. kAddonFolderName .. "\\Controls-Background-SolidBlack",
        bgFile ="Interface\\Buttons\\WHITE8X8",
        ----edgeFile = (not bDropDown and "Interface\\Tooltips\\UI-Tooltip-Border") or nil,
        ----edgeFile = (bDropDown and "Interface\\DialogFrame\\UI-DialogBox-Gold-Border") or "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        ----insets = {left = 6, right = 6, top = 6, bottom = 6},
        ----insets = {left=2, right=4, top=4, bottom=4},  edgeSize=12,
        ----insets = {left=6, right=6, top=6, bottom=6},  edgeSize=24,
        ----insets = {left=6, right=9, top=6, bottom=6},  edgeSize=24,
        ----insets = {left=4, right=4, top=4, bottom=4},  edgeSize=16,
        insets = {left=3, right=3, top=2, bottom=3},  edgeSize=12,
    }
    gDropDownListBoxFrame:Hide()
    gDropDownListBoxFrame:SetBackdropColor(0,0,0, 1)  -- --DJUadded: Solid black background.
    ----gDropDownListBoxFrame:SetBackdropBorderColor(0.7,0.7,0.7, 1)  --DJUadded: Darken the dropdown's edges.

    local listbox = CreateListBox(gDropDownListBoxFrame, true)  --DJUchanged: Added true param.
    listbox:SetToplevel(true)
    listbox:SetFrameStrata("FULLSCREEN_DIALOG")
    listbox:SetCreateLineHandler(DropDown_CreateLine)
    listbox:SetDisplayHandler(DropDown_DisplayLine)
    listbox:SetClickHandler(DropDown_OnClickLine)

    gDropDownListBoxFrame.listbox = listbox

    --DJUadded vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    gDropDownListBoxFrame:SetClampedToScreen(true)  -- Keep the bottom of the dropdown list on-screen.
    gDropDownListBoxFrame:SetScript("OnKeyDown", function(this, key)
            -- Close dropdown list when Escape key is pressed.
            local bPassKeyToParent = false
            if key == "ESCAPE" then this:Hide()
            else bPassKeyToParent = true end
            if not InCombatLockdown() then this:SetPropagateKeyboardInput(bPassKeyToParent) end
        end)
    --DJUadded ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
end


-- ****************************************************************************
-- Creates and returns a dropdown object ready to be configured.
-- ****************************************************************************
local function CreateDropDown(parent)
    -- Create dropdown listbox if it hasn't already been.
    if (not gDropDownListBoxFrame) then DropDown_CreateListBoxFrame(parent, true) end  --DJUchanged: Added true param.

    -- Create container frame.
    local dropdown = CreateFrame("Frame", nil, parent)

    dropdown:SetHeight(25)  --DJUchanged: Was 38.
    dropdown:EnableMouse(true)
    dropdown:SetScript("OnEnter", DropDown_OnEnter)
    dropdown:SetScript("OnLeave", DropDown_OnLeave)
    dropdown:SetScript("OnHide", DropDown_OnHide)
    dropdown:SetScript("OnMouseWheel", function(this, delta) --DJUadded
            if (delta < 0) then DropDown_SelectNext(this)
            else DropDown_SelectPrevious(this) end
        end)

    -- Left border.
    local left = dropdown:CreateTexture(nil, "BACKGROUND")
    left:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
    left:SetWidth(9)
    left:SetHeight(25)
    left:SetPoint("BOTTOMLEFT")
    left:SetTexCoord(0.125, 0.1953125, 0.28125, 0.671875)

    -- Right border.
    local right = dropdown:CreateTexture(nil, "BACKGROUND")
    right:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
    right:SetWidth(9)
    right:SetHeight(25)
    right:SetPoint("BOTTOMRIGHT")
    right:SetTexCoord(0.7890625, 0.859375, 0.28125, 0.671875)

    -- Middle border.
    local middle = dropdown:CreateTexture(nil, "BACKGROUND")
    middle:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
    middle:SetWidth(76)
    middle:SetHeight(25)
    middle:SetPoint("LEFT", left, "RIGHT", 0, 0)
    middle:SetPoint("RIGHT", right, "LEFT", 0, 0)
    middle:SetTexCoord(0.1953125, 0.7890625, 0.28125, 0.671875)

    -- Label.
    local label = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("BOTTOMLEFT", left, "TOPLEFT", 2, 2)


    -- DropDown button.
    local button = CreateFrame("Button", nil, dropdown)
    button:SetWidth(24)
    button:SetHeight(24)
    button:SetPoint("BOTTOMRIGHT", 1, 1)
    button:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    button:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
    button:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled")
    button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    button:GetHighlightTexture():SetBlendMode("ADD")
    button:SetScript("OnClick", DropDown_OnClick)
    button:SetScript("OnEnter", DropDown_OnEnter)  --DJUadded
    button:SetScript("OnLeave", DropDown_OnLeave)  --DJUadded
    button:SetScript("OnHide", DropDown_OnHide)  --DJUadded

    --DJUadded vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    local fullWidthButton = CreateFrame("Button", nil, dropdown)
    fullWidthButton:SetPoint("TOPLEFT", dropdown, "TOPLEFT")
    fullWidthButton:SetPoint("BOTTOMRIGHT", button, "BOTTOMLEFT")
    fullWidthButton:SetScript("OnClick", DropDown_OnClick)

    fullWidthButton:SetScript("OnEnter", DropDown_OnEnter)
    fullWidthButton:SetScript("OnLeave", DropDown_OnLeave)
    fullWidthButton:SetScript("OnHide", DropDown_OnHide)
    --DJUadded ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


    -- Selected text.
    local selected = dropdown:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    selected:SetPoint("LEFT", left, "RIGHT", 1, 0)  --DJUadded offsets.
    selected:SetPoint("RIGHT", button, "LEFT")
    selected:SetJustifyH("LEFT")  --DJUchanged (was "RIGHT")


    -- Extension functions.
    dropdown.Configure          = DropDown_Configure
    dropdown.SetListBoxHeight   = DropDown_SetListBoxHeight
    dropdown.SetListBoxWidth    = DropDown_SetListBoxWidth
    dropdown.SetLabel           = DropDown_SetLabel
    dropdown.SetTooltip         = DropDown_SetTooltip
    dropdown.SetChangeHandler   = DropDown_SetChangeHandler
    dropdown.HideSelections     = DropDown_HideSelections
    dropdown.GetNumItems        = DropDown_GetNumItems  --DJUadded
    dropdown.AddItem            = DropDown_AddItem
    dropdown.RemoveItem         = DropDown_RemoveItem
    dropdown.Clear              = DropDown_Clear
    dropdown.ClearSelection     = DropDown_ClearSelection  --DJUadded
    dropdown.GetSelectedText    = DropDown_GetSelectedText
    dropdown.SelectText         = DropDown_SelectText  --DJUadded
    dropdown.GetSelectedID      = DropDown_GetSelectedID
    dropdown.SelectID           = DropDown_SelectID
    dropdown.GetSelectedIndex   = DropDown_GetSelectedIndex  --DJUadded
    dropdown.SelectIndex        = DropDown_SelectIndex  --DJUadded
    dropdown.Sort               = DropDown_Sort
    dropdown.Disable            = DropDown_Disable
    dropdown.Enable             = DropDown_Enable
    dropdown.GetListBoxFrame    = DropDown_GetListBoxFrame  --DJUadded
    dropdown.SelectNext         = DropDown_SelectNext  --DJUadded
    dropdown.SelectPrevious     = DropDown_SelectPrevious  --DJUadded
    dropdown.SetBackdropColor   = DropDown_SetBackdropColor  --DJUadded
    dropdown.SetBackdropBorderColor = DropDown_SetBackdropBorderColor  --DJUadded

    -- Track internal values.
    dropdown.selectedFontString = selected
    dropdown.buttonFrame = button
    dropdown.labelFontString = label
    dropdown.items = {}
    dropdown.itemIDs = {}
    dropdown.selectedItem = 0  -- index #
    dropdown.fullWidthButton = fullWidthButton  --DJUadded
    return dropdown
end


--[[
--#############################################################################
-------------------------------------------------------------------------------
-- EditBox functions.
-------------------------------------------------------------------------------
--#############################################################################


-- ****************************************************************************
-- Called when the editbox has focus and escape is pressed.
-- ****************************************************************************
local function EditBox_OnEscape(this)
    this:ClearFocus()
    local editbox = this:GetParent()
    if (editbox.escapeHandler) then editbox:escapeHandler() end
end


-- ****************************************************************************
-- Called when the editbox loses focus.
-- ****************************************************************************
local function EditBox_OnFocusLost(this)
    this:HighlightText(0, 0)
end


-- ****************************************************************************
-- Called when the editbox gains focus.
-- ****************************************************************************
local function EditBox_OnFocusGained(this)
    this:HighlightText()
end


-- ****************************************************************************
-- Called when the text in the editbox changes.
-- ****************************************************************************
local function EditBox_OnTextChanged(this)
    local editbox = this:GetParent()
    if (editbox.textChangedHandler) then editbox:textChangedHandler() end
end


-- ****************************************************************************
-- Called when the mouse enters the editbox.
-- ****************************************************************************
local function EditBox_OnEnter(this)
    if (this.tooltip) then
        GameTooltip:SetOwner(this, this.tooltipAnchor or "ANCHOR_RIGHT")
        GameTooltip:SetText(this.tooltip, nil, nil, nil, nil, 1)
    end
end


-- ****************************************************************************
-- Called when the mouse leaves the editbox.
-- ****************************************************************************
local function EditBox_OnLeave(this)
    GameTooltip:Hide()
end


-- ****************************************************************************
-- Sets the label for the editbox.
-- ****************************************************************************
local function EditBox_SetLabel(this, label)
    this.labelFontString:SetText(label)
end


-- ****************************************************************************
-- Sets the tooltip for the editbox.
-- ****************************************************************************
local function EditBox_SetTooltip(this, tooltip)
    this.editboxFrame.tooltip = tooltip
end


-- ****************************************************************************
-- Configures the editbox.
-- ****************************************************************************
local function EditBox_Configure(this, width, label, tooltip)
    -- Don't do anything if required parameters are invalid.
    if (not width) then return end

    this:SetWidth(width)
    EditBox_SetLabel(this, label)
    EditBox_SetTooltip(this, tooltip)
end


-- ****************************************************************************
-- Sets the handler to be called when the enter button is pressed.
-- ****************************************************************************
local function EditBox_SetEnterHandler(this, handler)
    this.editboxFrame:SetScript("OnEnterPressed", handler)
end


-- ****************************************************************************
-- Sets the handler to be called when the escape button is pressed.
-- ****************************************************************************
local function EditBox_SetEscapeHandler(this, handler)
    this.escapeHandler = handler
end


-- ****************************************************************************
-- Sets the handler to be called when the text in the editbox changes.
-- ****************************************************************************
local function EditBox_SetTextChangedHandler(this, handler)
    this.textChangedHandler = handler
end


-- ****************************************************************************
-- Sets the focus to the editbox.
-- ****************************************************************************
local function EditBox_SetFocus(this)
    this.editboxFrame:SetFocus()
end


-- ****************************************************************************
-- Gets the text entered in the editbox.
-- ****************************************************************************
local function EditBox_GetText(this)
    return this.editboxFrame:GetText()
end


-- ****************************************************************************
-- Sets the text entered in the editbox.
-- ****************************************************************************
local function EditBox_SetText(this, text)
    return this.editboxFrame:SetText(text or "")
end


-- ****************************************************************************
-- Disables the editbox.
-- ****************************************************************************
local function EditBox_Disable(this)
    this.editboxFrame:EnableMouse(false)
    this.labelFontString:SetTextColor(0.5, 0.5, 0.5)
end

-- ****************************************************************************
-- Enables the editbox.
-- ****************************************************************************
local function EditBox_Enable(this)
    this.editboxFrame:EnableMouse(true)
    this.labelFontString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
end


-- ****************************************************************************
-- Creates and returns an editbox object ready to be configured.
-- ****************************************************************************
local function CreateEditBox(parent)
    -- Create container frame.
    local editbox = CreateFrame("Frame", nil, parent)
    editbox:SetHeight(32)

    -- Create editbox frame.
    local editboxFrame = CreateFrame("EditBox", nil, editbox)
    editboxFrame:SetHeight(20)
    editboxFrame:SetPoint("BOTTOMLEFT", editbox, "BOTTOMLEFT", 5, 0)
    editboxFrame:SetPoint("BOTTOMRIGHT")
    editboxFrame:SetAutoFocus(false)
    editboxFrame:SetFontObject(ChatFontNormal)
    editboxFrame:SetScript("OnEscapePressed", EditBox_OnEscape)
    editboxFrame:SetScript("OnEditFocusLost", EditBox_OnFocusLost)
    editboxFrame:SetScript("OnEditFocusGained", EditBox_OnFocusGained)
    editboxFrame:SetScript("OnTextChanged", EditBox_OnTextChanged)
    editboxFrame:SetScript("OnEnter", EditBox_OnEnter)
    editboxFrame:SetScript("OnLeave", EditBox_OnLeave)

    -- Left border.
    local left = editboxFrame:CreateTexture(nil, "BACKGROUND")
    left:SetTexture("Interface\\Common\\Common-Input-Border")
    left:SetWidth(8)
    left:SetHeight(20)
    left:SetPoint("LEFT", editboxFrame, "LEFT", -5, 0)
    left:SetTexCoord(0, 0.0625, 0, 0.625)

    -- Right border.
    local right = editboxFrame:CreateTexture(nil, "BACKGROUND")
    right:SetTexture("Interface\\Common\\Common-Input-Border")
    right:SetWidth(8)
    right:SetHeight(20)
    right:SetPoint("RIGHT")
    right:SetTexCoord(0.9375, 1, 0, 0.625)

    -- Middle border.
    local middle = editboxFrame:CreateTexture(nil, "BACKGROUND")
    middle:SetTexture("Interface\\Common\\Common-Input-Border")
    middle:SetWidth(10)
    middle:SetHeight(20)
    middle:SetPoint("LEFT", left, "RIGHT", 0, 0)
    middle:SetPoint("RIGHT", right, "LEFT", 0, 0)
    middle:SetTexCoord(0.0625, 0.9375, 0, 0.625)


    -- Label.
    local label = editbox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOPLEFT")
    label:SetPoint("TOPRIGHT")
    label:SetJustifyH("LEFT")


    -- Extension functions.
    editbox.Configure               = EditBox_Configure
    editbox.SetLabel                = EditBox_SetLabel
    editbox.SetTooltip              = EditBox_SetTooltip
    editbox.SetEnterHandler         = EditBox_SetEnterHandler
    editbox.SetEscapeHandler        = EditBox_SetEscapeHandler
    editbox.SetTextChangedHandler   = EditBox_SetTextChangedHandler
    editbox.SetFocus                = EditBox_SetFocus
    editbox.GetText                 = EditBox_GetText
    editbox.SetText                 = EditBox_SetText
    editbox.Disable                 = EditBox_Disable
    editbox.Enable                  = EditBox_Enable


    -- Track internal values.
    editbox.editboxFrame = editboxFrame
    editbox.labelFontString = label
    return editbox
end
]]


--#############################################################################
-------------------------------------------------------------------------------
-- ColorSwatch functions.
-------------------------------------------------------------------------------
--#############################################################################


-- ****************************************************************************
-- Returns true if the standard color picker has been modified by functions 
-- in this file.  Returns nil if it is in its original state.
-- ****************************************************************************
local function isColorPickerCustomized()
    return ColorPickerFrame[kCustomizedTag]
end


-- ****************************************************************************
-- Restores modified attributes of the ColorPickerFrame back to their original values.
-- Returns true if our customizations were undone.
-- Returns false if the color picker is not currently customized.
-- ****************************************************************************
local function ColorPickerFrame_RestoreAttributes()
    if not isColorPickerCustomized() then
        return false  -- Color picker is not currenlty customized.  (Nothing to restore.)
    end

    local orig = gColorPickerAttributes

    if gColorPaletteFrame then gColorPaletteFrame:Hide() end
    ColorPickerFrame:SetHeight( orig.height )
    ColorPickerFrame:EnableKeyboard( orig.isKeyboardEnabled )
    ColorPickerFrame:SetClampedToScreen( orig.isClamped )
    ColorPickerFrame:SetClampRectInsets( unpack(orig.insets) )

    setPointTable(ColorPickerFrame, orig.point)

    gColorPickerOkayBtn:SetWidth( orig.okayBtnW )
    setPointTable(gColorPickerOkayBtn, orig.okayBtnPoint)

    gColorPickerCancelBtn:SetWidth( orig.cancelBtnW )
    setPointTable(gColorPickerCancelBtn, orig.cancelBtnPoint)

    if orig.hexBoxPoint then setPointTable(ColorPickerFrame.Content.HexBox, orig.hexBoxPoint) end
    if orig.titleWidth  then ColorPickerFrame.Header:SetWidth( orig.titleWidth ) end
    if orig.title       then ColorPickerFrame.Header.Text:SetText( orig.title ) end

    ColorPickerFrame[kCustomizedTag] = nil  -- Done.  (We restored color picker to original state.)
    return true
end


-- ****************************************************************************
-- Saves current attributes of the ColorPickerFrame that will by modified by this file.
-- ****************************************************************************
local function ColorPickerFrame_SaveAttributes()
    if not gColorPickerAttributes then
        local orig = {}
        orig.height = ColorPickerFrame:GetHeight()
        orig.isKeyboardEnabled = ColorPickerFrame:IsKeyboardEnabled()
        orig.isClamped = ColorPickerFrame:IsClampedToScreen()
        orig.insets = { ColorPickerFrame:GetClampRectInsets() }
        orig.point = getPointTable(ColorPickerFrame)

        orig.okayBtnW = gColorPickerOkayBtn:GetWidth()
        orig.okayBtnPoint = getPointTable(gColorPickerOkayBtn)

        orig.cancelBtnW = gColorPickerCancelBtn:GetWidth()
        orig.cancelBtnPoint = getPointTable(gColorPickerCancelBtn)

        if ColorPickerFrame.Content and ColorPickerFrame.Content.HexBox then
            orig.hexBoxPoint = getPointTable( ColorPickerFrame.Content.HexBox )
        end
        
        if ColorPickerFrame.Header then
            orig.titleWidth = ColorPickerFrame.Header:GetWidth()
            orig.title = ColorPickerFrame.Header.Text:GetText()
        end

        gColorPickerAttributes = orig  -- Store data in our global var.

        -- Always restore these original attributes whenever our color picker is closed.
        ColorPickerFrame:SetScript("OnHide", function(self)
                    if not ColorPickerFrame_RestoreAttributes() then
                        -- The standard color picker (not our customized version) was closed.
                        -- Always update our stored position to preserve where user last moved it.
                        gColorPickerAttributes.point = getPointTable( ColorPickerFrame )
                    end
                end)
    end
end


-- ****************************************************************************
-- Sets the color of the color swatch.
-- ****************************************************************************
local function ColorSwatch_SetColor(swatchBtn, r, g, b, a)
    -- Update our variables.
    swatchBtn.r = r
    swatchBtn.g = g
    swatchBtn.b = b
    swatchBtn.a = a

    -- Update swatch button's color.
    swatchBtn:GetNormalTexture():SetVertexColor(r, g, b, a)
end


-- ****************************************************************************
-- Returns the color of the color swatch.
-- ****************************************************************************
local function ColorSwatch_GetColor(swatchBtn)
    return swatchBtn.r, swatchBtn.g, swatchBtn.b, swatchBtn.a
end


-- ****************************************************************************
-- Called when the color picker values change, or the picker is canceled.
-- ****************************************************************************
local function ColorSwatch_Callback(previousValues)
    local swatchBtn = gAssociatedColorSwatch
    if not swatchBtn then return end

    local r, g, b, a
    if previousValues then
        -- The user canceled.  Extract the old color from 'previousValues', initialized in ShowColorPicker().
        r, g, b, a = previousValues.r, previousValues.g, previousValues.b, previousValues.a
    else
        -- Either color or opacity changed.  Check both.
        r, g, b = ColorPickerFrame:GetColorRGB()
        if ColorPickerFrame.hasOpacity then
            a = OpacitySlider_GetValue()
            ----if not kMinVer_10_2_5 then
            ----    a = 1.0 - a  -- Older versions of WoW flip opacity and alpha.
            ----end
        end
    end

    ColorSwatch_SetColor(swatchBtn, r, g, b, a)  -- Updates color of the swatch button.
    if swatchBtn.colorChangedHandler then swatchBtn:colorChangedHandler() end  -- Updates color of caller's UI element(s).
end


-- ****************************************************************************
-- Creates a color palette frame (if necessary).  This palette is shown in the color picker.
-- ****************************************************************************
local function ColorSwatch_CreateColorPalette()
    if not gColorPaletteFrame then
        local paletteColors = {
                { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }, -- white
                { r = 0.0, g = 0.0, b = 0.0, a = 1.0 }, -- black
                { r = 1.0, g = 0.0, b = 0.0, a = 1.0 },	-- red
                --{ r = 1.0, g = 0.0, b = 0.5, a = 1.0 }, -- rose
                { r = 1.0, g = 0.0, b = 1.0, a = 1.0 },	-- magenta
                { r = 0.5, g = 0.0, b = 1.0, a = 1.0 },	-- violet
                { r = 0.0, g = 0.0, b = 1.0, a = 1.0 },	-- blue
                { r = 0.0, g = 0.5, b = 1.0, a = 1.0 },	-- azure
                { r = 0.0, g = 1.0, b = 1.0, a = 1.0 },	-- cyan
                --{ r = 0.0, g = 1.0, b = 0.5, a = 1.0 }, -- aquamarine
                { r = 0.0, g = 1.0, b = 0.0, a = 1.0 }, -- green
                { r = 0.5, g = 1.0, b = 0.0, a = 1.0 }, -- chartreuse
                { r = 1.0, g = 1.0, b = 0.0, a = 1.0 }, -- yellow
                { r = 1.0, g = 0.5, b = 0.0, a = 1.0 }, -- orange
                { r = 0.976, g = 0.549, b = 0.714, a = 1.0 }, -- Pastels ...
                { r = 0.984, g = 0.714, b = 0.820, a = 1.0 },
                { r = 0.647, g = 0.537, b = 0.757, a = 1.0 },
                { r = 0.757, g = 0.702, b = 0.843, a = 1.0 },
                { r = 0.459, g = 0.537, b = 0.749, a = 1.0 },
                { r = 0.580, g = 0.659, b = 0.816, a = 1.0 },
                { r = 0.604, g = 0.808, b = 0.874, a = 1.0 },
                { r = 0.710, g = 0.882, b = 0.682, a = 1.0 },
                { r = 0.749, g = 0.894, b = 0.462, a = 1.0 },
                { r = 0.999, g = 0.980, b = 0.506, a = 1.0 },
                { r = 0.992, g = 0.792, b = 0.635, a = 1.0 },
                --{ r = 0.859, g = 0.835, b = 0.725, a = 1.0 },
                --{ r = 0.0, g = 0.0, b = 0.0, a = 1.0 }, -- black
                --{ r = 0.1, g = 0.1, b = 0.1, a = 1.0 }, -- shades of gray
                --{ r = 0.2, g = 0.2, b = 0.2, a = 1.0 },
                --{ r = 0.3, g = 0.3, b = 0.3, a = 1.0 },
                --{ r = 0.4, g = 0.4, b = 0.4, a = 1.0 },
                { r = 0.5, g = 0.5, b = 0.5, a = 1.0 }, -- gray
                --{ r = 0.6, g = 0.6, b = 0.6, a = 1.0 },
                --{ r = 0.7, g = 0.7, b = 0.7, a = 1.0 },
                --{ r = 0.8, g = 0.8, b = 0.8, a = 1.0 },
                --{ r = 0.9, g = 0.9, b = 0.9, a = 1.0 },
                --{ r = 1.0, g = 1.0, b = 1.0, a = 1.0 }, -- white
                --{ r = 0.7, g = 0.7, b = 0.7, a = 0.7 }, -- transparent gray
            }
        local rows = 2
        local cols = 12
        local spacer = 0
        local margin = 0
        local swatchSize = 20
        local bgtable = {
                bgFile = "Interface\\Buttons\\WHITE8X8",
                edgeFile = "Interface\\Buttons\\WHITE8X8",
                tile = false,
                tileSize = 16,
                edgeSize = 1,
                insets = { 0, 0, 0, 0 },
            }

        -- Create a frame for the palette squares.
        gColorPaletteFrame = CreateFrame("Frame", nil, ColorPickerFrame, BackdropTemplateMixin and "BackdropTemplate")
        gColorPaletteFrame:SetBackdrop(bgtable)
        gColorPaletteFrame:SetFrameLevel( gColorPickerOkayBtn:GetFrameLevel() )
        gColorPaletteFrame:SetSize((cols*swatchSize)+((cols-1)*spacer)+(2*margin),
                                   (rows*swatchSize)+((rows-1)*spacer)+(2*margin))
        gColorPaletteFrame:ClearAllPoints()
        gColorPaletteFrame:SetPoint("CENTER", ColorPickerFrame, "CENTER", 0, 0)
        gColorPaletteFrame:SetPoint("BOTTOM", gColorPickerOkayBtn, "TOP", 0, 8)
        gColorPaletteFrame:SetBackdropColor(0, 0, 0, 0)
        gColorPaletteFrame:SetBackdropBorderColor(0, 0, 0, 0)
        ----gColorPaletteFrame:Show()

        -- Create palette swatch squares.
        local i, j, k = 0, 0, 0
        for j = 1, rows do
            for i = 1, cols do
                k = k + 1
                local color = paletteColors[k]
                if not color then break end  -- Stop if no more colors in palette.
                local f = CreateFrame("Button", nil, gColorPaletteFrame, BackdropTemplateMixin and "BackdropTemplate")
                f:SetBackdrop(bgtable)
                f:SetBackdropColor(color.r, color.g, color.b, color.a)
                f:SetBackdropBorderColor(0, 0, 0)  --(0, 0, 0, color.a)
                f:SetSize(swatchSize, swatchSize)
                ----createCheckerboardBG(f, false, swatchSize, swatchSize)
                f:ClearAllPoints()
                f:SetPoint("TOPLEFT", gColorPaletteFrame, "TOPLEFT",
                              margin + (spacer*(i-1)) + ((i-1)*swatchSize),
                            -(margin + (spacer*(j-1)) + ((j-1)*swatchSize)))

                f:SetScript("OnClick", function(self)  -- 'self' is one of the palette buttons.
                            local r, g, b, a = self:GetBackdropColor()
                            ColorPickerFrame_SetColorRGB(r, g, b)
                            if ColorPickerFrame.hasOpacity then
                                ColorPickerFrame.opacity = a
                                OpacitySlider_SetValue( ColorPickerFrame.opacity )
                            end
                        end)
            end
        end
    end

    gColorPaletteFrame:Show()
    ColorPickerFrame:SetHeight( kColorPickerDefaultHeight + gColorPaletteFrame:GetHeight() + 16 )
end


-- ****************************************************************************
-- Called when the color swatch is clicked.  Shows the color picker.
-- ****************************************************************************
local function ColorSwatch_ShowColorPicker(swatchBtn)
    if ColorPickerFrame:IsShown() then
        if isColorPickerCustomized() then return end  -- Already shown.  Do nothing else.
        
        -- Otherwise, color picker is opened by another addon.  Close that one so we can show ours (later).
        ColorPickerFrame:Hide()
    end
    ----vdt_dump(swatchBtn, "swatchBtn in ColorSwatch_ShowColorPicker()")

    ColorPickerFrame_SaveAttributes()
    ColorPickerFrame[kCustomizedTag] = true  -- So we restore the color picker to original state when it is closed.
    gAssociatedColorSwatch = swatchBtn
    
    swatchBtn.r = swatchBtn.r or 1
    swatchBtn.g = swatchBtn.g or 1
    swatchBtn.b = swatchBtn.b or 1
    ColorPickerFrame.previousValues = {r = swatchBtn.r, g = swatchBtn.g, b = swatchBtn.b, a = swatchBtn.a}

    if (swatchBtn.a ~= nil) then
        ColorPickerFrame.hasOpacity = true
        ColorPickerFrame.opacity = swatchBtn.a
    else
        ColorPickerFrame.hasOpacity = false
        ColorPickerFrame.opacity = nil
    end

    ColorPickerFrame.func = ColorSwatch_Callback
    ColorPickerFrame.opacityFunc = ColorSwatch_Callback
    ColorPickerFrame.cancelFunc = ColorSwatch_Callback

    if kMinVer_10_2_5 then  -- WoW 10.2.5 or newer?
        -- Set new API stuff.
        ColorPickerFrame.swatchFunc = ColorSwatch_Callback
        ColorPickerFrame.Content.ColorSwatchOriginal:SetColorTexture(swatchBtn.r, swatchBtn.g, swatchBtn.b)
        ColorPickerFrame.Content.HexBox:OnColorSelect(swatchBtn.r, swatchBtn.g, swatchBtn.b)
    end

    -- Set color and opacity.
    ColorPickerFrame_SetColorRGB(swatchBtn.r, swatchBtn.g, swatchBtn.b)
    if (ColorPickerFrame.opacity) then
        OpacitySlider_SetValue(ColorPickerFrame.opacity)
    end

    --::::::::::::::::::[ CUSTOMIZE COLOR PICKER ]:::::::::::::::::::

    -- Attach color picker to top-right corner of the parent frame.
    ColorPickerFrame:ClearAllPoints()
    ColorPickerFrame:SetPoint("TOPLEFT", swatchBtn:GetParent(), "TOPRIGHT", -12, -6)
    ColorPickerFrame:SetClampedToScreen(true)  -- Keep color picker frame on screen.
    ColorPickerFrame:SetClampRectInsets(12, -12, -12, 12) -- Allow for dragging partially off screen.
    
    -- Verify no other addon customtized the color picker.  (Check its height.)
    if (ColorPickerFrame:GetHeight() <  kColorPickerDefaultHeight+1) then
        -- Change title text.
        if ColorPickerFrame.Header then  -- (Header variable doesn't exist in classic WoW versions.)
            ColorPickerFrame.Header.Text:SetText( kAddonFolderName .. " " .. gColorPickerAttributes.title )
            local strWidth = ColorPickerFrame.Header.Text:GetStringWidth()
            ColorPickerFrame.Header:SetWidth( strWidth+41 )
        end

        -- Reposition the Color Picker's OK and CANCEL buttons (slightly).
        gColorPickerOkayBtn:SetWidth(kColorPickerButtonWidth)  -- Was 144.
        gColorPickerCancelBtn:SetWidth(kColorPickerButtonWidth)  -- Was 144.
        gColorPickerCancelBtn:ClearAllPoints()
        gColorPickerCancelBtn:SetPoint("BOTTOMRIGHT", ColorPickerFrame, "BOTTOMRIGHT", -14, 16)
        gColorPickerOkayBtn:ClearAllPoints()
        gColorPickerOkayBtn:SetPoint("RIGHT", gColorPickerCancelBtn, "LEFT", -2, 0)

        -- Reposition the hex box (if it exists).
        if ColorPickerFrame.Content and ColorPickerFrame.Content.HexBox then
            ColorPickerFrame.Content.HexBox:ClearAllPoints()
            ColorPickerFrame.Content.HexBox:SetPoint("RIGHT", ColorPickerFrame.Content, "RIGHT", -23, 0)
            ColorPickerFrame.Content.HexBox:SetPoint("BOTTOM", ColorPickerFrame.Content.ColorPicker, "BOTTOM", 0, 6)
        end

        -- Add color palette swatches to the bottom of the standard color picker.
        ColorSwatch_CreateColorPalette()
    end
    --:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

    -- Finish.
    ColorPickerFrame:EnableKeyboard(false)  -- Prevent color picker from intercepting keystrokes.
    ColorPickerFrame:Hide()  -- Forces the OnShow handler to run the next time OnShow() is called.
    ColorPickerFrame:Show()
end


-- ****************************************************************************
-- Closes the color picker (if it is open) by triggering its OK or CANCEL button
-- depending on the bSaveChanges parameter passed in.
-- ****************************************************************************
local function ColorSwatch_CloseColorPicker(bSaveChanges)
    if ColorPickerFrame:IsShown() then
        if bSaveChanges then
            gColorPickerOkayBtn:Click()
        else
            gColorPickerCancelBtn:Click()
        end
    end
end


-- ****************************************************************************
-- Called when the mouse enters the color swatch.
-- ****************************************************************************
local function ColorSwatch_OnEnter(swatchBtn)
    if (swatchBtn.tooltip) then
        GameTooltip:SetOwner(swatchBtn, swatchBtn.tooltipAnchor or "ANCHOR_RIGHT")
        GameTooltip:SetText(swatchBtn.tooltip, nil, nil, nil, nil, 1)
    end

    ----swatchBtn.borderTexture:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
end


-- ****************************************************************************
-- Called when the mouse leaves the color swatch.
-- ****************************************************************************
local function ColorSwatch_OnLeave(swatchBtn)
    GameTooltip:Hide()
    ----swatchBtn.borderTexture:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
end


-- ****************************************************************************
-- Sets the handler to be called when the color changes.
-- ****************************************************************************
local function ColorSwatch_SetColorChangedHandler(swatchBtn, handler)
    swatchBtn.colorChangedHandler = handler
end


-- ****************************************************************************
-- Sets the tooltip for the color swatch.
-- ****************************************************************************
local function ColorSwatch_SetTooltip(swatchBtn, tooltip)
    swatchBtn.tooltip = tooltip
end


-- ****************************************************************************
-- Disables the colors watch.
-- ****************************************************************************
local function ColorSwatch_Disable(swatchBtn)
    swatchBtn:GetNormalTexture():SetVertexColor(0.5, 0.5, 0.5) -- Dim the color swatch.
    swatchBtn:SetAlpha(0.2)
    swatchBtn:oldDisableHandler()
end


-- ****************************************************************************
-- Enables the color swatch.
-- ****************************************************************************
local function ColorSwatch_Enable(swatchBtn)
    swatchBtn:oldEnableHandler()
    swatchBtn:GetNormalTexture():SetVertexColor(swatchBtn.r, swatchBtn.g, swatchBtn.b)  -- Undim the color swatch.
    swatchBtn:SetAlpha(1.0)
end


-- ****************************************************************************
-- Creates and returns a color swatch object ready to be configured.
-- ****************************************************************************
local function CreateColorSwatch(parent, size)
    ----vdt_dump(gColorPickerAttributes, "gColorPickerAttributes") -- For debugging.
    size = size or 20

    -- Create button frame.
    local colorswatch = CreateFrame("Button", nil, parent)
    colorswatch:SetWidth(size)
    colorswatch:SetHeight(size)
    colorswatch:SetNormalTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
    colorswatch:SetScript("OnClick", ColorSwatch_ShowColorPicker)
    colorswatch:SetScript("OnEnter", ColorSwatch_OnEnter)
    colorswatch:SetScript("OnLeave", ColorSwatch_OnLeave)

    -- Border texture.
    colorswatch.borderTexture = colorswatch:CreateTexture(nil, "BACKGROUND")
    colorswatch.borderTexture:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
    ----colorswatch.borderTexture:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    colorswatch.borderTexture:SetVertexColor(1, 1, 1)
    ----colorswatch.borderTexture:SetColorTexture(1, 1, 1)
    colorswatch.borderTexture:SetWidth(size-2)
    colorswatch.borderTexture:SetHeight(size-2)
    colorswatch.borderTexture:SetPoint("CENTER")

    -- Checkerboard texture.  (Requires WoW version 10.0.2 or later to use texture 188523.)
    if (kGameTocVersion >= 100002) then
        colorswatch.checkers = colorswatch:CreateTexture(nil, "BACKGROUND")
        colorswatch.checkers:SetWidth(size * 0.75)
        colorswatch.checkers:SetHeight(size * 0.75)
        colorswatch.checkers:SetTexture(188523) -- Tileset\\Generic\\Checkers
        colorswatch.checkers:SetTexCoord(.25, 0, 0.5, .25)
        colorswatch.checkers:SetDesaturated(true)
        colorswatch.checkers:SetVertexColor(1, 1, 1, 0.75)
        colorswatch.checkers:SetPoint("CENTER")
    end

    -- Save old disable/enable handlers.
    colorswatch.oldDisableHandler = colorswatch.Disable
    colorswatch.oldEnableHandler = colorswatch.Enable

    -- Extension functions.
    colorswatch.SetColor                = ColorSwatch_SetColor
    colorswatch.GetColor                = ColorSwatch_GetColor
    colorswatch.SetColorChangedHandler  = ColorSwatch_SetColorChangedHandler
    colorswatch.SetTooltip              = ColorSwatch_SetTooltip
    colorswatch.Disable                 = ColorSwatch_Disable
    colorswatch.Enable                  = ColorSwatch_Enable
    colorswatch.CloseColorPicker        = ColorSwatch_CloseColorPicker

    -- Finish.
    return colorswatch
end


--#############################################################################
-------------------------------------------------------------------------------
-- TextScrollFrame functions.
-------------------------------------------------------------------------------
--#############################################################################


-- ****************************************************************************
-- Creates and returns a scrollable text frame object.
-- ****************************************************************************
local function CreateTextScrollFrame(parent, title, width, height)  --DJUadded
    parent = parent or UIParent
    width = width or 400
    height = height or 600

    local margin = 9

    -----------------------------
    -- Create a container frame.
    -----------------------------
    local containerFrame = CreateFrame("frame", nil, parent) ----, "BackdropTemplate")
    ----containerFrame:Hide()
    containerFrame:SetFrameStrata("DIALOG")
    containerFrame:SetFrameLevel(10)
    ----containerFrame:SetToplevel(true)
    containerFrame:EnableMouse(true)  -- Prevents clicking thru this frame and triggering things beneath it.
    containerFrame:SetPoint("CENTER")
    containerFrame:SetWidth(width)
    containerFrame:SetHeight(height)
    ----containerFrame:SetBackdropColor(0,0,0, 1)

    -- Create dark marbled background.
    containerFrame.bg = containerFrame:CreateTexture(nil, "BACKGROUND") ----, "BackdropTemplate")
    containerFrame.bg:SetPoint("TOPLEFT", 1, -1)
    containerFrame.bg:SetPoint("BOTTOMRIGHT", -1, 1)
    containerFrame.bg:SetTexture("Interface\\FrameGeneral\\UI-Background-Marble", true, true)
    ----containerFrame.bg:SetColorTexture(0, 0, 0, 1) -- Black

    containerFrame.bg:SetHorizTile(true)
    containerFrame.bg:SetVertTile(true)
    ----containerFrame.bg:SetBackdropColor(0,0,0, 1)

    -- Create border around the edges.
    for k, v in pairs({
            {"UI-Frame-InnerTopLeft", "TOPLEFT", 0, 0},
            {"UI-Frame-InnerTopRight", "TOPRIGHT", 0, 0},
            {"UI-Frame-InnerBotLeftCorner", "BOTTOMLEFT", 0, 0},
            {"UI-Frame-InnerBotRight", "BOTTOMRIGHT", 0, 0},
            {"_UI-Frame-InnerTopTile", "TOPLEFT", 6, 0, "TOPRIGHT", -6, 0},
            {"_UI-Frame-InnerBotTile", "BOTTOMLEFT", 6, 0, "BOTTOMRIGHT", -6, 0},
            {"!UI-Frame-InnerLeftTile", "TOPLEFT", 0, -6, "BOTTOMLEFT", 0, 6},
            {"!UI-Frame-InnerRightTile", "TOPRIGHT", 0, -6, "BOTTOMRIGHT", 0, 6}
            }) do
        local border = containerFrame:CreateTexture(nil, "BORDER", v[1])
        border:ClearAllPoints()
        border:SetPoint( v[2], v[3], v[4] )
        if v[5] then border:SetPoint( v[5], v[6], v[7] ) end
    end

    -- Create title banner.
    if title then
        containerFrame.title = containerFrame:CreateFontString("ARTWORK", nil, "SplashHeaderFont")  -- "GameFontNormalLarge"?
        containerFrame.title:SetPoint("TOP", 0, -margin-1)
        ----local titleFont = containerFrame.title:GetFontObject()
        ----titleFont:SetTextColor(1,1,1)
        ----titleFont:SetShadowColor(0,0,1)
        containerFrame.title:SetText(title)
    end

    -- Create CLOSE button.

    containerFrame.closeBtn = CreateFrame("Button", nil, containerFrame, kButtonTemplate)
    containerFrame.closeBtn:SetText("Close")
    containerFrame.closeBtn:SetPoint("BOTTOM", 0, 12)
    containerFrame.closeBtn:SetSize(width/3, 24)
    containerFrame.closeBtn:SetScript("OnClick", function(self) self:GetParent():Hide() end)

    -----------------------------------------------------------------
    -- Create a scroll frame (view port) inside the container frame.
    -----------------------------------------------------------------

    -- Create the scrolling parent frame and size it to fit inside the texture.
    containerFrame.scrollFrame = CreateFrame("ScrollFrame", nil, containerFrame, "UIPanelScrollFrameTemplate")
    if containerFrame.title then
        containerFrame.scrollFrame:SetPoint("TOP", containerFrame.title, "BOTTOM", 0, -8)
    else
        containerFrame.scrollFrame:SetPoint("TOP", containerFrame, "TOP", 0, -margin)
    end
    containerFrame.scrollFrame:SetPoint("LEFT", margin, 0)
    containerFrame.scrollFrame:SetPoint("BOTTOM", containerFrame.closeBtn, "TOP", 0, margin*0.6)
    containerFrame.scrollFrame:SetPoint("RIGHT", -23, 0)

    containerFrame.scrollFrame.ScrollBar:ClearAllPoints()
	containerFrame.scrollFrame.ScrollBar:SetPoint("TOPLEFT", containerFrame.scrollFrame, "TOPRIGHT", 2, -17)
	containerFrame.scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", containerFrame.scrollFrame, "BOTTOMRIGHT", 18, 16)

    containerFrame.scrollFrame.ScrollBar.texture = containerFrame.scrollFrame.ScrollBar:CreateTexture(nil, "BACKGROUND")
    containerFrame.scrollFrame.ScrollBar.texture:SetPoint("TOPLEFT", 0, -4)
    containerFrame.scrollFrame.ScrollBar.texture:SetPoint("BOTTOMRIGHT", -1, 5)
    containerFrame.scrollFrame.ScrollBar.texture:SetColorTexture(0.08, 0.08, 0.08, 0.5)

    ----containerFrame.scrollFrame:SetScript("OnMouseWheel", function(self, delta)
    ----        -- Customize mouse wheel scroll speed.
    ----        local newValue = self:GetVerticalScroll() - (delta * 20) -- Larger delta multiplier speeds up scrolling.
    ----        if (newValue < 0) then newValue = 0
    ----        elseif (newValue > self:GetVerticalScrollRange()) then newValue = self:GetVerticalScrollRange()
    ----        end
    ----        self:SetVerticalScroll(newValue)
    ----    end)

    -- Create the scrolling child frame, set its width to fit, and give it an arbitrary minimum height of 1.
    containerFrame.scrollChild = CreateFrame("Frame", nil, containerFrame.scrollFrame)
    containerFrame.scrollChild:SetWidth( containerFrame:GetWidth()-18 )
    containerFrame.scrollChild:SetHeight( 1 )  -- Specifies an arbitrary minimum height.
    containerFrame.scrollChild.bg = containerFrame.scrollChild:CreateTexture(nil, "BACKGROUND")
    containerFrame.scrollChild.bg:SetAllPoints(containerFrame.scrollFrame, true)
    containerFrame.scrollChild.bg:SetColorTexture(0.6, 0.3, 0.0, 0.13)  -- R, G, B, a
    containerFrame.scrollFrame:SetScrollChild( containerFrame.scrollChild )

    ------------------------
    -- Extension functions.
    ------------------------

    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
    -- AddText(text, dx, dy, fontName):
    --      'dx' and 'dy' must be positive!
    --      Note: You can change color of text parts using the "|cAARRGGBB...|r" syntax.
    containerFrame.strings = {}
    containerFrame.nextVertPos = 0  -- # of pixels from the top to add the next text string.
    containerFrame.AddText = function(self, text, dx, dy, fontName)
            assert(type(self) == "table")  -- Fails if this function is called using a dot instead of a colon.
            dx = dx or 0
            assert(dx >= 0)
            dy = dy or 1
            assert(dy >= 0)

            local numStrings = #containerFrame.strings
            numStrings = numStrings + 1
            local str = self.scrollChild:CreateFontString("ARTWORK", nil, fontName or "GameFontNormal")
            str:SetJustifyH("LEFT")  -- Required when using carriage returns or wordwrap.
            str:SetText(text)
            str:SetPoint("LEFT", dx+2, 0)
            str:SetPoint("RIGHT", -20, 0)
            if (numStrings > 1) then
                str:SetPoint("TOP", self.strings[numStrings-1], "BOTTOM", 0, -dy)
            else -- It's the first string to be added.
                str:SetPoint("TOP", self.scrollChild, "TOP", 0, -dy)
            end
            str.verticalScrollPos = self.nextVertPos
            self.nextVertPos = self.nextVertPos + str:GetHeight() + dy
            self.strings[numStrings] = str  -- Store this string.

            return str  -- Return the font string so it can be customized.
        end

    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
    -- GetNextVerticalPosition():
    -- Returns vertical position (in pixels) of where the next line will be added by AddText().
    containerFrame.GetNextVerticalPosition = function(self)
            return self.nextVertPos
        end

    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
    -- SetVerticalScroll(offsetInPixels):
    -- Scrolls to 'offsetInPixels' from the top.  'offsetInPixels' must be positive!
    containerFrame.SetVerticalScroll = function(self, offsetInPixels)
            assert(type(self) == "table")  -- Fails if this function is called using a dot instead of a colon.
            assert(offsetInPixels >= 0)
            local delaySecs = 0.1
            if (GetTime() - self.creationTime < delaySecs and offsetInPixels > 0) then
                -- Must delay executing this function until 0.1 secs after the control
                -- was created.  Otherwise, the scrollbar's thumb position and/or the
                -- control's contents do not scroll correctly.
                C_Timer.After(delaySecs, function() self:SetVerticalScroll(offsetInPixels) end)
            else
                -- Scroll to the specified offset.
                self.scrollFrame:SetVerticalScroll(offsetInPixels)
            end
        end

    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
    -- SetScrollTextBackColor(r, g, b, alpha):
    containerFrame.SetScrollTextBackColor = function(self, r, g, b, alpha)
            assert(type(self) == "table")  -- Fails if this function is called using a dot instead of a colon.
            self.scrollChild.bg:SetColorTexture(r, g, b, alpha)
        end

    -----------
    -- Finish.
    -----------
    containerFrame.creationTime = GetTime()
    return containerFrame
end


--#############################################################################
-------------------------------------------------------------------------------
-- GroupBox functions.
-------------------------------------------------------------------------------
--#############################################################################


-- ****************************************************************************
-- Make the title's background size the same as the current title's text size,
-- plus extra margin space along each edge (if specified).
-- Call this if title text is changed so title background size matches the text.
-- The margins parameter must be a table containing elements named left, right,
-- top, and bottom.  e.g.  {left=1, right=1, top=1, bottom=1}
-- ****************************************************************************
local function GroupBox_UpdateTitleSize(self, margins)
    assert(type(margins) == "table", "Expected a table for margins, got a ".. type(margins)..".")
    margins = margins or {}
    margins.left = margins.left or 0
    margins.right = margins.right or 0
    margins.top = margins.top or 0
    margins.bottom = margins.bottom or 0

    self.titleBackground:SetPoint("TOPLEFT", self.title, "TOPLEFT", -margins.left, margins.top)
    self.titleBackground:SetPoint("BOTTOMRIGHT", self.title, "BOTTOMRIGHT", margins.right, -margins.bottom)
end

-- ****************************************************************************
-- Change the title text's background color.
-- ****************************************************************************
local function GroupBox_SetTitleBackColor(self, r, g, b, alpha)
    if not self.titleBackground then
        self.titleBackground = self:CreateTexture()
        self.titleBackground:SetTexture("Interface\\Buttons\\WHITE8X8")
    end
    self.titleBackground:SetVertexColor(r, g, b, alpha)
    GroupBox_UpdateTitleSize(self, {left=1, right=1, top=1, bottom=1})  -- Make background size same as title size.
end

-- ****************************************************************************
-- Creates and returns a group box frame with the given title.
-- Set title to nil if you don't want title text for the groupbox.
-- Set width to nil to have the groupbox expand to the right edge of its parent (minus space for a margin).
-- Set height to nil to have the groupbox expand to the bottom of its parent (minus space for a margin).
-- ****************************************************************************
local function CreateGroupBox(title, anchor, parent, relativeAnchor, x, y, width, height)  --DJUadded
    ----local groupbox = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    ----groupbox:SetBackdrop{
    ----    bgFile ="Interface\\Buttons\\WHITE8X8",
    ----    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    ----    insets = {left=3, right=3, top=2, bottom=3},  edgeSize=12,
    ----}
    local groupbox = CreateFrame("Frame", nil, parent, kBoxTemplate)

    groupbox:SetPoint(anchor, parent, relativeAnchor, x, y)
    if (width and width > 0) then
        groupbox:SetWidth(width)
    else
        groupbox:SetPoint("RIGHT", -16, 0)
    end
    if (height and height > 0) then
        groupbox:SetHeight(height)
    else
        groupbox:SetPoint("BOTTOM", 0, -16)
    end

    if title then
        groupbox.title = groupbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        groupbox.title:SetPoint("TOPLEFT", 6, 12)
        groupbox.title:SetText(title or "")
    end

    -- Extension functions.
    groupbox.SetTitleBackColor  = GroupBox_SetTitleBackColor
    groupbox.UpdateTitleSize    = GroupBox_UpdateTitleSize

    return groupbox
end


--#############################################################################
-------------------------------------------------------------------------------
-- Exposed utility functions.
-------------------------------------------------------------------------------
--#############################################################################


-------------------------------------------------------------------------------
private.Controls.handleGlobalMouseClick = function(button)  --DJUadded
    -- Closes any open dropdown list if user clicks outside of it.
    -- Call this function from a GLOBAL_MOUSE_DOWN event handler in your addon.
    -- Based on \Interface\SharedXML\UIDropDownMenu.lua, UIDropDownMenu_HandleGlobalMouseEvent().
        if not gDropDownListBoxFrame or not gDropDownListBoxFrame:IsShown() then return end  -- Nothing to do.
        if button == nil or button == "LeftButton" then
            -- Did user click somewhere inside the dropdown or its listbox?  If so, exit.
            if gDropDownListBoxFrame:IsMouseOver() then return end
            if gDropDownListBoxFrame.dropdown and gDropDownListBoxFrame.dropdown:IsMouseOver() then return end
            -- Otherwise, user clicked outside of the dropdown.  Close its listbox.
            gDropDownListBoxFrame:Hide()
        end
    end
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
    -- NOTE: While the following line works nicely without an extra work needed from the addon using
    --       the dropdown in this file, I did not prefer using it because it is always called on every
    --       mouse click, even when the UI containing our dropdown isn't being displayed.  (And even if
    --       the UI doesn't contain any dropdown controls!)
    --       The more robust solution for closing dropdowns when users click outside of them, is to require
    --       addon developers to handle the GLOBAL_MOUSE_DOWN event and call handleGlobalMouseClick() in that
    --       event handler.  This approach permits registering the event when the UI is shown, and
    --       unregistering the event when the UI is closed.  Then mouse clicks are only causing extra
    --       work while the UI is open.  And if the UI doesn't use any dropdown controls, the addon developer
    --       can simply do nothing and not handle GLOBAL_MOUSE_DOWN events at all.
--~     hooksecurefunc("UIDropDownMenu_HandleGlobalMouseEvent", private.Controls.handleGlobalMouseClick)


-------------------------------------------------------------------------------
private.Controls.DisplayAllFonts = function(width, height)
        -- Create the fonts frame, if necessary.
        if (_G.FontNamesScrollFrame == nil) then
            _G.FontNamesScrollFrame = CreateTextScrollFrame(UIParent, "*** Available Game Fonts ***", width or 1000, height or 600)

            local fontNames = _G.GetFonts()
            table.sort(fontNames, function(name1, name2) return (name1 < name2); end)
            local name
            for i = 1, #fontNames do
                name = fontNames[i]
                if (name and type(name) == "string" ----and name ~= ""
                    and name ~= "ScrollingMessageFrame"
                    and name:sub(1, 6) ~= "table:"
                  ) then
                    ----print("DBG: fontNames["..i.."]:", name)
                    _G.FontNamesScrollFrame:AddText(name, nil, nil, name)
                end
            end    
        end
        
        -- Show the fonts frame.
        _G.FontNamesScrollFrame:Show()
    end

    
--#############################################################################
-------------------------------------------------------------------------------
-- Module interface.
-------------------------------------------------------------------------------
--#############################################################################


-- Exposed Functions.
private.Controls.CreateListBox          = CreateListBox
private.Controls.CreateCheckBox         = CreateCheckBox
private.Controls.CreateIconButton       = CreateIconButton
private.Controls.CreateSlider           = CreateSlider
private.Controls.CreateDropDown         = CreateDropDown
--~ private.Controls.CreateEditBox          = CreateEditBox
--~ private.Controls.CreateOptionButton     = CreateOptionButton
private.Controls.CreateColorSwatch      = CreateColorSwatch  --DJUadded
private.Controls.CreateTextScrollFrame  = CreateTextScrollFrame  --DJUadded
private.Controls.CreateGroupBox         = CreateGroupBox  --DJUadded

--- End of File ---