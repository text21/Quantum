local Presets = {}

Presets.UI = {
	Snappy = {
		stiffness = 24,
		damping = 2.8,
	},
	Bouncy = {
		stiffness = 18,
		damping = 1.6,
	},
	Soft = {
		stiffness = 12,
		damping = 2.2,
	},
}

Presets.Physics = {
	Heavy = {
		stiffness = 10,
		damping = 2.4,
	},
	Loose = {
		stiffness = 6,
		damping = 1.8,
	},
}

return Presets
