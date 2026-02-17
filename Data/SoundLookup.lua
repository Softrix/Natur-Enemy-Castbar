--[[

	Natur Sound Lookup Table for Classic Era, Hardcore, SoD, TBC Anniversary, WotLK Classic, and MoP Classic.
  
]]

if not _G.NaturSoundPaths then
  _G.NaturSoundPaths = {}
end
local paths = _G.NaturSoundPaths

local addon = "Interface\\AddOns\\Natur\\assets\\sounds"
local pvp = addon .. "\\pvp"

paths.stealth = pvp .. "\\other\\stealth.ogg"
paths.ccbreak = pvp .. "\\other\\ccbreak.ogg"
paths.failed = pvp .. "\\other\\failed.ogg"
paths.laugh = pvp .. "\\other\\laugh.ogg"
paths.applied = pvp .. "\\other\\applied.ogg"
paths.renewed = pvp .. "\\other\\renewed.ogg"

-- Killing blow voicepack sounds (play order: firstblood -> dominating -> monsterkill -> killingspree -> unstoppable -> godlike)
paths.killingBlowVoicepack1 = {
	pvp .. "\\voicepack1\\firstblood.ogg",
	pvp .. "\\voicepack1\\dominating.ogg",
	pvp .. "\\voicepack1\\monsterkill.ogg",
	pvp .. "\\voicepack1\\killingspree.ogg",
	pvp .. "\\voicepack1\\unstoppable.ogg",
	pvp .. "\\voicepack1\\godlike.ogg",
}
paths.killingBlowVoicepack2 = {
	pvp .. "\\voicepack2\\firstblood.ogg",
	pvp .. "\\voicepack2\\dominating.ogg",
	pvp .. "\\voicepack2\\monsterkill.ogg",
	pvp .. "\\voicepack2\\killingspree.ogg",
	pvp .. "\\voicepack2\\unstoppable.ogg",
	pvp .. "\\voicepack2\\godlike.ogg",
}
