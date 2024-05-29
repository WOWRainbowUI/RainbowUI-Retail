local CONTROLS_VERSION = "2024-05-28"  -- Version (date) of this file.  Stored as "UDControls.VERSION".

--[[---------------------------------------------------------------------------
FILE:   UDControls.lua
DESC:   Adds functions to your addon's private data block that can be used
        to create various UI controls.
AUTHOR: UppyDan  (Credits: Large portions of this file are based on code from Mikord's "MSBT Options".)

REQUIREMENTS / DEPENDANCIES:
        The following files must be placed in your addon's folder ...
            - UDControls.lua
        Also, any icon artwork used in calls to CreateIconButton() must also
        be placed in your addon's folder.
        Finally, add UDControls.lua to your TOC file.

USAGE:  See examples at end of this comment block.
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
CHANGE HISTORY:
    May 28, 2024
        - Renamed this file to "UDControls.lua" (was "Controls.lua").
        - Added CONTROLS_VERSION, indicating the version (date) of this file.
        - Fixed dropdown height calculations so they no longer shrink so small they can't show any lines.
          (Occurred when the bottom of a dropdown menu went beyoond the bottom of the screen.)
        - Fixed dropdown menu tooltips.
        - Changed CreateGroupBox() title text to be left-justified.
        - Added CreateTextureButton().
        - Made CreateOptionButton() available.  Added an example for it.
        - Added tooltipAnchor to option buttons returned by CreateOptionButton().
        - Changed msgBox() default preferred index from 3 to 1.
        - Updated comments and examples.
        - Added CreateTexture_NEW(), CreateHorizontalDivider(), and TextSize object.
        - Added a close [X] button to the frame created by CreateTextScrollFrame().
        - Added support for right-clicking listbox lines.  See RegisterForClicks() in the listbox example.
        - Fixed minor problems with listbox scrollbars, including using mousewheel over them.
        - Changed ListBox_OnMouseWheel() so it scrolls by the slider's step size when it's changed to
          a value greater than one.  Otherwise, mousewheel scrolls by page size (as it did previously).
        - Added ListBox_SelectNextItem() and ListBox_SelectPreviousItem().
        - Removed Enable/Disable functions from the listbox.  Those functions are not working correctly,
          and are not necessary at the moment.
    Mar 06, 2024
        - Added SetBackColor()/GetBackColor() to the groupbox control, for changing its background color.
        - Added MsgBox().
        - Added a parameter to DropDown_Sort() for optionally sorting while ignoring upper/lower case.
        - Fixed listbox so hovering or clicking over empty lines at the bottom of it do nothing, especially
          if another frame underneath the listbox processes "OnEnter", "OnLeave", or "OnClick" events.
        - Fixed ListBox_SelectItem() so the lower bounds no longer can be a negative number.
        - Fixed bugs in code and examples where CreateFontString() parameters were in the wrong order.
        - Updated listbox comments to include GetSelectedItemNumber() as an available function.
        - Added ListBox_SelectItemText() and ListBox_ClearSelection().
        - Updated local aliases to certain global variables for faster access to them.
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
        CreateOptionButton()    - Returns a standard button frame.
        CreateSlider()          - Returns a Slider object.
        CreateTextScrollFrame() - Returns a TextScrollFrame object.
        CreateTextureButton()   - Returns a standard button frame.
        DisplayAllFonts()       - Creates and shows a window of all game fonts. (For development use.)

        handleGlobalMouseClick() - (OPTIONAL) Register your addon for the GLOBAL_MOUSE_DOWN event, and
                                  call this function when it occurs.  Do this to close a dropdown when
                                  users click somewhere else while it is open.  (See dropdown example.)
                                  Ideally, register this event when your UI is shown, and unregister it
                                  when your UI is closed.  This will minimize event handling to just
                                  while the UI is open.
        MsgBox()                - Shows a window that displays a text message and up to two buttons
                                  with corresponding handler functions that can process custom data.

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
        checkButton
        checkButton.tooltip             - Text to show when mouse is over this control.
        checkButton.tooltipAnchor       - Defaults to "ANCHOR_RIGHT".
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
        tooltip             - Text to show when mouse is over this control.
        tooltipAnchor       - Defaults to "ANCHOR_RIGHT".

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
        tooltip             - Text to show when mouse is over this control (excluding the popup list of choices).
        tooltipAnchor       - Defaults to "ANCHOR_RIGHT".

~~~~~~~~~~~~~~~
   ListBox
~~~~~~~~~~~~~~~

    Functions:
        AddItem( text, bScrollIntoView )
        Clear()
        ClearSelection()
        Configure()
        Disable()
        Enable()
        GetItem()
        GetLine()
        GetNumItems()
        GetNumLines()
        GetOffset()
        GetSelectedItem()   - Returns selected item (text).
        GetSelectedItemNumber() - Returns the selected line number.
        Refresh()
        RemoveItem()
        SetClickHandler( func )
        SetCreateLineHandler( func )
        SetDisplayHandler( func )
        SetOffset()
        SelectItem( itemNumber, bScrollIntoView )  - Selects the specified item number.
        SelectItemText( text, bScrollIntoView )    - Selects the item matching the specified text.
        SelectNextItem()
        SelectPreviousItem()

    Callbacks:
        clickHandler()      - Called when a line in the listbox is clicked.
        displayHandler()    - Called when a line is being displayed.
        lineHandler()       - Called when a new line needs to be created.

    Variables:
        displayFrame        - Area where listbox contents is displayed.  (Excludes scrollbar.)
        sliderFrame         - Scrollbar for the listbox.
        upButton            - Scrollbar's up button.
        downButton          - Scrollbar's down button.
        highlightFrame      - For highlighting the selected line.
        items               - All the data that can be displayed by the listbox.
        lines               - The data lines that are visible (within the height of the listbox).
        lineCache           - Contains lines that that will no longer fit on the page because the listbox
                              height was reduced.  These lines get reused the next time a new line is "created".
        selectedItem        - Selected item's index #.

~~~~~~~~~~~~~~~~~~~~~
    Option Button
~~~~~~~~~~~~~~~~~~~~~

    Functions:
        Configure()         - Sets the button's height, text, and optional tooltip.
        SetClickHandler()
        SetLabel()          - Sets the button's text.
        SetTooltip()

    Variables:
        tooltipAnchor       - Defaults to "ANCHOR_RIGHT".

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
        sliderFrame.tooltip         - Text to show when mouse is over this control.
        sliderFrame.tooltipAnchor   - Defaults to "ANCHOR_RIGHT".
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
        GetBackColor
        SetBackColor
        SetTitleBackColor
        UpdateTitleSize

    Variables:
        background
        title
        titleBackground


=================================[ EXAMPLES ]==================================
~~~~~~~~~~~~~~~~~~
 CheckBox Example
~~~~~~~~~~~~~~~~~~

    local kAddonFolderName, private = ...  -- First line of LUA file that will use these controls.
        .                                  -- (The variable names can be changed to anything you like.)
        .
        .

    local checkbox = private.UDControls.CreateCheckBox( YourOptionsFrame, "GameFontNormal" )
    checkbox:SetLabel("An example of a checkbox option.")
    checkbox:SetTooltip("Click me to change my value!")
    checkbox:SetPoint("TOPLEFT", YourOptionsFrame, "TOPLEFT", 10, -10)
    checkbox:SetPoint("RIGHT", YourOptionsFrame, "RIGHT", -10, 0)
    checkbox:SetClickHandler( function(thisCheckBox, isChecked)
                print( thisCheckBox.fontString:GetText() .." -->", isChecked and "ON" or "OFF" )
            end)

    checkbox:SetChecked(true)  -- Set its default state.


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

    local colorswatch = private.UDControls.CreateColorSwatch( YourOptionsFrame )
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
            private.UDControls.handleGlobalMouseClick(button)
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

    local dropdown = private.UDControls.CreateDropDown(YourOptionsFrame)
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
    dropdown.tooltip = "Some helpful info about this dropdown menu."
    dropdown.tooltipAnchor = "ANCHOR_TOP"  -- (Optional)

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

    local groupbox = private.UDControls.CreateGroupBox("Options", "TOPLEFT", YourOptionsFrame, "TOPLEFT", x, y, width, height)
    groupbox:SetBackColor(0.0, 0.0, 0.2, 1.0)   -- (Optional) Change groupbox background color.
    groupbox:SetBackdropBorderColor(0.6 ,0.6, 0.6) -- (Optional) Darken the border edges.
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
    local listboxH = (listboxLineH * listboxLinesPerPage) + 5

    -- - - - - - - - - - - - - - - - - - - - - - - - - - --
    local function listboxCreateLine(thisLB)
        local line = CreateFrame("Button", nil, thisLB)
        line.parentListBox = thisLB
        line:RegisterForClicks("LeftButtonUp", "RightButtonUp")  -- Allow left and right mouse clicks.
        line.tooltip = "Some useful info about this line."  -- Example of how to simulate ListBox_SetToolTip().
        line.tooltipAnchor = "ANCHOR_LEFT"  -- (Optional)

        -- Text.
        line.fontString = line:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        line.fontString:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        line.fontString:SetJustifyH("LEFT")
        line.fontString:SetPoint("LEFT", line, "LEFT", 4, 0)
        line.fontString:SetPoint("RIGHT", line, "RIGHT")
        line.fontString:SetPoint("TOP", line, "TOP")
        line.fontString:SetPoint("BOTTOM", line, "BOTTOM")

        -- (OPTIONAL) "Delete Item" button.
        local iconPath = "Interface\\Addons\\" .. kAddonFolderName .. "\\Media\\"
        line.deleteBtn = private.UDControls.CreateIconButton(line, listboxLineH-8, iconPath, "DeleteIcon", "DeleteIconHighlight")
        -- NOTE: Alternatively, you could call CreateTextureButton() in the previous line instead of CreateIconButton().
        line.deleteBtn:SetTooltip("Click to delete the item.")
        local rightInset = -3
        line.deleteBtn:SetHitRectInsets(0, rightInset, 0, 0)  -- (Left, Right, Top, Bottom)
        line.deleteBtn:SetPoint("RIGHT", line, "RIGHT", rightInset, 0)
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
    local function listboxOnClickLine(thisLB, line, value, mouseButton)
        if mouseButton == "LeftButton" then
            thisLB.SelectItem(value)
            print("Selected listbox item:", value)
        end
    end
    -- - - - - - - - - - - - - - - - - - - - - - - - - - --

    -- Create listbox.
    local listbox = private.UDControls.CreateListBox(YourOptionsFrame)
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


~~~~~~~~~~~~~~~~
 MsgBox Example
~~~~~~~~~~~~~~~~
    See the examples documented in the implementation of MsgBox().


~~~~~~~~~~~~~~~~~~~~~~~
 Option Button Example
~~~~~~~~~~~~~~~~~~~~~~~
    Note: An option button is a basic red button with yellow text (and optional tooltip).

    local optionBtn = private.UDControls.CreateOptionButton(YourOptionsFrame)
    optionBtn:Configure(24, "OB Text", "Optional OB Tooltip")
    optionBtn.tooltipAnchor = "ANCHOR_TOP"  -- (Optional)
    optionBtn:SetPoint("TOPLEFT", YourOptionsFrame, "TOPLEFT", 10, 10)
    optionBtn:RegisterForClicks("AnyDown", "AnyUp")  -- (Optional)
    optionBtn:SetClickHandler( function(self, mouseButton, bDown)
            print("Option button clicked.  (", mouseButton, bDown and "DOWN" or "UP", ")")
        end)


~~~~~~~~~~~~~~~~~~~~~~~~~
 TextScrollFrame Example
~~~~~~~~~~~~~~~~~~~~~~~~~

    local kAddonFolderName, private = ...  -- First line of LUA file that will use these controls.
        .                                  -- (The variable names can be changed to anything you like.)
        .
        .

    local tsf = private.UDControls.CreateTextScrollFrame(YourOptionsFrame, "*** Scroll Window Test ***", 333)

    local title = tsf.scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -4)
    title:SetText("General Info")

    local firstLine = tsf.scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    firstLine:SetPoint("TOP", title, "BOTTOM", 0, -1)
    firstLine:SetJustifyH("LEFT")  -- Specify this when using text with carriage returns in it.
    firstLine:SetText("This is the first line.\n  (Scroll way down to see the last!)")

    local footer = tsf.scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
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
if private.UDControls then return end  -- Prevent multiple includes of this file.
private.UDControls = {}


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
local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
local GetBuildInfo = GetBuildInfo
local GetTime = GetTime
local HIGHLIGHT_FONT_COLOR = HIGHLIGHT_FONT_COLOR
local InCombatLockdown = InCombatLockdown
local ipairs = ipairs
local math = math
local next = next
local NORMAL_FONT_COLOR = NORMAL_FONT_COLOR
local OpacityFrameSlider = OpacityFrameSlider  -- WoW 10.2.5 and newer.
local OpacitySliderFrame = OpacitySliderFrame  -- WoW 10.2 and older.
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


-------------------------------------------------------------------------------
--[[                        Development Switches                             ]]
-------------------------------------------------------------------------------

----> Enable next 2 lines to find missing aliases to global things.  Reload afterwards to trigger errors.
--~     local _G = _G
--~     setfenv(1, private)  -- Everything after this uses our namespace rather than _G.


--#############################################################################
-------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------
--#############################################################################

-- Templates compatible with all versions of WoW.
local kGameTocVersion = select(4, GetBuildInfo())
local function isRetailWoW() return (kGameTocVersion >= 100000) end
local kButtonTemplate = ((kGameTocVersion >= 100000) and "UIPanelButtonTemplate") or "OptionsButtonTemplate"
local kBoxTemplate = ((kGameTocVersion >= 100000) and "TooltipBorderBackdropTemplate") or "OptionsBoxTemplate"
local kMinVer_10_2_5 = (kGameTocVersion >= 100205)  -- WoW 10.2.5 or newer?

-- Backdrop table to be reused for sliders.
local gSliderBackdrop

-- Emphasis shown when a listbox entry is moused over.
local gEmphasizeFrame

-- Container frame holding the listbox used by all dropdown controls.
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

-- Misc constants.
local kTexture_White8x8 = "Interface\\Buttons\\WHITE8X8"
local kScrollbarGlitchTime = 0.01 -- secs

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
local function ListBox_ShowHighlight(thisLB, line)
    local highlight = thisLB.highlightFrame
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
local function ListBox_ShowHideScrollBar(thisLB)
    -- Show or hide the scroll bar if there are more items than will fit on the page.
    local display = thisLB.displayFrame
    local slider = thisLB.sliderFrame
    local dx = -1*slider:GetWidth()
    if not thisLB.bHideBorder then  -- Showing listbox border?
        dx = dx - (2*thisLB.margin)
    end

    if (#thisLB.items <= #thisLB.lines) then
        slider:Hide()
        display:SetPoint("BOTTOMRIGHT")
    else
        --DJUremoved:  display:SetPoint("BOTTOMRIGHT", display:GetParent(), "BOTTOMRIGHT", dx, 0)
        display:SetPoint("BOTTOMRIGHT", thisLB, "BOTTOMRIGHT", dx, 0)  --DJUchanged (see previous line)
        slider:Show()
    end
end


-- ****************************************************************************
-- Returns whether the listbox is fully configured.
-- ****************************************************************************
local function ListBox_IsConfigured(thisLB)
    return thisLB.configured and thisLB.lineHandler and thisLB.displayHandler
end


-- ****************************************************************************
-- Returns the current offset.
-- ****************************************************************************
local function ListBox_GetOffset(thisLB)  -- Returned offset is 0-based.
    return math.floor( thisLB.sliderFrame:GetValue()+0.5 ) -- Round off in case SetObeyStepOnDrag(false) is set.  --DJUchanged
end


-- ****************************************************************************
-- Returns the current offset.
-- ****************************************************************************
local function ListBox_SetOffset(thisLB, offset)  -- 'offset' is 0-based.
    thisLB.sliderFrame:SetValue(offset)
end


-- ****************************************************************************
-- Called when the listbox needs to be refreshed.
-- ****************************************************************************
local function ListBox_Refresh(thisLB)
    -- Don't do anything if the listbox isn't configured.
    if (not ListBox_IsConfigured(thisLB)) then return end

    -- Handle scroll bar showing / resizing.
    ListBox_ShowHideScrollBar(thisLB)

    -- Hide the highlight.
    thisLB.highlightFrame:Hide()

    -- Show or hide the correct lines depending on how many items there are and
    -- apply a highlight to the selected item.
    local selectedItem = thisLB.selectedItem
    local isSelected
    for lineNum, line in ipairs(thisLB.lines) do
        if (lineNum > #thisLB.items) then
            line:Hide()
        else
            line.itemNumber = lineNum + ListBox_GetOffset(thisLB)
            line:Show()

            -- Move the highlight to the selected line and show it.
            if (selectedItem == line.itemNumber) then
                ListBox_ShowHighlight(thisLB, line)
                isSelected = true
            else
                isSelected = false
            end

            if (thisLB.displayHandler) then thisLB:displayHandler(line, thisLB.items[line.itemNumber], isSelected) end
        end
    end

    ----if thisLB.bMoreIndicators then  --DJUadded...
    ----    local scrollPos = thisLB.sliderFrame:GetValue()
    ----    local minPos, maxPos = thisLB.sliderFrame:GetMinMaxValues()
    ----    thisLB.moreAbove:SetShown( scrollPos > minPos )
    ----    thisLB.moreBelow:SetShown( scrollPos < maxPos )
    ----end
end


-- ****************************************************************************
-- Called when the listbox is scrolled up.
-- ****************************************************************************
local function ListBox_ScrollUp(thisLB)
    local slider = thisLB.sliderFrame
    slider:SetValue(slider:GetValue() - slider:GetValueStep())
end


-- ****************************************************************************
-- Called when the listbox is scrolled down.
-- ****************************************************************************
local function ListBox_ScrollDown(thisLB)
    local slider = thisLB.sliderFrame
    slider:SetValue(slider:GetValue() + slider:GetValueStep())
end


-- ****************************************************************************
-- Called when one of the lines in the listbox is clicked.
-- ****************************************************************************
local function ListBox_OnClickLine(thisLine, mouseButton)  --DJUchanged
    local listbox = thisLine:GetParent():GetParent()
    listbox.selectedItem = thisLine.lineNumber + ListBox_GetOffset(listbox)

    ListBox_ShowHighlight(listbox, thisLine)

    if (listbox.clickHandler) then
        listbox:clickHandler( thisLine, listbox.items[listbox.selectedItem], mouseButton )
    end
end


-- ****************************************************************************
-- Called when the mouse enters a line.
-- ****************************************************************************
local function ListBox_OnEnterLine(thisLine)
    local listbox = thisLine:GetParent():GetParent()
    if (thisLine.itemNumber ~= listbox.selectedItem) then
        gEmphasizeFrame:ClearAllPoints()
        gEmphasizeFrame:SetParent(thisLine)
        gEmphasizeFrame:SetPoint("TOPLEFT")
        gEmphasizeFrame:SetPoint("BOTTOMRIGHT")
        gEmphasizeFrame:Show()
    end

    if (thisLine.tooltip) then
        GameTooltip:SetOwner(thisLine, thisLine.tooltipAnchor or "ANCHOR_RIGHT")
        GameTooltip:SetText(thisLine.tooltip, nil, nil, nil, nil, 1)
    end
end


-- ****************************************************************************
-- Called when the mouse leaves a line.
-- ****************************************************************************
local function ListBox_OnLeaveLine(thisLine)
    gEmphasizeFrame:Hide()
    GameTooltip:Hide()
end


-- ****************************************************************************
-- Called when the scroll up button is pressed.
-- ****************************************************************************
local function ListBox_OnClickUp(thisLine)
    local listbox = thisLine:GetParent():GetParent()
    ListBox_ScrollUp(listbox)
    PlaySound(826)
end


-- ****************************************************************************
-- Called when the scroll down button is pressed.
-- ****************************************************************************
local function ListBox_OnClickDown(thisLine)
    local listbox = thisLine:GetParent():GetParent()
    ListBox_ScrollDown(listbox)
    PlaySound(827)
end


-- ****************************************************************************
-- Called when the mouse wheel is scrolled in the display frame.
-- ****************************************************************************
local function ListBox_OnMouseWheel(thisDisplay, delta)
    local listbox = thisDisplay:GetParent()
    local slider = listbox.sliderFrame  --DJUadded
    local scrollAmt = 1  --DJUadded
    if (slider:GetValueStep() == 1) then scrollAmt = math.max(1, listbox.linesPerPage-2) end  --DJUadded

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
local function ListBox_CreateLine(thisLB)
    -- Get a line from end of cache, if there are any.  Otherwise, call the
    -- registered line handler to create a new line.
    local lineCache = thisLB.lineCache
    local line = (#lineCache > 0) and table.remove(lineCache) or thisLB:lineHandler()

    line:SetParent(thisLB.displayFrame)
    line:SetHeight(thisLB.lineHeight)
    line:ClearAllPoints()
    ----line:RegisterForClicks("LeftButtonUp", "RightButtonUp")   --DJUadded
    line:SetScript("OnClick", ListBox_OnClickLine)
    line:SetScript("OnEnter", ListBox_OnEnterLine)
    line:SetScript("OnLeave", ListBox_OnLeaveLine)

    local lines = thisLB.lines
    if (#lines == 0) then
        line:SetPoint("TOPLEFT", 0, -thisLB.margin)  --DJUchanged
        line:SetPoint("TOPRIGHT", 0, -thisLB.margin)  --DJUchanged
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
local function ListBox_Reconfigure(thisLB, width, height, lineHeight)
    -- Don't allow negative widths.
    if (width < 0) then width = 0 end

    -- Setup container frame.
    thisLB:SetWidth(width)
    thisLB:SetHeight(height)

    -- Setup line calculations.
    thisLB.lineHeight = lineHeight
    thisLB.linesPerPage = math.floor(height / lineHeight)

    -- Resize the line height of existing lines.
    for _, line in ipairs(thisLB.lines) do
        line:SetHeight(thisLB.lineHeight)
    end

    -- Add lines if more will fit on the page and they are needed.
    local lines = thisLB.lines
    if (#thisLB.items > #lines) then
        while (#lines < thisLB.linesPerPage and #thisLB.items > #lines) do
            ListBox_CreateLine(thisLB)
        end
    end

    -- Remove and cache lines that will no longer fit on the page.
    local lineCache = thisLB.lineCache
    for x = thisLB.linesPerPage+1, #lines do
        lines[#lines]:Hide()
        lineCache[#lineCache+1] = table.remove(lines)
    end

    -- Setup slider frame.
    local slider = thisLB.sliderFrame
    slider:Hide()
    slider:SetMinMaxValues(0, math.max(#thisLB.items - #thisLB.lines, 0))
    slider:SetValue(0)

    ListBox_Refresh(thisLB)
end


-- ****************************************************************************
-- Configures the listbox.
-- ****************************************************************************
local function ListBox_Configure(thisLB, width, height, lineHeight)
    -- Don't do anything if required parameters are invalid.
    if (not width or not height or not lineHeight) then return end

    if (ListBox_IsConfigured(thisLB)) then ListBox_Reconfigure(thisLB, width, height, lineHeight) return end

    -- Don't allow negative widths.
    if (width < 0) then width = 0 end

    -- Setup container frame.
    thisLB:SetWidth(width)
    thisLB:SetHeight(height)

    -- Setup slider frame.
    local slider = thisLB.sliderFrame
    slider:SetMinMaxValues(0, 0)
    slider:SetValue(0)

    -- Setup line calculations.
    thisLB.lineHeight = lineHeight
    thisLB.linesPerPage = math.floor(height / lineHeight)

    thisLB.configured = true
end


-- ****************************************************************************
-- Set the function to be called when a new line needs to be created.  The
-- called function must return a "Button" frame.
-- ****************************************************************************
local function ListBox_SetCreateLineHandler(thisLB, handler)
    thisLB.lineHandler = handler
end


-- ****************************************************************************
-- Set the function to be called when a line is being displayed.
-- It is passed the line frame to be populated, and the value associated
-- with that line.
-- ****************************************************************************
local function ListBox_SetDisplayHandler(thisLB, handler)
    thisLB.displayHandler = handler
end


-- ****************************************************************************
-- Set the function to be called when a line in the listbox is clicked.
-- It is passed the line frame, and the value associated with that line.
-- ****************************************************************************
local function ListBox_SetClickHandler(thisLB, handler)
    thisLB.clickHandler = handler
end


-- ****************************************************************************
-- Adds the passed item to the listbox.
-- ****************************************************************************
local function ListBox_AddItem(thisLB, newItem, bScrollIntoView)
    -- Don't do anything if the listbox isn't configured.
    if (not ListBox_IsConfigured(thisLB)) then return end

    -- Add the passed item to the items list.
    local items = thisLB.items
    items[#items + 1] = newItem

    --  Create a new line if the max number allowed per page hasn't been reached.
    local lines = thisLB.lines
    if (#lines < thisLB.linesPerPage) then
        ListBox_CreateLine(thisLB)
    end

    -- Set the new max offset value.
    local maxOffset = math.max(#items - #lines, 0)
    thisLB.sliderFrame:SetMinMaxValues(0, maxOffset)

    -- Make sure the newly added item is visible if the force flag is set.
    if (bScrollIntoView) then ListBox_SetOffset(thisLB, maxOffset) end

    ListBox_Refresh(thisLB)
end


-- ****************************************************************************
-- Removes the passed item number from the listbox.
-- ****************************************************************************
local function ListBox_RemoveItem(thisLB, itemNumber)
    -- Don't do anything if the listbox isn't configured.
    if (not ListBox_IsConfigured(thisLB)) then return end

    local items = thisLB.items
    table.remove(items, itemNumber)

    -- Set the new max offset value.
    thisLB.sliderFrame:SetMinMaxValues(0, math.max(#items - #thisLB.lines, 0))

    ListBox_Refresh(thisLB)
end


-- ****************************************************************************
-- Returns the number of items in the listbox.
-- ****************************************************************************
local function ListBox_GetNumItems(thisLB)
    return #thisLB.items
end


-- ****************************************************************************
-- Returns the number of visible lines in the listbox.
-- ****************************************************************************
local function ListBox_GetNumLines(thisLB)
    return math.min(#thisLB.lines, #thisLB.items)
end


-- ****************************************************************************
-- Sets the listbox offset so that the selected item is shown.
-- ****************************************************************************
local function ListBox_ScrollSelectionIntoView(thisLB)  --DJUadded
    ----local delaySecs = 0.1
    ----if GetTime() - thisLB.creationTime < delaySecs then
    ----    -- Must delay executing this function until 0.1 secs after the listbox
    ----    -- was created.  Otherwise, the scrollbar's thumb position and/or listbox
    ----    -- contents do not scroll correctly.
    ----    C_Timer.After(delaySecs, function() ListBox_ScrollSelectionIntoView(thisLB) end)
    ----    return  -- Stop here.
    ----end

    ----for i, line in ipairs(thisLB.lines) do
    ----    if line:IsShown() and line.itemNumber == thisLB.selectedItem then
    ----        return  -- Done.  Line is already in view.
    ----    end
    ----end

    local lineNum = thisLB.selectedItem - ListBox_GetOffset(thisLB)
    if not thisLB.lines[lineNum] then
        ListBox_SetOffset(thisLB, thisLB.selectedItem - #thisLB.lines)
        ListBox_Refresh(thisLB)

        -- This next part fixes a glitch where the scrollbar's thumb position was sometimes below the scrollbar.
        if thisLB.sliderFrame:IsShown() and not thisLB.bGlitchFixed then  -- Only need to do this once.
            thisLB.bGlitchFixed = true
            local temp = thisLB.sliderFrame:GetValue()
            thisLB.sliderFrame:SetValue(0)
            C_Timer.After(kScrollbarGlitchTime, function() thisLB.sliderFrame:SetValue(temp) end) -- Restore pos.
        end
    end
end


-- ****************************************************************************
-- Selects the specified item number in the listbox.
-- If bCallClickHandler is true, this function also calls the listbox's click handler.
-- ****************************************************************************
local function ListBox_SelectItem(thisLB, itemNumber, bScrollIntoView, bCallClickHandler)  --DJUadded bScrollIntoView, bCallClickHandler.
    -- Don't do anything if the listbox isn't configured.
    if (not ListBox_IsConfigured(thisLB)) then return end

    itemNumber = itemNumber or 0  --DJUadded
    if type(itemNumber) ~= "number" then itemNumber = 0 end  --DJUadded

    --DJUremoved:  thisLB.selectedItem = itemNumber <= #thisLB.items and itemNumber or 0
    if itemNumber < 0 or itemNumber > #thisLB.items then itemNumber = 0 end  --DJUadded
    thisLB.selectedItem = itemNumber  --DJUadded

    if bScrollIntoView then ListBox_ScrollSelectionIntoView(thisLB) end  --DJUadded

    -- Highlight the selected line if it's visible.
    local line = thisLB.lines[thisLB.selectedItem - ListBox_GetOffset(thisLB)]
    if (line) then
        ListBox_ShowHighlight(thisLB, line)

        -- Call click handler.
        if bCallClickHandler and thisLB.clickHandler then  --DJUadded
            thisLB:clickHandler(line, thisLB.items[thisLB.selectedItem], "LeftButton")  --DJUadded
        end
    end
end


-- ****************************************************************************
-- Clears the listbox selection (so nothing is selected).
-- ****************************************************************************
local function ListBox_ClearSelection(thisLB)   --DJUadded
    ListBox_SelectItem(thisLB, 0)  -- Clears selection.
end


-- ****************************************************************************
-- Selects the specified item text in the listbox.
-- ****************************************************************************
local function ListBox_SelectItemText(thisLB, text, bScrollIntoView)  --DJUadded
    -- Don't do anything if the listbox isn't configured.
    if (not ListBox_IsConfigured(thisLB)) then return end

    if text then
        local items = thisLB.items
        for i = 1, #items do
            if items[i] == text then
                return ListBox_SelectItem(thisLB, i, bScrollIntoView) -- SUCCESS.
            end
        end
    end

    ListBox_ClearSelection(thisLB)
end


-- ****************************************************************************
-- Returns the item for the specified item number from the listbox.
-- ****************************************************************************
local function ListBox_GetItem(thisLB, itemNumber)
    return thisLB.items[itemNumber]
end


-- ****************************************************************************
-- Returns the selected item from the listbox.
-- ****************************************************************************
local function ListBox_GetSelectedItem(thisLB)
    if (thisLB.selectedItem ~= 0) then return thisLB.items[thisLB.selectedItem] end
end


-- ****************************************************************************
-- Returns the selected item number for the listbox.  (0 means nothing selected.)
-- ****************************************************************************
local function ListBox_GetSelectedItemNumber(thisLB)  --DJUadded
    return thisLB.selectedItem or 0
end


-- ****************************************************************************
-- Returns the specified line object from the listbox.
-- ****************************************************************************
local function ListBox_GetLine(thisLB, lineNumber)
    local lines = thisLB.lines
    if (lineNumber <= #lines) then return lines[lineNumber] end
end


-- ****************************************************************************
-- Selects item after the currently selected item and returns true.
-- Returns false if last item is already selected.
-- (Scrolls selected line into view if necessary.)
-- ****************************************************************************
local function ListBox_SelectNextItem(thisLB)  --DJUadded
    local itemNum = ListBox_GetSelectedItemNumber(thisLB)
    if itemNum < ListBox_GetNumItems(thisLB) then
        ListBox_SelectItem(thisLB, itemNum+1, true, true)  -- Scrolls into view and calls click handler.
        return true
    end
    return false
end


-- ****************************************************************************
-- Selects item before the currently selected item and returns true.
-- Returns false if first item is already selected.
-- (Scrolls selected line into view if necessary.)
-- ****************************************************************************
local function ListBox_SelectPreviousItem(thisLB)  --DJUadded
    local itemNum = ListBox_GetSelectedItemNumber(thisLB)
    if itemNum > 1 then
        ListBox_SelectItem(thisLB, itemNum-1, true, true)  -- Scrolls into view and calls click handler.
        return true
    end
    return false
end


-- ****************************************************************************
-- Clears the listbox contents.
-- ****************************************************************************
local function ListBox_Clear(thisLB)
    -- Don't do anything if the listbox isn't configured.
    if (not ListBox_IsConfigured(thisLB)) then return end

    local items = thisLB.items
    for k, v in ipairs(items) do
        items[k] = nil
    end

    thisLB.sliderFrame:SetMinMaxValues(0, 0)  -- Set the new max offset value.
    thisLB.selectedItem = 0
    ListBox_Refresh(thisLB)
end

---->>> DJUremoved.  These don't work right.  Would need to add calls to EnableMouse() for
----    the displayFrame, and calls to EnableMouseWheel() for the sliderFrame.  Additionally,
----    I think EnableMouseWheel() is needed on each line object, and possibly any icon buttons
----    the caller added to those lines.  A lot of work for a feature not needed at this time.
----    (IDEA: It might be easier to have a "blocker" frame that covers the listbox (to disable it.)
----
------ ****************************************************************************
------ Disables the listbox.
------ ****************************************************************************
----local function ListBox_Disable(thisLB)
----    thisLB.displayFrame:EnableMouseWheel(false)
----    thisLB.sliderFrame:EnableMouse(false)
----    thisLB.upButton:Disable()
----    thisLB.downButton:Disable()
----end
----
----
------ ****************************************************************************
------ Enables the listbox.
------ ****************************************************************************
----local function ListBox_Enable(thisLB)
----    thisLB.displayFrame:EnableMouseWheel(true)
----    thisLB.sliderFrame:EnableMouse(true)
----    thisLB.upButton:Enable()
----    thisLB.downButton:Enable()
----end


---->>> WORKS, but not really worth using more memory for this.
------ ****************************************************************************
------ Creates graphics for indicating more lines are above/below current scroll view.
------ Example (uses defaults):  listbox:SetIndicators( {} )
------ ****************************************************************************
----local function ListBox_SetIndicators(thisLB, options)  --DJUadded
----    if not options then
----        thisLB.bMoreIndicators = nil
----        if thisLB.moreAbove then thisLB.moreAbove:Hide() end
----        if thisLB.moreBelow then thisLB.moreBelow:Hide() end
----        return  -- Done.
----    end
----
----    thisLB.bMoreIndicators = true
----    local r, g, b, a = options.r or 0.7, options.g or 0.7, options.b or 0, options.a or 1
----    local thickness = options.thickness or 1
----    local inset = options.inset or 1
----    local halfLen = (options.length or 50) / 2
----
----    local dx = thisLB.sliderFrame:GetWidth() / 2 - 2
----    thisLB.moreAbove = thisLB.displayFrame:CreateLine(nil, "BACKGROUND", nil, 0)
----    thisLB.moreAbove:SetThickness(thickness)
----    thisLB.moreAbove:SetColorTexture(r, g, b, a)
----    thisLB.moreAbove:SetStartPoint("TOP", dx-halfLen, -inset-1)
----    thisLB.moreAbove:SetEndPoint("TOP", dx+halfLen, -inset-1)
----    thisLB.moreAbove:Hide()
----
----    inset = inset + 2
----    thisLB.moreBelow = thisLB.displayFrame:CreateLine(nil, "BACKGROUND", nil, 0)
----    thisLB.moreBelow:SetThickness(thickness)
----    thisLB.moreBelow:SetColorTexture(r, g, b, a)
----    thisLB.moreBelow:SetStartPoint("BOTTOM", dx-halfLen, inset)
----    thisLB.moreBelow:SetEndPoint("BOTTOM", dx+halfLen, inset)
----    thisLB.moreBelow:Hide()
----end


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
    local listbox = CreateFrame("Frame", nil, parent, (not bHideBorder and "InsetFrameTemplate") or nil)
    ----local listbox = CreateFrame("Frame", nil, parent, bHideBorder or "InsetFrameTemplate3")  -- Nice rect frame with thin bg.
    ----local listbox = CreateFrame("Frame", nil, parent, bHideBorder or "ThinBorderTemplate") -- Nice rect frame.  Just add color!
    ----local listbox = CreateFrame("Frame", nil, parent, bHideBorder or "GlowBoxTemplate") -- Bright yellow border with black-to-yellow gradient background.
    ----local listbox = CreateFrame("Frame", nil, parent, bHideBorder or "BackdropTemplate") --DJUadded
    ----listbox:SetBackdrop{  --DJUadded
    ----    ----bgFile = kTexture_White8x8,
    ----    bgFile ="Interface\\FrameGeneral\\UI-Background-Marble",
    ----    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    ----    insets = {left=3, right=3, top=2, bottom=3},  edgeSize=16,
    ----}
    ----listbox:SetBackdropColor(0,0,0, 1)  --DJUadded
    ----listbox:SetBackdropBorderColor(0.9, 0.9, 0.0)  -- (Optional) Colorize the edges.  --DJUadded
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

    -- Prevent highlight changes or mouse clicks from doing anything over empty lines.
    display:SetScript("OnEnter", function(self) end)  -- Do nothing.  --DJUadded
    display:SetScript("OnLeave", function(self) end)  -- Do nothing.  --DJUadded
    display:SetScript("OnMouseDown", function(self) end)  -- Do nothing.  --DJUadded
    display:SetScript("OnMouseUp", function(self) end)  -- Do nothing.  --DJUadded

    -- Create slider (scrollbar) to track the position.
    local sliderWidth = 16
    local sliderButtonWidth = sliderWidth + 2
    local sliderButtonHeight = sliderWidth - 0.75

    local slider = CreateFrame("Slider", nil, listbox)
    slider:Hide()
    slider:SetWidth(sliderWidth)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)
    slider:SetScript("OnValueChanged", ListBox_OnSliderChanged)

    -- Resize thumb texture to fit nicely inside our slider.
    slider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
    local thumb = slider:GetThumbTexture()
    thumb:SetVertexOffset(UPPER_LEFT_VERTEX,   2, -2)
    thumb:SetVertexOffset(LOWER_LEFT_VERTEX,   2,  2)
    thumb:SetVertexOffset(UPPER_RIGHT_VERTEX, -2, -2)
    thumb:SetVertexOffset(LOWER_RIGHT_VERTEX, -2,  2)

    slider.background = slider:CreateTexture(nil, "BACKGROUND")
    slider.background:SetPoint("TOPLEFT", 0, 0)
    slider.background:SetPoint("BOTTOMRIGHT", -1, 0)
    slider.background:SetColorTexture(0.06, 0.06, 0.06)

    -- Up button.
    local upButton = CreateFrame("Button", nil, slider, "UIPanelScrollUpButtonTemplate")
    upButton:SetSize(sliderButtonWidth, sliderButtonHeight)
    upButton:SetScript("OnClick", ListBox_OnClickUp)

    -- Down button.
    local downButton = CreateFrame("Button", nil, slider, "UIPanelScrollDownButtonTemplate")
    downButton:SetSize(sliderButtonWidth, sliderButtonHeight)
    downButton:SetScript("OnClick", ListBox_OnClickDown)

    -- Set scrollbar position.
    local dx = 0  -- Shifts scrollbar left/right while keeping all its parts aligned.
    local sliderButtonX = (sliderButtonWidth - sliderWidth) / 2  -- Centers button horizontally to slider.
    local sliderButtonY = 0
    if bHideBorder then
        -- Listbox does not have borders.  (Probably for a dropdown menu.)
        listbox.margin = 0
        sliderButtonY = -2
        slider:SetPoint("RIGHT", listbox, "RIGHT", dx+7.3, 0)
        slider:SetPoint("TOP", listbox, "TOP", 0, 7.5 - upButton:GetHeight() - sliderButtonY)
        slider:SetPoint("BOTTOM", listbox, "BOTTOM", 0, -8 + downButton:GetHeight() + sliderButtonY)
    else
        -- Normal listbox with borders.
        listbox.margin = 2
        sliderButtonY = listbox.margin + 2

        slider:SetPoint("RIGHT", listbox, "RIGHT", -listbox.margin - 2 + dx, 0)
        slider:SetPoint("TOP", listbox, "TOP", 0, 3.9 - upButton:GetHeight())
        slider:SetPoint("BOTTOM", listbox, "BOTTOM", 0, downButton:GetHeight() - 4.7)
    end

    -- Set scrollbar button positions.
    upButton:SetPoint("TOP", listbox, "TOP", 0, -sliderButtonY-1)
    upButton:SetPoint("RIGHT", slider, "RIGHT", sliderButtonX, 0)
    downButton:SetPoint("BOTTOM", listbox, "BOTTOM", 0, sliderButtonY-1)
    downButton:SetPoint("RIGHT", slider, "RIGHT", sliderButtonX, 0)

    -- Set display area position and size.
    display:SetPoint("TOPLEFT", listbox, "TOPLEFT", listbox.margin, -listbox.margin)
    display:SetPoint("BOTTOMRIGHT", listbox, "BOTTOMRIGHT", -listbox.margin, listbox.margin)

    -- Make it work with the mouse wheel.
    display:EnableMouseWheel(true)
    display:SetScript("OnMouseWheel", ListBox_OnMouseWheel)
    slider:EnableMouseWheel(true)  --DJUadded
    slider:SetScript("OnMouseWheel", ListBox_OnMouseWheel)  --DJUadded

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
    listbox.SelectItem              = ListBox_SelectItem  -- i.e. ListBox_SelectItemNumber()
    listbox.SelectItemText          = ListBox_SelectItemText  --DJUadded
    listbox.SelectNextItem          = ListBox_SelectNextItem  --DJUadded
    listbox.SelectPreviousItem      = ListBox_SelectPreviousItem  --DJUadded
    listbox.ClearSelection          = ListBox_ClearSelection  --DJUadded
    listbox.GetLine                 = ListBox_GetLine
    listbox.GetNumItems             = ListBox_GetNumItems
    listbox.GetNumLines             = ListBox_GetNumLines
    listbox.Refresh                 = ListBox_Refresh
    listbox.Clear                   = ListBox_Clear
    --DJUremoved:  listbox.Disable                 = ListBox_Disable
    --DJUremoved:  listbox.Enable                  = ListBox_Enable
    ----listbox.SetIndicators           = ListBox_SetIndicators  --DJUadded

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
-- Called when the internal CheckButton is clicked.
-- ****************************************************************************
local function CheckBox_OnClick(thisCheckButton)
    local isChecked = thisCheckButton:GetChecked() and true or false
    if (isChecked) then PlaySound(856) else PlaySound(857) end

    local checkbox = thisCheckButton:GetParent()
    if (checkbox.clickHandler) then checkbox:clickHandler(isChecked) end
end


-- ****************************************************************************
-- Called when the mouse enters the internal CheckButton.
-- ****************************************************************************
local function CheckBox_OnEnter(thisCheckButton)
    if thisCheckButton.tooltip then
        GameTooltip:SetOwner( thisCheckButton, thisCheckButton.tooltipAnchor or "ANCHOR_RIGHT" )
        GameTooltip:SetText( thisCheckButton.tooltip, nil, nil, nil, nil, 1 )
    end
end


-- ****************************************************************************
-- Called when the mouse leaves the internal CheckButton.
-- ****************************************************************************
local function CheckBox_OnLeave(thisCheckButton)
    GameTooltip:Hide()
end


-- ****************************************************************************
-- Sets the label for the checkbox.
-- ****************************************************************************
local function CheckBox_SetLabel(thisCheckBox, label)
    local fontString = thisCheckBox.fontString
    fontString:SetText(label or "")
    gCalcFontString:SetText(label or "")
    local labelWidth = gCalcFontString:GetStringWidth()
    local width = math.ceil( thisCheckBox.checkButton:GetWidth() + labelWidth + 2 )
    thisCheckBox:SetWidth(width)
    local rightInset = thisCheckBox.bClickableText and -labelWidth or 0  --DJUadded
    thisCheckBox.checkButton:SetHitRectInsets(0, rightInset, 0, 0)  --DJUadded
end


-- ****************************************************************************
-- Sets the tooltip for the checkbox.
-- ****************************************************************************
local function CheckBox_SetTooltip(thisCheckBox, tooltip, tooltipAnchor)
    thisCheckBox.checkButton.tooltip = tooltip
    thisCheckBox.checkButton.tooltipAnchor = tooltipAnchor
end


-- ****************************************************************************
-- Configures the checkbox.
-- ****************************************************************************
local function CheckBox_Configure(thisCheckBox, size, label, tooltip, tooltipAnchor)
    --DJUremoved:  if (not size) then return end  -- Don't do anything if required parameters are invalid.
    size = size or 26  --DJUadded

    -- Setup the container frame.
    thisCheckBox:SetHeight(size)

    -- Setup the checkbox dimensions.
    local check = thisCheckBox.checkButton
    check:SetWidth(size)
    check:SetHeight(size)

    -- Setup the label and tooltip.
    CheckBox_SetLabel(thisCheckBox, label)
    CheckBox_SetTooltip(thisCheckBox, tooltip, tooltipAnchor)

    thisCheckBox.configured = true
end


-- ****************************************************************************
-- Sets the function to be called when the checkbox is clicked.
-- It is passed the checkbox and whether or not it's checked.
-- ****************************************************************************
local function CheckBox_SetClickHandler(thisCheckBox, handler)
    thisCheckBox.clickHandler = handler
end


-- ****************************************************************************
-- Returns whether or not the checkbox is checked.
-- ****************************************************************************
local function CheckBox_GetChecked(thisCheckBox)
    return thisCheckBox.checkButton:GetChecked() and true or false
end


-- ****************************************************************************
-- Sets the checked state.
-- ****************************************************************************
local function CheckBox_SetChecked(thisCheckBox, isChecked)
    thisCheckBox.checkButton:SetChecked(isChecked)
end


-- ****************************************************************************
-- Disables the checkbox.
-- ****************************************************************************
local function CheckBox_Disable(thisCheckBox)
    thisCheckBox.checkButton:Disable()
    thisCheckBox.fontString:SetTextColor(0.5, 0.5, 0.5)
end


-- ****************************************************************************
-- Enables the checkbox.
-- ****************************************************************************
local function CheckBox_Enable(thisCheckBox)
    thisCheckBox.checkButton:Enable()
    thisCheckBox.fontString:SetTextColor( NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b )
end


-- ****************************************************************************
-- Creates and returns a checkbox object ready to be configured.
-- ****************************************************************************
local function CreateCheckBox(parent, fontTemplateName, dx, dy, bClickableText)
    --DJUadded:  fontTemplateName (e.g. "GameFontNormal"), dx, dy, bClickableText.
    fontTemplateName = fontTemplateName or "GameFontNormalSmall"  --DJUadded
    dx = dx or 0   --DJUadded
    dy = dy or 1   --DJUadded

    -- XXX Hack to work around apparent WoW API bug not returning correct string width.
    if (not gCalcFontString) then
        gCalcFontString = UIParent:CreateFontString(nil, "ARTWORK", fontTemplateName)
    end

    -- Create container frame.
    local checkbox = CreateFrame("Frame", nil, parent)

    -- Create check button.
    local checkButton = CreateFrame("CheckButton", nil, checkbox)
    checkButton:SetPoint("TOPLEFT")
    checkButton:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
    checkButton:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
    checkButton:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
    checkButton:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
    checkButton:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
    checkButton:SetScript("OnClick", CheckBox_OnClick)
    checkButton:SetScript("OnEnter", CheckBox_OnEnter)
    checkButton:SetScript("OnLeave", CheckBox_OnLeave)

    -- Label.
    local fontString = checkbox:CreateFontString(nil, "OVERLAY", fontTemplateName)
    fontString:SetJustifyH("LEFT")
    fontString:SetPoint("LEFT", checkButton, "RIGHT", dx, dy)
    fontString:SetPoint("RIGHT", checkbox, "RIGHT", 0, dy)

    -- Make clicking the text toggle the checkbox.  --DJUadded
    checkbox.bClickableText = bClickableText
    ---->>> PROBLEM: This approach doesn't highlight checkbox when mouse hovers over text.  Use SetHitRectInsets() instead.
    ----if bClickableText then
    ----    fontString:SetPoint("TOP", checkbox, 0, dy-2)
    ----    fontString:SetPoint("BOTTOM", checkbox, 0, dy+2)
    ----    fontString:SetScript("OnMouseUp", function(self) checkButton:Click() end)
    ----end

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
    checkbox.checkButton = checkButton
    checkbox.fontString = fontString

    CheckBox_Configure(checkbox)  --DJUadded
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
local function Button_OnClick(thisBtn, mouseButton, bDown)  --DJUadded mouseButton, bDown.
    PlaySound(856)
    if (thisBtn.clickHandler) then thisBtn:clickHandler(mouseButton, bDown) end
end


-- ****************************************************************************
-- Called when the mouse enters the button.
-- ****************************************************************************
local function Button_OnEnter(thisBtn)
    if (thisBtn.tooltip) then
        GameTooltip:SetOwner( thisBtn, thisBtn.tooltipAnchor or "ANCHOR_RIGHT" )
        GameTooltip:SetText(thisBtn.tooltip, nil, nil, nil, nil, 1)
    end
end


-- ****************************************************************************
-- Called when the mouse leaves the button.
-- ****************************************************************************
local function Button_OnLeave(thisBtn)
    GameTooltip:Hide()
end


-- ****************************************************************************
-- Sets the tooltip for the button.
-- ****************************************************************************
local function Button_SetTooltip(thisBtn, tooltip, tooltipAnchor)
    thisBtn.tooltip = tooltip
    thisBtn.tooltipAnchor = tooltipAnchor
end


-- ****************************************************************************
-- Sets the function to be called when the button is clicked.
-- ****************************************************************************
local function Button_SetClickHandler(thisBtn, handler)
    thisBtn.clickHandler = handler
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
local function OptionButton_SetLabel(thisOB, label)
    thisOB:SetText(label or "")
    thisOB:SetWidth(thisOB:GetFontString():GetStringWidth() + 50)
end


-- ****************************************************************************
-- Configures the option button.
-- ****************************************************************************
local function OptionButton_Configure(thisOB, height, label, tooltip, tooltipAnchor)
    thisOB:SetHeight(height)
    OptionButton_SetLabel(thisOB, label)
    Button_SetTooltip(thisOB, tooltip, tooltipAnchor)
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
-- EXAMPLE: (for a delete "X" button)
--   local deleteBtn = CreateIconButton(YourOptionsFrame, 24, "Interface\\Addons\\YourAddonName\\YourIcons\\"
--                                     "DeleteIcon", "DeleteIconHighlight", "DeleteIconDisable")
-- ****************************************************************************
local function CreateIconButton(parent, iconSize, iconPath, iconFname, iconHighlightFname, iconDisabledFname)  --DJUchanged
    iconSize = iconSize or 24
    iconPath = iconPath or "Interface\\Addons\\" .. kAddonFolderName .. "\\"
    local button = CreateButton(parent)
    button:SetWidth(iconSize)
    button:SetHeight(iconSize)
    if iconFname then button:SetNormalTexture(iconPath .. iconFname) end
    if iconHighlightFname then button:SetHighlightTexture(iconPath .. iconHighlightFname) end
    if iconDisabledFname then button:SetDisabledTexture(iconPath .. iconDisabledFname) end
    return button
end

-- ****************************************************************************
-- Similar to CreateIconButton, but uses textures created by the caller instead of names to images.
-- EXAMPLE: (for a delete "X" button)
--    local function createRedX(parent)
--        local tex = YourOptionsFrame:CreateTexture(nil, "ARTWORK")
--        tex:SetTexture("Interface\\BUTTONS\\UI-StopButton")
--        tex:SetSize(16, 16)
--        tex:SetVertexColor(1.0, 0.22, 0.22,  0.8)  -- Changes icon color to red.
--        return tex
--    end
--    local normal, highlight, disabled = createRedX(YourOptionsFrame), createRedX(YourOptionsFrame), createRedX(YourOptionsFrame)
--    local pushed = normal
--    normal:SetAlpha(0.4)
--    disabled:SetAlpha(0.2)
--    local deleteBtn = private.UDControls.CreateTextureButton(YourOptionsFrame, normal, highlight, pushed, disabled)
-- ****************************************************************************
local function CreateTextureButton(parent, normalTexture, highlightTexture, pushedTexture, disabledTexture)  --DJUadded
    local button = CreateButton(parent)
    button:SetSize(16, 16)
    local tex = normalTexture or highlightTexture or pushedTexture or disabledTexture
    if tex.GetObjectType and tex:GetObjectType() == "Texture" then
        button:SetSize( tex:GetSize() )  -- Make button same size as the first specified texture.
    end
    if normalTexture then button:SetNormalTexture(normalTexture) end
    if highlightTexture then button:SetHighlightTexture(highlightTexture) end
    if pushedTexture then button:SetPushedTexture(pushedTexture) end
    if disabledTexture then button:SetDisabledTexture(disabledTexture) end
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
local function Slider_OnValueChanged(thisSliderFrame, value)
    local slider = thisSliderFrame:GetParent()
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
local function Slider_OnEnter(thisSliderFrame)
    if (thisSliderFrame.tooltip) then
        GameTooltip:SetOwner( thisSliderFrame, thisSliderFrame.tooltipAnchor or "ANCHOR_RIGHT" )
        GameTooltip:SetText( thisSliderFrame.tooltip, nil, nil, nil, nil, 1 )
    end
end


-- ****************************************************************************
-- Called when the mouse leaves the slider.
-- ****************************************************************************
local function Slider_OnLeave(thisSliderFrame)
    GameTooltip:Hide()
end


-- ****************************************************************************
-- Sets the label for the slider.
-- ****************************************************************************
local function Slider_SetLabel(thisSlider, label)
    thisSlider.labelText = label or ""
    if (thisSlider.labelText ~= "") then
        thisSlider.labelFontString:SetText(thisSlider.labelText .. ": " .. thisSlider:GetValue())
    else
        thisSlider.labelFontString:SetText( thisSlider:GetValue() )
    end
end


-- ****************************************************************************
-- Sets the tooltip for the slider.
-- ****************************************************************************
local function Slider_SetTooltip(thisSlider, tooltip, tooltipAnchor)
    thisSlider.sliderFrame.tooltip = tooltip
    thisSlider.sliderFrame.tooltipAnchor = tooltipAnchor
end


-- ****************************************************************************
-- Configures the slider.
-- ****************************************************************************
local function Slider_Configure(thisSlider, width, label, tooltip, tooltipAnchor)
    thisSlider:SetWidth(width)
    Slider_SetLabel(thisSlider, label)
    Slider_SetTooltip(thisSlider, tooltip, tooltipAnchor)
end


-- ****************************************************************************
-- Sets the function to be called when the value of the slider is changed.
-- It is passed the slider and the new value.
-- ****************************************************************************
local function Slider_SetValueChangedHandler(thisSlider, handler)
    thisSlider.valueChangedHandler = handler
end


-- ****************************************************************************
-- Sets the minimum and maximum values for the slider.
-- ****************************************************************************
local function Slider_SetMinMaxValues(thisSlider, minValue, maxValue)
    thisSlider.sliderFrame:SetMinMaxValues( minValue, maxValue )
end


-- ****************************************************************************
-- Sets how far the slider moves with each "tick."
-- ****************************************************************************
local function Slider_SetValueStep(thisSlider, value)
    thisSlider.sliderFrame:SetValueStep( value )
end


-- ****************************************************************************
-- Sets the current value of the slider.
-- ****************************************************************************
local function Slider_GetValue(thisSlider)
    return thisSlider.sliderFrame:GetValue()
end


-- ****************************************************************************
-- Sets the current value of the slider.
-- ****************************************************************************
local function Slider_SetValue(thisSlider, value)
    thisSlider.sliderFrame:SetValue( value )
end


-- ****************************************************************************
-- Disables the slider.
-- ****************************************************************************
local function Slider_Disable(thisSlider)
    thisSlider.sliderFrame:EnableMouse(false)
    thisSlider.labelFontString:SetTextColor(0.5, 0.5, 0.5)
end


-- ****************************************************************************
-- Enables the slider.
-- ****************************************************************************
local function Slider_Enable(thisSlider)
    thisSlider.sliderFrame:EnableMouse(true)
    thisSlider.labelFontString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
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
local function DropDown_HideSelections(thisDD)
    if (gDropDownListBoxFrame:IsShown() and gDropDownListBoxFrame.dropdown == thisDD) then
        gDropDownListBoxFrame:Hide()
    end
end


-- ****************************************************************************
-- Called when the mouse enters the dropdown.
-- ****************************************************************************
local function DropDown_OnEnter(thisDD)
    if (thisDD.tooltip) then
        GameTooltip:SetOwner(thisDD, thisDD.tooltipAnchor or "ANCHOR_RIGHT")
        GameTooltip:SetText(thisDD.tooltip, nil, nil, nil, nil, 1)
    end
end


-- ****************************************************************************
-- Called when the mouse leaves the dropdown.
-- ****************************************************************************
local function DropDown_OnLeave(thisDD)
    GameTooltip:Hide()
end


-- ****************************************************************************
-- Called when the dropdown is hidden.
-- ****************************************************************************
local function DropDown_OnHide(thisDD)
    DropDown_HideSelections(thisDD)
end


-- ****************************************************************************
-- Returns the common listbox frame used by all dropdown menus to display
-- their items when clicked open.
-- ****************************************************************************
local function DropDown_GetListBoxFrame(thisDD)  --DJUadded
    return gDropDownListBoxFrame
end


-- ****************************************************************************
-- Called when the button for the dropdown is pressed.
-- ****************************************************************************
local function DropDown_OnClick(thisDropDownButton)
    -- Close the listbox and exit if it's already open for the dropdown.
    local dropdown = thisDropDownButton:GetParent()
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
    local maxHeight = math.max( thisDropDownButton:GetBottom()-kListBoxBottomMargin, 3*kListBoxLineHeight )
    maxHeight = maxHeight / gDropDownListBoxFrame:GetScale()  -- GetBottom() is relative to screen, not parent.
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

    -- This next part fixes a glitch where the scrollbar's thumb position was sometimes below the scrollbar.
    if listbox.sliderFrame:IsShown() and not listbox.bGlitchFixed then  -- Only need to do this once.
        listbox.bGlitchFixed = true
        local temp = listbox.sliderFrame:GetValue()
        listbox.sliderFrame:SetValue(0)
        C_Timer.After(kScrollbarGlitchTime, function() listbox.sliderFrame:SetValue(temp) end) -- Restore pos.
    end
end


-- ****************************************************************************
-- Called by listbox to create a line.
-- ****************************************************************************
local function DropDown_CreateLine(thisDD)
    local frame = CreateFrame("Button", nil, thisDD)
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
local function DropDown_DisplayLine(thisDDLB, line, value, isSelected)
    line.fontString:SetText(gDropDownListBoxFrame.dropdown.items[value])
    local color = isSelected and HIGHLIGHT_FONT_COLOR or NORMAL_FONT_COLOR
    line.fontString:SetTextColor(color.r, color.g, color.b)
end


-- ****************************************************************************
-- Called when a line is clicked.
-- ****************************************************************************
local function DropDown_OnClickLine(thisDDLB, line, value)
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
local function DropDown_SetLabel(thisDD, label)
    thisDD.labelFontString:SetText(label or "")
end


-- ****************************************************************************
-- Sets the tooltip for the dropdown.
-- ****************************************************************************
local function DropDown_SetTooltip(thisDD, tooltip)
    thisDD.tooltip = tooltip
end


-- ****************************************************************************
-- Configures the dropdown.
-- ****************************************************************************
local function DropDown_Configure(thisDD, width, label, tooltip)
    -- Don't do anything if required parameters are invalid.
    ----DJUremoved:  if (not width) then return end
    assert(width ~= nil and width > 0)  --DJUadded

    -- Set the width of the dropdown and the max height of the listbox is shown.
    thisDD:SetWidth(width)

    DropDown_SetLabel(thisDD, label)
    DropDown_SetTooltip(thisDD, tooltip)

    -- Stretch the dropdown's button over its entire width so users can click anywhere to open it.
    -- Also adjust top/bottom points to match when the (optional) tooltip appears/disappears.
    local button = thisDD.buttonFrame
    button:SetHitRectInsets( -thisDD:GetWidth()+button:GetWidth(), 0, -2, -2 ) -- (Left, Right, Top, Bottom)
end


-- ****************************************************************************
-- Sets the max height the listbox frame can be for the dropdown.
-- ****************************************************************************
local function DropDown_SetListBoxHeight(thisDD, height)
    thisDD.listboxHeight = height
end

-- ****************************************************************************
-- Sets the width of the listbox frame for the dropdown.
-- ****************************************************************************
local function DropDown_SetListBoxWidth(thisDD, width)
    thisDD.listboxWidth = width
end


-- ****************************************************************************
-- Sets the function to be called when one of the dropdown's options is
-- selected. It is passed the ID for the selected item.
-- ****************************************************************************
local function DropDown_SetChangeHandler(thisDD, handler)
    thisDD.changeHandler = handler
end


-- ****************************************************************************
-- Returns the number of items in the listbox.
-- ****************************************************************************
local function DropDown_GetNumItems(thisDD)  --DJUadded
    return #thisDD.items
end


-- ****************************************************************************
-- Adds the passed text and id to the dropdown.
-- ****************************************************************************
local function DropDown_AddItem(thisDD, text, id, bPreventDuplicate)
    if bPreventDuplicate then
        -- Check if 'text' already exists.  If so, update its ID and return.
        for itemNum, itemText in ipairs(thisDD.items) do
            if (itemText == text) then
                thisDD.itemIDs[itemNum] = id  -- Update existing item's ID.
                return  -- Done.
            end
        end
    end

    -- New item, so add it.
    thisDD.items[ #thisDD.items+1 ] = text
    thisDD.itemIDs[ #thisDD.items ] = id
end


-- ****************************************************************************
-- Remove the passed item id from the dropdown.
-- ****************************************************************************
local function DropDown_RemoveItem_Helper(thisDD, itemNumToRemove)
    -- Hide dropdown if it is shown.
    DropDown_HideSelections(thisDD)

    -- Clear the selected item if it's the item being removed.
    if (itemNumToRemove == thisDD.selectedItem) then
        thisDD.selectedItem = 0
        thisDD.selectedFontString:SetText("")
    end

    table.remove(thisDD.items, itemNumToRemove)
    table.remove(thisDD.itemIDs, itemNumToRemove)
    return true
end
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
local function DropDown_RemoveItem(thisDD, id)
    assert(id)

    -- Compare id with ID entries.
    for itemNum, itemID in ipairs(thisDD.itemIDs) do
        if (itemID == id) then
            return DropDown_RemoveItem_Helper(thisDD, itemNum)  -- DONE.
        end
    end

    -- Compare id with text entries.
    if (type(id) == "string") then
        for itemNum, itemText in ipairs(thisDD.items) do
            if (itemText == id) then
                return DropDown_RemoveItem_Helper(thisDD, itemNum)  -- DONE.
            end
        end
    end

    return false  -- FAILED.
end


-- ****************************************************************************
-- Clears the dropdown.
-- ****************************************************************************
local function DropDown_Clear(thisDD)
    local items = thisDD.items
    for k, v in ipairs(items) do
        items[k] = nil
    end

    local itemIDs = thisDD.itemIDs
    for k, v in ipairs(itemIDs) do
        itemIDs[k] = nil
    end

    thisDD.selectedFontString:SetText(nil)
    thisDD.selectedItem = nil  --DJUadded
end


-- ****************************************************************************
-- Clears the dropdown selection.  (The popup menu contents will still exist.)
-- ****************************************************************************
local function DropDown_ClearSelection(thisDD)  --DJUadded
    if (thisDD.selectedItem ~= nil and thisDD.selectedItem ~= 0) then
        thisDD.selectedItem = 0
        thisDD.selectedFontString:SetText("")
    end
end


-- ****************************************************************************
-- Gets the selected index (item number) from the dropdown.
-- ****************************************************************************
local function DropDown_GetSelectedIndex(thisDD)  --DJUadded
    return thisDD.selectedItem
end


-- ****************************************************************************
-- Sets the selected item for the dropdown given an item number (1-based index).
-- Returns true if successful, nil otherwise.
-- ****************************************************************************
local function DropDown_SelectIndex(thisDD, itemNum)  --DJUadded
    if (itemNum == nil) then return end  -- Fail.
    thisDD.selectedFontString:SetText( thisDD.items[itemNum] )
    thisDD.selectedItem = itemNum

--~     -- Call the registered change handler for the dropdown.
--~     if (thisDD.changeHandler) then thisDD:changeHandler( thisDD.itemIDs[itemNum] ) end
    return true
end


-- ****************************************************************************
-- Gets the selected id from the dropdown.
-- ****************************************************************************
local function DropDown_GetSelectedID(thisDD)
    if (thisDD.selectedItem) then return thisDD.itemIDs[ thisDD.selectedItem ] end
end


-- ****************************************************************************
-- Sets the selected item for the dropdown given an item ID.
-- Returns true if successful, nil otherwise.
-- ****************************************************************************
local function DropDown_SelectID(thisDD, id)
    if (id == nil) then return end  -- Fail.
    for itemNum, itemID in ipairs(thisDD.itemIDs) do
        if (itemID == id) then
            DropDown_SelectIndex(thisDD, itemNum)  --DJUadded
            return true  -- Done, exit loop.     --DJUadded
            --DJUremoved:  thisDD.selectedFontString:SetText( thisDD.items[itemNum] )
            --DJUremoved:  thisDD.selectedItem = itemNum
            --DJUremoved:  return
        end
    end
end


-- ****************************************************************************
-- Gets the selected text from the dropdown.
-- ****************************************************************************
local function DropDown_GetSelectedText(thisDD)
    return thisDD.selectedFontString:GetText()
end


-- ****************************************************************************
-- Sets the selected item for the dropdown given the text shown in the menu.
-- Returns true if successful, nil otherwise.
-- ****************************************************************************
local function DropDown_SelectText(thisDD, text)  --DJUadded
    if (text == nil or text == "") then return end  -- Fail.
    for itemNum, itemText in ipairs(thisDD.items) do
        if (itemText == text) then
            DropDown_SelectIndex(thisDD, itemNum)
            return true  -- Done, exit loop.
        end
    end
end


-- ****************************************************************************
-- Selects next item in the dropdown and invokes the change handler (if set).
-- ****************************************************************************
local function DropDown_SelectNext(thisDD)  --DJUadded
    if gDropDownListBoxFrame:IsShown() then gDropDownListBoxFrame:Hide() end
    local itemNum = thisDD:GetSelectedIndex()
    if (itemNum < thisDD:GetNumItems()) then
        thisDD:SelectIndex( itemNum+1 )
        if thisDD.changeHandler then
            local selectedID = DropDown_GetSelectedID(thisDD)
            thisDD:changeHandler( thisDD.itemIDs[selectedID] )
        end
    end
end


-- ****************************************************************************
-- Selects previous item in the dropdown and invokes the change handler (if set).
-- ****************************************************************************
local function DropDown_SelectPrevious(thisDD)  --DJUadded
    if gDropDownListBoxFrame:IsShown() then gDropDownListBoxFrame:Hide() end
    local itemNum = thisDD:GetSelectedIndex()
    if (itemNum > 1) then
        thisDD:SelectIndex( itemNum-1 )

        -- Call the registered change handler for the dropdown.
        if thisDD.changeHandler then
            local selectedID = DropDown_GetSelectedID(thisDD)
            thisDD:changeHandler( thisDD.itemIDs[selectedID] )
        end
    end
end


-- ****************************************************************************
-- Sorts the contents of the dropdown.
-- ****************************************************************************
local function DropDown_Sort(thisDD, bCaseInsensitive)
    local selectedID = DropDown_GetSelectedID(thisDD)

    -- Sort the dropdown items and associated IDs using an insertion sort.
    local items = thisDD.items
    local itemIDs = thisDD.itemIDs
    local tempItem, tempID, j
    for i = 2, #items do
        tempItem = items[i]
        tempID = itemIDs[i]
        j = i - 1
        if bCaseInsensitive then
            while (j > 0 and string.lower(items[j]) > string.lower(tempItem)) do
                items[j + 1] = items[j]
                itemIDs[j + 1] = itemIDs[j]
                j = j - 1
            end
        else -- Case sensitive sort.
            while (j > 0 and items[j] > tempItem) do
                items[j + 1] = items[j]
                itemIDs[j + 1] = itemIDs[j]
                j = j - 1
            end
        end
        items[j + 1] = tempItem
        itemIDs[j + 1] = tempID
    end

    DropDown_SelectID(thisDD, selectedID)
end


-- ****************************************************************************
-- Disables the dropdown.
-- ****************************************************************************
local function DropDown_Disable(thisDD)
    DropDown_HideSelections(thisDD)
    thisDD:EnableMouse(false)
    thisDD.buttonFrame:Disable()
    thisDD.labelFontString:SetTextColor(0.5, 0.5, 0.5)
    thisDD.selectedFontString:SetTextColor(0.5, 0.5, 0.5)
end


-- ****************************************************************************
-- Enables the dropdown.
-- ****************************************************************************
local function DropDown_Enable(thisDD)
    thisDD:EnableMouse(true)
    thisDD.buttonFrame:Enable()
    thisDD.labelFontString:SetTextColor( NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b )
    thisDD.selectedFontString:SetTextColor( HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b )
end


-- ****************************************************************************
-- Sets the color of the dropdown's background.  ('alpha' is optional.)
-- ****************************************************************************
local function DropDown_SetBackdropColor(thisDD, r, g, b, alpha)  --DJUadded
    ----if (gDropDownListBoxFrame.dropdown == thisDD) then
        gDropDownListBoxFrame:SetBackdropColor(r, g, b, (alpha or 1.0))
    ----end
end

-- ****************************************************************************
-- Sets the color of the dropdown's edges.  ('alpha' is optional.)
-- ****************************************************************************
local function DropDown_SetBackdropBorderColor(thisDD, r, g, b, alpha)  --DJUadded
    ----if (gDropDownListBoxFrame.dropdown == thisDD) then
        gDropDownListBoxFrame:SetBackdropBorderColor(r, g, b, (alpha or 1.0))
    ----end
end

-- ****************************************************************************
-- Creates the listbox frame that dropdowns use.
-- ****************************************************************************
local function DropDown_CreateListBoxFrame(parent, bDropDown)  --DJUchanged: Added bDropDown.
    assert(not gDropDownListBoxFrame)  --DJUadded
    gDropDownListBoxFrame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    gDropDownListBoxFrame:EnableMouse(true)
    gDropDownListBoxFrame:SetToplevel(true)
    gDropDownListBoxFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    gDropDownListBoxFrame:SetBackdrop{  --DJUchanged ...
        ----bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        -----bgFile = "Interface\\Addons\\" .. kAddonFolderName .. "\\Controls-Background-SolidBlack",
        bgFile = kTexture_White8x8,
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
    ----local c = 0.5
    ----gDropDownListBoxFrame.TopEdge:SetVertexColor(c,c,c, 1)
    ----gDropDownListBoxFrame.TopLeftCorner:SetVertexColor(c,c,c, 1)
    ----gDropDownListBoxFrame.TopRightCorner:SetVertexColor(c,c,c, 1)

    local listbox = CreateListBox(gDropDownListBoxFrame, true)  --DJUchanged: Added true param.
    gDropDownListBoxFrame.listbox = listbox
    listbox:SetToplevel(true)
    listbox:SetFrameStrata("FULLSCREEN_DIALOG")
    listbox:SetCreateLineHandler(DropDown_CreateLine)
    listbox:SetDisplayHandler(DropDown_DisplayLine)
    listbox:SetClickHandler(DropDown_OnClickLine)

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
    button:SetScript("OnEnter", function(self) DropDown_OnEnter(dropdown) end)  --DJUadded
    button:SetScript("OnLeave", function(self) DropDown_OnLeave(dropdown) end)  --DJUadded
    button:SetScript("OnHide", function(self) DropDown_OnHide(dropdown) end)  --DJUadded

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
local function EditBox_OnEscape(thisEditBoxFrame)
    thisEditBoxFrame:ClearFocus()
    local editbox = thisEditBoxFrame:GetParent()
    if (editbox.escapeHandler) then editbox:escapeHandler() end
end


-- ****************************************************************************
-- Called when the editbox loses focus.
-- ****************************************************************************
local function EditBox_OnFocusLost(thisEditBoxFrame)
    thisEditBoxFrame:HighlightText(0, 0)
end


-- ****************************************************************************
-- Called when the editbox gains focus.
-- ****************************************************************************
local function EditBox_OnFocusGained(thisEditBoxFrame)
    thisEditBoxFrame:HighlightText()
end


-- ****************************************************************************
-- Called when the text in the editbox changes.
-- ****************************************************************************
local function EditBox_OnTextChanged(thisEditBoxFrame)
    local editbox = thisEditBoxFrame:GetParent()
    if (editbox.textChangedHandler) then editbox:textChangedHandler() end
end


-- ****************************************************************************
-- Called when the mouse enters the editbox.
-- ****************************************************************************
local function EditBox_OnEnter(thisEditBoxFrame)
    if (thisEditBoxFrame.tooltip) then
        GameTooltip:SetOwner(thisEditBoxFrame, thisEditBoxFrame.tooltipAnchor or "ANCHOR_RIGHT")
        GameTooltip:SetText(thisEditBoxFrame.tooltip, nil, nil, nil, nil, 1)
    end
end


-- ****************************************************************************
-- Called when the mouse leaves the editbox.
-- ****************************************************************************
local function EditBox_OnLeave(thisEditBoxFrame)
    GameTooltip:Hide()
end


-- ****************************************************************************
-- Sets the label for the editbox.
-- ****************************************************************************
local function EditBox_SetLabel(thisEB, label)
    thisEB.labelFontString:SetText(label)
end


-- ****************************************************************************
-- Sets the tooltip for the editbox.
-- ****************************************************************************
local function EditBox_SetTooltip(thisEB, tooltip, tooltipAnchor)
    thisEB.editboxFrame.tooltip = tooltip
    thisEB.editboxFrame.tooltipAnchor = tooltipAnchor
end


-- ****************************************************************************
-- Configures the editbox.
-- ****************************************************************************
local function EditBox_Configure(thisEB, width, label, tooltip, tooltipAnchor)
    -- Don't do anything if required parameters are invalid.
    if (not width) then return end

    thisEB:SetWidth(width)
    EditBox_SetLabel(thisEB, label)
    EditBox_SetTooltip(thisEB, tooltip, tooltipAnchor)
end


-- ****************************************************************************
-- Sets the handler to be called when the enter button is pressed.
-- ****************************************************************************
local function EditBox_SetEnterHandler(thisEB, handler)
    thisEB.editboxFrame:SetScript("OnEnterPressed", handler)
end


-- ****************************************************************************
-- Sets the handler to be called when the escape button is pressed.
-- ****************************************************************************
local function EditBox_SetEscapeHandler(thisEB, handler)
    thisEB.escapeHandler = handler
end


-- ****************************************************************************
-- Sets the handler to be called when the text in the editbox changes.
-- ****************************************************************************
local function EditBox_SetTextChangedHandler(thisEB, handler)
    thisEB.textChangedHandler = handler
end


-- ****************************************************************************
-- Sets the focus to the editbox.
-- ****************************************************************************
local function EditBox_SetFocus(thisEB)
    thisEB.editboxFrame:SetFocus()
end


-- ****************************************************************************
-- Gets the text entered in the editbox.
-- ****************************************************************************
local function EditBox_GetText(thisEB)
    return thisEB.editboxFrame:GetText()
end


-- ****************************************************************************
-- Sets the text entered in the editbox.
-- ****************************************************************************
local function EditBox_SetText(thisEB, text)
    return thisEB.editboxFrame:SetText(text or "")
end


-- ****************************************************************************
-- Disables the editbox.
-- ****************************************************************************
local function EditBox_Disable(thisEB)
    thisEB.editboxFrame:EnableMouse(false)
    thisEB.labelFontString:SetTextColor(0.5, 0.5, 0.5)
end

-- ****************************************************************************
-- Enables the editbox.
-- ****************************************************************************
local function EditBox_Enable(thisEB)
    thisEB.editboxFrame:EnableMouse(true)
    thisEB.labelFontString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
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
local function ColorSwatch_SetColor(thisCS, r, g, b, a)
    -- Update our variables.
    thisCS.r = r
    thisCS.g = g
    thisCS.b = b
    thisCS.a = a

    -- Update swatch button's color.
    thisCS:GetNormalTexture():SetVertexColor(r, g, b, a)
end


-- ****************************************************************************
-- Returns the color of the color swatch.
-- ****************************************************************************
local function ColorSwatch_GetColor(thisCS)
    return thisCS.r, thisCS.g, thisCS.b, thisCS.a
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
                bgFile = kTexture_White8x8,
                edgeFile = kTexture_White8x8,
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
local function ColorSwatch_ShowColorPicker(thisCS)
    if ColorPickerFrame:IsShown() then
        if isColorPickerCustomized() then return end  -- Already shown.  Do nothing else.

        -- Otherwise, color picker is opened by another addon.  Close that one so we can show ours (later).
        ColorPickerFrame:Hide()
    end
    ----vdt_dump(thisCS, "thisCS in ColorSwatch_ShowColorPicker()")

    ColorPickerFrame_SaveAttributes()
    ColorPickerFrame[kCustomizedTag] = true  -- So we restore the color picker to original state when it is closed.
    gAssociatedColorSwatch = thisCS

    thisCS.r = thisCS.r or 1
    thisCS.g = thisCS.g or 1
    thisCS.b = thisCS.b or 1
    ColorPickerFrame.previousValues = {r = thisCS.r, g = thisCS.g, b = thisCS.b, a = thisCS.a}

    if (thisCS.a ~= nil) then
        ColorPickerFrame.hasOpacity = true
        ColorPickerFrame.opacity = thisCS.a
    else
        ColorPickerFrame.hasOpacity = false
        ColorPickerFrame.opacity = nil
    end

    ColorPickerFrame.func = ColorSwatch_Callback  -- Old Blizzard name.  (Does same thing as 'swatchFunc'.)
    ColorPickerFrame.swatchFunc = ColorSwatch_Callback  -- New Blizzard name (10.2.5 and later).
    ColorPickerFrame.opacityFunc = ColorSwatch_Callback
    ColorPickerFrame.cancelFunc = ColorSwatch_Callback

    if kMinVer_10_2_5 then  -- WoW 10.2.5 or newer?
        -- Set new API stuff.
        ColorPickerFrame.Content.ColorSwatchOriginal:SetColorTexture(thisCS.r, thisCS.g, thisCS.b)
        ColorPickerFrame.Content.HexBox:OnColorSelect(thisCS.r, thisCS.g, thisCS.b)
    end

    -- Set color and opacity.
    ColorPickerFrame_SetColorRGB(thisCS.r, thisCS.g, thisCS.b)
    if (ColorPickerFrame.opacity) then
        OpacitySlider_SetValue(ColorPickerFrame.opacity)
    end

    --::::::::::::::::::[ CUSTOMIZE COLOR PICKER ]:::::::::::::::::::

    -- Attach color picker to top-right corner of the parent frame.
    ColorPickerFrame:ClearAllPoints()
    ColorPickerFrame:SetPoint("TOPLEFT", thisCS:GetParent(), "TOPRIGHT", -12, -6)
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
local function ColorSwatch_CloseColorPicker(thisCS, bSaveChanges)
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
local function ColorSwatch_OnEnter(thisCS)
    if (thisCS.tooltip) then
        GameTooltip:SetOwner(thisCS, thisCS.tooltipAnchor or "ANCHOR_RIGHT")
        GameTooltip:SetText(thisCS.tooltip, nil, nil, nil, nil, 1)
    end

    ----thisCS.borderTexture:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
end


-- ****************************************************************************
-- Called when the mouse leaves the color swatch.
-- ****************************************************************************
local function ColorSwatch_OnLeave(thisCS)
    GameTooltip:Hide()
    ----thisCS.borderTexture:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
end


-- ****************************************************************************
-- Sets the handler to be called when the color changes.
-- ****************************************************************************
local function ColorSwatch_SetColorChangedHandler(thisCS, handler)
    thisCS.colorChangedHandler = handler
end


-- ****************************************************************************
-- Sets the tooltip for the color swatch.
-- ****************************************************************************
local function ColorSwatch_SetTooltip(thisCS, tooltip, tooltipAnchor)
    thisCS.tooltip = tooltip
    thisCS.tooltipAnchor = tooltipAnchor
end


-- ****************************************************************************
-- Disables the colors watch.
-- ****************************************************************************
local function ColorSwatch_Disable(thisCS)
    thisCS:GetNormalTexture():SetVertexColor(0.5, 0.5, 0.5) -- Dim the color swatch.
    thisCS:SetAlpha(0.2)
    thisCS:oldDisableHandler()
end


-- ****************************************************************************
-- Enables the color swatch.
-- ****************************************************************************
local function ColorSwatch_Enable(thisCS)
    thisCS:oldEnableHandler()
    thisCS:GetNormalTexture():SetVertexColor(thisCS.r, thisCS.g, thisCS.b)  -- Undim the color swatch.
    thisCS:SetAlpha(1.0)
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
        containerFrame.title = containerFrame:CreateFontString(nil, "ARTWORK", "SplashHeaderFont")  -- "GameFontNormalLarge"?
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

    -- [X] BUTTON --
    local x, y, size = -7, -8, 22
    if not isRetailWoW() then
        x, y, size = 1, 1, 36
    end
    containerFrame.xBtn = CreateFrame("Button", nil, containerFrame, "UIPanelCloseButton")
    containerFrame.xBtn:SetSize(size, size)
    containerFrame.xBtn:SetPoint("TOPRIGHT", containerFrame, "TOPRIGHT", x, y)
    containerFrame.xBtn:SetScript("OnClick", function(self) self:GetParent():Hide() end)

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
            local str = self.scrollChild:CreateFontString(nil, "ARTWORK", fontName or "GameFontNormal")
            self.strings[numStrings] = str  -- Store this string.

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
local function GroupBox_UpdateTitleSize(thisGB, margins)
    assert(type(margins) == "table", "Expected a table for margins, got a ".. type(margins)..".")
    margins = margins or {}
    margins.left = margins.left or 0
    margins.right = margins.right or 0
    margins.top = margins.top or 0
    margins.bottom = margins.bottom or 0

    thisGB.titleBackground:SetPoint("TOPLEFT", thisGB.title, "TOPLEFT", -margins.left, margins.top)
    thisGB.titleBackground:SetPoint("BOTTOMRIGHT", thisGB.title, "BOTTOMRIGHT", margins.right, -margins.bottom)
end

-- ****************************************************************************
-- Change the title text's background color.
-- ****************************************************************************
local function GroupBox_SetTitleBackColor(thisGB, r, g, b, alpha)
    if not thisGB.titleBackground then
        thisGB.titleBackground = thisGB:CreateTexture(nil, "BACKGROUND")
        thisGB.titleBackground:SetTexture(kTexture_White8x8)
    end
    thisGB.titleBackground:SetVertexColor(r, g, b, alpha)
    GroupBox_UpdateTitleSize(thisGB, {left=1, right=1, top=1, bottom=1})  -- Make background size same as title size.
end

-- ****************************************************************************
-- Sets the color of the groupbox background.
-- ****************************************************************************
local function GroupBox_SetBackColor(thisGB, r, g, b, alpha)
    thisGB.background:SetVertexColor(r, g, b, alpha or 1)
end

-- ****************************************************************************
-- Gets the color of the groupbox background.
-- ****************************************************************************
local function GroupBox_GetBackColor(thisGB)
    return thisGB.background:GetVertexColor()
end

-- ****************************************************************************
-- Creates and returns a group box frame with the given title.
-- Set title to nil if you don't want title text for the groupbox.
-- Set width to nil to have the groupbox expand to the right edge of its parent (minus space for a margin).
-- Set height to nil to have the groupbox expand to the bottom of its parent (minus space for a margin).
-- ****************************************************************************
local function CreateGroupBox(title, anchor, parent, relativeAnchor, x, y, width, height)  --DJUadded
    ----local groupbox = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    ----groupbox:SetBackdrop{  -- See WoW file, Backdrop.lua, for many sample backdrop tables.
    ----    bgFile = kTexture_White8x8,  ----tile=true,  tileSize=8,
    ----    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",  tileEdge=true,  edgeSize=16,
    ----    insets = {left=4, right=4, top=4, bottom=4},
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

    groupbox.background = groupbox:CreateTexture(nil, "BACKGROUND")
    groupbox.background:SetTexture(kTexture_White8x8)
    local margin = 4
    groupbox.background:SetPoint("TOPLEFT", margin, -margin)
    groupbox.background:SetPoint("BOTTOMRIGHT", -margin, margin)
    groupbox.background:SetVertexColor(0.1, 0.1, 0.1,  0.5)  -- Set a color so the background isn't transparent.
    ----GroupBox_SetBackColor(groupbox, 1,0,1, 1)  -- FOR TESTING.

    if title then
        groupbox.title = groupbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        groupbox.title:SetPoint("TOPLEFT", 6, 12)
        groupbox.title:SetJustifyH("LEFT")
        groupbox.title:SetText(title or "")
    end

    -- Extension functions.
    groupbox.GetBackColor       = GroupBox_GetBackColor
    groupbox.SetBackColor       = GroupBox_SetBackColor
    groupbox.SetTitleBackColor  = GroupBox_SetTitleBackColor
    groupbox.UpdateTitleSize    = GroupBox_UpdateTitleSize

    return groupbox
end


--#############################################################################
-------------------------------------------------------------------------------
-- Utility Functions.  --DJUadded--
-------------------------------------------------------------------------------
--#############################################################################


-- ****************************************************************************
local function handleGlobalMouseClick(button)
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
--~     hooksecurefunc("UIDropDownMenu_HandleGlobalMouseEvent", private.UDControls.handleGlobalMouseClick)


-- ****************************************************************************
local function DisplayAllFonts(width, height)
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


-- ****************************************************************************
local function MsgBox( msg,
                    btnText1, btnFunc1,
                    btnText2, btnFunc2,
                    customData, customData2, -- Can be tables of values if more than two data parameters are needed.
                    bShowAlertIcon, soundID, timeoutSecs, preferredIndex)
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--~ EXAMPLE 1: Basic message with a single "Okay" button.
--~     MsgBox("Job done.")
--~
--~ EXAMPLE 2: A prompt with two choices that each call a function that uses a custom data buffer (myDataBuffer).
--~     MsgBox("Bad data found!  Click OK to use it anyway, or CANCEL to restore defaults.",
--~             "Okay", function(thisStaticPopupTable, data, data2)  -- 'data2' unused in this example.
--~                             local dataBuffer = data
--~                             saveMyData(dataBuffer)
--~                         end,
--~             "Cancel", function(thisStaticPopupTable, data, reason)  -- 'reason' can be "clicked", "timeout", or "override".
--~                             local dataBuffer = data
--~                             restoreMyDefaultData(dataBuffer)
--~                         end,
--~             myDataBuffer, nil,  -- data, data2
--~             true, SOUNDKIT.IG_MAINMENU_OPEN, 0, 3)  -- Icon, Sound, Timeout, Preferred Index.
--~
--~ EXAMPLE 3: A Yes/No prompt with a single function for "Yes", and a 15 second time limit.
--~     MsgBox("Uh oh! Show help?\n\n(This message goes away after 15 seconds.)",
--~             "Yes", showMyHelp,
--~             "No", nil,
--~             nil, nil,  -- data, data2
--~             false, SOUNDKIT.ALARM_CLOCK_WARNING_3, 15)  -- Icon, Sound, Timeout, Preferred Index.
--~
--~ EXAMPLE 4: Demonstrates how to pass more than two parameters to a button's handler function.
--~     local SrcName = "My DPS Profile"
--~     local DestName = "My Tank Profile"
--~     MsgBox( 'Are you sure?\n\nThe profile "'..SrcName..'" will be copied to "'..DestName..'".',
--~             "Copy Profile", function(thisStaticPopupTable, data, data2)  -- 'data2' unused in this example.
--~                                 data.profileFrame:copyProfile( data.srcName, data.destName )
--~                             end,
--~             "Cancel", nil,
--~             {profileFrame=ProfileFrame, srcName=SrcName, destName=DestName}, nil,  -- data, data2
--~             false, SOUNDKIT.IG_MAINMENU_OPEN)  -- Icon, Sound, Timeout, Preferred Index.
--~
--~ For more info, see ...
--~     https://wowpedia.fandom.com/wiki/Creating_simple_pop-up_dialog_boxes
--~     https://wowwiki-archive.fandom.com/wiki/Creating_simple_pop-up_dialog_boxes
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
    local msgboxID = "MSGBOX_FOR_" .. kAddonFolderName

    assert(msg and type(msg) == "string" and msg ~= "")
    assert(btnFunc1 == nil or type(btnFunc1) == "function")
    assert(btnFunc2 == nil or type(btnFunc2) == "function")
    assert(bShowAlertIcon == true or bShowAlertIcon == false or bShowAlertIcon == nil)

    if (btnText1 == "" or btnText1 == nil) then btnText1 = "Okay" end
    if (btnText2 == "") then btnText2 = nil end
    if (bShowAlertIcon ~= true) then bShowAlertIcon = nil end  -- Forces it to be 'true' or 'nil'.

    _G.StaticPopupDialogs[msgboxID] =
    {
        text = (msg or ""),
        showAlert = bShowAlertIcon,
        sound = soundID,
        timeout = timeoutSecs,

        enterClicksFirstButton = true,
        hideOnEscape = true,
        whileDead = true,
        exclusive = true,  -- Makes the popup go away if any other popup is displayed.
        preferredIndex = preferredIndex or 1,  -- Which of the global StaticPopup frames to use (if available).

        button1 = btnText1,
        OnAccept = btnFunc1,

        button2 = btnText2,
        OnCancel = btnFunc2,

        OnHide = function(thisStaticPopupTable) thisStaticPopupTable.data = nil; thisStaticPopupTable.data2 = nil; end,
    }

    local msgbox = _G.StaticPopup_Show(msgboxID)
    if msgbox then
        -- Note: 'data' and 'data2' get passed to your OnAccept() function, and 'data' also is passed to OnCancel().
        msgbox.data = customData
        msgbox.data2 = customData2
    end
    return msgbox
end


-- ****************************************************************************
-- Creates the "new feature" glowy text used in the Blizzard UI for new features.
-- ****************************************************************************
local function CreateTexture_NEW(parent, bRightJustify, x, y)
    local anchor = parent
    if parent:GetObjectType() ~= "Frame" then
        parent = parent:GetParent()  -- In case caller sent us a FontString, for example.
        assert(parent:GetObjectType() == "Frame") -- Fails if we can't find a frame to use.
    end
    local tex = parent:CreateTexture(nil, "OVERLAY")
    tex:SetTexture("Interface\\Glues\\CHARACTERCREATE\\NewCharacterNotification")
    local minX, maxX, minY, maxY = 0.0, 1.0,  0.0, 0.5  -- (0.0% to 1.0%)
    if bRightJustify then
        minY, maxY = 0.5, 1.0
        tex:SetPoint("LEFT", anchor, "RIGHT", (x or 0), (y or 0))
    else -- Left justify.
        tex:SetPoint("RIGHT", anchor, "LEFT", (x or 0), (y or 0))
    end
    tex:SetTexCoord(minX, maxX, minY, maxY)
    tex:SetSize(128, 64)
    tex:SetScale(0.65)
    return tex
end


-- ****************************************************************************
-- Creates a horizontal divider (separator) line.
-- ****************************************************************************
local function CreateHorizontalDivider(parent, width, height)
    local divider = parent:CreateTexture(nil, "OVERLAY")
    divider:SetTexture("Interface\\RaidFrame\\Raid-HSeparator")
    ----divider:SetVertexColor(1,1,1, 0.5)
    divider:SetSize(width or 32, height or 12)
    return divider
end


-- ****************************************************************************
-- An object for getting width and height of a text string.
-- EXAMPLE:
--      local TextSize = private.UDControls.TextSize
--      TextSize:SetFontObject("GameFontNormalSmall")
--      print("Text Size (width, height):", TextSize:GetSize("This is the line of text to measure."))
-- ****************************************************************************
local TextSize = {
    fontString = UIParent:CreateFontString(nil, "BACKGROUND", "GameFontNormal"),

    GetSize = function(self, text)  -- TextSize:GetSize(text)
        local fs = self.fontString
        ----fs:SetHeight(1200)  -- Set to an arbitrary large height to hold all the lines in the text parameter.
        fs:SetText(text)
        local height = fs:GetStringHeight()
        local width = fs:GetUnboundedStringWidth()
        fs:SetText("")
        return width, height
    end,

    SetFontObject = function(self, fontTemplateName)  -- TextSize:SetFontObject()
        self.fontString:SetFontObject(fontTemplateName)
    end,

    SetFont = function(self, fontName, fontSize, fontFlags)  -- TextSize:SetFont()
        self.fontString:SetFont(fontName, fontSize, fontFlags)
    end,

    GetFont = function(self)  -- TextSize:GetFont()
        return self.fontString:GetFont()  -- Returns fontName, fontSize, fontFlags.
    end,
}


--#############################################################################
-------------------------------------------------------------------------------
-- Module interface.
-------------------------------------------------------------------------------
--#############################################################################

private.UDControls.VERSION = CONTROLS_VERSION

-- Exposed Functions.
private.UDControls.CreateListBox          = CreateListBox
private.UDControls.CreateCheckBox         = CreateCheckBox
private.UDControls.CreateIconButton       = CreateIconButton
private.UDControls.CreateTextureButton    = CreateTextureButton  --DJUadded
private.UDControls.CreateSlider           = CreateSlider
private.UDControls.CreateDropDown         = CreateDropDown
--~ private.UDControls.CreateEditBox          = CreateEditBox
private.UDControls.CreateOptionButton     = CreateOptionButton
private.UDControls.CreateColorSwatch      = CreateColorSwatch  --DJUadded
private.UDControls.CreateTextScrollFrame  = CreateTextScrollFrame  --DJUadded
private.UDControls.CreateGroupBox         = CreateGroupBox  --DJUadded

-- Exposed Utility Functions.  --DJUadded--
private.UDControls.handleGlobalMouseClick = handleGlobalMouseClick
private.UDControls.DisplayAllFonts        = DisplayAllFonts
private.UDControls.MsgBox                 = MsgBox
private.UDControls.CreateTexture_NEW      = CreateTexture_NEW
private.UDControls.CreateHorizontalDivider= CreateHorizontalDivider
private.UDControls.TextSize               = TextSize

--- End of File ---