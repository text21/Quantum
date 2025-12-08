local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Trove = require(Packages.Trove)

local UserInputService = game:GetService("UserInputService")

local Follow = {}
Follow.__index = Follow

local function defaultPropertyFor(instance: Instance)
	if instance:IsA("GuiObject") then
		return "Position"
	elseif instance:IsA("BasePart") then
		return "CFrame"
	end
	return "Position"
end

local function isGui(instance: Instance)
	return instance:IsA("GuiObject")
end

local function isPart(instance: Instance)
	return instance:IsA("BasePart")
end

function Follow.new(engine, config)
	local self = setmetatable({}, Follow)

	self._engine = engine
	self._trove = Trove.new()
	self._destroyed = false

	self._effector = config.effector
	self._targetSpec = config.target
	self._stiffness = config.stiffness or 18
	self._damping = config.damping or 2.2
	self._maxDistance = config.maxDistance

	self._property = config.property or defaultPropertyFor(self._effector)
	self._isGui = isGui(self._effector)

	local initial = self._effector[self._property]

	self._motor = engine:Spring(self._effector, self._property, {
		target = initial,
		stiffness = self._stiffness,
		damping = self._damping,
	})

	return self
end

function Follow:SetTarget(target)
	self._targetSpec = target
end

function Follow:_resolveTarget()
	local spec = self._targetSpec

	if typeof(spec) == "Instance" then
		if isGui(spec) then
			return spec.Position
		elseif isPart(spec) then
			return spec.CFrame
		end
	elseif typeof(spec) == "function" then
		return spec()
	elseif spec == "Mouse" then
		if self._isGui then
			local effector = self._effector :: GuiObject
			local parent = effector.Parent
			local mouse = UserInputService:GetMouseLocation()

			if parent and parent:IsA("GuiObject") then
				local root = parent :: GuiObject
				local rootPos = root.AbsolutePosition
				local x = mouse.X - rootPos.X
				local y = mouse.Y - rootPos.Y
				return UDim2.fromOffset(x, y)
			else
				return UDim2.fromOffset(mouse.X, mouse.Y)
			end
		end
	end

	return nil
end

function Follow:Step(dt: number)
	if self._destroyed then
		return
	end

	local target = self:_resolveTarget()
	if target ~= nil then
		self._motor:SetTarget(target)
	end
end

function Follow:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	if self._motor then
		self._motor:Destroy()
		self._motor = nil
	end
	self._trove:Destroy()
end

return Follow
