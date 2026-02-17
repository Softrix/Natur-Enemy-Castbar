--[[ Natur Enemy Castbar - Diminishing Returns
     Tracks when the player applies a diminish return spell from BuffLookup to hostile target/focus.
     Maintains per-dest per-spell state: 20s window, 1st/2nd/3rd/immune. Shows 20s countdown bar on TargetDR/FocusDR.
]]--

local NT = _G.NaturTimers
if not NT then return end

local DR_WINDOW = 20
local DR_MAX_APPLICATIONS = 3

local NaturDRState = _G.NaturDRState or {}
_G.NaturDRState = NaturDRState

local RAID_ICON_TEXTURE = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_%d"
local COMBATLOG_OBJECT_RAIDTARGET_MASK = _G.COMBATLOG_OBJECT_RAIDTARGET_MASK or 0xFF
local RaidIconLookup = {
	[_G.COMBATLOG_OBJECT_RAIDTARGET1 or 0x01] = 1,
	[_G.COMBATLOG_OBJECT_RAIDTARGET2 or 0x02] = 2,
	[_G.COMBATLOG_OBJECT_RAIDTARGET3 or 0x04] = 3,
	[_G.COMBATLOG_OBJECT_RAIDTARGET4 or 0x08] = 4,
	[_G.COMBATLOG_OBJECT_RAIDTARGET5 or 0x10] = 5,
	[_G.COMBATLOG_OBJECT_RAIDTARGET6 or 0x20] = 6,
	[_G.COMBATLOG_OBJECT_RAIDTARGET7 or 0x40] = 7,
	[_G.COMBATLOG_OBJECT_RAIDTARGET8 or 0x80] = 8,
}
local NaturCCRaidMarks = _G.NaturCCRaidMarks or {}
_G.NaturCCRaidMarks = NaturCCRaidMarks

--- Return destDisplay with raid icon prefix when we have a stored mark for destGUID.
local function AddRaidIconToDestDisplay(destGUID, destDisplay)
	if not destGUID or not destDisplay then return destDisplay end
	local idx = NaturCCRaidMarks[destGUID]
	if idx and idx >= 1 and idx <= 8 then
		return "|T" .. string.format(RAID_ICON_TEXTURE, idx) .. ":14:14:0:0|t " .. destDisplay
	end
	return destDisplay
end

--- Resolve spellId from spellName when combat log returns 0 (Classic). Returns spellId or nil.
local function ResolveSpellIdFromName(spellName)
	if not spellName or spellName == "" then return nil end
	local NaturBuffDB = _G.NaturBuffDB
	if not NaturBuffDB then return nil end
	for spellId, entry in pairs(NaturBuffDB) do
		if entry and entry.diminish then
			local name = GetSpellInfo(spellId)
			if name and name == spellName then return spellId end
		end
	end
	return nil
end

--- Get full duration for a spell from BuffLookup (used for "Next: Xs" label). PvP cap: 10s unless spell duration is below 10s then leave alone.
local function GetFullDuration(spellId)
	local NaturBuffDB = _G.NaturBuffDB
	if not NaturBuffDB then return 10 end
	local entry = NaturBuffDB[spellId]
	if not entry or not entry.duration or entry.duration <= 0 then return 10 end
	if entry.duration >= 10 then return 10 end
	return entry.duration
end

--- Compute "next cast" duration in seconds: full, half, quarter, or 0 (immune).
local function GetNextCastDuration(applications, fullDuration)
	if applications >= DR_MAX_APPLICATIONS then return 0 end
	local div = 2 ^ applications
	return fullDuration / div
end

--- Shared API: PvP full duration (cap 10s unless spell < 10s). Used by CrowdControl for CC bar duration.
function Natur_GetPvPFullDuration(spellId)
	return GetFullDuration(spellId)
end

--- Shared API: applied duration for current application count (full/2^(applications-1) for 1-3, 0 otherwise). Must match Diminish logic.
function Natur_GetDRAppliedDuration(applications, fullDuration)
	if not applications or applications < 1 or applications > DR_MAX_APPLICATIONS then return 0 end
	local div = 2 ^ (applications - 1)
	return fullDuration / div
