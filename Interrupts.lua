--[[

  	Natur - Interrupt alerts
  	Warns when hostile target/focus is casting a healing spell (that you can interrupt).
  	Only alerts if the player has an interrupt spell learned. On successful interrupt, plays laugh.ogg.
	
]]

local INTERRUPT_SPELL_IDS = {
	-- Mage
	2139,   -- Counterspell (Vanilla/Retail)
	15122,  -- Counterspell (WotLK Classic)
	-- Rogue
	1766,   -- Kick
	-- Warrior
	6552,   -- Pummel
	72,     -- Shield Bash
	-- Shaman
	8042,   -- Earth Shock
	-- Druid (Cata+)
	93985,  -- Skull Bash (Cat/Bear)
	97547,  -- Solar Beam (eclipse, optional)
	-- Paladin (Cata+)
	96231,  -- Rebuke
	-- Monk (MoP+)
	116705, -- Spear Hand Strike
	-- Death Knight (WotLK+)
	47528,  -- Mind Freeze
	-- Demon Hunter (Legion+)
	183752, -- Consume Magic
	-- Warlock (pet)
	19647,  -- Spell Lock
	-- Hunter
	34490,  -- Silencing Shot (optional)
}

--- Path for laugh sound on successful interrupt (use NaturSoundPaths.laugh if set).
local function GetLaughSoundPath()
	local paths = _G.NaturSoundPaths
	if paths and paths.laugh then return paths.laugh end
	return "Interface\\AddOns\\Natur\\assets\\sounds\\pvp\\other\\laugh.ogg"
end

-- Cache of healing spell names (from NaturBuffDB), built on first use.
local healingSpellNamesCache = nil

local function BuildHealingSpellNames()
	local names = {}
	local db = _G.NaturBuffDB
	if not db then return names end
	for spellId, entry in pairs(db) do
		if entry and entry.healing then
			local name = GetSpellInfo(spellId)
			if name and name ~= "" then
				names[name] = true
			end
		end
	end
	return names
end

--- Return true if castName matches a known healing spell (from BuffLookup healing = true).
local function IsHealingSpell(castName)
	if not castName or castName == "" then return false end
	if not healingSpellNamesCache then
		healingSpellNamesCache = BuildHealingSpellNames()
	end
	return healingSpellNamesCache[castName] == true
end

--- Return true if the player has at least one interrupt spell learned in their spellbook.
local function HasInterruptLearned()
	if not IsSpellKnown then return false end
	for _, spellId in ipairs(INTERRUPT_SPELL_IDS) do
		if IsSpellKnown(spellId) then
			return true
		end
	end
	return false
end

--- Alert when unit (target or focus) starts casting a heal and we can interrupt.
local function OnCastStart(unit)
	local db = _G.NaturOptionsDB
	if not db or not db.healingWarnings then return end
	if not UnitExists(unit) then return end
	if not UnitCanAttack("player", unit) then return end -- must be hostile
	if not HasInterruptLearned() then return end

	local name = UnitCastingInfo(unit)
	if not name then
		name = UnitChannelInfo(unit)
	end
	if not name or name == "" then return end
	if not IsHealingSpell(name) then return end

	local unitLabel = (unit == "target") and "Target" or "Focus"
	local who = UnitName(unit) or unitLabel
	DEFAULT_CHAT_FRAME:AddMessage(unitLabel .. " " .. who .. " is casting " .. name .. " - interrupt!")
end

--- Combat log: SPELL_INTERRUPT with player as source -> play laugh only when the interrupted spell was a healing spell.
local function OnCombatLogEvent()
	local db = _G.NaturOptionsDB
	if not db or not db.healingWarnings then return end
	if not CombatLogGetCurrentEventInfo then return end
	local _, subevent, _, sourceGUID, _, _, _, _, _, _, _, _, _, _, extraSpellId, extraSpellName = CombatLogGetCurrentEventInfo()
	if subevent ~= "SPELL_INTERRUPT" then return end
	local playerGUID = UnitGUID("player")
	if not playerGUID or sourceGUID ~= playerGUID then return end
	-- Only play sound when the spell we interrupted was a healing spell
	if not IsHealingSpell(extraSpellName) then return end
	PlaySoundFile(GetLaughSoundPath(), "Master")
end

-- Frame for cast start/channel start on target and focus
local castFrame = CreateFrame("Frame")
castFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", "target", "focus")
castFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "target", "focus")
castFrame:SetScript("OnEvent", function(_, event, unit)
	if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
		OnCastStart(unit)
	end
end)

-- Frame for combat log (successful interrupt)
local combatFrame = CreateFrame("Frame")
combatFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
combatFrame:SetScript("OnEvent", OnCombatLogEvent)
