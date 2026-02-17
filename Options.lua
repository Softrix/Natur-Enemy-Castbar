--[[ Natur Enemy Castbar - Options and defaults ]]--

local addonName = ...
local L = _G.Natur_L or {}

-- Group keys in display order
local GROUP_KEYS = {
	"TargetCasts", "FocusCasts", "TargetGains", "FocusGains",
	"TargetCooldowns", "FocusCooldowns", "TargetDR", "FocusDR", "CrowdControl",
}

local GROUP_TITLE_KEYS = {
	TargetCasts     = "GROUP_TARGET_CASTS",
	FocusCasts      = "GROUP_FOCUS_CASTS",
	TargetGains     = "GROUP_TARGET_GAINS",
	FocusGains      = "GROUP_FOCUS_GAINS",
	TargetCooldowns = "GROUP_TARGET_COOLDOWNS",
	FocusCooldowns  = "GROUP_FOCUS_COOLDOWNS",
	TargetDR        = "GROUP_TARGET_DR",
	FocusDR         = "GROUP_FOCUS_DR",
	CrowdControl    = "GROUP_CROWD_CONTROL",
}

local DEFAULT_TEXTURE = "Blizzard"
local DEFAULT_FONT = "Friz Quadrata TT"
local DEFAULT_BAR_WIDTH = 200
local DEFAULT_BAR_HEIGHT = 18
local DEFAULT_SPACING = 2

--- Build default options
local function GetDefaultOptions()
	local groups = {}
	for _, key in ipairs(GROUP_KEYS) do
		local titleKey = GROUP_TITLE_KEYS[key]
		groups[key] = {
			title = titleKey and L[titleKey] or key,
			texture = DEFAULT_TEXTURE,
			font = DEFAULT_FONT,
			fontSize = 10,
			fontFlags = "",
			point = "CENTER",
			relativePoint = "CENTER",
			x = 0,
			y = 0,
			width = DEFAULT_BAR_WIDTH,
			height = DEFAULT_BAR_HEIGHT,
			spacing = DEFAULT_SPACING,
			growthDirection = "DOWN",
		}
	end

	return {
		groups = groups,
		showAnchors               = true,
		showPlayerNamesOnTimers   = false,
		showFriendlyCasts    = true,
		showHostileCasts     = true,
		showFriendlyGains    = true,
		showHostileGains     = true,
		showFriendlyCooldowns = true,
		showHostileCooldowns = true,
		showFriendlyDR      = true,
		showHostileDR        = true,
		showFriendlyCC      = true,
		showHostileCC        = true,
		showDetectedHostileTargets = true,
		detectStealthClasses = true,
		flashStealthScreenBorder = true,
		playStealthSound        = true,
		announceStealthClassToChat = false,
		playSoundOnMyCCEvents    = true,
		healingWarnings         = true,
		announceMyCCApply       = false,
		announceMyCCRenews      = false,
		announceMyCCBreaks      = false,
		announceMyCCImmune      = true,
		graphicalPopups         = true,
		showMinimapIcon         = true,
		minimapButtonAngle      = 315,  -- degrees, 0=right 90=top; button orbits minimap edge
		playPvPKillingBlowSounds = true,
		playNPCKillingBlowSounds = false,
		playPvPKillingBlowSoundpack = 1,
		debugMode = false,
		settingsResetFlag = 0,
	}
end

--- Default per-character options
local function GetDefaultPerCharOptions()
	return { enabled = true }
end

--- Deep copy table (for default options structure).
local function DeepCopy(t)
	if type(t) ~= "table" then return t end
	local c = {}
	for k, v in pairs(t) do
		c[k] = (type(v) == "table" and not rawget(v, 1) and not rawget(v, 0)) and DeepCopy(v) or v
	end
	return c
end

--- Deep-merge defaults into target; only adds missing keys.
local function MergeDefaults(target, defaults)
	if type(defaults) ~= "table" then return end
	for k, v in pairs(defaults) do
		if target[k] == nil then
			if type(v) == "table" and not (v[1] or v[0]) then
				target[k] = {}
				MergeDefaults(target[k], v)
			else
				target[k] = v
			end
		elseif type(target[k]) == "table" and type(v) == "table" and not (v[1] or v[0]) then
			MergeDefaults(target[k], v)
		end
	end
end

--- Ensure NaturOptionsDB has all default keys
function Natur_Options_InitGlobalDB()
	local defaults = GetDefaultOptions()
	if not _G.NaturOptionsDB then
		_G.NaturOptionsDB = {}
	end
	MergeDefaults(_G.NaturOptionsDB, defaults)
	if not _G.NaturOptionsDB.groups then
		_G.NaturOptionsDB.groups = defaults.groups
	else
		for key, groupDefaults in pairs(defaults.groups) do
			if not _G.NaturOptionsDB.groups[key] then
				_G.NaturOptionsDB.groups[key] = {}
			end
			MergeDefaults(_G.NaturOptionsDB.groups[key], groupDefaults)
		end
	end
end

--- Ensure NaturOptionsPerCharDB has per-character entry with defaults
function Natur_Options_InitPerCharDB()
	local realm = GetRealmName()
	local char = UnitName("player")
	if not realm or not char then return end
	if not _G.NaturOptionsPerCharDB then
		_G.NaturOptionsPerCharDB = {}
	end
	if not _G.NaturOptionsPerCharDB[realm] then
		_G.NaturOptionsPerCharDB[realm] = {}
	end
	if not _G.NaturOptionsPerCharDB[realm][char] then
		_G.NaturOptionsPerCharDB[realm][char] = GetDefaultPerCharOptions()
	else
		MergeDefaults(_G.NaturOptionsPerCharDB[realm][char], GetDefaultPerCharOptions())
	end
end

--- If stored settingsResetFlag differs from NATUR_RESETFLAG, reset to defaults, save new flag
function Natur_Options_CheckResetFlag()
	local current = _G.NATUR_RESETFLAG
	local db = _G.NaturOptionsDB
	local stored = db and db.settingsResetFlag
	if current == nil or stored == current then return end
	Natur_Options_ResetToDefaults()
	_G.NaturOptionsDB.settingsResetFlag = _G.NATUR_RESETFLAG
	local msg = (L and L.MAJOR_UPDATE_RESET) or "Major update, setting structures have changed\nAddon will reset the current settings."
	if not StaticPopupDialogs["NATUR_MAJOR_UPDATE_RESET"] then
		StaticPopupDialogs["NATUR_MAJOR_UPDATE_RESET"] = {
			text = msg,
			button1 = OKAY or "Okay",
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
		}
	else
		StaticPopupDialogs["NATUR_MAJOR_UPDATE_RESET"].text = msg
	end
	StaticPopup_Show("NATUR_MAJOR_UPDATE_RESET")
end

--- Get current per-char options table
function Natur_Options_GetPerChar()
	local realm = GetRealmName()
	local char = UnitName("player")
	if not _G.NaturOptionsPerCharDB or not realm or not char then return nil end
	local realmT = _G.NaturOptionsPerCharDB[realm]
	return realmT and realmT[char] or nil
end

--- Get global options
function Natur_Options_GetGlobal()
	return _G.NaturOptionsDB
