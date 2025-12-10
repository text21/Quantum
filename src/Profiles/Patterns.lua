
local Sequence = require(script.Parent.Parent.Engine.Sequence)

local Patterns = {}

local function scaleValue(base, factor)
	local t = typeof(base)

	if t == "number" then
		return base * factor
	elseif t == "Vector2" or t == "Vector3" then
		return base * factor
	elseif t == "UDim2" then
		return UDim2.new(
			base.X.Scale * factor,
			base.X.Offset * factor,
			base.Y.Scale * factor,
			base.Y.Offset * factor
		)
	else
		return base
	end
end

local function popSequence(target, opts)
	opts = opts or {}

	local prop = opts.property or "Size"
	local base = opts.base or target[prop]

	local popUp = opts.popUp
	local settle = opts.settle or base

	if not popUp then
		popUp = scaleValue(base, 1.1)
	end

	local profileUp = opts.profileUp or "UI.Punchy"
	local profileDown = opts.profileDown or "UI.Soft"
	local holdTime = opts.holdTime or 0.04

	local seq = Sequence.new("Pop")

	return seq
		:Spring(target, prop, {
			from = base,
			target = popUp,
			profile = profileUp,
		})
		:Wait(holdTime)
		:Spring(target, prop, {
			from = popUp,
			target = settle,
			profile = profileDown,
		})
end

---------------------------------------------------------------------
-- UI: RewardPop
---------------------------------------------------------------------
function Patterns.RewardPop(target, opts)
	opts = opts or {}
	local prop = opts.property or "Size"

	local seq = popSequence(target, {
		property = prop,
		base = opts.base or target[prop],
		popUp = opts.popUp,
		settle = opts.settle,
		profileUp = "UI.Punchy",
		profileDown = "UI.Soft",
		holdTime = 0.05,
	})

	if opts.afterDelay and opts.afterDelay > 0 then
		seq:Wait(opts.afterDelay)
	end

	return seq
end

---------------------------------------------------------------------
-- UI: AttentionPulse
---------------------------------------------------------------------
function Patterns.AttentionPulse(target, opts)
	opts = opts or {}

	local prop = opts.property or "Size"
	local base = opts.base or target[prop]

	local pulseUp = opts.pulseUp or scaleValue(base, 1.06)
	local pulseDown = base
	local profile = opts.profile or "UI.Soft"

	local seq = Sequence.new("AttentionPulse")
		:Spring(target, prop, {
			from = pulseDown,
			target = pulseUp,
			profile = profile,
		})
		:Wait(0.06)
		:Spring(target, prop, {
			from = pulseUp,
			target = pulseDown,
			profile = profile,
		})

	return seq
end

---------------------------------------------------------------------
-- UI: ErrorShake (horizontal shake)
---------------------------------------------------------------------
function Patterns.ErrorShake(target, opts)
	opts = opts or {}

	local prop = "Position"
	local base = opts.base or target.Position
	local offset = opts.offset or UDim2.new(0.02, 0, 0, 0)

	local left = UDim2.new(
		base.X.Scale - offset.X.Scale,
		base.X.Offset - offset.X.Offset,
		base.Y.Scale,
		base.Y.Offset
	)

	local right = UDim2.new(
		base.X.Scale + offset.X.Scale,
		base.X.Offset + offset.X.Offset,
		base.Y.Scale,
		base.Y.Offset
	)

	local profile = opts.profile or "UI.Bouncy"

	local seq = Sequence.new("ErrorShake")
		:Spring(target, prop, {
			from = base,
			target = left,
			profile = profile,
		})
		:Wait(0.02)
		:Spring(target, prop, {
			from = left,
			target = right,
			profile = profile,
		})
		:Wait(0.02)
		:Spring(target, prop, {
			from = right,
			target = base,
			profile = profile,
		})

	return seq
end

---------------------------------------------------------------------
-- Camera: RecoilKick
---------------------------------------------------------------------
function Patterns.RecoilKick(camera, opts)
	opts = opts or {}

	local base = camera.CFrame
	local up = opts.upAngle or 3
	local backDist = opts.backDist or 0.3

	local kickCF = base
		* CFrame.new(0, 0, -backDist)
		* CFrame.Angles(math.rad(-up), 0, 0)

	local seq = Sequence.new("RecoilKick")
		:Spring(camera, "CFrame", {
			from = base,
			target = kickCF,
			profile = "Camera.RecoilBig",
		})
		:Spring(camera, "CFrame", {
			from = kickCF,
			target = base,
			profile = "Camera.FollowSnappy",
		})

	return seq
end

---------------------------------------------------------------------
-- Physics-ish: ImpactSquash
---------------------------------------------------------------------
function Patterns.ImpactSquash(target, opts)
	opts = opts or {}

	local prop = opts.property or "Size"
	local base = opts.base or target[prop]

	local squash
	local overshoot

	if typeof(base) == "UDim2" then
		squash = UDim2.new(
			base.X.Scale * 1.08,
			base.X.Offset,
			base.Y.Scale * 0.9,
			base.Y.Offset
		)
		overshoot = UDim2.new(
			base.X.Scale * 0.98,
			base.X.Offset,
			base.Y.Scale * 1.04,
			base.Y.Offset
		)
	else
		squash = scaleValue(base, 1.08)
		overshoot = scaleValue(base, 0.98)
	end

	local seq = Sequence.new("ImpactSquash")
		:Spring(target, prop, {
			from = base,
			target = squash,
			profile = "UI.Elastic",
		})
		:Wait(0.03)
		:Spring(target, prop, {
			from = squash,
			target = overshoot,
			profile = "UI.Bouncy",
		})
		:Spring(target, prop, {
			from = overshoot,
			target = base,
			profile = "UI.Soft",
		})

	return seq
end

return Patterns