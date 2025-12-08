local SpringConfig = {}

SpringConfig.Presets = {
	Snappy = {
		stiffness = 24,
		damping = 2.8,
	},
	Bouncy = {
		stiffness = 16,
		damping = 1.6,
	},
	Heavy = {
		stiffness = 10,
		damping = 2.2,
	},
}

function SpringConfig.apply(config)
	local out = {}

	if config.profile and SpringConfig.Presets[config.profile] then
		for k, v in pairs(SpringConfig.Presets[config.profile]) do
			out[k] = v
		end
	end

	for k, v in pairs(config) do
		out[k] = v
	end

	return out
end

return SpringConfig
