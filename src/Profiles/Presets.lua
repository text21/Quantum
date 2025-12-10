local Presets = {}

Presets.UI = {
	Soft = {
		stiffness = 16,
		damping = 3.2,
	},
	Snappy = {
		stiffness = 24,
		damping = 3.6,
	},
	Punchy = {
		stiffness = 32,
		damping = 2.8,
	},
	Tooltip = {
		stiffness = 14,
		damping = 3.4,
	},
	Elastic = {
		stiffness = 26,
		damping = 2.0,
	},
	Bouncy = {
		stiffness = 20,
		damping = 1.8,
	},
}

Presets.Camera = {
	FollowSoft = {
		stiffness = 10,
		damping = 2.4,
	},
	FollowSnappy = {
		stiffness = 16,
		damping = 3.0,
	},
	RecoilSmall = {
		stiffness = 24,
		damping = 3.8,
	},
	RecoilBig = {
		stiffness = 28,
		damping = 3.2,
	},
	ShakeShort = {
		stiffness = 30,
		damping = 4.0,
	},
}

Presets.Physics = {
	Bungee = {
		stiffness = 18,
		damping = 1.6,
	},
	Heavy = {
		stiffness = 30,
		damping = 5.0,
	},
	Floaty = {
		stiffness = 10,
		damping = 1.4,
	},
	RagdollLight = {
		stiffness = 14,
		damping = 2.4,
	},
	RagdollHeavy = {
		stiffness = 20,
		damping = 3.8,
	},
}

function Presets.Get(path)
	if not path or type(path) ~= "string" then
		return nil
	end

	local current = Presets
	for segment in string.gmatch(path, "[^%.]+") do
		current = current[segment]
		if current == nil then
			return nil
		end
	end

	return current
end

return Presets
