local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SpringMotor = require(script.Parent.SpringMotor)
local ValueMotor = require(script.Parent.ValueMotor)
local Scheduler = require(script.Parent.Scheduler)
local PropertyBinder = require(script.Parent.PropertyBinder)

local Orbit = require(script.Parent.Parent.Relationships.Orbit)
local Chain = require(script.Parent.Parent.Relationships.Chain)
local Follow = require(script.Parent.Parent.Relationships.Follow)
local RagdollUI = require(script.Parent.Parent.Relationships.RagdollUI)

local Engine = {}
Engine.__index = Engine

type EngineOptions = {
	StepMode: string?,
	TimeScale: number?,
}

function Engine.new(options: EngineOptions?)
	options = options or {}
	local self = setmetatable({}, Engine)

	self._motors = {} :: { any }
	self._systems = {} :: { any }

	self._timeScale = options.TimeScale or 1
	local stepMode = options.StepMode or "Heartbeat"

	self._scheduler = Scheduler.new(function(dt)
		self:_step(dt)
	end, stepMode)
	self._scheduler:SetTimeScale(self._timeScale)
	self._scheduler:Start()

	return self
end

function Engine:_step(dt: number)
	if dt <= 0 then
		return
	end

	for i = #self._motors, 1, -1 do
		local motor = self._motors[i]
		if motor:IsDead() then
			table.remove(self._motors, i)
		else
			motor:Step(dt)
		end
	end

	for i = #self._systems, 1, -1 do
		local system = self._systems[i]
		if system._destroyed then
			table.remove(self._systems, i)
		else
			system:Step(dt)
		end
	end
end

function Engine:SetTimeScale(scale: number)
	self._timeScale = scale
	if self._scheduler then
		self._scheduler:SetTimeScale(scale)
	end
end

function Engine:Pause()
	if self._scheduler then
		self._scheduler:Stop()
	end
end

function Engine:Resume()
	if self._scheduler then
		self._scheduler:Start()
	end
end

function Engine:_addMotor(motor)
	table.insert(self._motors, motor)
	return motor
end

function Engine:Spring(instance: Instance, property: string, config)
	local binder = PropertyBinder.new(instance, property)
	local initial = binder:Get()
	local motor = SpringMotor.new(initial, config or {})
	motor:OnStep(function(value)
		binder:Set(value)
	end)
	self:_addMotor(motor)
	return motor
end

function Engine:ValueSpring(initialValue: any, config)
	local motor = ValueMotor.new(initialValue, config or {})
	self:_addMotor(motor)
	return motor
end

function Engine:_addSystem(system)
	table.insert(self._systems, system)
	return system
end

function Engine:Orbit(config)
	local system = Orbit.new(self, config or {})
	return self:_addSystem(system)
end

function Engine:Chain(config)
	local system = Chain.new(self, config or {})
	return self:_addSystem(system)
end

function Engine:Follow(config)
	local system = Follow.new(self, config or {})
	return self:_addSystem(system)
end

function Engine:RagdollUI(config)
	local system = RagdollUI.new(self, config or {})
	return self:_addSystem(system)
end

function Engine:Destroy()
	if self._scheduler then
		self._scheduler:Destroy()
		self._scheduler = nil
	end

	for _, motor in ipairs(self._motors) do
		motor:Destroy()
	end
	self._motors = {}

	for _, system in ipairs(self._systems) do
		system:Destroy()
	end
	self._systems = {}
end

return Engine