end

--- Refresh DR bars for one unit (target or focus). Only shows when hostile and showHostileDR.
local function Natur_RefreshUnitDRBars(unit, groupKey)
	local db = _G.NaturOptionsDB
	if not db or not db.showHostileDR then
		NT:StopAllTimers(groupKey)
		return
	end

	if not UnitExists(unit) then
		NT:StopAllTimers(groupKey)
		return
	end

	-- DR only applies to players; don't show DR bars on NPCs
	if not UnitIsPlayer(unit) then
		NT:StopAllTimers(groupKey)
		local guid = UnitGUID(unit)
		if guid then NaturDRState[guid] = nil end
		return
	end

	local guid = UnitGUID(unit)
	if not guid then
		NT:StopAllTimers(groupKey)
		return
	end

	if not UnitCanAttack("player", unit) then
		NT:StopAllTimers(groupKey)
		return
	end

	local now = GetTime()
	local guidTable = NaturDRState[guid]
	local activeKeys = {}

	if guidTable then
		for spellId, data in pairs(guidTable) do
			local windowEnd = data.windowEndTime
			if not windowEnd or windowEnd <= now then
				guidTable[spellId] = nil
			else
				local remaining = windowEnd - now
				if remaining > 0 and remaining <= DR_WINDOW then
					local elapsed = DR_WINDOW - remaining
					local applications = data.applications or 0
					local fullDuration = GetFullDuration(spellId)
					local nextDur = GetNextCastDuration(applications, fullDuration)
					local spellName = GetSpellInfo(spellId) or tostring(spellId)
					local label
					if nextDur <= 0 then
						label = spellName .. " DR (Immune)"
					else
						label = string.format("%s DR (Next: %.1fs)", spellName, nextDur)
					end
					local icon = select(3, GetSpellInfo(spellId))
					local opts = {
						label = label,
						reverse = true,
						iconLeft = icon,
						startElapsed = elapsed,
					}
					opts.iconRight = "Interface\\AddOns\\Natur\\assets\\graphics\\drhostile.tga"
					local timerKey = "dr_" .. tostring(spellId)
					activeKeys[timerKey] = true
					NT:StartTimer(groupKey, timerKey, DR_WINDOW, opts)
				end
			end
		end
		if not next(guidTable) then
			NaturDRState[guid] = nil
		end
	end

	-- Stop timers for this group that are no longer active
	local group = NT:GetGroup(groupKey)
	if group and group.timers then
		for key in pairs(group.timers) do
			if string.match(key, "^dr_") and not activeKeys[key] then
				NT:StopTimer(groupKey, key)
			end
		end
	end
end

--- Refresh DR bars for both target and focus (and prune expired state).
function Natur_Diminish_RefreshBars()
	Natur_RefreshUnitDRBars("target", "TargetDR")
	Natur_RefreshUnitDRBars("focus", "FocusDR")
end