end

--- Reset addon settings to default structure (global + current character).
function Natur_Options_ResetToDefaults()
	local defaults = GetDefaultOptions()
	_G.NaturOptionsDB = DeepCopy(defaults)
	local realm = GetRealmName()
	local char = UnitName("player")
	if realm and char then
		if not _G.NaturOptionsPerCharDB then _G.NaturOptionsPerCharDB = {} end
		if not _G.NaturOptionsPerCharDB[realm] then _G.NaturOptionsPerCharDB[realm] = {} end
		_G.NaturOptionsPerCharDB[realm][char] = DeepCopy(GetDefaultPerCharOptions())
	end
	if _G.Natur_OnOptionsReset then _G.Natur_OnOptionsReset() end
	local f = _G.NaturOptionsFrame
	if f and f:IsShown() and f:GetScript("OnShow") then
		f:GetScript("OnShow")(f)
	end
end

--- Open options frame (create if needed)
function Natur_Options_Open()
	if _G.NaturOptionsFrame and _G.NaturOptionsFrame:IsShown() then
		_G.NaturOptionsFrame:Hide()
		return
	end
	-- Ensure DBs exist (e.g. if /natur used before ADDON_LOADED)
	if Natur_Options_InitGlobalDB then Natur_Options_InitGlobalDB() end
	if Natur_Options_InitPerCharDB then Natur_Options_InitPerCharDB() end
	Natur_Options_CreateFrame()
	if _G.NaturOptionsFrame then
		_G.NaturOptionsFrame:Show()
		local f = _G.NaturOptionsFrame
		if f.selectedTimerGroup then
			local titleKey = GROUP_TITLE_KEYS[f.selectedTimerGroup]
			local text = (titleKey and L[titleKey]) or f.selectedTimerGroup
			if _G.Natur_DebugPrint then _G.Natur_DebugPrint(("Adjusting timer bar settings for the %s group, adjust to your desired group."):format(text)) end
		end
	end
end

