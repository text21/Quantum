local Sequence = {}
Sequence.__index = Sequence

local QuantumAPI = nil

function Sequence._setQuantumAPI(q)
	QuantumAPI = q
end

function Sequence.new(name)
	local self = setmetatable({}, Sequence)
	self._name = name or "Sequence"
	self._steps = {}
	return self
end

local function addStep(self, step)
	table.insert(self._steps, step)
	return self
end

function Sequence:Spring(instance, property, opts)
	opts = opts or {}
	addStep(self, {
		type = "spring",
		instance = instance,
		property = property,
		opts = opts,
	})
	return self
end

function Sequence:Wait(seconds)
	addStep(self, {
		type = "wait",
		duration = seconds or 0,
	})
	return self
end

function Sequence:Call(callback)
	if callback then
		addStep(self, {
			type = "call",
			cb = callback,
		})
	end
	return self
end

function Sequence:_run(cancelToken)
	if not QuantumAPI then
		warn("[Quantum.Sequence] QuantumAPI not set; did you forget _setQuantumAPI?")
		return
	end

	cancelToken = cancelToken or { cancelled = false }

	for _, step in ipairs(self._steps) do
		if cancelToken.cancelled then
			break
		end

		local stepType = step.type

		if stepType == "spring" then
			local instance = step.instance
			local property = step.property
			local opts = step.opts or {}

			if not instance or instance.Parent == nil or not property then
				continue
			end

			local target = opts.target
			if target == nil then
				continue
			end

			local startValue = opts.from
			if startValue == nil then
				local ok, current = pcall(function()
					return instance[property]
				end)
				if not ok then
					continue
				end
				startValue = current
			end

			local stiffness = opts.stiffness
			local damping = opts.damping

			if opts.profile and QuantumAPI.Presets and QuantumAPI.Presets.Get then
				local preset = QuantumAPI.Presets.Get(opts.profile)
				if preset then
					stiffness = stiffness or preset.stiffness
					damping = damping or preset.damping
				end
			end

			stiffness = stiffness or 20
			damping = damping or 3

			local done = false

			local motor = QuantumAPI.ValueSpring(startValue, {
				stiffness = stiffness,
				damping = damping,
				onStep = function(v)
					if cancelToken.cancelled then
						return
					end
					if instance and instance.Parent then
						local ok = pcall(function()
							instance[property] = v
						end)
						if not ok then
							cancelToken.cancelled = true
						end
					end
				end,
			})

			if motor.OnComplete then
				motor:OnComplete(function()
					done = true
				end)
			else
				task.spawn(function()
					task.wait(0.5)
					done = true
				end)
			end

			motor:SetTarget(target)

			while not done and not cancelToken.cancelled do
				task.wait()
			end

			if motor.Stop then
				motor:Stop()
			end

		elseif stepType == "wait" then
			local duration = step.duration or 0
			local elapsed = 0
			while elapsed < duration and not cancelToken.cancelled do
				local dt = task.wait()
				elapsed += dt
			end

		elseif stepType == "call" then
			if step.cb and not cancelToken.cancelled then
				local ok, err = pcall(step.cb)
				if not ok then
					warn("[Quantum.Sequence] Call step error:", err)
				end
			end
		end
	end
end

return Sequence