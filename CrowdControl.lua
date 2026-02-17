--[[ 

	Natur Enemy Castbar - Crowd Control timers
     
]]--

local NT = _G.NaturTimers
if not NT then return end

local DR_WINDOW = 20
local DR_MAX_APPLICATIONS = 3
local ASSETS = "Interface\\AddOns\\Natur\\assets\\graphics\\"
local COMBATLOG_OBJECT_REACTION_HOSTILE = 0x40

-- Combat log raid target flags: destRaidFlags & MASK gives one of RAIDTARGET1-8; map to icon index 1-8
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

local RAID_ICON_TEXTURE = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_%d"
local NaturCCRaidMarks = _G.NaturCCRaidMarks or {}
_G.NaturCCRaidMarks = NaturCCRaidMarks

--- Return destDisplay with raid icon texture prefix when we have a stored mark for destGUID (from combat log or previous store).
local function AddRaidIconToDestDisplay(destGUID, destDisplay)
	if not destGUID or not destDisplay then return destDisplay end
	local idx = NaturCCRaidMarks[destGUID]
	if idx and idx >= 1 and idx <= 8 then
		return "|T" .. string.format(RAID_ICON_TEXTURE, idx) .. ":14:14:0:0|t " .. destDisplay
	end
	return destDisplay
end

local NaturDRStateCCOnMe = _G.NaturDRStateCCOnMe or {}
_G.NaturDRStateCCOnMe = NaturDRStateCCOnMe

--- Key -> true for friendly CC that the player applied (for break announcements).
local NaturCCMyKeys = {}

--- Resolve spellId from spellName when combat log returns 0 (Classic). Check crowdcontrol for CC; diminish for DR-on-me.
local function ResolveSpellIdFromName(spellName, needDiminish)
	if not spellName or spellName == "" then return nil end
	local NaturBuffDB = _G.NaturBuffDB
	if not NaturBuffDB then return nil end
	for spellId, entry in pairs(NaturBuffDB) do
		if entry then
			if needDiminish then
				if entry.diminish then
					local name = GetSpellInfo(spellId)
					if name and name == spellName then return spellId end
				end
			else
				if entry.crowdcontrol then
					local name = GetSpellInfo(spellId)
					if name and name == spellName then return spellId end
				end
			end
		end
	end
	return nil
end

local function GetFullDuration(spellId)
	local NaturBuffDB = _G.NaturBuffDB
	if not NaturBuffDB then return 10 end
	local entry = NaturBuffDB[spellId]
	if not entry or not entry.duration then return 10 end
	return entry.duration
end

local function GetNextCastDuration(applications, fullDuration)
	if applications >= DR_MAX_APPLICATIONS then return 0 end
	local div = 2 ^ applications
	return fullDuration / div
end

--- Build set of GUIDs for player + party/raid members. 
local function GetPartyRaidGUIDSet()
	local set = {}
	local myGUID = UnitGUID("player")
	if myGUID then set[myGUID] = true end
	if IsInRaid() then
		local n = GetNumGroupMembers and GetNumGroupMembers() or 0
		for i = 1, n do
			local g = UnitGUID("raid" .. i)
			if g then set[g] = true end
		end
	else
		for i = 1, 4 do
			local g = UnitGUID("party" .. i)
			if g then set[g] = true end
		end
	end
	return set
end

--- Refresh "CC on me" DR bars (prune expired, update labels).
local function RefreshCCOnMeDRBars()
	local db = _G.NaturOptionsDB
	if not db or not db.showHostileDR then return end
	local now = GetTime()
	local NaturBuffDB = _G.NaturBuffDB
	if not NaturBuffDB then return end

	for sourceGUID, guidTable in pairs(NaturDRStateCCOnMe) do
		for spellId, data in pairs(guidTable) do
			local windowEnd = data.windowEndTime
			if not windowEnd or windowEnd <= now then
				guidTable[spellId] = nil
				local key = "cc_me_dr_" .. sourceGUID .. "_" .. tostring(spellId)
				NT:StopTimer("CrowdControl", key)
			else
				local remaining = windowEnd - now
				if remaining > 0 and remaining <= DR_WINDOW then
					local elapsed = DR_WINDOW - remaining
					local applications = data.applications or 0
					local fullDuration = (Natur_GetPvPFullDuration and Natur_GetPvPFullDuration(spellId)) or GetFullDuration(spellId)
					local nextDur = GetNextCastDuration(applications, fullDuration)
					local spellName = GetSpellInfo(spellId) or tostring(spellId)
					local label
					if nextDur <= 0 then
						label = spellName .. " DR (Immune)"
					else
						label = string.format("%s DR (Next: %.1fs)", spellName, nextDur)
					end
					local icon = select(3, GetSpellInfo(spellId))
					local key = "cc_me_dr_" .. sourceGUID .. "_" .. tostring(spellId)
					NT:StartTimer("CrowdControl", key, DR_WINDOW, {
						label = label,
						reverse = true,
						iconLeft = icon,
						startElapsed = elapsed,
						iconRight = ASSETS .. "drhostile.tga",
					})
				end
			end
		end
		if not next(guidTable) then
			NaturDRStateCCOnMe[sourceGUID] = nil
		end
	end
