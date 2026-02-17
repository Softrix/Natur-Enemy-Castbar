--[[ 

	Natur Enemy Castbar - Cooldowns
    All cooldown tracking and display logic.
 
	
]]--

local NT = _G.NaturTimers
if not NT then return end

local COMBATLOG_OBJECT_CONTROL_PLAYER = 0x00000100

local NaturCooldownState = _G.NaturCooldownState or {}
_G.NaturCooldownState = NaturCooldownState

--- Save current cooldowns to the options DB so they persist across reloads/login.
local function Natur_Cooldowns_SaveToDB()
	local db = _G.NaturOptionsDB
	if not db then return end

	local nowEpoch = time and time() or 0
	local now = GetTime()
	local out = {}

	for guid, spells in pairs(NaturCooldownState) do
		for spellId, data in pairs(spells) do
			if data.cooldown and data.endTime then
				local remaining = data.endTime - now
				if remaining and remaining > 0 then
					local endEpoch = nowEpoch + remaining
					out[guid] = out[guid] or {}
					out[guid][spellId] = {
						spellId = spellId,
						cooldown = data.cooldown,
						endEpoch = endEpoch,
						sourceName = data.sourceName,
						spellName = data.spellName,
					}
				end
			end
		end
	end

	db.cooldowns = next(out) and out or nil
end

--- Restore cooldowns from options DB into runtime state, pruning expired.
local function Natur_Cooldowns_RestoreFromDB()
	local db = _G.NaturOptionsDB
	if not db or not db.cooldowns then return end

	local nowEpoch = time and time() or 0
	local now = GetTime()

	for guid, spells in pairs(db.cooldowns) do
		for spellId, data in pairs(spells) do
			local endEpoch = data.endEpoch
			local cooldown = data.cooldown
			if endEpoch and cooldown and cooldown > 0 and endEpoch > nowEpoch then
				local remaining = endEpoch - nowEpoch
				if remaining > 0 and remaining <= cooldown then
					local startTime = now - (cooldown - remaining)
					local endTime = now + remaining
					local guidTable = NaturCooldownState[guid]
					if not guidTable then
						guidTable = {}
						NaturCooldownState[guid] = guidTable
					end
					guidTable[spellId] = {
						spellId = spellId,
						cooldown = cooldown,
						startTime = startTime,
						endTime = endTime,
						sourceName = data.sourceName,
						spellName = data.spellName,
					}
				end
			end
		end
	end
end

--- Record that a player with the given GUID has started a cooldown from BuffLookup.
local function Natur_Cooldowns_OnSpellCast(sourceGUID, sourceName, spellId, spellName)
	if not sourceGUID or sourceGUID == "" or not spellId or spellId == 0 then return end
	local NaturBuffDB = _G.NaturBuffDB
	if not NaturBuffDB then return end
	local entry = NaturBuffDB[spellId]
	if not entry or not entry.cooldown or entry.cooldown <= 0 then return end

	local now = GetTime()
	local cooldown = entry.cooldown
	local displayName = spellName
	if not displayName or displayName == "" then
		displayName = GetSpellInfo(spellId) or tostring(spellId)
	end

	local guidTable = NaturCooldownState[sourceGUID]
	if not guidTable then
		guidTable = {}
		NaturCooldownState[sourceGUID] = guidTable
	end

	guidTable[spellId] = {
		spellId = spellId,
		cooldown = cooldown,
		startTime = now,
		endTime = now + cooldown,
		sourceName = sourceName,
		spellName = displayName,
	}

	-- Debug: log when we detect a cooldown from the combat log.
	if Natur_DebugPrint then
		local name = sourceName and sourceName ~= "" and sourceName or "Unknown"
		Natur_DebugPrint(string.format("Cooldown detected: %s cast %s (spellId=%d, cd=%ds).", name, displayName, spellId, cooldown))
	end

	-- Persist updated cooldown state for reload/login.
	Natur_Cooldowns_SaveToDB()
end