--- On combat log: detect player applying a diminish spell to hostile target/focus; update state and refresh bars.
local function Natur_OnDRCombatLogEvent()
	if not CombatLogGetCurrentEventInfo then return end
	local NaturBuffDB = _G.NaturBuffDB
	if not NaturBuffDB then return end

	local playerGUID = UnitGUID("player")
	if not playerGUID then return end

	local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
	      destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool = CombatLogGetCurrentEventInfo()

	if subevent ~= "SPELL_AURA_APPLIED" and subevent ~= "SPELL_AURA_REFRESH" and subevent ~= "SPELL_CAST_SUCCESS" then return end
	if not sourceGUID or sourceGUID == "" then return end
	if sourceGUID ~= playerGUID then return end
	if not destGUID or destGUID == "" then return end

	-- Resolve spellId if Classic returns 0
	if not spellId or spellId == 0 then
		spellId = ResolveSpellIdFromName(spellName)
		if not spellId then return end
	end

	local entry = NaturBuffDB[spellId]
	if not entry or not entry.diminish then return end

	-- Dest must be current hostile target or focus
	local targetGUID = UnitExists("target") and UnitGUID("target") or nil
	local focusGUID = UnitExists("focus") and UnitGUID("focus") or nil
	if destGUID ~= targetGUID and destGUID ~= focusGUID then return end

	local unit = (destGUID == targetGUID) and "target" or "focus"
	-- DR only applies to players; don't record or show DR for NPCs
	if not UnitIsPlayer(unit) then return end
	if not UnitCanAttack("player", unit) then return end

	local now = GetTime()
	local guidTable = NaturDRState[destGUID]
	if not guidTable then
		guidTable = {}
		NaturDRState[destGUID] = guidTable
	end

	local data = guidTable[spellId]
	if not data then
		data = { applications = 0, windowEndTime = 0 }
		guidTable[spellId] = data
	end

	if subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH" then
		local windowExpired = (now >= data.windowEndTime)
		if windowExpired then
			data.applications = 0
		end
		data.applications = math.min(DR_MAX_APPLICATIONS, data.applications + 1)
		data.windowEndTime = now + DR_WINDOW
		if Natur_DebugPrint then
			local displayName = spellName or GetSpellInfo(spellId) or tostring(spellId)
			local fullDuration = GetFullDuration(spellId)
			local nextDur = GetNextCastDuration(data.applications, fullDuration)
			local nextStr = nextDur > 0 and string.format("%.1fs", nextDur) or "Immune"
			local expiredStr = windowExpired and " (window had expired, reset to 1st application)" or ""
			Natur_DebugPrint(string.format("DR: %s (id=%s) on %s -> applications=%d, next cast duration=%s%s. 20s window started.", displayName, tostring(spellId), unit, data.applications, nextStr, expiredStr))
		end
	else
		local applications = data.applications or 0
		local windowStillActive = (data.windowEndTime and data.windowEndTime > now)
		if applications < DR_MAX_APPLICATIONS then
			data.windowEndTime = now + DR_WINDOW
		elseif windowStillActive then
			if bit and destRaidFlags then
				local mobRaidIcon = RaidIconLookup[bit.band(destRaidFlags, COMBATLOG_OBJECT_RAIDTARGET_MASK)]
				if mobRaidIcon and mobRaidIcon >= 1 and mobRaidIcon <= 8 then
					NaturCCRaidMarks[destGUID] = mobRaidIcon
				end
			end
			local db = _G.NaturOptionsDB
			if db then
				if db.playSoundOnMyCCEvents then
					local paths = _G.NaturSoundPaths
					if paths and paths.failed then
						PlaySoundFile(paths.failed, "Master")
					end
				end
				if _G.Natur_ShowPopup then _G.Natur_ShowPopup("immune") end		-- display popup for immune
				if db.announceMyCCImmune then
					local announce = _G.Natur_AnnounceCC
					if announce then
						local L = _G.Natur_L
						local fmt = (L and L.CC_IMMUNE) or "%s is IMMUNE to my [%s] and has %s seconds remaining on my DR timer."
						local destDisplay = (destName and destName ~= "" and destName) or "?"
						destDisplay = AddRaidIconToDestDisplay(destGUID, destDisplay)
						local spellDisplay = GetSpellInfo(spellId) or spellName or tostring(spellId)
						local remaining = math.max(0, math.floor(data.windowEndTime - now))
						local msg = string.format(fmt, destDisplay, spellDisplay, tostring(remaining))
						announce(msg, db.announceMyCCBreaks)
					end
				end
			end
		end
	end

	Natur_Diminish_RefreshBars()
end

-- Public entry points for Natur.lua / events

function Natur_Diminish_OnCombatLogEvent()
	Natur_OnDRCombatLogEvent()
end

function Natur_Diminish_OnTargetChanged()
	Natur_RefreshUnitDRBars("target", "TargetDR")
end

function Natur_Diminish_OnFocusChanged()
	Natur_RefreshUnitDRBars("focus", "FocusDR")
end

function Natur_Diminish_OnAddonLoaded()
	Natur_Diminish_RefreshBars()
end
