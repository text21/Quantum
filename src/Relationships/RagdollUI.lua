local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Trove = require(Packages.Trove)

local RagdollUI = {}
RagdollUI.__index = RagdollUI

type NodeConfig = {
	object: GuiObject,
	mass: number?,
}

local function vec2(x, y)
	return Vector2.new(x, y)
end

function RagdollUI.new(_, config)
	local self = setmetatable({}, RagdollUI)

	self._trove = Trove.new()
	self._destroyed = false

	self._nodes = {}
	self._nodeByObject = {}

	self._gravity = config.gravity or vec2(0, 1200)
	self._stiffness = config.stiffness or 12
	self._damping = config.damping or 3
	self._bounce = config.bounce or 0.3
	self._bounds = config.bounds

	for _, nodeConfig: NodeConfig in ipairs(config.nodes or {}) do
		local gui = nodeConfig.object
		local mass = nodeConfig.mass or 1

		local restPos = gui.AbsolutePosition
		local state = {
			object = gui,
			mass = mass,
			restPos = vec2(restPos.X, restPos.Y),
			pos = vec2(restPos.X, restPos.Y),
			vel = vec2(0, 0),
		}

		table.insert(self._nodes, state)
		self._nodeByObject[gui] = state
	end

	return self
end

function RagdollUI:_applyBounds(node)
	if not self._bounds then
		return
	end

	local bounds = self._bounds :: GuiObject
	local bPos = bounds.AbsolutePosition
	local bSize = bounds.AbsoluteSize

	local pos = node.pos
	local vel = node.vel

	local minX = bPos.X
	local minY = bPos.Y
	local maxX = bPos.X + bSize.X
	local maxY = bPos.Y + bSize.Y

	if pos.X < minX then
		pos = vec2(minX, pos.Y)
		vel = vec2(-vel.X * self._bounce, vel.Y)
	elseif pos.X > maxX then
		pos = vec2(maxX, pos.Y)
		vel = vec2(-vel.X * self._bounce, vel.Y)
	end

	if pos.Y < minY then
		pos = vec2(pos.X, minY)
		vel = vec2(vel.X, -vel.Y * self._bounce)
	elseif pos.Y > maxY then
		pos = vec2(pos.X, maxY)
		vel = vec2(vel.X, -vel.Y * self._bounce)
	end

	node.pos = pos
	node.vel = vel
end

function RagdollUI:Impulse(object: GuiObject?, impulse: Vector2)
	if self._destroyed then
		return
	end

	if object == nil then
		for _, node in ipairs(self._nodes) do
			node.vel += impulse / node.mass
		end
	else
		local node = self._nodeByObject[object]
		if node then
			node.vel += impulse / node.mass
		end
	end
end

function RagdollUI:Step(dt: number)
	if self._destroyed then
		return
	end

	if dt <= 0 then
		return
	end

	for _, node in ipairs(self._nodes) do
		local mass = node.mass
		local pos = node.pos
		local vel = node.vel
		local restPos = node.restPos

		local offset = pos - restPos
		local springForce = -self._stiffness * offset
		local dampingForce = -self._damping * vel
		local gravityForce = self._gravity * mass

		local force = springForce + dampingForce + gravityForce
		local acc = force / mass

		vel = vel + acc * dt
		pos = pos + vel * dt

		node.pos = pos
		node.vel = vel

		self:_applyBounds(node)

		local gui = node.object
		local parent = gui.Parent
		if parent and parent:IsA("GuiObject") then
			local root = parent :: GuiObject
			local rootPos = root.AbsolutePosition
			local localPos = node.pos - vec2(rootPos.X, rootPos.Y)
			gui.Position = UDim2.fromOffset(localPos.X, localPos.Y)
		else
			gui.Position = UDim2.fromOffset(node.pos.X, node.pos.Y)
		end
	end
end

function RagdollUI:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	self._nodes = {}
	self._nodeByObject = {}
	self._trove:Destroy()
end

return RagdollUI