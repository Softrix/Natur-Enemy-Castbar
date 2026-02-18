--[[
	Natur Enemy Castbar - Stealth Class Detection
	Detects hostile Rogue/Druid spell use (stealth abilities), triggers flash/sound/chat alerts.
]]--

local COMBATLOG_OBJECT_REACTION_HOSTILE = 0x40
local COMBATLOG_OBJECT_CONTROL_PLAYER = 0x00000100

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

--- Return the chat channel to use for stealth announce (nil when solo).
local function GetStealthAnnounceChannel()
	if not IsInGroup() and not UnitExists("party1") and not (GetNumGroupMembers and GetNumGroupMembers() >= 2) then return nil end
	return (LE_PARTY_CATEGORY_INSTANCE and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY"
end

--- List of detected hostile stealth players
local stealthDetectedList = {}

--- True if the current zone is a sanctuary (neutral city, no PvP); flash/sound/chat are suppressed there but debug still shows.
local function IsInNeutralCitySanctuary()
	local pvpType = GetZonePVPInfo and GetZonePVPInfo()
	return pvpType == "sanctuary"
end

--- Prune stealth detection list: remove entries older than 60s and show debug for each removed.
function Natur_PruneStealthDetectedList()
	local L = _G.Natur_L
	local throttleExpiredFmt = (L and L.STEALTH_THROTTLE_EXPIRED_DEBUG) or "Hostile stealth detection throttle expired for %s, can be detected again."
	local now = GetTime()
	local db = _G.NaturOptionsDB
	local throttle = (db and tonumber(db.stealthThrottleSeconds)) or 120
	for k, entry in pairs(stealthDetectedList) do
		if entry.addedTime and (now - entry.addedTime) >= throttle then
			local displayName = (entry.sourceName and entry.sourceName ~= "" and entry.sourceName) or tostring(k):sub(-8)
			if _G.Natur_DebugPrint then
				_G.Natur_DebugPrint(string.format(throttleExpiredFmt, displayName))
			end
			stealthDetectedList[k] = nil
		end
	end
end
_G.Natur_PruneStealthDetectedList = Natur_PruneStealthDetectedList

--- Called when a hostile rogue/druid stealth is detected; applies flash, sound, and/or chat per options.
local function Natur_OnHostileStealthDetected(sourceName, spellName, class, sourceGUID)
	local db = _G.NaturOptionsDB
	if not db or not db.detectStealthClasses then return end
	if db.stealthOnlyWhenPVPFlagged and not UnitIsPVP("player") then return end
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
	if _G.Natur_DebugPrint then
		_G.Natur_DebugPrint(addedMsg)
	end

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
			-- SendChatMessage rejects pipe escape codes; use same stripping as Natur_AnnounceCC
			local plainMsg = formatted:gsub("|c%x%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
			plainMsg = plainMsg:gsub("|TInterface\\TargetingFrame\\UI%-RaidTargetingIcon_(%d)[^|]*|t", "{rt%1}")
			plainMsg = plainMsg:gsub("|T[^|]*|t", "")
			plainMsg = plainMsg:gsub("|H[^|]*|h([^|]*)|h", "%1")
			plainMsg = plainMsg:gsub("|", "")
			SendChatMessage(plainMsg, channel, nil)
		elseif DEFAULT_CHAT_FRAME then
			DEFAULT_CHAT_FRAME:AddMessage(formatted)
		else
			print(formatted)
		end
	end
end

--- Detect any hostile Rogue or Druid spell and trigger stealth-class warning
function Natur_OnStealthCombatLogEvent()
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
	if bit.band(sourceFlags or 0, COMBATLOG_OBJECT_CONTROL_PLAYER) == 0 then return end

	local entry = spellId and buffDB[spellId]
	if not entry or not entry.class then return end
	if entry.class ~= "ROGUE" and entry.class ~= "DRUID" then return end

	Natur_OnHostileStealthDetected(sourceName, spellName, entry.class, sourceGUID)
end
_G.Natur_OnStealthCombatLogEvent = Natur_OnStealthCombatLogEvent

-- Start prune ticker when player has entered world
local stealthFrame = CreateFrame("Frame")
stealthFrame:RegisterEvent("PLAYER_LOGIN")
stealthFrame:SetScript("OnEvent", function()
	stealthFrame:UnregisterEvent("PLAYER_LOGIN")
	if C_Timer and C_Timer.NewTicker then
		C_Timer.NewTicker(10, function()
			Natur_PruneStealthDetectedList()
		end)
	end
end)
