--[[ 

	Natur Enemy Castbar - Gains
    All target/focus gains.
    
]]--

local NT = _G.NaturTimers
if not NT then return end

--- Bind Target Gains to target's buffs when target is friendly and Show Friendly Gains is true,
--- or hostile and Show Hostile Gains is true; otherwise unbind.
function Natur_UpdateTargetGainsBinding()
	local db = _G.NaturOptionsDB
	if not db then return end
	local showFriendly = db.showFriendlyGains
	local showHostile = db.showHostileGains
	if not UnitExists("target") then
		NT:UnbindGroupFromUnitAuras("TargetGains")
		return
	end
	local canAttack = UnitCanAttack("player", "target")
	local friendly = not canAttack
	local shouldBind = (friendly and showFriendly) or (not friendly and showHostile)
	if shouldBind then
		-- Use UnitReaction for icon so hostile targets get htarget even when UnitCanAttack is nil/delayed
		local reaction = UnitReaction("player", "target")
		local useHostileIcon = (reaction and reaction <= 4) or (canAttack == true)
		local opts = { maxBars = 20, showPlayerNames = (db.showPlayerNamesOnTimers ~= false) }
		opts.iconRight = useHostileIcon and "Interface\\AddOns\\Natur\\assets\\graphics\\htarget.tga"
			or "Interface\\AddOns\\Natur\\assets\\graphics\\ftarget.tga"
		NT:BindGroupToUnitAuras("TargetGains", "target", "HELPFUL", opts)
	else
		NT:UnbindGroupFromUnitAuras("TargetGains")
	end
end

--- Bind Focus Gains to focus's buffs when focus is friendly and Show Friendly Gains is true,
--- or hostile and Show Hostile Gains is true; otherwise unbind.
function Natur_UpdateFocusGainsBinding()
	local db = _G.NaturOptionsDB
	if not db then return end
	local showFriendly = db.showFriendlyGains
	local showHostile = db.showHostileGains
	if not UnitExists("focus") then
		NT:UnbindGroupFromUnitAuras("FocusGains")
		return
	end
	local canAttack = UnitCanAttack("player", "focus")
	local friendly = not canAttack
	local shouldBind = (friendly and showFriendly) or (not friendly and showHostile)
	if shouldBind then
		-- Use UnitReaction for icon so hostile focus gets hfocus even when UnitCanAttack is nil/delayed
		local reaction = UnitReaction("player", "focus")
		local useHostileIcon = (reaction and reaction <= 4) or (canAttack == true)
		local opts = { maxBars = 20, showPlayerNames = (db.showPlayerNamesOnTimers ~= false) }
		opts.iconRight = useHostileIcon and "Interface\\AddOns\\Natur\\assets\\graphics\\hfocus.tga"
			or "Interface\\AddOns\\Natur\\assets\\graphics\\ffocus.tga"
		NT:BindGroupToUnitAuras("FocusGains", "focus", "HELPFUL", opts)
	else
		NT:UnbindGroupFromUnitAuras("FocusGains")
	end
end

-- Public entry points for Natur.lua / events

function Natur_Gains_OnAddonLoaded()
	-- Ensure bindings reflect current target/focus and options.
	Natur_UpdateTargetGainsBinding()
	Natur_UpdateFocusGainsBinding()
end

function Natur_Gains_OnTargetChanged()
	Natur_UpdateTargetGainsBinding()
end

function Natur_Gains_OnFocusChanged()
	Natur_UpdateFocusGainsBinding()
end