end

--- Combat log: SPELL_AURA_APPLIED, SPELL_AURA_REFRESH (renew), and SPELL_AURA_REMOVED for CC timers and "CC on me" DR.
function Natur_CrowdControl_OnCombatLogEvent()
	if not CombatLogGetCurrentEventInfo then return end
	local db = _G.NaturOptionsDB
	if not db then return end
	if not db.showFriendlyCC and not db.showHostileCC and not db.showHostileDR then return end

	local NaturBuffDB = _G.NaturBuffDB
	if not NaturBuffDB then return end

	local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
	      destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool = CombatLogGetCurrentEventInfo()

	if subevent ~= "SPELL_AURA_APPLIED" and subevent ~= "SPELL_AURA_REFRESH" and subevent ~= "SPELL_AURA_REMOVED" then return end
	if not sourceGUID or sourceGUID == "" or not destGUID or destGUID == "" then return end

	-- Resolve spellId when Classic returns 0
	if not spellId or spellId == 0 then
		spellId = ResolveSpellIdFromName(spellName, false)
		if not spellId then
			spellId = ResolveSpellIdFromName(spellName, true)
		end
	end

	local playerGUID = UnitGUID("player")
	local isDestMe = (playerGUID and destGUID == playerGUID)

	if subevent == "SPELL_AURA_REMOVED" then
		if spellId and spellId ~= 0 then
			local keyF = "cc_f_" .. tostring(spellId) .. "_" .. destGUID
			local keyH = "cc_h_" .. tostring(spellId) .. "_" .. destGUID
			if NaturCCMyKeys[keyF] then
				if db.playSoundOnMyCCEvents then
					local paths = _G.NaturSoundPaths
					if paths and paths.ccbreak then
						PlaySoundFile(paths.ccbreak, "Master")
					end
				end
				local announce = _G.Natur_AnnounceCC
				if announce then
					local L = _G.Natur_L
					local fmt = (L and L.CC_BROKE_FREE) or "[%s] has broken free on %s!"
					local spellDisplay = GetSpellInfo(spellId) or spellName or "?"
					local destDisplay = (destName and destName ~= "" and destName) or "?"
					destDisplay = AddRaidIconToDestDisplay(destGUID, destDisplay)
					local msg = string.format(fmt, spellDisplay, destDisplay)
					-- Option on + in group -> party/raid/bg; option off or solo -> DEFAULT_CHAT_FRAME
					announce(msg, db.announceMyCCBreaks)
				end
				NaturCCMyKeys[keyF] = nil
			end
			NT:StopTimer("CrowdControl", keyF)
			NT:StopTimer("CrowdControl", keyH)
			if isDestMe then
				local keyDR = "cc_me_dr_" .. sourceGUID .. "_" .. tostring(spellId)
				NT:StopTimer("CrowdControl", keyDR)
			end
		end
		return
	end

	if not spellId or spellId == 0 then return end
	local entry = NaturBuffDB[spellId]
	if not entry then return end

	-- SPELL_AURA_APPLIED or SPELL_AURA_REFRESH
	if not entry.crowdcontrol then
		if isDestMe and entry.diminish and db.showHostileDR then
			-- Only care about diminish branch for "CC on me"
		else
			return
		end
	end

	-- Branch 1: CC on me
	if isDestMe then
		-- Do not start a CC duration timer
		if db.showHostileDR and entry.diminish then
			local now = GetTime()
			local guidTable = NaturDRStateCCOnMe[sourceGUID]
			if not guidTable then
				guidTable = {}
				NaturDRStateCCOnMe[sourceGUID] = guidTable
			end
			local data = guidTable[spellId]
			if not data then
				data = { applications = 0, windowEndTime = 0 }
				guidTable[spellId] = data
			end
			local windowExpired = (now >= data.windowEndTime)
			if windowExpired then
				data.applications = 0
			end
			data.applications = math.min(DR_MAX_APPLICATIONS, data.applications + 1)
			data.windowEndTime = now + DR_WINDOW
			-- Update bar (with caster name for label)
			local applications = data.applications
			local fullDuration = GetFullDuration(spellId)
			local nextDur = GetNextCastDuration(applications, fullDuration)
			local spellDisplay = GetSpellInfo(spellId) or tostring(spellId)
			local casterName = sourceName and sourceName ~= "" and sourceName or "?"
			local label
			if nextDur <= 0 then
				label = spellDisplay .. " DR (Immune) - " .. casterName
			else
				label = string.format("%s DR (Next: %.1fs) - %s", spellDisplay, nextDur, casterName)
			end
			local icon = select(3, GetSpellInfo(spellId))
			local key = "cc_me_dr_" .. sourceGUID .. "_" .. tostring(spellId)
			NT:StartTimer("CrowdControl", key, DR_WINDOW, {
				label = label,
				reverse = true,
				iconLeft = icon,
				startElapsed = 0,
				iconRight = ASSETS .. "drhostile.tga",
			})
		end
		return
	end

	-- Branch 2 & 3: Friendly or Hostile CC (dest is not player)
	if not entry.crowdcontrol then return end
	local partySet = GetPartyRaidGUIDSet()
	local sourceInParty = partySet[sourceGUID]
	local spellDisplay = GetSpellInfo(spellId) or tostring(spellId)
	local destDisplay = (destName and destName ~= "" and destName) or "?"
	-- Raid icon from combat log (works for any CC, including party members')
	if bit and destRaidFlags then
		local mobRaidIcon = RaidIconLookup[bit.band(destRaidFlags, COMBATLOG_OBJECT_RAIDTARGET_MASK)]
		if mobRaidIcon and mobRaidIcon >= 1 and mobRaidIcon <= 8 then
			NaturCCRaidMarks[destGUID] = mobRaidIcon
		end
	end
	destDisplay = AddRaidIconToDestDisplay(destGUID, destDisplay)
	local label = spellDisplay .. " (" .. destDisplay .. ")"
	-- Show right icon (target/focus marker) only when CC is on our current target or focus
	local targetGUID = UnitGUID("target")
	local focusGUID = UnitGUID("focus")
	local destIsMyTargetOrFocus = (destGUID == targetGUID or destGUID == focusGUID)
	local destHostile = (bit and bit.band(destFlags or 0, COMBATLOG_OBJECT_REACTION_HOSTILE) ~= 0)
	local destIcon = destHostile and "htarget.tga" or "ftarget.tga"

	-- Base duration: use DR-reduced when my CC + diminish + hostile target/focus; else raw or 10
	local duration = entry.duration and entry.duration > 0 and entry.duration or 10
	local NaturDRState = _G.NaturDRState
	local isMyCC = (sourceGUID == playerGUID)
	if isMyCC and entry.diminish and destIsMyTargetOrFocus and destHostile and NaturDRState and Natur_GetPvPFullDuration and Natur_GetDRAppliedDuration then
		local drData = NaturDRState[destGUID] and NaturDRState[destGUID][spellId]
		local applications = drData and drData.applications or 1
		if applications > DR_MAX_APPLICATIONS then
			-- Immune: do not start a CC duration bar (only DR bar is shown by Diminish)
			return
		end
		local fullDuration = Natur_GetPvPFullDuration(spellId)
		duration = Natur_GetDRAppliedDuration(applications, fullDuration)
		if duration <= 0 then
			return
		end
	end

	if db.showFriendlyCC and sourceInParty then
		local key = "cc_f_" .. tostring(spellId) .. "_" .. destGUID
		if isMyCC then
			if db.playSoundOnMyCCEvents then
				local paths = _G.NaturSoundPaths
				if subevent == "SPELL_AURA_APPLIED" and paths and paths.applied then
					PlaySoundFile(paths.applied, "Master")
				elseif subevent == "SPELL_AURA_REFRESH" and paths and paths.renewed then
					PlaySoundFile(paths.renewed, "Master")
				end
			end
			local announce = _G.Natur_AnnounceCC
			if announce then
				local L = _G.Natur_L
				if subevent == "SPELL_AURA_APPLIED" then
					local fmt = (L and L.CC_APPLIED) or "[%s] was applied to %s (for %s seconds)."
					local msg = string.format(fmt, spellDisplay, destDisplay, tostring(duration))
					-- Option on + in group -> party/raid/bg; option off or solo -> DEFAULT_CHAT_FRAME
					announce(msg, db.announceMyCCApply)
				elseif subevent == "SPELL_AURA_REFRESH" then
					local fmt = (L and L.CC_RENEWED) or "[%s] was renewed on %s (for %s seconds)."
					local msg = string.format(fmt, spellDisplay, destDisplay, tostring(duration))
					announce(msg, db.announceMyCCRenews)
				end
			end
			if subevent == "SPELL_AURA_APPLIED" then
				NaturCCMyKeys[key] = true
			end
		end
		local opts = {
			label = label,
			reverse = true,
			iconLeft = select(3, GetSpellInfo(spellId)),
			startElapsed = 0,
		}
		if destIsMyTargetOrFocus then
			opts.iconRight = ASSETS .. destIcon
		end
		NT:StartTimer("CrowdControl", key, duration, opts)
		return
	end

	if db.showHostileCC and not sourceInParty then
		local key = "cc_h_" .. tostring(spellId) .. "_" .. destGUID
		local opts = {
			label = label,
			reverse = true,
			iconLeft = select(3, GetSpellInfo(spellId)),
			startElapsed = 0,
		}
		if destIsMyTargetOrFocus then
			opts.iconRight = ASSETS .. destIcon
		end
		NT:StartTimer("CrowdControl", key, duration, opts)
	end
end

--- Call from Natur.lua on addon load to refresh "CC on me" DR bars (e.g. after options load).
function Natur_CrowdControl_OnAddonLoaded()
	RefreshCCOnMeDRBars()
end
