--[[ 

		Natur Enemy Castbar 
		For Classic Era, Hardcore, SoD, TBC Anniversary & Classic MoP
		Author: Codermik
		Version: 1.0.x
		License: MIT
		Description: Shows timers for hostile targets and focus, including casts, gains, cooldowns, diminish returns, crowd controls and interrupts.
		Dependencies: LibSharedMedia-3.0
		Dependencies: NaturTimers
		Dependencies: CallbackHandler-1.0

]]--

local addonName = ...
local NT = _G.NaturTimers
if not NT then return end

local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
local DEFAULT_TEXTURE = "Interface\\TargetingFrame\\UI-StatusBar"
local COMBATLOG_OBJECT_REACTION_HOSTILE = 0x40
local COMBATLOG_OBJECT_CONTROL_PLAYER = 0x00000100
local DEFAULT_FONT_PATH = "Fonts\\FRIZQT__.TTF"
local DEFAULT_FONT_SIZE = 10
local DEFAULT_FONT_FLAGS = ""

local NaturKillingBlowState = { currentIndex = 1, lastPlayTime = 0 }

-- version information, version x.x.date
local NATUR_VERSION = "1.0.170226"		-- x.x.ddmmyy
local NATUR_RESETFLAG = 0				-- only change this value if you need to force a settings db reset
_G.NATUR_VERSION = NATUR_VERSION
_G.NATUR_RESETFLAG = NATUR_RESETFLAG

--	Nine timer groups. 
local GROUP_DEFS = {
	{ key = "TargetCasts",     sortOrder = "none",             defaultTitle = "Target Casts" },
	{ key = "FocusCasts",      sortOrder = "none",             defaultTitle = "Focus Casts" },
	{ key = "TargetGains",     sortOrder = "remaining_asc",    defaultTitle = "Target Gains" },
	{ key = "FocusGains",      sortOrder = "remaining_asc",   defaultTitle = "Focus Gains" },
	{ key = "TargetCooldowns", sortOrder = "remaining_asc",    defaultTitle = "Target Cooldowns" },
	{ key = "FocusCooldowns",  sortOrder = "remaining_asc",   defaultTitle = "Focus Cooldowns" },
	{ key = "TargetDR",        sortOrder = "remaining_asc",    defaultTitle = "Target Diminish Returns" },
	{ key = "FocusDR",         sortOrder = "remaining_asc",    defaultTitle = "Focus Diminish Returns" },
	{ key = "CrowdControl",    sortOrder = "remaining_asc",  defaultTitle = "Crowd Controls" },
}

--- Red border flash frame for stealth alert (created on first use)
local function GetStealthFlashFrame()
	if _G.NaturStealthFlashFrame then return _G.NaturStealthFlashFrame end
	local thickness = 12
	local r, g, b, a = 1, 0, 0, 0.85
	local f = CreateFrame("Frame", "NaturStealthFlashFrame", UIParent)
	f:SetFrameStrata("FULLSCREEN_DIALOG")
	f:SetFrameLevel(1000)
	f:SetPoint("CENTER")
	f:EnableMouse(false)
	f:SetAlpha(0)
	f.bars = {}
	for i, point in ipairs({ { "TOP", 0, 0 }, { "BOTTOM", 0, 0 }, { "LEFT", 0, 0 }, { "RIGHT", 0, 0 } }) do
		local anchor, x, y = point[1], point[2], point[3]
		local tex = f:CreateTexture(nil, "BACKGROUND")
		tex:SetColorTexture(r, g, b, a)
		tex:SetPoint(anchor, f, anchor, x, y)
		f.bars[i] = { tex = tex, anchor = anchor }
	end
	_G.NaturStealthFlashFrame = f
	return f
end

local function ResizeStealthFlashFrame()
	local f = _G.NaturStealthFlashFrame
	if not f or not f.bars then return end
	local w, h = UIParent:GetSize()
	local thickness = 12
	f:SetSize(w, h)
	local sizeByAnchor = { TOP = { w, thickness }, BOTTOM = { w, thickness }, LEFT = { thickness, h }, RIGHT = { thickness, h } }
	for _, rec in ipairs(f.bars) do
		local tw, th = sizeByAnchor[rec.anchor][1], sizeByAnchor[rec.anchor][2]
		rec.tex:SetSize(tw, th)
	end
end

--- Flash screen border red 3 times (used when hostile stealth detected)
local function Natur_FlashStealthBorder()
	local frame = GetStealthFlashFrame()
	ResizeStealthFlashFrame()
	local flashDuration = 0.12
	local gapDuration = 0.12
	local function doFlash(flashCount)
		if flashCount <= 0 then frame:SetAlpha(0); return end
		frame:SetAlpha(1)
		C_Timer.After(flashDuration, function()
			frame:SetAlpha(0)
			C_Timer.After(gapDuration, function()
				doFlash(flashCount - 1)
			end)
		end)
	end
	doFlash(3)
end
_G.Natur_FlashStealthBorder = Natur_FlashStealthBorder

--- Format class for display (e.g. "ROGUE" -> "Rogue")
local function FormatClassForAnnounce(class)
	if not class or class == "" then return "stealth class" end
	return string.upper(string.sub(class, 1, 1)) .. string.lower(string.sub(class, 2))
end