--- Return a list of active cooldown records for the given GUID, pruning expired entries.
local function Natur_Cooldowns_GetActiveForGUID(guid)
	if not guid then return nil end
	local guidTable = NaturCooldownState[guid]
	if not guidTable then return nil end

	local now = GetTime()
	local result = {}

	for spellId, data in pairs(guidTable) do
		if data.endTime and data.endTime > now then
			result[#result + 1] = data
		else
			if Natur_DebugPrint then
				local name = (data and data.sourceName and data.sourceName ~= "") and data.sourceName or "Unknown"
				local spell = (data and data.spellName and data.spellName ~= "") and data.spellName or (GetSpellInfo and GetSpellInfo(spellId)) or tostring(spellId)
				Natur_DebugPrint(string.format("Cooldown removed (expired): [%s] - %s (spellId=%s, guid=%s).", name, spell, tostring(spellId), tostring(guid and guid:sub(-8) or "?")))
			end
			guidTable[spellId] = nil
		end
	end

	if not next(guidTable) then
		NaturCooldownState[guid] = nil
	end

	if #result == 0 then
		return nil
	end
	return result
end

--- Update cooldown bars for a given unit (target or focus) from NaturCooldownState.
local function Natur_UpdateUnitCooldownBars(unit, groupKey)
	local db = _G.NaturOptionsDB
	if not db then return end

	if not UnitExists(unit) then
		NT:StopAllTimers(groupKey)
		return
	end

	local guid = UnitGUID(unit)
	if not guid then
		NT:StopAllTimers(groupKey)
		return
	end

	local canAttack = UnitCanAttack("player", unit)
	local friendly = not canAttack
	local showFriendly = db.showFriendlyCooldowns
	local showHostile = db.showHostileCooldowns

	if (friendly and not showFriendly) or (not friendly and not showHostile) then
		NT:StopAllTimers(groupKey)
		return
	end

	local records = Natur_Cooldowns_GetActiveForGUID(guid)
	local activeKeys = {}

	if records then
		local now = GetTime()
		for _, data in ipairs(records) do
			local duration = data.cooldown
			local remaining = (data.endTime or 0) - now
			if duration and duration > 0 and remaining and remaining > 0 then
				local elapsed = duration - remaining
				if elapsed < 0 then elapsed = 0 end
				if elapsed > duration then elapsed = duration end

				local spellId = data.spellId
				local displayName = data.spellName or (spellId and (GetSpellInfo(spellId))) or tostring(spellId)
				local label = displayName
				if db.showPlayerNamesOnTimers ~= false and data.sourceName and data.sourceName ~= "" then
					label = displayName .. " (" .. data.sourceName .. ")"
				end

				local icon = select(3, GetSpellInfo(spellId))
				local opts = {
					label = label,
					reverse = true,
					iconLeft = icon,
					startElapsed = elapsed,
				}
				-- Use UnitReaction for icon so hostile gets htarget/hfocus even when UnitCanAttack is nil/delayed
				local reaction = UnitReaction("player", unit)
				local useHostileIcon = (reaction and reaction <= 4) or (canAttack == true)
				if unit == "target" then
					opts.iconRight = useHostileIcon and "Interface\\AddOns\\Natur\\assets\\graphics\\htarget.tga"
						or "Interface\\AddOns\\Natur\\assets\\graphics\\ftarget.tga"
				else
					opts.iconRight = useHostileIcon and "Interface\\AddOns\\Natur\\assets\\graphics\\hfocus.tga"
						or "Interface\\AddOns\\Natur\\assets\\graphics\\ffocus.tga"
				end

				local timerKey = "cd_" .. tostring(spellId)
				activeKeys[timerKey] = true
				NT:StartTimer(groupKey, timerKey, duration, opts)
			end
		end
	end
	-- Stop any cooldown timers on this group that are no longer active for this GUID.
	local group = NT:GetGroup(groupKey)
	if group and group.timers then
		for key in pairs(group.timers) do
			if string.match(key, "^cd_") and not activeKeys[key] then
				NT:StopTimer(groupKey, key)
			end
		end
	end
end

_G.Natur_UpdateUnitCooldownBars = Natur_UpdateUnitCooldownBars

--- Prune all expired cooldowns from NaturCooldownState (so they are deleted even if we never query that GUID again). 
--- Refreshes target/focus cooldown bars after pruning so expired bars disappear from the UI.
local function Natur_Cooldowns_PruneExpired()
	local now = GetTime()
	for guid, guidTable in pairs(NaturCooldownState) do
		for spellId, data in pairs(guidTable) do
			if not data.endTime or data.endTime <= now then
				if Natur_DebugPrint then
					local name = (data and data.sourceName and data.sourceName ~= "") and data.sourceName or "Unknown"
					local spell = (data and data.spellName and data.spellName ~= "") and data.spellName or (GetSpellInfo and GetSpellInfo(spellId)) or tostring(spellId)
					Natur_DebugPrint(string.format("Cooldown removed (expired): %s - %s (spellId=%s, guid=%s).", name, spell, tostring(spellId), tostring(guid and guid:sub(-8) or "?")))
				end
				guidTable[spellId] = nil
			end
		end
		if not next(guidTable) then
			NaturCooldownState[guid] = nil
		end
	end
	-- Refresh bars so expired cooldowns disappear from target/focus display.
	if UnitExists("target") then
		Natur_UpdateUnitCooldownBars("target", "TargetCooldowns")
	end
	if UnitExists("focus") then
		Natur_UpdateUnitCooldownBars("focus", "FocusCooldowns")
	end
end

--- Combat log: record cooldowns for any player source using BuffLookup.
local function Natur_OnCombatLogEvent()
	if not CombatLogGetCurrentEventInfo then return end
	local NaturBuffDB = _G.NaturBuffDB
	if not NaturBuffDB then return end

	local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
	      destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool = CombatLogGetCurrentEventInfo()
	if subevent ~= "SPELL_CAST_SUCCESS" then return end
	if not sourceGUID or sourceGUID == "" then return end
	if not spellId or spellId == 0 then return end

	-- Only track player-controlled units (ignore NPCs/bosses).
	if bit and bit.band and bit.band(sourceFlags or 0, COMBATLOG_OBJECT_CONTROL_PLAYER) == 0 then
		return
	end

	-- Only track spells with a configured cooldown.
	local entry = NaturBuffDB[spellId]
	if not entry or not entry.cooldown or entry.cooldown <= 0 then return end

	Natur_Cooldowns_OnSpellCast(sourceGUID, sourceName, spellId, spellName)

	-- If current target/focus matches this source, refresh their cooldown bars immediately.
	if UnitExists("target") and sourceGUID == UnitGUID("target") then
		if NT and NT.GetGroup then
			if _G.Natur_UpdateUnitCooldownBars then
				_G.Natur_UpdateUnitCooldownBars("target", "TargetCooldowns")
			end
		end
	end
	if UnitExists("focus") and sourceGUID == UnitGUID("focus") then
		if NT and NT.GetGroup then
			if _G.Natur_UpdateUnitCooldownBars then
				_G.Natur_UpdateUnitCooldownBars("focus", "FocusCooldowns")
			end
		end
	end
end

--- Clear target/focus cooldown timers (e.g. when option is turned off). Called from options.
local function Natur_ClearFriendlyCooldownTimers()
	if NT then
		NT:StopAllTimers("TargetCooldowns")
		NT:StopAllTimers("FocusCooldowns")
	end
end

_G.Natur_ClearFriendlyCooldownTimers = Natur_ClearFriendlyCooldownTimers

-- Public entry points for Natur.lua / events

function Natur_Cooldowns_OnAddonLoaded()
	-- Restore persisted cooldowns into runtime state.
	Natur_Cooldowns_RestoreFromDB()

	-- Refresh cooldown bars for current target/focus from restored state, if any.
	if UnitExists("target") then
		Natur_UpdateUnitCooldownBars("target", "TargetCooldowns")
	end
	if UnitExists("focus") then
		Natur_UpdateUnitCooldownBars("focus", "FocusCooldowns")
	end

	if C_Timer and C_Timer.NewTicker then
		C_Timer.NewTicker(5, Natur_Cooldowns_PruneExpired)
	end
end

function Natur_Cooldowns_OnTargetChanged()
	Natur_UpdateUnitCooldownBars("target", "TargetCooldowns")
end

function Natur_Cooldowns_OnFocusChanged()
	Natur_UpdateUnitCooldownBars("focus", "FocusCooldowns")
end

function Natur_Cooldowns_OnCombatLogEvent()
	Natur_OnCombatLogEvent()
end

