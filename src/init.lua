local Engine = require(script.Engine.Engine)
local Presets = require(script.Profiles.Presets)
local TweenServiceFactory = require(script.Compat.TweenService)

local Quantum = {}

local defaultEngine = Engine.new({
	StepMode = "Heartbeat",
	TimeScale = 1,
})

Quantum.default = defaultEngine
Quantum.Presets = Presets
Quantum.TweenService = TweenServiceFactory(defaultEngine)

function Quantum.new(options)
	return Engine.new(options or {})
end

function Quantum.Spring(instance, property, config)
	return defaultEngine:Spring(instance, property, config or {})
end

function Quantum.ValueSpring(initialValue, config)
	return defaultEngine:ValueSpring(initialValue, config or {})
end

Quantum.Relationship = {}

function Quantum.Relationship.Orbit(config)
	return defaultEngine:Orbit(config)
end

function Quantum.Relationship.Chain(config)
	return defaultEngine:Chain(config)
end

function Quantum.Relationship.Follow(config)
	return defaultEngine:Follow(config)
end

function Quantum.Relationship.RagdollUI(config)
	return defaultEngine:RagdollUI(config)
end

return Quantum