--- Return the chat channel to use for chat messages, solo we dont show chat messages.
local function GetStealthAnnounceChannel()
	if not IsInGroup() and not UnitExists("party1") and not (GetNumGroupMembers and GetNumGroupMembers() >= 2) then return nil end
	return (LE_PARTY_CATEGORY_INSTANCE and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY"
end

--- Announce a CC message to group channel or DEFAULT_CHAT_FRAME. 
function Natur_AnnounceCC(msg, useGroupChannel)
	if not msg or msg == "" then return end
	if useGroupChannel then
		local channel = GetStealthAnnounceChannel()
		if channel then
			local db = _G.NaturOptionsDB
			if db and db.debugMode and Natur_DebugPrint then
				Natur_DebugPrint("Sending CC announce to: " .. tostring(channel))
			end
			-- SendChatMessage rejects color codes and |T texture; use {rtN} for raid icons in channel (renders as icon)
			local plainMsg = msg:gsub("|c%x%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
			plainMsg = plainMsg:gsub("|TInterface\\TargetingFrame\\UI%-RaidTargetingIcon_(%d)[^|]*|t", "{rt%1}")
			plainMsg = plainMsg:gsub("|T[^|]+|t", "")  -- remove any other texture escapes to avoid invalid escape
			SendChatMessage(plainMsg, channel, nil)
			return
		else
			-- Default chat frame
			local L = _G.Natur_L
			local nameStr = (L and L.ADDON_NAME) or "Natur"
			local formatted = "|cff00e0ff" .. nameStr .. "|r|cffffffff : " .. msg .. "|r"
			if DEFAULT_CHAT_FRAME then
				DEFAULT_CHAT_FRAME:AddMessage(formatted)
			else
				print(formatted)
			end
		end
	end
end
_G.Natur_AnnounceCC = Natur_AnnounceCC

--- Return a display string for current group type: "Solo", "Party", "Raid", "Battleground", "Arena".
local function GetGroupTypeString()
	if not IsInGroup() then return "Solo" end
	local inInstance, instanceType = GetInstanceInfo()
	if instanceType == "arena" then return "Arena" end
	if instanceType == "pvp" then return "Battleground" end
	if IsInRaid() then return "Raid" end
	return "Party"
end

--- Show a debug message only when debug mode is enabled.
function Natur_DebugPrint(msg)
	local db = _G.NaturOptionsDB
	if db and db.debugMode and msg then
		local L = _G.Natur_L
		local nameStr = (L and L.ADDON_NAME) or "Natur"
		local debugLabel = (L and L.DEBUG_LABEL) or " (Debug)"
		local prefix = nameStr .. debugLabel
		local msgStr = tostring(msg)
		local textPlain = prefix .. " : " .. msgStr
		local textChat = "|cffff8800" .. prefix .. "|r|cffffffff : " .. msgStr .. "|r"
		if DEFAULT_CHAT_FRAME then
			DEFAULT_CHAT_FRAME:AddMessage(textChat)
		else
			print(textChat)
		end
	end
end
_G.Natur_DebugPrint = Natur_DebugPrint

--- List of detected hostile stealth players
local stealthDetectedList = {}

--- True if the current zone is a sanctuary (neutral city, no PvP); flash/sound/chat are suppressed there but debug still shows.
local function IsInNeutralCitySanctuary()
	local pvpType = GetZonePVPInfo and GetZonePVPInfo()
	return pvpType == "sanctuary"
end

--- Prune stealth detection list: remove entries older than 60s and show debug for each removed.
local function Natur_PruneStealthDetectedList()
	local L = _G.Natur_L
	local throttleExpiredFmt = (L and L.STEALTH_THROTTLE_EXPIRED_DEBUG) or "Hostile stealth detection throttle expired for %s, can be detected again."
	local now = GetTime()
	for k, entry in pairs(stealthDetectedList) do
		if entry.addedTime and (now - entry.addedTime) >= 60 then
			local displayName = (entry.sourceName and entry.sourceName ~= "" and entry.sourceName) or tostring(k):sub(-8)
			Natur_DebugPrint(string.format(throttleExpiredFmt, displayName))
			stealthDetectedList[k] = nil
		end
	end
end

--- Called when a hostile rogue/druid stealth is detected; applies flash, sound, and/or chat per options.
local function Natur_OnHostileStealthDetected(sourceName, spellName, class, sourceGUID)
	local db = _G.NaturOptionsDB
	if not db or not db.detectStealthClasses then return end
	local L = _G.Natur_L
	local now = GetTime()

	local key = sourceGUID and sourceGUID ~= "" and sourceGUID or sourceName
	if not key then return end
	if stealthDetectedList[key] then return end

	stealthDetectedList[key] = {
		addedTime = now,
		sourceName = sourceName,
		sourceGUID = sourceGUID,
		class = class,
		spellName = spellName,
	}
	local displayName = (sourceName and sourceName ~= "" and sourceName) or tostring(key):sub(-8)
	local addedFmt = (L and L.STEALTH_PLAYER_ADDED_DEBUG) or "Hostile player %s added to stealth detection list."
	local addedMsg = string.format(addedFmt, displayName)
	if IsInNeutralCitySanctuary() then
		local suffix = (L and L.STEALTH_MUTED_IN_CITY_SUFFIX) or " (muted in a city sanctuary)"
		addedMsg = addedMsg .. suffix
	end
	Natur_DebugPrint(addedMsg)

	-- In neutral cities (sanctuary) skip flash, sound and chat
	if IsInNeutralCitySanctuary() then return end

	if db.flashStealthScreenBorder then
		Natur_FlashStealthBorder()
	end
	if db.playStealthSound then
		local paths = _G.NaturSoundPaths
		if paths and paths.stealth then
			PlaySoundFile(paths.stealth, "Master")
		end
	end
	if db.announceStealthClassToChat then
		local channel = GetStealthAnnounceChannel()
		local L = _G.Natur_L
		local fmt = (L and L.STEALTH_ANNOUNCE_MSG) or "Detected hostile player [%s] using %s, beware as there is a %s nearby."
		local player = sourceName and sourceName ~= "" and sourceName or "Unknown"
		local spell = spellName and spellName ~= "" and spellName or "unknown ability"
		local classDisplay = FormatClassForAnnounce(class)
		local playerYellow = "|cffffff00" .. player .. "|r"
		local spellYellow = "|cffffff00" .. spell .. "|r"
		local msg = string.format(fmt, playerYellow, spellYellow, classDisplay)
		local nameStr = (L and L.ADDON_NAME) or "Natur"
		local formatted = "|cff00e0ff" .. nameStr .. "|r|cffffffff : |r|cffff0000" .. msg .. "|r"
		if channel then
			-- SendChatMessage rejects |c, |r and other escape codes; strip to plain text
			local plainMsg = formatted:gsub("|c%x%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
			plainMsg = plainMsg:gsub("|T[^|]+|t", "")
			SendChatMessage(plainMsg, channel, nil)
		elseif DEFAULT_CHAT_FRAME then
			DEFAULT_CHAT_FRAME:AddMessage(formatted)
		else
			print(formatted)
		end
	end
end

--- Detect any hostile Rogue or Druid spell and trigger stealth-class warning
local function Natur_OnStealthCombatLogEvent()
	local db = _G.NaturOptionsDB
	if not db or not db.detectStealthClasses then return end
	if not CombatLogGetCurrentEventInfo then return end
	local buffDB = _G.NaturBuffDB
	if not buffDB then return end

	local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
	      destGUID, destName, destFlags, destRaidFlags, spellId, spellName = CombatLogGetCurrentEventInfo()
	if subevent ~= "SPELL_CAST_SUCCESS" and subevent ~= "SPELL_AURA_APPLIED" then return end
	if not sourceGUID or sourceGUID == "" then return end
	if bit.band(sourceFlags or 0, COMBATLOG_OBJECT_REACTION_HOSTILE) == 0 then return end
	-- Only detect hostile players, not NPCs (e.g. Rogue/Druid mobs)
	if bit.band(sourceFlags or 0, COMBATLOG_OBJECT_CONTROL_PLAYER) == 0 then return end

	local entry = spellId and buffDB[spellId]
	if not entry or not entry.class then return end
	if entry.class ~= "ROGUE" and entry.class ~= "DRUID" then return end

	Natur_OnHostileStealthDetected(sourceName, spellName, entry.class, sourceGUID)
end

--- Play next killing-blow voicepack sound when player gets a kill (PARTY_KILL). Cycles through list
function Natur_KillingBlow_OnCombatLogEvent()
	if not CombatLogGetCurrentEventInfo then return end
	local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
	      destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
	if subevent ~= "PARTY_KILL" then return end
	if not sourceGUID or sourceGUID ~= UnitGUID("player") then return end
	local db = _G.NaturOptionsDB
	if not db or not db.playPvPKillingBlowSounds then return end
	local isPlayerVictim = bit and bit.band and (bit.band(destFlags or 0, COMBATLOG_OBJECT_CONTROL_PLAYER) ~= 0)
	if not isPlayerVictim and not db.playNPCKillingBlowSounds then return end
	local soundpack = (db.playPvPKillingBlowSoundpack == 1 or db.playPvPKillingBlowSoundpack == 2) and db.playPvPKillingBlowSoundpack or 1
	local state = NaturKillingBlowState
	local now = GetTime()
	if now - state.lastPlayTime > 60 then
		state.currentIndex = 1
	end
	local soundPaths = _G.NaturSoundPaths
	local voicepack = soundPaths and (soundpack == 2 and soundPaths.killingBlowVoicepack2 or soundPaths.killingBlowVoicepack1)
	local path = voicepack and voicepack[state.currentIndex]
	if path then
		PlaySoundFile(path, "Master")
		state.currentIndex = state.currentIndex + 1
		if state.currentIndex > 6 then state.currentIndex = 6 end  -- stay on last sound until 60s expires
		state.lastPlayTime = now
	end
end

--- Resolve LSM key to path; fallback to Blizzard default if LSM missing or key invalid.
local function ResolveTexture(key)
	if LSM then
		local path = LSM:Fetch("statusbar", key)
		if path and path ~= "" then return path end
	end
	return DEFAULT_TEXTURE
end

local function ResolveFont(key)
	if LSM then
		local path = LSM:Fetch("font", key)
		if path and path ~= "" then return path end
	end
	return DEFAULT_FONT_PATH
end

--- Build group options for CreateGroup/UpdateGroupOptions from individual group settings.
local function BuildGroupOpts(saved, def)
	local title = (saved and saved.title) or (def and def.defaultTitle)
	local texKey = saved and saved.texture
	local fontKey = saved and saved.font
	return {
		title = title,
		texture = ResolveTexture(texKey),
		font = ResolveFont(fontKey),
		fontSize = (saved and saved.fontSize) or DEFAULT_FONT_SIZE,
		fontFlags = (saved and saved.fontFlags) or DEFAULT_FONT_FLAGS,
		point = saved and saved.point,
		relativePoint = saved and saved.relativePoint,
		x = saved and saved.x,
		y = saved and saved.y,
		width = saved and saved.width,
		height = saved and saved.height,
		spacing = saved and saved.spacing,
		growthDirection = (saved and saved.growthDirection) or "DOWN",
		sortOrder = (saved and saved.sortOrder) or (def and def.sortOrder),
	}
end

--- Persist group position to DB (call from anchor OnDragStop).
local function SaveGroupPosition(group)
	local name = group and group:GetName()
	local key = name and name:match("^NaturTimersGroup_(.+)$")
	if not key then return end
	local db = _G.NaturOptionsDB
	if not db or not db.groups or not db.groups[key] then return end
	local saved = db.groups[key]
	local point, _, relativePoint, x, y = group:GetPoint(1)
	if point and relativePoint then
		saved.point = point
		saved.relativePoint = relativePoint
		saved.x = x
		saved.y = y
	end
end

--- Create or update all 9 timer groups from individual group settings in options.
function Natur_RefreshGroups()
	local db = _G.NaturOptionsDB
	if not db or not db.groups then return end

	for _, def in ipairs(GROUP_DEFS) do
		local key = def.key
		local saved = db.groups[key]
		local opts = BuildGroupOpts(saved, def)
		opts.relativeTo = UIParent

		local group = NT:GetGroup(key)
		if group then
			NT:UpdateGroupOptions(key, opts)
		else
			NT:CreateGroup(key, opts)
		end

		-- Persist position when user drags the group
		group = NT:GetGroup(key)
		if group and group.anchor then
			group.anchor:SetScript("OnDragStop", function(self)
				local parent = self:GetParent()
				parent:StopMovingOrSizing()
				SaveGroupPosition(parent)
			end)
		end
	end

	-- Apply anchor visibility from global setting showAnchors
	Natur_ApplyAnchorVisibility(db.showAnchors)
end

--- Refresh a single timer group from options (for per-group settings UI).
function Natur_RefreshGroup(key)
	if not key then return end
	local db = _G.NaturOptionsDB
	if not db or not db.groups or not db.groups[key] then return end
	local def
	for _, d in ipairs(GROUP_DEFS) do
		if d.key == key then def = d break end
	end
	if not def then return end
	local saved = db.groups[key]
	local opts = BuildGroupOpts(saved, def)
	opts.relativeTo = UIParent
	local group = NT:GetGroup(key)
	if group then
		NT:UpdateGroupOptions(key, opts)
		if group.anchor then
			group.anchor:SetScript("OnDragStop", function(self)
				local parent = self:GetParent()
				parent:StopMovingOrSizing()
				SaveGroupPosition(parent)
			end)
		end
	end
end

--- Show or hide anchors for all groups (global setting). 
function Natur_ApplyAnchorVisibility(visible)
	local db = _G.NaturOptionsDB
	local show = (visible ~= nil) and visible or (db and db.showAnchors)
	for _, def in ipairs(GROUP_DEFS) do
		NT:SetGroupAnchorVisible(def.key, show)
	end
	Natur_UpdateEmptyGroupVisibility()
end

--- Show or hide all groups based on per-char enabled.
function Natur_SetEnabled(enabled)
	for _, def in ipairs(GROUP_DEFS) do
		local group = NT:GetGroup(def.key)
		if group then
			if enabled then
				group:Show()
			else
				group:Hide()
			end
		end
	end
	Natur_UpdateCastsGroupsVisibility()
end

--- Return whether the group's category is visible (addon enabled + relevant show toggles).
local function Natur_IsGroupCategoryVisible(key)
	local db = _G.NaturOptionsDB
	local perChar = Natur_Options_GetPerChar and Natur_Options_GetPerChar()
	local addonEnabled = (perChar == nil) or (perChar.enabled ~= false)
	if not addonEnabled or not db then return false end
	if key == "TargetCasts" or key == "FocusCasts" then return db.showFriendlyCasts or db.showHostileCasts end
	if key == "TargetGains" or key == "FocusGains" then return db.showFriendlyGains or db.showHostileGains end
	if key == "TargetCooldowns" or key == "FocusCooldowns" then return db.showFriendlyCooldowns or db.showHostileCooldowns end
	if key == "TargetDR" or key == "FocusDR" then return db.showFriendlyDR or db.showHostileDR end
	if key == "CrowdControl" then return db.showFriendlyCC or db.showHostileCC or db.showHostileDR end
	return false
end

--- Set one group's visibility: visible when category is on and (anchors visible or has active timers). Hides blank frames when anchors are hidden.
function Natur_SetGroupVisibility(key)
	local group = NT:GetGroup(key)
	if not group then return end
	local categoryVisible = Natur_IsGroupCategoryVisible(key)
	local showAnchors = (_G.NaturOptionsDB and _G.NaturOptionsDB.showAnchors) or false
	local activeCount = 0
	for _, bar in pairs(group.timers or {}) do
		if bar.active then activeCount = activeCount + 1 end
	end
	local visible = categoryVisible and (showAnchors or activeCount > 0)
	if visible then group:Show() else group:Hide() end
end

--- DR window length used for test timers 
local DR_WINDOW_TEST = 18

--- Add 3 test timers to each group whose category is enabled (for previewing layout).
function Natur_AddTestTimers()
	local NT = _G.NaturTimers
	if not NT then return end
	for _, def in ipairs(GROUP_DEFS) do
		local key = def.key
		if Natur_IsGroupCategoryVisible(key) then
			if key == "TargetDR" or key == "FocusDR" then
				local iconRight = "Interface\\AddOns\\Natur\\assets\\graphics\\drhostile.tga"
				NT:StartTimer(key, "test_dr_1", DR_WINDOW_TEST, {
					label = "Polymorph DR (Next: 10s)",
					reverse = true,
					startElapsed = 0,
					iconRight = iconRight,
				})
				NT:StartTimer(key, "test_dr_2", DR_WINDOW_TEST, {
					label = "Fear DR (Next: 5s)",
					reverse = true,
					startElapsed = 8,
					iconRight = iconRight,
				})
				NT:StartTimer(key, "test_dr_3", DR_WINDOW_TEST, {
					label = "Sap DR (Immune)",
					reverse = true,
					startElapsed = 13,
					iconRight = iconRight,
				})
			else
				local isCasts = (key == "TargetCasts" or key == "FocusCasts")
				local reverse = not isCasts
				NT:StartTimer(key, "test_1", 10, { label = "Test 1", reverse = reverse })
				NT:StartTimer(key, "test_2", 15, { label = "Test 2", reverse = reverse })
				NT:StartTimer(key, "test_3", 20, { label = "Test 3", reverse = reverse })
			end
		end
	end
end
_G.Natur_AddTestTimers = Natur_AddTestTimers

--- Callback from NaturTimers when timer layout changes (bar added/removed). Keeps empty groups hidden when anchors are hidden.
function Natur_OnTimerLayoutChanged(groupName, activeCount)
	local group = NT:GetGroup(groupName)
	if not group then return end
	local categoryVisible = Natur_IsGroupCategoryVisible(groupName)
	local showAnchors = (_G.NaturOptionsDB and _G.NaturOptionsDB.showAnchors) or false
	local visible = categoryVisible and (showAnchors or activeCount > 0)
	if visible then group:Show() else group:Hide() end
end
_G.Natur_OnTimerLayoutChanged = Natur_OnTimerLayoutChanged

--- Update all groups' visibility (e.g. after anchor visibility or category toggles change).
function Natur_UpdateEmptyGroupVisibility()
	for _, def in ipairs(GROUP_DEFS) do
		Natur_SetGroupVisibility(def.key)
	end
end

--- Casts: if both Show Friendly/Hostile Casts are false, disable Target/Focus Casts; otherwise enable both.
function Natur_UpdateCastsGroupsVisibility()
	Natur_UpdateEmptyGroupVisibility()
end

_G.Natur_SetEnabled = Natur_SetEnabled
_G.Natur_UpdateCastsGroupsVisibility = Natur_UpdateCastsGroupsVisibility
_G.Natur_RefreshGroups = Natur_RefreshGroups
_G.Natur_RefreshGroup = Natur_RefreshGroup
_G.Natur_ApplyAnchorVisibility = Natur_ApplyAnchorVisibility
--- Update Target Casts bar from current target's cast/channel. Call on cast events and on target change so mid-cast targeting shows full duration and remaining.
function Natur_UpdateTargetCast()
	local db = _G.NaturOptionsDB
	if not db then return end
	if not UnitExists("target") then
		NT:StopTimer("TargetCasts", "cast")
		return
	end
	local showFriendly = db.showFriendlyCasts
	local showHostile = db.showHostileCasts
	local canAttack = UnitCanAttack("player", "target")
	local friendly = not canAttack
	if not ((friendly and showFriendly) or (not friendly and showHostile)) then
		NT:StopTimer("TargetCasts", "cast")
		return
	end
	local name, _, texture, startTimeMS, endTimeMS = UnitCastingInfo("target")
	if not name then
		name, _, texture, startTimeMS, endTimeMS = UnitChannelInfo("target")
	end
	if not name or not endTimeMS or not startTimeMS then
		NT:StopTimer("TargetCasts", "cast")
		return
	end
	local fullDuration = (endTimeMS - startTimeMS) / 1000
	local remaining = (endTimeMS / 1000) - GetTime()
	local elapsed = fullDuration - remaining
	if fullDuration <= 0 or remaining <= 0 then
		NT:StopTimer("TargetCasts", "cast")
		return
	end
	local label = name
	if db.showPlayerNamesOnTimers ~= false then
		local unitName = UnitName("target")
		if unitName then label = name .. " (" .. unitName .. ")" end
	end
	local opts = {
		label = label,
		iconLeft = texture,
		reverse = false,
		startElapsed = math.max(0, math.min(elapsed, fullDuration)),
	}
	-- Use UnitReaction for icon so hostile targets get htarget even when UnitCanAttack is nil/delayed
	local reaction = UnitReaction("player", "target")
	local useHostileIcon = (reaction and reaction <= 4) or (canAttack == true)
	opts.iconRight = useHostileIcon and "Interface\\AddOns\\Natur\\assets\\graphics\\htarget.tga"
		or "Interface\\AddOns\\Natur\\assets\\graphics\\ftarget.tga"
	NT:StartTimer("TargetCasts", "cast", fullDuration, opts)
end

--- Update Focus Casts bar from current focus's cast/channel.
function Natur_UpdateFocusCast()
	local db = _G.NaturOptionsDB
	if not db then return end
	if not UnitExists("focus") then
		NT:StopTimer("FocusCasts", "cast")
		return
	end
	local showFriendly = db.showFriendlyCasts
	local showHostile = db.showHostileCasts
	local canAttack = UnitCanAttack("player", "focus")
	local friendly = not canAttack
	if not ((friendly and showFriendly) or (not friendly and showHostile)) then
		NT:StopTimer("FocusCasts", "cast")
		return
	end
	local name, _, texture, startTimeMS, endTimeMS = UnitCastingInfo("focus")
	if not name then
		name, _, texture, startTimeMS, endTimeMS = UnitChannelInfo("focus")
	end
	if not name or not endTimeMS or not startTimeMS then
		NT:StopTimer("FocusCasts", "cast")
		return
	end
	local fullDuration = (endTimeMS - startTimeMS) / 1000
	local remaining = (endTimeMS / 1000) - GetTime()
	local elapsed = fullDuration - remaining
	if fullDuration <= 0 or remaining <= 0 then
		NT:StopTimer("FocusCasts", "cast")
		return
	end
	local label = name
	if db.showPlayerNamesOnTimers ~= false then
		local unitName = UnitName("focus")
		if unitName then label = name .. " (" .. unitName .. ")" end
	end
	local opts = {
		label = label,
		iconLeft = texture,
		reverse = false,
		startElapsed = math.max(0, math.min(elapsed, fullDuration)),
	}
	-- Use UnitReaction for icon so hostile focus gets hfocus even when UnitCanAttack is nil/delayed
	local reaction = UnitReaction("player", "focus")
	local useHostileIcon = (reaction and reaction <= 4) or (canAttack == true)
	opts.iconRight = useHostileIcon and "Interface\\AddOns\\Natur\\assets\\graphics\\hfocus.tga"
		or "Interface\\AddOns\\Natur\\assets\\graphics\\ffocus.tga"
	NT:StartTimer("FocusCasts", "cast", fullDuration, opts)
end

_G.Natur_UpdateTargetGainsBinding = Natur_UpdateTargetGainsBinding
_G.Natur_UpdateFocusGainsBinding = Natur_UpdateFocusGainsBinding
_G.Natur_UpdateTargetCast = Natur_UpdateTargetCast
_G.Natur_UpdateFocusCast = Natur_UpdateFocusCast

--- Minimap button: parent = Minimap, icon from MiniMap-Enabled.tga / MiniMap-Disable.tga, right-click toggles per-char enabled.
--- Button orbits minimap edge (angle + radius); Shift+left-drag updates angle.
local MINIMAP_ICON_ENABLED = "Interface\\AddOns\\Natur\\assets\\graphics\\MiniMap-Enabled.tga"
local MINIMAP_ICON_DISABLED = "Interface\\AddOns\\Natur\\assets\\graphics\\MiniMap-Disable.tga"
local function atan2(y, x)
	if x == 0 and y == 0 then return 0 end
	local a = math.atan(y / x)
	if x < 0 then a = a + math.pi end
	if a < 0 then a = a + 2 * math.pi end
	return a
end

local function Natur_MinimapButton_Update()
	local db = _G.NaturOptionsDB
	if not db then return end
	local btn = _G.NaturMinimapButton
	if not btn then return end
	if not db.showMinimapIcon then
		btn:Hide()
		return
	end
	btn:Show()
	local perChar = Natur_Options_GetPerChar and Natur_Options_GetPerChar()
	local enabled = (perChar == nil) or (perChar.enabled ~= false)
	local tex = btn.icon
	if tex then
		tex:SetTexture(enabled and MINIMAP_ICON_ENABLED or MINIMAP_ICON_DISABLED)
	end
end
_G.Natur_MinimapButton_Update = Natur_MinimapButton_Update

local function Natur_MinimapButton_Create()
	if _G.NaturMinimapButton then
		Natur_MinimapButton_Update()
		return
	end
	local Minimap = _G.Minimap
	if not Minimap then
		-- Minimap may not exist yet at ADDON_LOADED; try again next frame
		if C_Timer and C_Timer.After then
			C_Timer.After(0, Natur_MinimapButton_Create)
		end
		return
	end
	local db = _G.NaturOptionsDB
	if not db then return end

	local btn = CreateFrame("Button", "NaturMinimapButton", Minimap)
	btn:SetSize(28, 28)
	-- Orbit on minimap edge: angle in degrees (0=right, 90=top), radius from center
	local w, h = Minimap:GetWidth(), Minimap:GetHeight()
	local radius = (w and h and (math.min(w, h) * 0.5 + 5)) or 40
	local angleDeg = db.minimapButtonAngle
	if angleDeg == nil and db.minimapButtonOffsetX ~= nil and db.minimapButtonOffsetY ~= nil then
		-- Migrate from old offset to angle
		angleDeg = math.deg(atan2(db.minimapButtonOffsetY, db.minimapButtonOffsetX))
		db.minimapButtonAngle = angleDeg
	end
	if angleDeg == nil then angleDeg = 315 end
	local rad = math.rad(angleDeg)
	local ox = radius * math.cos(rad)
	local oy = radius * math.sin(rad)
	btn:SetPoint("CENTER", Minimap, "CENTER", ox, oy)
	btn:SetFrameStrata("MEDIUM")
	btn:SetFrameLevel(Minimap:GetFrameLevel() + 5)
	btn:EnableMouse(true)
	btn:RegisterForClicks("RightButtonUp", "LeftButtonUp")
	btn:RegisterForDrag("LeftButton")

	local icon = btn:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints(btn)
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	btn.icon = icon

	btn:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		local L = _G.Natur_L
		local nameStr = (L and L.ADDON_NAME) or "Natur"
		local versionStr = tostring(_G.NATUR_VERSION or "")
		local rightStr = (L and L.MINIMAP_TOOLTIP_RIGHT_CLICK) or "Click right mouse to toggle on or off."
		local shiftRightStr = (L and L.MINIMAP_TOOLTIP_SHIFT_RIGHT_CLICK) or "Hold Shift and click right mouse for anchors."
		local leftStr = (L and L.MINIMAP_TOOLTIP_LEFT_CLICK) or "Click left mouse button for options."
		GameTooltip:SetText(nameStr .. "\n" .. versionStr .. "\n\n" .. rightStr .. "\n" .. shiftRightStr .. "\n" .. leftStr)
		GameTooltip:Show()
	end)
	btn:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	btn:SetScript("OnDragStart", function(self)
		if not IsShiftKeyDown() then return end
		GameTooltip:Hide()
		self.dragging = true
		self:SetScript("OnUpdate", function(frame)
			if not frame.dragging then frame:SetScript("OnUpdate", nil) return end
			local db = _G.NaturOptionsDB
			local p = Minimap
			local left, bottom = p:GetLeft(), p:GetBottom()
			if not left or not bottom then return end
			local uiScale = _G.UIParent and _G.UIParent:GetEffectiveScale() or 1
			local cx, cy = GetCursorPosition()
			cx, cy = cx / uiScale, cy / uiScale
			local w, h = p:GetWidth(), p:GetHeight()
			if not w or not h then return end
			local centerX = left + w * 0.5
			local centerY = bottom + h * 0.5
			local angleRad = atan2(cy - centerY, cx - centerX)
						local radius = math.min(w, h) * 0.5 + 5
			local ox = radius * math.cos(angleRad)
			local oy = radius * math.sin(angleRad)
			frame:ClearAllPoints()
			frame:SetPoint("CENTER", p, "CENTER", ox, oy)
			if db then
				db.minimapButtonAngle = math.deg(angleRad)
			end
		end)
	end)
	btn:SetScript("OnDragStop", function(self)
		if self.dragging then
			self.dragging = nil
			self:SetScript("OnUpdate", nil)
		end
	end)
	btn:SetScript("OnClick", function(_, mouseButton)
		if mouseButton == "LeftButton" and not IsShiftKeyDown() then
			if _G.Natur_Options_Open then _G.Natur_Options_Open() end
			return
		end
		if mouseButton ~= "RightButton" then return end
		-- Shift+right-click: toggle anchors
		if IsShiftKeyDown() then
			local db = _G.NaturOptionsDB
			if db then
				db.showAnchors = not db.showAnchors
				if _G.Natur_ApplyAnchorVisibility then
					_G.Natur_ApplyAnchorVisibility(db.showAnchors)
				end
				local L = _G.Natur_L
				local nameStr = (L and L.ADDON_NAME) or "Natur"
				local stateMsg = db.showAnchors and (L and L.SHOW_ANCHORS or "Show anchors") or (L and L.ANCHORS_HIDDEN or "Anchors hidden")
				local text = "|cff00e0ff" .. nameStr .. "|r|cffffffff : " .. stateMsg .. "|r"
				if DEFAULT_CHAT_FRAME then
					DEFAULT_CHAT_FRAME:AddMessage(text)
				else
					print(text)
				end
			end
			return
		end
		if not Natur_Options_InitPerCharDB then return end
		Natur_Options_InitPerCharDB()
		local perChar = Natur_Options_GetPerChar and Natur_Options_GetPerChar()
		if not perChar then return end
		perChar.enabled = not (perChar.enabled ~= false)
		Natur_SetEnabled(perChar.enabled ~= false)
		Natur_MinimapButton_Update()
		local L = _G.Natur_L
		local nameStr = (L and L.ADDON_NAME) or "Natur"
		local stateMsg = (perChar.enabled ~= false) and (L and L.ADDON_NOW_ENABLED or "Addon is now enabled.") or (L and L.ADDON_NOW_DISABLED or "Addon is now disabled.")
		local text = "|cff00e0ff" .. nameStr .. "|r|cffffffff : " .. stateMsg .. "|r"
		if DEFAULT_CHAT_FRAME then
			DEFAULT_CHAT_FRAME:AddMessage(text)
		else
			print(text)
		end
	end)

	Natur_MinimapButton_Update()
end

local function OnAddonLoaded(_, name)
	if name ~= addonName then return end

	-- 1) Initialise options (global and per-character)
	if Natur_Options_InitGlobalDB then
		Natur_Options_InitGlobalDB()
	end
	if Natur_Options_InitPerCharDB then
		Natur_Options_InitPerCharDB()
	end
	if Natur_Options_CheckResetFlag then
		Natur_Options_CheckResetFlag()
	end

	-- 2) Setup the 9 groups from options; each group gets its settings from NaturOptionsDB.groups[key]
	Natur_RefreshGroups()
	-- Natur_RefreshGroups() also applies showAnchors from global settings

	-- 3) Show/hide all groups per per-char enabled; then apply casts groups rule (both cast options false = hide Target/Focus Casts)
	local perChar = Natur_Options_GetPerChar and Natur_Options_GetPerChar()
	local enabled = (perChar == nil) or (perChar.enabled ~= false)
	Natur_SetEnabled(enabled)
	Natur_UpdateCastsGroupsVisibility()
	-- Gains module: ensure bindings reflect current target/focus and options.
	if Natur_Gains_OnAddonLoaded then
		Natur_Gains_OnAddonLoaded()
	end
	Natur_UpdateTargetCast()
	Natur_UpdateFocusCast()
	-- Cooldowns module: restore any persisted cooldowns and start its housekeeping ticker.
	if Natur_Cooldowns_OnAddonLoaded then
		Natur_Cooldowns_OnAddonLoaded()
	end
	if Natur_Diminish_OnAddonLoaded then
		Natur_Diminish_OnAddonLoaded()
	end

	-- Credits Text: addon name (cyan), Discord link (yellow)
	local L = _G.Natur_L
	local addonNameStr = (L and L.ADDON_NAME) or "Natur"
	local loadedStr = (L and L.WELCOME_LOADED) or " loaded! - please report any problems on Curse or Discord at "
	local urlStr = (L and L.WELCOME_DISCORD_URL) or "https://discord.gg/R6EkZ94TKK"
	local supportStr = (L and L.WELCOME_FOR_SUPPORT) or " for improved support"
	local welcomeMsg = "|cff00e0ff" .. addonNameStr .. "|r" .. loadedStr .. "|cffffff00" .. urlStr .. "|r|cffffffff" .. supportStr .. "|r"
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage(welcomeMsg)
	else
		print(welcomeMsg)
	end

	-- Callback for Options reset: reapply groups and visibility from new defaults
	_G.Natur_OnOptionsReset = function()
		Natur_RefreshGroups()
		local perChar = Natur_Options_GetPerChar and Natur_Options_GetPerChar()
		Natur_SetEnabled((perChar == nil) or (perChar.enabled ~= false))
		Natur_UpdateCastsGroupsVisibility()
		if Natur_Gains_OnAddonLoaded then Natur_Gains_OnAddonLoaded() end
		Natur_UpdateTargetCast()
		Natur_UpdateFocusCast()
		if Natur_Cooldowns_OnAddonLoaded then Natur_Cooldowns_OnAddonLoaded() end
		if Natur_Diminish_OnAddonLoaded then Natur_Diminish_OnAddonLoaded() end
	end

	-- Minimap button (respects showMinimapIcon; right-click toggles enabled)
	Natur_MinimapButton_Create()
