--[[

	Natur Enemy Castbar - Popups
	Batman-style "POW!" popup: graphic grows from small into view, holds, then shrinks back.

]]--

local ASSETS = "Interface\\AddOns\\Natur\\assets\\graphics\\"

-- Animation timing (seconds)
local PHASE_GROW   = 0.12   -- small -> full
local PHASE_HOLD   = 0.45   -- hold at full
local PHASE_SHAKE  = 1.0    -- shake at full size, then shrink
local PHASE_SHRINK = 0.18   -- full -> small
local SCALE_START  = 0.08   -- start/end scale (small)
local SCALE_PEAK   = 1.35   -- peak scale (slightly overshoot for punch)
local SHAKE_PIXELS = 5      -- max position jitter during shake
local baseYOffset  = 0      -- cache for UIParent:GetHeight()/6

local popupFrame
local popupTexture
local animStartTime
local animActive

local function Popup_OnUpdate(_, elapsed)
	if not animActive or not popupFrame or not popupFrame:IsShown() then return end
	local now = GetTime()
	local t = now - animStartTime

	if t < PHASE_GROW then
		-- Ease-out grow: small -> peak
		local u = t / PHASE_GROW
		u = u * u * (3 - 2 * u)  -- smoothstep
		popupFrame:SetScale(SCALE_START + (SCALE_PEAK - SCALE_START) * u)
		popupFrame:SetAlpha(u)
	elseif t < PHASE_GROW + PHASE_HOLD then
		popupFrame:SetScale(SCALE_PEAK)
		popupFrame:SetAlpha(1)
	elseif t < PHASE_GROW + PHASE_HOLD + PHASE_SHAKE then
		-- Shake at full size: jitter position each frame
		popupFrame:SetScale(SCALE_PEAK)
		popupFrame:SetAlpha(1)
		local jx = (math.random() - 0.5) * 2 * SHAKE_PIXELS
		local jy = (math.random() - 0.5) * 2 * SHAKE_PIXELS
		popupFrame:ClearAllPoints()
		popupFrame:SetPoint("CENTER", UIParent, "CENTER", jx, baseYOffset + jy)
	elseif t < PHASE_GROW + PHASE_HOLD + PHASE_SHAKE + PHASE_SHRINK then
		-- Ease-in shrink: peak -> small (reset position so no jitter)
		local shrinkStart = PHASE_GROW + PHASE_HOLD + PHASE_SHAKE
		if t - elapsed < shrinkStart then
			popupFrame:ClearAllPoints()
			popupFrame:SetPoint("CENTER", UIParent, "CENTER", 0, baseYOffset)
		end
		local u = (t - shrinkStart) / PHASE_SHRINK
		u = u * u * (3 - 2 * u)
		popupFrame:SetScale(SCALE_PEAK - (SCALE_PEAK - SCALE_START) * u)
		popupFrame:SetAlpha(1 - u)
	else
		popupFrame:SetScript("OnUpdate", nil)
		popupFrame:Hide()
		animActive = false
	end
end

local function GetPopupFrame()
	if popupFrame then return popupFrame end

	popupFrame = CreateFrame("Frame", "NaturPopupFrame", UIParent)
	popupFrame:SetFrameStrata("FULLSCREEN_DIALOG")
	popupFrame:SetFrameLevel(100)
	popupFrame:SetSize(256, 256)
	-- Center horizontally, about one-third down from top of screen
	baseYOffset = UIParent:GetHeight() / 6
	popupFrame:SetPoint("CENTER", UIParent, "CENTER", 0, baseYOffset)
	popupFrame:SetScale(SCALE_START)
	popupFrame:SetAlpha(0)
	popupFrame:Hide()

	popupTexture = popupFrame:CreateTexture(nil, "ARTWORK")
	popupTexture:SetAllPoints(popupFrame)
	popupTexture:SetTexCoord(0, 1, 0, 1)

	return popupFrame
end

--- Show a Batman-style "POW!" popup: graphic grows from small into view, holds, then shrinks back.
--- @param graphic string Filename (e.g. "immune", "interrupt") or full path. If no path separator, uses addon assets and appends .tga.
function Natur_ShowPopup(graphic)
	if not graphic or graphic == "" then return end
	local db = _G.NaturOptionsDB
	if db and db.graphicalPopups == false then return end

	local path = graphic
	if not path:find("\\") then
		path = path:gsub("%.tga$", ""):gsub("%.blp$", "")
		path = ASSETS .. path .. ".tga"
	end

	local frame = GetPopupFrame()
	popupTexture:SetTexture(path)
	frame:SetScale(SCALE_START)
	frame:SetAlpha(0)
	frame:Show()

	baseYOffset = UIParent:GetHeight() / 6
	animStartTime = GetTime()
	animActive = true
	frame:SetScript("OnUpdate", Popup_OnUpdate)
end

_G.Natur_ShowPopup = Natur_ShowPopup
