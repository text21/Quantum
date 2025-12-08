local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Trove = require(Packages.Trove)
local MathUtils = require(script.Parent.Parent.Util.MathUtils)

local Chain = {}
Chain.__index = Chain

local function defaultPropertyFor(instance: Instance)
	if instance:IsA("GuiObject") then
		return "Position"
	elseif instance:IsA("BasePart") then
		return "CFrame"
	end
	return "Position"
end

function Chain.new(engine, config)
	local self = setmetatable({}, Chain)

	self._engine = engine
	self._trove = Trove.new()
	self._destroyed = false

	self._nodes = config.nodes or {}
	self._property = config.property
	if (#self._nodes > 0) and not self._property then
		self._property = defaultPropertyFor(self._nodes[1])
	end

	self._stiffness = config.stiffness or 12
	self._damping = config.damping or 2
	self._tailDrag = config.tailDrag or 0

	self._offsets = {}
	self._motors = {}

	if #self._nodes >= 2 then
		local leader = self._nodes[1]
		local base = leader[self._property]

		for i, node in ipairs(self._nodes) do
			if i == 1 then
				self._offsets[i] = MathUtils.zeroVectorLike(base)
				self._motors[i] = nil
			else
				local value = node[self._property]
				self._offsets[i] = MathUtils.sub(value, base)

				local motor = engine:Spring(node, self._property, {
					target = value,
					stiffness = self._stiffness,
					damping = self._damping + (self._tailDrag * (i - 1)),
				})
				self._motors[i] = motor
			end
		end
	end

	return self
end

function Chain:SetNodes(nodes: { Instance })
	self._nodes = nodes
end

function Chain:Step(dt: number)
	if self._destroyed then
		return
	end

	if #self._nodes < 2 then
		return
	end

	local leader = self._nodes[1]
	local baseValue = leader[self._property]

	for i = 2, #self._nodes do
		local node = self._nodes[i]
		local motor = self._motors[i]
		local offset = self._offsets[i]

		if node and motor and offset then
			local target = MathUtils.add(baseValue, offset)
			motor:SetTarget(target)
		end
	end
end

function Chain:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	for _, motor in pairs(self._motors) do
		if motor then
			motor:Destroy()
		end
	end
	self._motors = {}
	self._trove:Destroy()
end

return Chain