end

--- When player has entered world, realm/char are set; apply per-char enabled and casts groups visibility.
local function OnPlayerLogin()
	local perChar = Natur_Options_GetPerChar and Natur_Options_GetPerChar()
	if perChar ~= nil then
		Natur_SetEnabled(perChar.enabled ~= false)
	end
	Natur_UpdateCastsGroupsVisibility()
	if Natur_Gains_OnAddonLoaded then
		Natur_Gains_OnAddonLoaded()
	end
	Natur_UpdateTargetCast()
	Natur_UpdateFocusCast()
	-- Timer to prune expired stealth detections every 10s (entries older than 60s removed and debug shown)
	if C_Timer and C_Timer.NewTicker then
		C_Timer.NewTicker(10, function() Natur_PruneStealthDetectedList() end)
	end
end

--- Track last group type for debug "Group changed to X" messages.
local lastGroupType = ""

local function CheckGroupTypeChanged()
	local current = GetGroupTypeString()
	if current ~= lastGroupType then
		lastGroupType = current
			local L = _G.Natur_L
		local fmt = (L and L.DEBUG_GROUP_CHANGED) or "Group changed to %s."
		local msg = string.format(fmt, current)
		if current == "Solo" then
			local suffix = (L and L.DEBUG_GROUP_SOLO_SUFFIX) or " - no chat messages will be announced."
			msg = msg .. suffix
		end
		Natur_DebugPrint(msg)
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", function(_, event, name)
	if event == "ADDON_LOADED" then
		OnAddonLoaded(_, name)
	elseif event == "PLAYER_LOGIN" then
		OnPlayerLogin()
		CheckGroupTypeChanged()
	elseif event == "PLAYER_TARGET_CHANGED" then
		if Natur_DebugPrint then
			local targetName = UnitName("target")
			local targetGuid = UnitGUID("target")
			if targetName and targetGuid then
				local targetClass = select(1, UnitClass("target"))
				local displayName = targetClass and ("%s (%s)"):format(targetName, targetClass) or targetName
				Natur_DebugPrint(("Target: %s, guid=%s"):format(displayName, tostring(targetGuid)))
			else
				Natur_DebugPrint("Target cleared")
			end
		end
		if Natur_Gains_OnTargetChanged then
			Natur_Gains_OnTargetChanged()
		end
		Natur_UpdateTargetCast()
		if Natur_Cooldowns_OnTargetChanged then
			Natur_Cooldowns_OnTargetChanged()
		end
		if Natur_Diminish_OnTargetChanged then
			Natur_Diminish_OnTargetChanged()
		end
	elseif event == "PLAYER_FOCUS_CHANGED" then
		if Natur_DebugPrint then
			local focusName = UnitName("focus")
			local focusGuid = UnitGUID("focus")
			if focusName and focusGuid then
				Natur_DebugPrint(("Focus: name=%s, guid=%s"):format(tostring(focusName), tostring(focusGuid)))
			else
				Natur_DebugPrint("Focus cleared")
			end
		end
		if Natur_Gains_OnFocusChanged then
			Natur_Gains_OnFocusChanged()
		end
		Natur_UpdateFocusCast()
		if Natur_Cooldowns_OnFocusChanged then
			Natur_Cooldowns_OnFocusChanged()
		end
		if Natur_Diminish_OnFocusChanged then
			Natur_Diminish_OnFocusChanged()
		end
	elseif event == "GROUP_ROSTER_UPDATE" or event == "ZONE_CHANGED_NEW_AREA" then
		CheckGroupTypeChanged()
	end