--- Create the options frame 
function Natur_Options_CreateFrame()
	if _G.NaturOptionsFrame then return end

	local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
	local db = _G.NaturOptionsDB
	local perChar = Natur_Options_GetPerChar()
	if not db or not perChar then return end

	local BANNER_INSET = 5
	local BANNER_SCALE = 2
	local BANNER_HEIGHT_SCALE = 0.82
	local bannerBaseW = 390
	local bannerBaseH = 88
	local bannerDisplayH = bannerBaseH * BANNER_SCALE * BANNER_HEIGHT_SCALE
	local frameWidth = bannerBaseW * BANNER_SCALE + BANNER_INSET * 2
	local frameHeight = 760 + (bannerDisplayH - bannerBaseH)

	local frame = CreateFrame("Frame", "NaturOptionsFrame", UIParent, "BackdropTemplate")
	frame:SetSize(frameWidth, frameHeight)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	if frame.SetBackdrop then
		frame:SetBackdrop({
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = true, tileSize = 16, edgeSize = 12,
			insets = { left = 4, right = 4, top = 4, bottom = 4 },
		})
		frame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
	end

	local versionText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	versionText:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -20)
	versionText:SetText(_G.NATUR_VERSION or "?")
	frame.versionText = versionText

	-- Banner graphic
	local banner = frame:CreateTexture(nil, "ARTWORK")
	banner:SetTexture("Interface\\AddOns\\Natur\\assets\\graphics\\optbanner.tga")
	banner:SetPoint("TOP", 0, -BANNER_INSET)
	banner:SetSize(bannerBaseW * BANNER_SCALE, bannerDisplayH)
	banner:SetHorizTile(false)
	banner:SetVertTile(false)

	local y = -(BANNER_INSET + bannerDisplayH + BANNER_INSET) - 10
	frame.checkboxes = {}
	local function AddCheckbox(label, key, isPerChar, tooltip, xOffset, noDecrement, small)
		local box = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
		box:SetPoint("TOPLEFT", 24 + (xOffset or 0), y)
		box.optionKey = key
		box.isPerChar = isPerChar
		box.label = box:CreateFontString(nil, "OVERLAY", small and "GameFontHighlightSmall" or "GameFontNormal")
		box.label:SetPoint("LEFT", box, "RIGHT", 4, 0)
		box.label:SetText(label)
		if small then
			box:SetScale(0.85)
		end
		if tooltip and tooltip ~= "" then
			box:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(tooltip)
				GameTooltip:Show()
			end)
			box:SetScript("OnLeave", function() GameTooltip:Hide() end)
		end
		box:SetChecked(isPerChar and perChar[key] or db[key])
		box:SetScript("OnClick", function(self)
			local checked = self:GetChecked()
			if isPerChar then
				perChar[key] = checked
				if _G.Natur_SetEnabled then _G.Natur_SetEnabled(checked) end
			else
				db[key] = checked
				if key == "showAnchors" and _G.Natur_ApplyAnchorVisibility then
					_G.Natur_ApplyAnchorVisibility(checked)
				end
				if (key == "showFriendlyCasts" or key == "showHostileCasts" or key == "showFriendlyGains" or key == "showHostileGains" or key == "showFriendlyCooldowns" or key == "showHostileCooldowns" or key == "showFriendlyDR" or key == "showHostileDR" or key == "showFriendlyCC" or key == "showHostileCC") and _G.Natur_UpdateCastsGroupsVisibility then
					_G.Natur_UpdateCastsGroupsVisibility()
					if (key == "showFriendlyGains" or key == "showHostileGains") then
						if _G.Natur_UpdateTargetGainsBinding then _G.Natur_UpdateTargetGainsBinding() end
						if _G.Natur_UpdateFocusGainsBinding then _G.Natur_UpdateFocusGainsBinding() end
					end
					if (key == "showFriendlyCasts" or key == "showHostileCasts") then
						if _G.Natur_UpdateTargetCast then _G.Natur_UpdateTargetCast() end
						if _G.Natur_UpdateFocusCast then _G.Natur_UpdateFocusCast() end
					end
					if (key == "showFriendlyCooldowns" or key == "showHostileCooldowns") and _G.Natur_ClearFriendlyCooldownTimers then
						_G.Natur_ClearFriendlyCooldownTimers()
					end
				end
				if key == "showPlayerNamesOnTimers" then
					if _G.Natur_UpdateTargetGainsBinding then _G.Natur_UpdateTargetGainsBinding() end
					if _G.Natur_UpdateFocusGainsBinding then _G.Natur_UpdateFocusGainsBinding() end
					if _G.Natur_UpdateTargetCast then _G.Natur_UpdateTargetCast() end
					if _G.Natur_UpdateFocusCast then _G.Natur_UpdateFocusCast() end
				end
				if key == "flashStealthScreenBorder" and checked and _G.Natur_FlashStealthBorder then
					_G.Natur_FlashStealthBorder()
				end
				if key == "playStealthSound" and checked then
					local paths = _G.NaturSoundPaths
					if paths and paths.stealth then PlaySoundFile(paths.stealth, "Master") end
				end
			end
		end)
		if not xOffset and not noDecrement then
			y = y - 24
		end
		frame.checkboxes[#frame.checkboxes + 1] = box
		return box
	end

	local addonEnabledBox = AddCheckbox(L.ADDON_ENABLED or "Addon enabled", "enabled", true, L.ADDON_ENABLED_TT, nil, true)
	frame.addonEnabledBox = addonEnabledBox
	if addonEnabledBox.label then addonEnabledBox.label:SetTextColor(0, 1, 0) end
	local showAnchorsBox = AddCheckbox(L.SHOW_ANCHORS or "Show anchors", "showAnchors", false, L.SHOW_ANCHORS_TT, 140)
	if showAnchorsBox.label then showAnchorsBox.label:SetTextColor(0, 1, 0) end
	y = y - 24
	frame.debugModeBox = AddCheckbox(L.DEBUG_MODE or "Debug mode", "debugMode", false, L.DEBUG_MODE_TT, 24, true)
	frame.debugModeBox:ClearAllPoints()
	frame.debugModeBox:SetPoint("TOPLEFT", addonEnabledBox, "BOTTOMLEFT", 44, 9)
	y = y - 24
	frame.debugModeBox:SetScale(0.85)
	if frame.debugModeBox.label then
		frame.debugModeBox.label:SetFontObject(GameFontHighlightSmall)
		frame.debugModeBox.label:SetTextColor(0, 1, 0)
	end

	y = y - 45
	local barGroupHeading = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	barGroupHeading:SetPoint("TOP", frame, "TOP", 0, y)
	barGroupHeading:SetPoint("LEFT", addonEnabledBox, "LEFT", 2, 0)
	barGroupHeading:SetText(L.BAR_GROUP_OPTIONS or "Timer Groups")
	barGroupHeading:SetTextColor(1, 1, 1)
	barGroupHeading:SetScale(0.92)
	local timerSettingsHeading = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	timerSettingsHeading:SetPoint("TOP", barGroupHeading, "TOP", 0, 0)
	timerSettingsHeading:SetPoint("LEFT", barGroupHeading, "LEFT", 410, 0)
	timerSettingsHeading:SetText(L.TIMER_SETTINGS or "Select Timer Group Settings")
	timerSettingsHeading:SetTextColor(1, 1, 1)
	timerSettingsHeading:SetScale(0.92)
	local TIMER_CONTROL_WIDTH = 210  -- same width for timer dropdowns and sliders
	local timerGroupDropdown = CreateFrame("Frame", "NaturOptionsTimerGroupDropdown", frame, "UIDropDownMenuTemplate")
	timerGroupDropdown:SetPoint("TOPLEFT", timerSettingsHeading, "BOTTOMLEFT", -20, -11)
	timerGroupDropdown:EnableMouse(true)
	timerGroupDropdown:SetScript("OnEnter", function(self)
		local tt = L.TIMER_GROUP_DROPDOWN_TT or "Select the group timer settings you wish to adjust."
		if tt and tt ~= "" then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(tt)
			GameTooltip:Show()
		end
	end)
	timerGroupDropdown:SetScript("OnLeave", function() GameTooltip:Hide() end)
	frame.timerGroupDropdown = timerGroupDropdown
	frame.selectedTimerGroup = frame.selectedTimerGroup or "TargetCasts"
	if UIDropDownMenu_SetWidth then UIDropDownMenu_SetWidth(timerGroupDropdown, TIMER_CONTROL_WIDTH) end
	if UIDropDownMenu_JustifyText then UIDropDownMenu_JustifyText(timerGroupDropdown, "LEFT") end
	local function ApplyTimerGroupSetting(key, field, value)
		local db = _G.NaturOptionsDB
		if not db or not db.groups then return end
		if not db.groups[key] then db.groups[key] = {} end
		db.groups[key][field] = value
		if _G.Natur_RefreshGroup then _G.Natur_RefreshGroup(key) end
	end

	local function RefreshTimerSettingsControls()
		local key = frame.selectedTimerGroup
		local db = _G.NaturOptionsDB
		local saved = (db and db.groups and db.groups[key]) and db.groups[key] or {}
		local h = frame.timerHeightSlider
		local w = frame.timerWidthSlider
		local growth = frame.timerGrowthDropdown
		local tex = frame.timerTextureDropdown
		local font = frame.timerFontDropdown
		local fs = frame.timerFontSizeSlider
		if h then local v = saved.height or DEFAULT_BAR_HEIGHT; h:SetValue(v); if h.valueText then h.valueText:SetText(tostring(v)) end end
		if w then local v = saved.width or DEFAULT_BAR_WIDTH; w:SetValue(v); if w.valueText then w.valueText:SetText(tostring(v)) end end
		if growth and UIDropDownMenu_SetSelectedValue then
			UIDropDownMenu_SetSelectedValue(growth, saved.growthDirection or "DOWN")
		end
		if growth and UIDropDownMenu_SetText then
			local dir = saved.growthDirection or "DOWN"
			local dirText = (L["TIMER_GROWTH_" .. dir] or dir)
			UIDropDownMenu_SetText(growth, dirText)
		end
		if tex and UIDropDownMenu_SetSelectedValue then
			UIDropDownMenu_SetSelectedValue(tex, saved.texture or DEFAULT_TEXTURE)
		end
		if tex and UIDropDownMenu_SetText then
			UIDropDownMenu_SetText(tex, saved.texture or DEFAULT_TEXTURE)
		end
		if font and UIDropDownMenu_SetSelectedValue then
			UIDropDownMenu_SetSelectedValue(font, saved.font or DEFAULT_FONT)
		end
		if font and UIDropDownMenu_SetText then
			UIDropDownMenu_SetText(font, saved.font or DEFAULT_FONT)
		end
		if fs then local v = saved.fontSize or 10; fs:SetValue(v); if fs.valueText then fs.valueText:SetText(tostring(v)) end end
	end

	local function TimerGroupDropdown_OnSelect(_, groupKey)
		frame.selectedTimerGroup = groupKey
		local titleKey = GROUP_TITLE_KEYS[groupKey]
		local text = (titleKey and L[titleKey]) or groupKey
		if _G.Natur_DebugPrint then _G.Natur_DebugPrint(("Adjusting timer bar settings for the %s group, adjust to your desired group."):format(text)) end
		if UIDropDownMenu_SetText then UIDropDownMenu_SetText(timerGroupDropdown, text) end
		RefreshTimerSettingsControls()
	end
	if UIDropDownMenu_Initialize then
		UIDropDownMenu_Initialize(timerGroupDropdown, function(self, level, menuList)
			if level and level == 1 then
				for _, groupKey in ipairs(GROUP_KEYS) do
					local titleKey = GROUP_TITLE_KEYS[groupKey]
					local info = UIDropDownMenu_CreateInfo()
					info.text = (titleKey and L[titleKey]) or groupKey
					info.value = groupKey
					info.func = TimerGroupDropdown_OnSelect
					info.arg1 = groupKey
					info.checked = (frame.selectedTimerGroup == groupKey)
					UIDropDownMenu_AddButton(info, level)
				end
			end
		end)
	end
	do
		local sel = frame.selectedTimerGroup
		local titleKey = GROUP_TITLE_KEYS[sel]
		local text = (titleKey and L[titleKey]) or sel
		if UIDropDownMenu_SetText then UIDropDownMenu_SetText(timerGroupDropdown, text) end
	end

	-- Timer group controls: height, width, growth, texture, font, font size
	local timerControlsAnchor = timerGroupDropdown
	local function addSliderLabel(parent, text, point, relPoint, x, y, relativePoint)
		local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		if relativePoint then
			label:SetPoint(point or "TOPLEFT", relPoint or parent, relativePoint, x or 0, y or 0)
		else
			label:SetPoint(point or "TOPLEFT", relPoint or parent, x or 0, y or 0)
		end
		label:SetText(text)
		return label
	end
	local function createTimerSlider(anchor, minVal, maxVal, step, xOff)
		local slider = CreateFrame("Slider", nil, frame, "BackdropTemplate")
		slider:SetSize(TIMER_CONTROL_WIDTH, 17)
		slider:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", xOff or 0, -18)
		if slider.SetOrientation then slider:SetOrientation("HORIZONTAL") end
		slider:SetMinMaxValues(minVal, maxVal)
		slider:SetValueStep(step)
		slider:SetValue(minVal)
		if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
		local thumb = slider:CreateTexture(nil, "ARTWORK")
		thumb:SetSize(16, 24)
		thumb:SetTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
		slider:SetThumbTexture(thumb)
		if slider.SetBackdrop then
			slider:SetBackdrop({
				bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
				edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
				edgeSize = 8,
				insets = { left = 2, right = 2, top = 2, bottom = 2 },
			})
			slider:SetBackdropColor(0.2, 0.2, 0.2, 0.6)
			slider:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
		end
		local valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		valueText:SetPoint("LEFT", slider, "RIGHT", 8, 0)
		slider.valueText = valueText
		valueText:SetText(tostring(minVal))
		return slider
	end
	-- Height slider
	local heightSlider = createTimerSlider(timerControlsAnchor, 8, 48, 1, 20)
	heightSlider:SetValue(DEFAULT_BAR_HEIGHT)
	heightSlider.valueText:SetText(tostring(DEFAULT_BAR_HEIGHT))
	heightSlider:SetScript("OnValueChanged", function(self, value)
		local key = frame.selectedTimerGroup
		if not key then return end
		value = math.floor(value + 0.5)
		ApplyTimerGroupSetting(key, "height", value)
		self.valueText:SetText(tostring(value))
	end)
	addSliderLabel(frame, L.TIMER_BAR_HEIGHT or "Bar height", "BOTTOMLEFT", heightSlider, 0, 4, "TOPLEFT")
	frame.timerHeightSlider = heightSlider
	timerControlsAnchor = heightSlider

	-- Width slider
	local widthSlider = createTimerSlider(timerControlsAnchor, 80, 500, 5, 0)
	widthSlider:SetValue(DEFAULT_BAR_WIDTH)
	widthSlider.valueText:SetText(tostring(DEFAULT_BAR_WIDTH))
	widthSlider:SetScript("OnValueChanged", function(self, value)
		local key = frame.selectedTimerGroup
		if not key then return end
		value = math.floor(value + 0.5)
		ApplyTimerGroupSetting(key, "width", value)
		self.valueText:SetText(tostring(value))
	end)
	addSliderLabel(frame, L.TIMER_BAR_WIDTH or "Bar width", "BOTTOMLEFT", widthSlider, 0, 4, "TOPLEFT")
	frame.timerWidthSlider = widthSlider
	timerControlsAnchor = widthSlider

	-- Growth direction dropdown
	local growthDropdown = CreateFrame("Frame", "NaturOptionsTimerGrowthDropdown", frame, "UIDropDownMenuTemplate")
	growthDropdown:SetPoint("TOPLEFT", timerControlsAnchor, "BOTTOMLEFT", -20, -18)
	if UIDropDownMenu_SetWidth then UIDropDownMenu_SetWidth(growthDropdown, TIMER_CONTROL_WIDTH) end
	local growthOptions = { { value = "DOWN" }, { value = "UP" }, { value = "LEFT" }, { value = "RIGHT" } }
	if UIDropDownMenu_Initialize then
		UIDropDownMenu_Initialize(growthDropdown, function(self, level, menuList)
			if level and level == 1 then
				for _, g in ipairs(growthOptions) do
					local info = UIDropDownMenu_CreateInfo()
					info.text = L["TIMER_GROWTH_" .. g.value] or g.value
					info.value = g.value
					info.arg1 = g.value
					info.func = function(_, val)
						local key = frame.selectedTimerGroup
						if key then
							ApplyTimerGroupSetting(key, "growthDirection", val)
							if UIDropDownMenu_SetSelectedValue then UIDropDownMenu_SetSelectedValue(growthDropdown, val) end
							if UIDropDownMenu_SetText then UIDropDownMenu_SetText(growthDropdown, L["TIMER_GROWTH_" .. val] or val) end
						end
					end
					local cur = (frame.selectedTimerGroup and _G.NaturOptionsDB and _G.NaturOptionsDB.groups and _G.NaturOptionsDB.groups[frame.selectedTimerGroup]) and _G.NaturOptionsDB.groups[frame.selectedTimerGroup].growthDirection or "DOWN"
					info.checked = (cur == g.value)
					UIDropDownMenu_AddButton(info, level)
				end
			end
		end)
	end
	addSliderLabel(frame, L.TIMER_GROWTH_DIRECTION or "Grow direction", "BOTTOMLEFT", growthDropdown, 18, 4, "TOPLEFT")
	frame.timerGrowthDropdown = growthDropdown
	timerControlsAnchor = growthDropdown

	-- Texture dropdown
	local textureDropdown = CreateFrame("Frame", "NaturOptionsTimerTextureDropdown", frame, "UIDropDownMenuTemplate")
	textureDropdown:SetPoint("TOPLEFT", timerControlsAnchor, "BOTTOMLEFT", 0, -18)
	if UIDropDownMenu_SetWidth then UIDropDownMenu_SetWidth(textureDropdown, TIMER_CONTROL_WIDTH) end
	if UIDropDownMenu_Initialize then
		UIDropDownMenu_Initialize(textureDropdown, function(self, level, menuList)
			if level and level == 1 then
				local list = (LSM and LSM:HashTable("statusbar")) or {}
				local keys = {}
				for k in pairs(list) do keys[#keys + 1] = k end
				table.sort(keys)
				if #keys == 0 then keys[1] = DEFAULT_TEXTURE end
				for _, k in ipairs(keys) do
					local info = UIDropDownMenu_CreateInfo()
					info.text = k
					info.value = k
					info.arg1 = k
					info.func = function(_, val)
						local key = frame.selectedTimerGroup
						if key and val then
							ApplyTimerGroupSetting(key, "texture", val)
							if UIDropDownMenu_SetSelectedValue then UIDropDownMenu_SetSelectedValue(textureDropdown, val) end
							if UIDropDownMenu_SetText then UIDropDownMenu_SetText(textureDropdown, val) end
						end
					end
					local cur = (frame.selectedTimerGroup and _G.NaturOptionsDB and _G.NaturOptionsDB.groups and _G.NaturOptionsDB.groups[frame.selectedTimerGroup]) and _G.NaturOptionsDB.groups[frame.selectedTimerGroup].texture or DEFAULT_TEXTURE
					info.checked = (cur == k)
					UIDropDownMenu_AddButton(info, level)
				end
			end
		end)
	end
	addSliderLabel(frame, L.TIMER_TEXTURE or "Texture", "BOTTOMLEFT", textureDropdown, 18, 4, "TOPLEFT")
	frame.timerTextureDropdown = textureDropdown
	timerControlsAnchor = textureDropdown

	-- Font dropdown
	local fontDropdown = CreateFrame("Frame", "NaturOptionsTimerFontDropdown", frame, "UIDropDownMenuTemplate")
	fontDropdown:SetPoint("TOPLEFT", timerControlsAnchor, "BOTTOMLEFT", 0, -18)
	if UIDropDownMenu_SetWidth then UIDropDownMenu_SetWidth(fontDropdown, TIMER_CONTROL_WIDTH) end
	if UIDropDownMenu_Initialize then
		UIDropDownMenu_Initialize(fontDropdown, function(self, level, menuList)
			if level and level == 1 then
				local list = (LSM and LSM:HashTable("font")) or {}
				local keys = {}
				for k in pairs(list) do keys[#keys + 1] = k end
				table.sort(keys)
				if #keys == 0 then keys[1] = DEFAULT_FONT end
				for _, k in ipairs(keys) do
					local info = UIDropDownMenu_CreateInfo()
					info.text = k
					info.value = k
					info.arg1 = k
					info.func = function(_, val)
						local key = frame.selectedTimerGroup
						if key and val then
							ApplyTimerGroupSetting(key, "font", val)
							if UIDropDownMenu_SetSelectedValue then UIDropDownMenu_SetSelectedValue(fontDropdown, val) end
							if UIDropDownMenu_SetText then UIDropDownMenu_SetText(fontDropdown, val) end
						end
					end
					local cur = (frame.selectedTimerGroup and _G.NaturOptionsDB and _G.NaturOptionsDB.groups and _G.NaturOptionsDB.groups[frame.selectedTimerGroup]) and _G.NaturOptionsDB.groups[frame.selectedTimerGroup].font or DEFAULT_FONT
					info.checked = (cur == k)
					UIDropDownMenu_AddButton(info, level)
				end
			end
		end)
	end
	addSliderLabel(frame, L.TIMER_FONT or "Font", "BOTTOMLEFT", fontDropdown, 18, 4, "TOPLEFT")
	frame.timerFontDropdown = fontDropdown
	timerControlsAnchor = fontDropdown

	-- Font size slider
	local fontSizeSlider = createTimerSlider(timerControlsAnchor, 6, 24, 1, 20)
	fontSizeSlider:SetValue(10)
	fontSizeSlider.valueText:SetText("10")
	fontSizeSlider:SetScript("OnValueChanged", function(self, value)
		local key = frame.selectedTimerGroup
		if not key then return end
		value = math.floor(value + 0.5)
		ApplyTimerGroupSetting(key, "fontSize", value)
		self.valueText:SetText(tostring(value))
	end)
	addSliderLabel(frame, L.TIMER_FONT_SIZE or "Font size", "BOTTOMLEFT", fontSizeSlider, 0, 4, "TOPLEFT")
	frame.timerFontSizeSlider = fontSizeSlider

	frame.RefreshTimerSettingsControls = RefreshTimerSettingsControls
	RefreshTimerSettingsControls()

	y = y - 24
	local showPlayerNamesBox = AddCheckbox(L.SHOW_PLAYER_NAMES_ON_TIMERS or "Include player names on timer bars", "showPlayerNamesOnTimers", false, L.SHOW_PLAYER_NAMES_ON_TIMERS_TT, nil, nil, true)
	showPlayerNamesBox:ClearAllPoints()
	showPlayerNamesBox:SetPoint("TOPLEFT", barGroupHeading, "BOTTOMLEFT", -2, -4)
	local showFriendlyGainsBox = AddCheckbox(L.SHOW_FRIENDLY_GAINS or "Friendly Gains", "showFriendlyGains", false, L.SHOW_FRIENDLY_GAINS_TT, nil, nil, true)
	local showFriendlyCooldownsBox = AddCheckbox(L.SHOW_FRIENDLY_COOLDOWNS or "Friendly Cooldowns", "showFriendlyCooldowns", false, L.SHOW_FRIENDLY_COOLDOWNS_TT, nil, nil, true)
	local showFriendlyDRBox = AddCheckbox(L.SHOW_FRIENDLY_DR or "Friendly DR's", "showFriendlyDR", false, L.SHOW_FRIENDLY_DR_TT, nil, nil, true)
	local showFriendlyCCBox = AddCheckbox(L.SHOW_FRIENDLY_CC or "Friendly CC's", "showFriendlyCC", false, L.SHOW_FRIENDLY_CC_TT, nil, nil, true)
	showFriendlyCooldownsBox:ClearAllPoints()
	showFriendlyCooldownsBox:SetPoint("TOPLEFT", showFriendlyGainsBox, "BOTTOMLEFT", 0, 5)
	showFriendlyDRBox:ClearAllPoints()
	showFriendlyDRBox:SetPoint("TOPLEFT", showFriendlyCooldownsBox, "BOTTOMLEFT", 0, 5)
	showFriendlyCCBox:ClearAllPoints()
	showFriendlyCCBox:SetPoint("TOPLEFT", showFriendlyDRBox, "BOTTOMLEFT", 0, 5)
	local stealthHeading = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	stealthHeading:SetPoint("TOPLEFT", showFriendlyCCBox, "BOTTOMLEFT", 0, -20)
	stealthHeading:SetText(L.STEALTH_CLASS_DETECTION or "Stealth Class Detection")
	stealthHeading:SetTextColor(1, 1, 1)
	stealthHeading:SetScale(0.92)
	y = y - 12

	local showFriendlyCastsBox = AddCheckbox(L.SHOW_FRIENDLY_CASTS or "Friendly Casts", "showFriendlyCasts", false, L.SHOW_FRIENDLY_CASTS_TT, nil, nil, true)
	showFriendlyCastsBox:ClearAllPoints()
	showFriendlyCastsBox:SetPoint("TOPLEFT", showPlayerNamesBox, "BOTTOMLEFT", 0, 3)
	local showHostileCastsBox = AddCheckbox(L.SHOW_HOSTILE_CASTS or "Hostile Casts", "showHostileCasts", false, L.SHOW_HOSTILE_CASTS_TT, nil, nil, true)
	showHostileCastsBox:ClearAllPoints()
	showHostileCastsBox:SetPoint("TOP", showFriendlyCastsBox, "TOP", 0, 0)
	showHostileCastsBox:SetPoint("LEFT", showFriendlyCastsBox.label, "RIGHT", 50, 0)
	showFriendlyGainsBox:ClearAllPoints()
	showFriendlyGainsBox:SetPoint("TOPLEFT", showFriendlyCastsBox, "BOTTOMLEFT", 0, 5)
	local detectStealthBox = AddCheckbox(L.DETECT_STEALTH_CLASSES or "Detect Stealth Classes", "detectStealthClasses", false, L.DETECT_STEALTH_CLASSES_TT, nil, nil, true)
	detectStealthBox:ClearAllPoints()
	detectStealthBox:SetPoint("TOPLEFT", stealthHeading, "BOTTOMLEFT", -2, -4)
	local showHostileGainsBox = AddCheckbox(L.SHOW_HOSTILE_GAINS or "Hostile Gains", "showHostileGains", false, L.SHOW_HOSTILE_GAINS_TT, nil, nil, true)
	showHostileGainsBox:ClearAllPoints()
	showHostileGainsBox:SetPoint("TOP", showFriendlyGainsBox, "TOP", 0, 0)
	showHostileGainsBox:SetPoint("LEFT", showHostileCastsBox, "LEFT", 0, 0)
	local flashStealthBorderBox = AddCheckbox(L.FLASH_STEALTH_SCREEN_BORDER or "Flash Screen Border", "flashStealthScreenBorder", false, L.FLASH_STEALTH_SCREEN_BORDER_TT, nil, nil, true)
	flashStealthBorderBox:ClearAllPoints()
	flashStealthBorderBox:SetPoint("TOPLEFT", detectStealthBox, "BOTTOMLEFT", 30, 8)
	local showHostileCooldownsBox = AddCheckbox(L.SHOW_HOSTILE_COOLDOWNS or "Hostile Cooldowns", "showHostileCooldowns", false, L.SHOW_HOSTILE_COOLDOWNS_TT, nil, nil, true)
	showHostileCooldownsBox:ClearAllPoints()
	showHostileCooldownsBox:SetPoint("TOP", showFriendlyCooldownsBox, "TOP", 0, 0)
	showHostileCooldownsBox:SetPoint("LEFT", showHostileGainsBox, "LEFT", 0, 0)
	local playStealthSoundBox = AddCheckbox(L.PLAY_STEALTH_SOUND or "Play sound", "playStealthSound", false, L.PLAY_STEALTH_SOUND_TT, nil, nil, true)
	playStealthSoundBox:ClearAllPoints()
	playStealthSoundBox:SetPoint("TOPLEFT", flashStealthBorderBox, "BOTTOMLEFT", 0, 8)
	local showHostileDRBox = AddCheckbox(L.SHOW_HOSTILE_DR or "Hostile DR's", "showHostileDR", false, L.SHOW_HOSTILE_DR_TT, nil, nil, true)
	showHostileDRBox:ClearAllPoints()
	showHostileDRBox:SetPoint("TOP", showFriendlyDRBox, "TOP", 0, 0)
	showHostileDRBox:SetPoint("LEFT", showHostileCooldownsBox, "LEFT", 0, 0)
	local announceStealthBox = AddCheckbox(L.ANNOUNCE_STEALTH_CLASS_TO_CHAT or "Announce to chat", "announceStealthClassToChat", false, L.ANNOUNCE_STEALTH_CLASS_TO_CHAT_TT, nil, nil, true)
	announceStealthBox:ClearAllPoints()
	announceStealthBox:SetPoint("TOPLEFT", playStealthSoundBox, "BOTTOMLEFT", 0, 8)
	frame.stealthDependentBoxes = { flashStealthBorderBox, playStealthSoundBox, announceStealthBox }
	local showHostileCCBox = AddCheckbox(L.SHOW_HOSTILE_CC or "Hostile CC's", "showHostileCC", false, L.SHOW_HOSTILE_CC_TT, nil, nil, true)
	showHostileCCBox:ClearAllPoints()
	showHostileCCBox:SetPoint("TOP", showFriendlyCCBox, "TOP", 0, 0)
	showHostileCCBox:SetPoint("LEFT", showHostileDRBox, "LEFT", 0, 0)

	local ccKbHeading = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	ccKbHeading:SetPoint("TOP", announceStealthBox, "BOTTOM", 0, -16)
	ccKbHeading:SetPoint("LEFT", stealthHeading, "LEFT", 0, 0)
	ccKbHeading:SetText(L.CC_AND_KILLING_BLOW or "Crowd Control & Killing Blow Settings")
	ccKbHeading:SetTextColor(1, 1, 1)
	ccKbHeading:SetScale(0.92)
	local playSoundCCBreakBox = AddCheckbox(L.PLAY_SOUND_ON_MY_CC or "Play Crowd Control Sounds", "playSoundOnMyCCEvents", false, L.PLAY_SOUND_ON_MY_CC_TT, nil, nil, true)
	playSoundCCBreakBox:ClearAllPoints()
	playSoundCCBreakBox:SetPoint("TOPLEFT", ccKbHeading, "BOTTOMLEFT", -2, -4)
	local healingWarningsBox = AddCheckbox(L.HEALING_WARNINGS or "Hostile healing warning", "healingWarnings", false, L.HEALING_WARNINGS_TT or "Get notified when your hostile target or focus casts\na healing spell you can interrupt.", nil, nil, true)
	healingWarningsBox:ClearAllPoints()
	healingWarningsBox:SetPoint("TOPLEFT", playSoundCCBreakBox, "BOTTOMLEFT", 0, 7)
	local announceMyCCApplyBox = AddCheckbox(L.ANNOUNCE_MY_CC_APPLY or "Announce my CC's", "announceMyCCApply", false, L.ANNOUNCE_MY_CC_APPLY_TT, nil, nil, true)
	announceMyCCApplyBox:ClearAllPoints()
	announceMyCCApplyBox:SetPoint("TOPLEFT", healingWarningsBox, "BOTTOMLEFT", 0, 7)
	local announceMyCCImmuneBox = AddCheckbox(L.ANNOUNCE_MY_CC_IMMUNE or "Announce immune", "announceMyCCImmune", false, L.ANNOUNCE_MY_CC_IMMUNE_TT, nil, nil, true)
	announceMyCCImmuneBox:ClearAllPoints()
	announceMyCCImmuneBox:SetPoint("TOP", announceMyCCApplyBox, "TOP", 0, 0)
	announceMyCCImmuneBox:SetPoint("LEFT", announceMyCCApplyBox.label, "RIGHT", 40, 0)
	-- Invisible anchor so "Other Settings" position can be adjusted in one place (avoids dual-SetPoint quirks)
	local otherSettingsAnchor = CreateFrame("Frame", nil, frame)
	otherSettingsAnchor:SetSize(1, 1)
	otherSettingsAnchor:SetPoint("LEFT", frame.timerFontSizeSlider, "LEFT", 0, 0)
	otherSettingsAnchor:SetPoint("TOP", playSoundCCBreakBox, "BOTTOM", 0, -3)
	local otherSettingsHeading = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	otherSettingsHeading:SetText(L.OTHER_SETTINGS or "Other Settings")
	otherSettingsHeading:SetTextColor(1, 1, 1)
	otherSettingsHeading:SetScale(0.92)
	otherSettingsHeading:ClearAllPoints()
	otherSettingsHeading:SetPoint("TOPLEFT", otherSettingsAnchor, "TOPLEFT", 0, 0)
	-- Healing Warnings: place directly under "Other Settings" (no other controls moved)
	healingWarningsBox:ClearAllPoints()
	healingWarningsBox:SetPoint("TOPLEFT", otherSettingsHeading, "BOTTOMLEFT", -2, -4)
	local graphicalPopupsBox = AddCheckbox(L.GRAPHICAL_POPUPS or "Graphical popups", "graphicalPopups", false, L.GRAPHICAL_POPUPS_TT or "Show Batman-style popup graphics (e.g. immune, interrupt) when they occur.", nil, nil, true)
	graphicalPopupsBox:ClearAllPoints()
	graphicalPopupsBox:SetPoint("TOPLEFT", healingWarningsBox, "BOTTOMLEFT", 0, 7)
	announceMyCCApplyBox:ClearAllPoints()
	announceMyCCApplyBox:SetPoint("TOPLEFT", playSoundCCBreakBox, "BOTTOMLEFT", 0, 7)
	local announceMyCCRenewsBox = AddCheckbox(L.ANNOUNCE_MY_CC_RENEWS or "Announce my renewed CC's", "announceMyCCRenews", false, L.ANNOUNCE_MY_CC_RENEWS_TT, nil, nil, true)
	announceMyCCRenewsBox:ClearAllPoints()
	announceMyCCRenewsBox:SetPoint("TOPLEFT", announceMyCCApplyBox, "BOTTOMLEFT", 0, 7)
	local announceMyCCBreaksBox = AddCheckbox(L.ANNOUNCE_MY_CC_BREAKS or "Announce my CC breaks", "announceMyCCBreaks", false, L.ANNOUNCE_MY_CC_BREAKS_TT, nil, nil, true)
	announceMyCCBreaksBox:ClearAllPoints()
	announceMyCCBreaksBox:SetPoint("TOPLEFT", announceMyCCRenewsBox, "BOTTOMLEFT", 0, 7)
	local playPvPKillingBlowBox = AddCheckbox(L.PLAY_PVP_KILLING_BLOW_SOUNDS or "Play PvP killing blow sounds", "playPvPKillingBlowSounds", false, L.PLAY_PVP_KILLING_BLOW_SOUNDS_TT, nil, nil, true)
	playPvPKillingBlowBox:ClearAllPoints()
	playPvPKillingBlowBox:SetPoint("TOPLEFT", announceMyCCBreaksBox, "BOTTOMLEFT", 0, 7)
	local playNPCKillingBlowBox = AddCheckbox(L.PLAY_NPC_KILLING_BLOW_SOUNDS or "Play killing blow sounds on NPCs (questing)", "playNPCKillingBlowSounds", false, L.PLAY_NPC_KILLING_BLOW_SOUNDS_TT, nil, nil, true)
	playNPCKillingBlowBox:ClearAllPoints()
	playNPCKillingBlowBox:SetPoint("TOPLEFT", playPvPKillingBlowBox, "BOTTOMLEFT", 30, 8)
	local soundpackDropdown = CreateFrame("Frame", "NaturOptionsPvPKillingBlowSoundpackDropdown", frame, "UIDropDownMenuTemplate")
	soundpackDropdown:SetPoint("TOPLEFT", playNPCKillingBlowBox, "BOTTOMLEFT", -15, -18)
	if UIDropDownMenu_SetWidth then UIDropDownMenu_SetWidth(soundpackDropdown, 150) end
	if UIDropDownMenu_JustifyText then UIDropDownMenu_JustifyText(soundpackDropdown, "LEFT") end
	if UIDropDownMenu_Initialize then
		UIDropDownMenu_Initialize(soundpackDropdown, function(self, level, menuList)
			if level and level == 1 then
				for i = 1, 2 do
					local info = UIDropDownMenu_CreateInfo()
					info.text = "Soundpack " .. i
					info.value = i
					info.arg1 = i
					info.func = function(_, val)
						local db = _G.NaturOptionsDB
						if db then
							db.playPvPKillingBlowSoundpack = val
							if UIDropDownMenu_SetSelectedValue then UIDropDownMenu_SetSelectedValue(soundpackDropdown, val) end
							if UIDropDownMenu_SetText then UIDropDownMenu_SetText(soundpackDropdown, "Soundpack " .. val) end
							-- Preview first sound from selected pack
							local paths = _G.NaturSoundPaths
							local pack = paths and (val == 2 and paths.killingBlowVoicepack2 or paths.killingBlowVoicepack1)
							local firstPath = pack and pack[1]
							if firstPath then PlaySoundFile(firstPath, "Master") end
						end
					end
					local cur = (_G.NaturOptionsDB and _G.NaturOptionsDB.playPvPKillingBlowSoundpack) or 1
					info.checked = (cur == i)
					UIDropDownMenu_AddButton(info, level)
				end
			end
		end)
	end
	local db = _G.NaturOptionsDB
	local initialSoundpack = (db and (db.playPvPKillingBlowSoundpack == 1 or db.playPvPKillingBlowSoundpack == 2)) and db.playPvPKillingBlowSoundpack or 1
	if UIDropDownMenu_SetSelectedValue then UIDropDownMenu_SetSelectedValue(soundpackDropdown, initialSoundpack) end
	if UIDropDownMenu_SetText then UIDropDownMenu_SetText(soundpackDropdown, "Soundpack " .. initialSoundpack) end
	addSliderLabel(frame, L.PVP_KILLING_BLOW_SOUNDPACK or "Soundpack", "BOTTOMLEFT", soundpackDropdown, 18, 4, "TOPLEFT")
	frame.pvpKillingBlowSoundpackDropdown = soundpackDropdown
	frame.pvpKillingBlowDependentBoxes = { playNPCKillingBlowBox }

	local creditsTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	creditsTitle:SetPoint("TOP", frame.versionText, "BOTTOM", 0, -19)
	creditsTitle:SetPoint("RIGHT", frame, "RIGHT", -19, 0)
	creditsTitle:SetText(L.OPTIONS_CREDITS_TITLE or "Natur Enemy Castbar - Classic")
	creditsTitle:SetTextColor(1, 0.82, 0)
	creditsTitle:SetFont(creditsTitle:GetFont(), 14, "OUTLINE")
	creditsTitle:SetJustifyH("RIGHT")
	local creditsBody = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	creditsBody:SetPoint("TOP", creditsTitle, "BOTTOM", 0, -4)
	creditsBody:SetPoint("RIGHT", frame, "RIGHT", -19, 0)
	creditsBody:SetWidth(frame:GetWidth() - 48)
	creditsBody:SetJustifyH("RIGHT")
	creditsBody:SetNonSpaceWrap(true)
	creditsBody:SetText(L.OPTIONS_CREDITS_BODY or "Written by Codermik\n\nJoin Discord for quick support, or to\nshare ideas or offer feedback:\n\n|cff00e0ffhttps://discord.gg/R6EkZ94TKK|r")

	local close = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	close:SetSize(120, 22)
	close:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -24, 16)
	close:SetText(CLOSE or "Close")
	close:SetScript("OnClick", function() frame:Hide() end)

	local testTimers = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	testTimers:SetSize(100, 22)
	testTimers:SetPoint("BOTTOMRIGHT", close, "BOTTOMLEFT", -10, 0)
	testTimers:SetText((L and L.TEST_TIMERS) or "Test timers")
	testTimers:SetScript("OnClick", function()
		if _G.Natur_AddTestTimers then _G.Natur_AddTestTimers() end
		if _G.Natur_ShowPopup then _G.Natur_ShowPopup("interrupt") end
	end)

	StaticPopupDialogs["NATUR_RESET_DEFAULTS"] = {
		text = (L and L.RESET_DEFAULTS_CONFIRM) or "Are you sure you want to reset all settings to defaults?",
		button1 = YES or "Yes",
		button2 = CANCEL or "Cancel",
		OnAccept = function()
			if Natur_Options_ResetToDefaults then Natur_Options_ResetToDefaults() end
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
	}

	local resetDefaults = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	resetDefaults:SetSize(110, 22)
	resetDefaults:SetPoint("BOTTOMRIGHT", testTimers, "BOTTOMLEFT", -10, 0)
	resetDefaults:SetText((L and L.RESET_DEFAULTS) or "Reset Defaults")
	resetDefaults:SetScript("OnClick", function()
		StaticPopup_Show("NATUR_RESET_DEFAULTS")
	end)

	frame:SetScript("OnShow", function()
		local pc = Natur_Options_GetPerChar()
		local d = Natur_Options_GetGlobal()
		if not pc or not d then return end
		for _, box in ipairs(frame.checkboxes) do
			local val = box.isPerChar and pc[box.optionKey] or d[box.optionKey]
			if val ~= nil then box:SetChecked(val) end
		end
		local detectOn = d.detectStealthClasses
		for _, box in ipairs(frame.stealthDependentBoxes or {}) do
			if detectOn then box:Enable() else box:Disable() end
		end
		local pvpKbOn = d.playPvPKillingBlowSounds
		for _, box in ipairs(frame.pvpKillingBlowDependentBoxes or {}) do
			if pvpKbOn then box:Enable() else box:Disable() end
		end
		if frame.pvpKillingBlowSoundpackDropdown then
			local ddBtn = frame.pvpKillingBlowSoundpackDropdown.Button
			if ddBtn then if pvpKbOn then ddBtn:Enable() else ddBtn:Disable() end end
			local soundpackVal = (d.playPvPKillingBlowSoundpack == 1 or d.playPvPKillingBlowSoundpack == 2) and d.playPvPKillingBlowSoundpack or 1
			if UIDropDownMenu_SetSelectedValue then UIDropDownMenu_SetSelectedValue(frame.pvpKillingBlowSoundpackDropdown, soundpackVal) end
			if UIDropDownMenu_SetText then UIDropDownMenu_SetText(frame.pvpKillingBlowSoundpackDropdown, "Soundpack " .. soundpackVal) end
		end
		local addonOn = pc.enabled ~= false
		if frame.debugModeBox then
			if addonOn then frame.debugModeBox:Enable() else frame.debugModeBox:Disable() end
		end
		if frame.RefreshTimerSettingsControls then frame.RefreshTimerSettingsControls() end
	end)

	-- When "Detect Stealth Classes" is toggled, enable/disable the dependent checkboxes (flash, sound, announce)
	for _, box in ipairs(frame.checkboxes) do
		if box.optionKey == "detectStealthClasses" then
			local oldOnClick = box:GetScript("OnClick")
			box:SetScript("OnClick", function(self)
				oldOnClick(self)
				if not box.isPerChar then
					for _, b in ipairs(frame.stealthDependentBoxes or {}) do
						if self:GetChecked() then b:Enable() else b:Disable() end
					end
				end
			end)
			break
		end
	end
	-- When "Play PvP killing blow sounds" is toggled, enable/disable the NPC killing blow checkbox
	for _, box in ipairs(frame.checkboxes) do
		if box.optionKey == "playPvPKillingBlowSounds" then
			local oldOnClick = box:GetScript("OnClick")
			box:SetScript("OnClick", function(self)
				oldOnClick(self)
				if not box.isPerChar then
					for _, b in ipairs(frame.pvpKillingBlowDependentBoxes or {}) do
						if self:GetChecked() then b:Enable() else b:Disable() end
					end
					if frame.pvpKillingBlowSoundpackDropdown and frame.pvpKillingBlowSoundpackDropdown.Button then
						if self:GetChecked() then frame.pvpKillingBlowSoundpackDropdown.Button:Enable() else frame.pvpKillingBlowSoundpackDropdown.Button:Disable() end
					end
				end
			end)
			break
		end
	end
	-- When "Addon enabled" is toggled, enable/disable the Debug mode checkbox
	for _, box in ipairs(frame.checkboxes) do
		if box.optionKey == "enabled" then
			local oldOnClick = box:GetScript("OnClick")
			box:SetScript("OnClick", function(self)
				oldOnClick(self)
				if frame.debugModeBox then
					if self:GetChecked() then frame.debugModeBox:Enable() else frame.debugModeBox:Disable() end
				end
			end)
			break
		end
	end
end

--- Slash command
SLASH_NATUR1 = "/natur"
SLASH_NATUR2 = "/naturcastbar"
SlashCmdList["NATUR"] = function(msg)
	msg = msg and strtrim(msg):lower()
	if msg == "options" or msg == "config" or msg == "" then
		Natur_Options_Open()
	elseif msg == "debug" then
		if Natur_Options_InitGlobalDB then Natur_Options_InitGlobalDB() end
		local db = _G.NaturOptionsDB
		if db then
			db.debugMode = not db.debugMode
			local L = _G.Natur_L
			local msg = db.debugMode and (L and L.DEBUG_MODE_ON or "Debug mode on") or (L and L.DEBUG_MODE_OFF or "Debug mode off")
			local name = (L and L.ADDON_NAME) or "Natur"
			print("|cffff8800" .. name .. "|r|cffffffff : " .. msg .. ".|r")
		end
		if _G.Natur_DebugPrint then
			local L = _G.Natur_L
			_G.Natur_DebugPrint((L and L.DEBUG_SLASH_TOGGLED) or "Slash debug toggled.")
		end
	elseif msg == "togglemm" then
		if Natur_Options_InitGlobalDB then Natur_Options_InitGlobalDB() end
		local db = _G.NaturOptionsDB
		if db then
			db.showMinimapIcon = not db.showMinimapIcon
			local L = _G.Natur_L
			local name = (L and L.ADDON_NAME) or "Natur"
			local stateMsg = db.showMinimapIcon and (L and L.MINIMAP_ICON_SHOWN or "Minimap icon shown.") or (L and L.MINIMAP_ICON_HIDDEN or "Minimap icon hidden.")
			local text = "|cff00e0ff" .. name .. "|r|cffffffff : " .. stateMsg .. "|r"
			if DEFAULT_CHAT_FRAME then
				DEFAULT_CHAT_FRAME:AddMessage(text)
			else
				print(text)
			end
			if _G.Natur_MinimapButton_Update then
				_G.Natur_MinimapButton_Update()
			end
		end
	else
		local L = _G.Natur_L
		local name = (L and L.ADDON_NAME) or "Natur"
		print("|cff00e0ff" .. name .. "|r|cffffffff : /natur or /natur options - open options; /natur debug - toggle debug; /natur togglemm - toggle minimap icon|r")
	end
end
