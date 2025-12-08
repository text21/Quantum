local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Signal = require(Packages.Signal)
local MathUtils = require(script.Parent.Parent.Util.MathUtils)
local SpringConfig = require(script.Parent.Parent.Util.SpringConfig)

local SpringMotor = {}
SpringMotor.__index = SpringMotor

export type SpringConfigType = {
	target: any?,
	stiffness: number?,
	damping: number?,
	mass: number?,
	tolerance: number?,
	profile: string?,
}

function SpringMotor.new(initialValue: any, config: SpringConfigType?)
	config = SpringConfig.apply(config or {})

	local pos = MathUtils.toVector(initialValue)
	local target = config.target ~= nil and MathUtils.toVector(config.target) or MathUtils.cloneVector(pos)
	local vel = MathUtils.zeroLike(pos)

	local self = setmetatable({}, SpringMotor)

	self._pos = pos
	self._vel = vel
	self._target = target
	self._template = initialValue

	self._stiffness = config.stiffness or 16
	self._damping = config.damping or 2
	self._mass = config.mass or 1
	self._tolerance = config.tolerance or 1e-4

	self._onStep = Signal.new()
	self._onComplete = Signal.new()

	self._dead = false
	self._completed = false

	return self
end

function SpringMotor:SetTarget(target: any)
	self._target = MathUtils.toVector(target)
	self._completed = false
end

function SpringMotor:SetConfig(config: SpringConfigType)
	config = SpringConfig.apply(config or {})
	if config.stiffness then
		self._stiffness = config.stiffness
	end
	if config.damping then
		self._damping = config.damping
	end
	if config.mass then
		self._mass = config.mass
	end
	if config.tolerance then
		self._tolerance = config.tolerance
	end
end

function SpringMotor:OnStep(fn: (any, { number }) -> ())
	return self._onStep:Connect(fn)
end

function SpringMotor:OnComplete(fn: () -> ())
	return self._onComplete:Connect(fn)
end

function SpringMotor:IsDead()
	return self._dead
end

function SpringMotor:Stop()
	self._dead = true
end

function SpringMotor:Destroy()
	self._dead = true
	self._onStep:Destroy()
	self._onComplete:Destroy()
end

function SpringMotor:Step(dt: number)
	if self._dead then
		return
	end

	if dt <= 0 then
		return
	end

	if dt > 0.1 then
		dt = 0.1
	end

	local pos = self._pos
	local vel = self._vel
	local target = self._target

	local k = self._stiffness
	local c = self._damping
	local m = self._mass

	local n = #pos
	for i = 1, n do
		local x = pos[i]
		local v = vel[i]
		local xT = target[i]

		local a = -((k / m) * (x - xT)) - ((c / m) * v)
		v = v + a * dt
		x = x + v * dt

		pos[i] = x
		vel[i] = v
	end

	local value = MathUtils.fromVector(pos, self._template)
	self._onStep:Fire(value, vel)

	local distSq = MathUtils.distanceSquared(pos, target)
	local velSq = MathUtils.lengthSquared(vel)
	local tolSq = self._tolerance * self._tolerance

	if distSq <= tolSq and velSq <= tolSq then
		if not self._completed then
			self._completed = true
			self._onComplete:Fire()
		end
	else
		self._completed = false
	end
end

return SpringMotor