end)

-- Cast monitoring: sync bar when cast starts/stops/delays/channel updates so full duration and remaining are correct (including when targeting mid-cast)
local castFrame = CreateFrame("Frame")
castFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", "target", "focus")
castFrame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "target", "focus")
castFrame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "target", "focus")
castFrame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "target", "focus")
castFrame:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", "target", "focus")
castFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "target", "focus")
castFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "target", "focus")
castFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "target", "focus")
castFrame:SetScript("OnEvent", function(_, event, unit)
	if unit == "target" then
		Natur_UpdateTargetCast()
	elseif unit == "focus" then
		Natur_UpdateFocusCast()
	end
end)

-- Friendly cooldowns: infer from combat log when target/focus casts a spell with a known cooldown
local combatLogFrame = CreateFrame("Frame")
combatLogFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
combatLogFrame:SetScript("OnEvent", function()
	if Natur_Cooldowns_OnCombatLogEvent then
		Natur_Cooldowns_OnCombatLogEvent()
	end
	Natur_OnStealthCombatLogEvent()
	if Natur_KillingBlow_OnCombatLogEvent then
		Natur_KillingBlow_OnCombatLogEvent()
	end
	if Natur_Diminish_OnCombatLogEvent then
		Natur_Diminish_OnCombatLogEvent()
	end
	if Natur_CrowdControl_OnCombatLogEvent then
		Natur_CrowdControl_OnCombatLogEvent()
	end
end)
